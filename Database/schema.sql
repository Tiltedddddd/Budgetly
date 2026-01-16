/* ===========================================================
   BudgetlyDB Schema (GO-safe, matches your current seed.sql)
   - Pets: Pets + PetStatusImages (Happy/Normal/Sad/Excited)
   - UserPets: PetStatus enum matches seed
   - Transactions: table exists (seed may insert later; ok)
   =========================================================== */

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ===========================================================
   1) TABLES
   =========================================================== */

----------------------------------------------------
-- USERS
----------------------------------------------------
CREATE TABLE dbo.Users (
    UserID INT IDENTITY PRIMARY KEY,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ResetDay INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT CK_Users_ResetDay CHECK (ResetDay BETWEEN 1 AND 28)
);
GO

----------------------------------------------------
-- USER PROFILES (1-to-1 with Users)
----------------------------------------------------
CREATE TABLE dbo.UserProfiles (
    ProfileID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    DisplayName VARCHAR(100) NULL,
    ProfileImagePath VARCHAR(255) NULL,
    ThemePreference VARCHAR(50) NULL,
    NotificationEnabled BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_UserProfiles_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
);
GO

----------------------------------------------------
-- SUBSCRIPTIONS
----------------------------------------------------
CREATE TABLE dbo.Subscriptions (
    SubscriptionID INT IDENTITY PRIMARY KEY,
    SubscriptionName VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NULL,
    CONSTRAINT UQ_Subscriptions_Name UNIQUE (SubscriptionName)
);
GO

----------------------------------------------------
-- USER SUBSCRIPTIONS
----------------------------------------------------
CREATE TABLE dbo.UserSubscriptions (
    UserSubscriptionID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    SubscriptionID INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    StartDate DATETIME2 NOT NULL,
    EndDate DATETIME2 NULL,
    CONSTRAINT CK_UserSubscriptions_DateRange CHECK (EndDate IS NULL OR EndDate >= StartDate),
    CONSTRAINT FK_UserSubscriptions_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_UserSubscriptions_Subscriptions FOREIGN KEY (SubscriptionID) REFERENCES dbo.Subscriptions(SubscriptionID),
    CONSTRAINT UQ_UserSubscriptions UNIQUE (UserID, SubscriptionID)
);
GO

----------------------------------------------------
-- ACCOUNTS / WALLETS
----------------------------------------------------
CREATE TABLE dbo.Accounts (
    AccountID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    AccountName VARCHAR(50) NOT NULL,
    AccountType VARCHAR(20) NOT NULL,
    Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsGmailSyncEnabled BIT NOT NULL DEFAULT 0,
    LastSyncDate DATETIME2 NULL,
    IsDefault BIT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Accounts_Type CHECK (AccountType IN ('Savings','Credit','Cash','Digital')),
    CONSTRAINT FK_Accounts_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
);
GO

----------------------------------------------------
-- ACCOUNT IMAGES
----------------------------------------------------
CREATE TABLE dbo.AccountImages (
    ImageID INT IDENTITY PRIMARY KEY,
    AccountID INT NOT NULL,
    ImagePath VARCHAR(255) NOT NULL,
    UploadedOn DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_AccountImages_Accounts FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID)
);
GO

----------------------------------------------------
-- CATEGORIES
----------------------------------------------------
CREATE TABLE dbo.Categories (
    CategoryID INT IDENTITY PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE,
    EcoWeight DECIMAL(3,2) NOT NULL,
    IsEssential BIT NOT NULL,
    IconPath VARCHAR(255) NULL,
    CONSTRAINT CK_Categories_EcoWeight CHECK (EcoWeight BETWEEN 0 AND 1)
);
GO

----------------------------------------------------
-- TRANSACTIONS (NO UserID)
----------------------------------------------------
CREATE TABLE dbo.Transactions (
    TransactionID INT IDENTITY PRIMARY KEY,
    AccountID INT NOT NULL,
    CategoryID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransactionType VARCHAR(10) NOT NULL,
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Merchant VARCHAR(100) NULL,
    Description VARCHAR(255) NULL,
    Source VARCHAR(20) NOT NULL,

    CONSTRAINT CK_Transactions_Amount_Positive CHECK (Amount > 0),
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT CK_Transactions_Type CHECK (TransactionType IN ('INCOME','EXPENSE')),
    CONSTRAINT CK_Transactions_Source CHECK (Source IN ('MANUAL','GMAIL','IMPORT'))
);
GO

----------------------------------------------------
-- TRANSACTION ATTACHMENTS
----------------------------------------------------
CREATE TABLE dbo.TransactionAttachments (
    AttachmentID INT IDENTITY PRIMARY KEY,
    TransactionID INT NOT NULL,
    FilePath VARCHAR(255) NOT NULL,
    FileType VARCHAR(20) NULL,
    UploadedOn DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_TransactionAttachments_Transactions FOREIGN KEY (TransactionID) REFERENCES dbo.Transactions(TransactionID)
);
GO

----------------------------------------------------
-- GMAIL TRANSACTION TRACKER
----------------------------------------------------
CREATE TABLE dbo.GmailTransactionTracker (
    GmailID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    EmailMessageID VARCHAR(255) NOT NULL,
    ParsedMerchant VARCHAR(100) NULL,
    ParsedAmount DECIMAL(18,2) NULL,
    ParsedDate DATETIME2 NULL,
    LinkedTransactionID INT NULL,
    Status VARCHAR(20) NOT NULL,

    CONSTRAINT CK_GmailTracker_Status CHECK (Status IN ('New','Parsed','Linked','Ignored','Error')),
    CONSTRAINT FK_GmailTracker_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_GmailTracker_Transactions FOREIGN KEY (LinkedTransactionID) REFERENCES dbo.Transactions(TransactionID),
    CONSTRAINT UQ_GmailTracker_UserMessage UNIQUE (UserID, EmailMessageID)
);
GO

----------------------------------------------------
-- INCOME (AccountID nullable)
----------------------------------------------------
CREATE TABLE dbo.Income (
    IncomeID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    AccountID INT NULL,
    YearMonth CHAR(7) NOT NULL,  -- "YYYY-MM"
    Amount DECIMAL(18,2) NOT NULL,
    Source VARCHAR(50) NULL,

    CONSTRAINT CK_Income_Amount_Positive CHECK (Amount > 0),
    CONSTRAINT FK_Income_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Income_Accounts FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_Income_YearMonth CHECK (
        YearMonth LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]'
        AND SUBSTRING(YearMonth, 6, 2) BETWEEN '01' AND '12'
    )
);
GO

----------------------------------------------------
-- BUDGETS (NO Title)
----------------------------------------------------
CREATE TABLE dbo.Budgets (
    BudgetID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    YearMonth CHAR(7) NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL,
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT CK_Budgets_TotalAmount_Positive CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Budgets_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT UQ_Budgets_UserMonth UNIQUE (UserID, YearMonth),
    CONSTRAINT CK_Budgets_YearMonth CHECK (
        YearMonth LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]'
        AND SUBSTRING(YearMonth, 6, 2) BETWEEN '01' AND '12'
    )
);
GO

----------------------------------------------------
-- BUDGET ENVELOPES
----------------------------------------------------
CREATE TABLE dbo.BudgetEnvelopes (
    EnvelopeID INT IDENTITY PRIMARY KEY,
    BudgetID INT NOT NULL,
    CategoryID INT NOT NULL,
    MonthlyLimit DECIMAL(18,2) NOT NULL,

    CONSTRAINT CK_BudgetEnvelopes_MonthlyLimit_Positive CHECK (MonthlyLimit >= 0),
    CONSTRAINT FK_BudgetEnvelopes_Budgets FOREIGN KEY (BudgetID) REFERENCES dbo.Budgets(BudgetID),
    CONSTRAINT FK_BudgetEnvelopes_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT UQ_BudgetEnvelopes UNIQUE (BudgetID, CategoryID)
);
GO

----------------------------------------------------
-- BUDGET PROGRESS
----------------------------------------------------
CREATE TABLE dbo.BudgetProgress (
    ProgressID INT IDENTITY PRIMARY KEY,
    BudgetID INT NOT NULL,
    CategoryID INT NOT NULL,
    SpentAmount DECIMAL(18,2) NOT NULL,
    RemainingAmount DECIMAL(18,2) NOT NULL,
    LastUpdated DATETIME2 NOT NULL,

    CONSTRAINT CK_BudgetProgress_NonNegative CHECK (SpentAmount >= 0 AND RemainingAmount >= 0),
    CONSTRAINT FK_BudgetProgress_Budgets FOREIGN KEY (BudgetID) REFERENCES dbo.Budgets(BudgetID),
    CONSTRAINT FK_BudgetProgress_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT UQ_BudgetProgress UNIQUE (BudgetID, CategoryID)
);
GO

----------------------------------------------------
-- PETS (MATCH SEED: no Status column)
----------------------------------------------------
CREATE TABLE dbo.Pets (
    PetID INT IDENTITY PRIMARY KEY,
    PetName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255) NULL
);
GO

----------------------------------------------------
-- PET STATUS IMAGES (MATCH SEED)
----------------------------------------------------
CREATE TABLE dbo.PetStatusImages (
    PetStatusImageID INT IDENTITY PRIMARY KEY,
    PetID INT NOT NULL,
    PetStatus VARCHAR(30) NOT NULL,
    ImagePath VARCHAR(255) NOT NULL,

    CONSTRAINT FK_PetStatusImages_Pets FOREIGN KEY (PetID) REFERENCES dbo.Pets(PetID),
    CONSTRAINT CK_PetStatusImages_Status CHECK (PetStatus IN ('Happy','Normal','Sad','Excited')),
    CONSTRAINT UQ_PetStatusImages UNIQUE (PetID, PetStatus)
);
GO

----------------------------------------------------
-- USER PETS (MATCH SEED: Happy/Normal/Sad/Excited, no StatusUpdatedOn)
----------------------------------------------------
CREATE TABLE dbo.UserPets (
    UserPetID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    PetID INT NOT NULL,
    XP INT NOT NULL DEFAULT 0,
    EcoScore INT NOT NULL DEFAULT 0,
    LastActiveDate DATETIME2 NOT NULL,
    InactiveDays INT NOT NULL DEFAULT 0,
    PetStatus VARCHAR(30) NOT NULL,
    IsPetSubscribed BIT NOT NULL DEFAULT 0,

    CONSTRAINT CK_UserPets_Status CHECK (PetStatus IN ('Happy','Normal','Sad','Excited')),
    CONSTRAINT CK_UserPets_NonNegative CHECK (XP >= 0 AND EcoScore >= 0 AND InactiveDays >= 0),
    CONSTRAINT FK_UserPets_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_UserPets_Pets FOREIGN KEY (PetID) REFERENCES dbo.Pets(PetID)
);
GO

----------------------------------------------------
-- BADGES
----------------------------------------------------
CREATE TABLE dbo.Badges (
    BadgeID INT IDENTITY PRIMARY KEY,
    BadgeName VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255) NULL,
    IconPath VARCHAR(255) NULL,
    XPReward INT NOT NULL
);
GO

----------------------------------------------------
-- USER BADGES
----------------------------------------------------
CREATE TABLE dbo.UserBadges (
    UserBadgeID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    BadgeID INT NOT NULL,
    EarnedOn DATETIME2 NOT NULL,

    CONSTRAINT FK_UserBadges_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_UserBadges_Badges FOREIGN KEY (BadgeID) REFERENCES dbo.Badges(BadgeID),
    CONSTRAINT UQ_UserBadges UNIQUE (UserID, BadgeID)
);
GO

----------------------------------------------------
-- CHALLENGES
----------------------------------------------------
CREATE TABLE dbo.Challenges (
    ChallengeID INT IDENTITY PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NULL,
    TargetAmount DECIMAL(18,2) NOT NULL,
    CategoryID INT NULL,
    XPReward INT NOT NULL,
    IsSystemGenerated BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Challenges_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID)
);
GO

----------------------------------------------------
-- USER CHALLENGES
----------------------------------------------------
CREATE TABLE dbo.UserChallenges (
    UserChallengeID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    ChallengeID INT NOT NULL,
    ProgressAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsCompleted BIT NOT NULL DEFAULT 0,
    CompletedOn DATETIME2 NULL,

    CONSTRAINT FK_UserChallenges_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_UserChallenges_Challenges FOREIGN KEY (ChallengeID) REFERENCES dbo.Challenges(ChallengeID),
    CONSTRAINT UQ_UserChallenges UNIQUE (UserID, ChallengeID)
);
GO

----------------------------------------------------
-- LEADERBOARD STATS
----------------------------------------------------
CREATE TABLE dbo.LeaderboardStats (
    LeaderboardID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    YearMonth CHAR(7) NOT NULL,
    SavingsPercentage DECIMAL(5,2) NOT NULL,
    FinancialLiteracyScore INT NOT NULL,

    CONSTRAINT FK_LeaderboardStats_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT UQ_LeaderboardStats UNIQUE (UserID, YearMonth),
    CONSTRAINT CK_LeaderboardStats_YearMonth CHECK (
        YearMonth LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]'
        AND SUBSTRING(YearMonth, 6, 2) BETWEEN '01' AND '12'
    )
);
GO

----------------------------------------------------
-- ECO SCORES
----------------------------------------------------
CREATE TABLE dbo.EcoScores (
    EcoScoreID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    YearMonth CHAR(7) NOT NULL,
    Score INT NOT NULL,

    CONSTRAINT FK_EcoScores_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT UQ_EcoScores UNIQUE (UserID, YearMonth),
    CONSTRAINT CK_EcoScores_YearMonth CHECK (
        YearMonth LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]'
        AND SUBSTRING(YearMonth, 6, 2) BETWEEN '01' AND '12'
    )
);
GO

----------------------------------------------------
-- MERCHANT RULES
----------------------------------------------------
CREATE TABLE dbo.MerchantRules (
    RuleID INT IDENTITY PRIMARY KEY,
    MerchantKeyword VARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    UserID INT NULL,

    CONSTRAINT FK_MerchantRules_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT FK_MerchantRules_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
);
GO

/* ===========================================================
   2) INDEXES
   =========================================================== */

CREATE INDEX IX_Accounts_UserID ON dbo.Accounts(UserID);
CREATE INDEX IX_Transactions_AccountID ON dbo.Transactions(AccountID);
CREATE INDEX IX_Transactions_CategoryID ON dbo.Transactions(CategoryID);
CREATE INDEX IX_Budgets_UserID ON dbo.Budgets(UserID);
CREATE INDEX IX_Income_UserID ON dbo.Income(UserID);
CREATE INDEX IX_Transactions_TransactionDate ON dbo.Transactions(TransactionDate);
CREATE INDEX IX_Transactions_AccountDate ON dbo.Transactions(AccountID, TransactionDate DESC);

-- Ensure only one default account per user at a time
CREATE UNIQUE INDEX UX_Accounts_OneDefaultPerUser
ON dbo.Accounts(UserID)
WHERE IsDefault = 1;
GO
