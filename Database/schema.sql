/* ===========================================================
   BudgetlyDB Schema (LocalDB / SQL Server)
   - Matches model fixes:
     * Transactions has NO UserID (infer via Accounts)
     * Budgets has NO Title
     * Accounts has IsDefault
     * Income.AccountID is nullable
   =========================================================== */

SET NOCOUNT ON;

/*SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
*/

-- USERS
CREATE TABLE Users (
    UserID INT IDENTITY PRIMARY KEY,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ResetDay INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT CK_Users_ResetDay CHECK (ResetDay BETWEEN 1 AND 28)
);

-- USER PROFILES (1-to-1 with Users)
CREATE TABLE UserProfiles (
    ProfileID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    DisplayName VARCHAR(100) NULL,
    ProfileImagePath VARCHAR(255) NULL,
    ThemePreference VARCHAR(50) NULL,
    NotificationEnabled BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_UserProfiles_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- SUBSCRIPTIONS
CREATE TABLE Subscriptions (
    SubscriptionID INT IDENTITY PRIMARY KEY,
    SubscriptionName VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NULL,
    CONSTRAINT UQ_Subscriptions_Name UNIQUE (SubscriptionName)
);

-- USER SUBSCRIPTIONS
CREATE TABLE UserSubscriptions (
    UserSubscriptionID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    SubscriptionID INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    StartDate DATETIME2 NOT NULL,
    EndDate DATETIME2 NULL,
    CONSTRAINT CK_UserSubscriptions_DateRange CHECK (EndDate IS NULL OR EndDate >= StartDate),
    CONSTRAINT FK_UserSubscriptions_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_UserSubscriptions_Subscriptions FOREIGN KEY (SubscriptionID) REFERENCES Subscriptions(SubscriptionID),
    CONSTRAINT UQ_UserSubscriptions UNIQUE (UserID, SubscriptionID)
);

-- ACCOUNTS / WALLETS
CREATE TABLE Accounts (
    AccountID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    AccountName VARCHAR(50) NOT NULL,
    AccountType VARCHAR(20) NOT NULL,
    Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsGmailSyncEnabled BIT NOT NULL DEFAULT 0,
    LastSyncDate DATETIME2 NULL,
    IsDefault BIT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Accounts_Type CHECK (AccountType IN ('Savings','Credit','Cash','Digital')),
    CONSTRAINT FK_Accounts_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- ACCOUNT IMAGES
CREATE TABLE AccountImages (
    ImageID INT IDENTITY PRIMARY KEY,
    AccountID INT NOT NULL,
    ImagePath VARCHAR(255) NOT NULL,
    UploadedOn DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_AccountImages_Accounts FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

-- CATEGORIES
CREATE TABLE Categories (
    CategoryID INT IDENTITY PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE,
    EcoWeight DECIMAL(3,2) NOT NULL,
    IsEssential BIT NOT NULL,
    IconPath VARCHAR(255) NULL,
    CONSTRAINT CK_Categories_EcoWeight CHECK (EcoWeight BETWEEN 0 AND 1)
);

-- TRANSACTIONS (NO UserID)
CREATE TABLE Transactions (
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
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT CK_Transactions_Type CHECK (TransactionType IN ('INCOME','EXPENSE')),
    CONSTRAINT CK_Transactions_Source CHECK (Source IN ('MANUAL','GMAIL','IMPORT'))
);

-- TRANSACTION ATTACHMENTS
CREATE TABLE TransactionAttachments (
    AttachmentID INT IDENTITY PRIMARY KEY,
    TransactionID INT NOT NULL,
    FilePath VARCHAR(255) NOT NULL,
    FileType VARCHAR(20) NULL,
    UploadedOn DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_TransactionAttachments_Transactions FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);

-- GMAIL TRANSACTION TRACKER
CREATE TABLE GmailTransactionTracker (
    GmailID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    EmailMessageID VARCHAR(255) NOT NULL,
    ParsedMerchant VARCHAR(100) NULL,
    ParsedAmount DECIMAL(18,2) NULL,
    ParsedDate DATETIME2 NULL,
    LinkedTransactionID INT NULL,
    Status VARCHAR(20) NOT NULL,
    CONSTRAINT CK_GmailTracker_Status CHECK (Status IN ('New','Parsed','Linked','Ignored','Error')),
    CONSTRAINT FK_GmailTracker_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_GmailTracker_Transactions FOREIGN KEY (LinkedTransactionID) REFERENCES Transactions(TransactionID),
    CONSTRAINT UQ_GmailTracker_UserMessage UNIQUE (UserID, EmailMessageID)
);

-- INCOME (AccountID nullable)
CREATE TABLE Income (
    IncomeID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    AccountID INT NULL,
    YearMonth CHAR(7) NOT NULL,  -- "YYYY-MM"
    Amount DECIMAL(18,2) NOT NULL,
    Source VARCHAR(50) NULL,
    CONSTRAINT CK_Income_Amount_Positive CHECK (Amount > 0),
    CONSTRAINT FK_Income_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Income_Accounts FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT CK_Income_YearMonth CHECK (YearMonth LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]' AND SUBSTRING(YearMonth, 6, 2) BETWEEN '01' AND '12')
);

-- BUDGETS (NO Title)
CREATE TABLE Budgets (
    BudgetID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    YearMonth CHAR(7) NOT NULL, -- "YYYY-MM"
    TotalAmount DECIMAL(18,2) NOT NULL,
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Budgets_TotalAmount_Positive CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Budgets_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT UQ_Budgets_UserMonth UNIQUE (UserID, YearMonth),
    CONSTRAINT CK_Budgets_YearMonth CHECK (YearMonth LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]' AND SUBSTRING(YearMonth, 6, 2) BETWEEN '01' AND '12')
);

-- BUDGET ENVELOPES
CREATE TABLE BudgetEnvelopes (
    EnvelopeID INT IDENTITY PRIMARY KEY,
    BudgetID INT NOT NULL,
    CategoryID INT NOT NULL,
    MonthlyLimit DECIMAL(18,2) NOT NULL,
    CONSTRAINT CK_BudgetEnvelopes_MonthlyLimit_Positive CHECK (MonthlyLimit >= 0),
    CONSTRAINT FK_BudgetEnvelopes_Budgets FOREIGN KEY (BudgetID) REFERENCES Budgets(BudgetID),
    CONSTRAINT FK_BudgetEnvelopes_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_BudgetEnvelopes UNIQUE (BudgetID, CategoryID)
);

-- BUDGET PROGRESS
CREATE TABLE BudgetProgress (
    ProgressID INT IDENTITY PRIMARY KEY,
    BudgetID INT NOT NULL,
    CategoryID INT NOT NULL,
    SpentAmount DECIMAL(18,2) NOT NULL,
    RemainingAmount DECIMAL(18,2) NOT NULL,
    LastUpdated DATETIME2 NOT NULL,
    CONSTRAINT CK_BudgetProgress_NonNegative CHECK (SpentAmount >= 0 AND RemainingAmount >= 0),
    CONSTRAINT FK_BudgetProgress_Budgets FOREIGN KEY (BudgetID) REFERENCES Budgets(BudgetID),
    CONSTRAINT FK_BudgetProgress_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_BudgetProgress UNIQUE (BudgetID, CategoryID)
);

-- PETS
CREATE TABLE Pets (
    PetID INT IDENTITY PRIMARY KEY,
    PetName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255) NULL
);

-- USER PETS (1-to-1 per user)
CREATE TABLE UserPets (
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
    CONSTRAINT FK_UserPets_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_UserPets_Pets FOREIGN KEY (PetID) REFERENCES Pets(PetID)
);

-- PET STATUS IMAGES
CREATE TABLE PetStatusImages (
    StatusImageID INT IDENTITY PRIMARY KEY,
    PetID INT NOT NULL,
    PetStatus VARCHAR(30) NOT NULL,
    ImagePath VARCHAR(255) NOT NULL,
    CONSTRAINT FK_PetStatusImages_Pets FOREIGN KEY (PetID) REFERENCES Pets(PetID),
    CONSTRAINT UQ_PetStatusImages UNIQUE (PetID, PetStatus)
);

-- BADGES
CREATE TABLE Badges (
    BadgeID INT IDENTITY PRIMARY KEY,
    BadgeName VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255) NULL,
    IconPath VARCHAR(255) NULL,
    XPReward INT NOT NULL
);

-- USER BADGES
CREATE TABLE UserBadges (
    UserBadgeID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    BadgeID INT NOT NULL,
    EarnedOn DATETIME2 NOT NULL,
    CONSTRAINT FK_UserBadges_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_UserBadges_Badges FOREIGN KEY (BadgeID) REFERENCES Badges(BadgeID),
    CONSTRAINT UQ_UserBadges UNIQUE (UserID, BadgeID)
);

-- CHALLENGES
CREATE TABLE Challenges (
    ChallengeID INT IDENTITY PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NULL,
    TargetAmount DECIMAL(18,2) NOT NULL,
    CategoryID INT NULL,
    XPReward INT NOT NULL,
    IsSystemGenerated BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Challenges_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- USER CHALLENGES
CREATE TABLE UserChallenges (
    UserChallengeID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    ChallengeID INT NOT NULL,
    ProgressAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsCompleted BIT NOT NULL DEFAULT 0,
    CompletedOn DATETIME2 NULL,
    CONSTRAINT FK_UserChallenges_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_UserChallenges_Challenges FOREIGN KEY (ChallengeID) REFERENCES Challenges(ChallengeID),
    CONSTRAINT UQ_UserChallenges UNIQUE (UserID, ChallengeID)
);

-- LEADERBOARD STATS
CREATE TABLE LeaderboardStats (
    LeaderboardID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    YearMonth CHAR(7) NOT NULL,
    SavingsPercentage DECIMAL(5,2) NOT NULL,
    FinancialLiteracyScore INT NOT NULL,
    CONSTRAINT FK_LeaderboardStats_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT UQ_LeaderboardStats UNIQUE (UserID, YearMonth),
    CONSTRAINT CK_LeaderboardStats_YearMonth CHECK (YearMonth LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]' AND SUBSTRING(YearMonth, 6, 2) BETWEEN '01' AND '12')
);

-- ECO SCORES
CREATE TABLE EcoScores (
    EcoScoreID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    YearMonth CHAR(7) NOT NULL,
    Score INT NOT NULL,
    CONSTRAINT FK_EcoScores_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT UQ_EcoScores UNIQUE (UserID, YearMonth),
    CONSTRAINT CK_EcoScores_YearMonth CHECK (YearMonth LIKE '[1-2][0-9][0-9][0-9]-[0-1][0-9]' AND SUBSTRING(YearMonth, 6, 2) BETWEEN '01' AND '12')
);

-- MERCHANT RULES
CREATE TABLE MerchantRules (
    RuleID INT IDENTITY PRIMARY KEY,
    MerchantKeyword VARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    UserID INT NULL,
    CONSTRAINT FK_MerchantRules_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT FK_MerchantRules_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Helper Indexes for performance
CREATE INDEX IX_Accounts_UserID ON Accounts(UserID);
CREATE INDEX IX_Transactions_AccountID ON Transactions(AccountID);
CREATE INDEX IX_Transactions_CategoryID ON Transactions(CategoryID);
CREATE INDEX IX_Budgets_UserID ON Budgets(UserID);
CREATE INDEX IX_Income_UserID ON Income(UserID);
CREATE INDEX IX_Transactions_TransactionDate ON Transactions(TransactionDate);
CREATE INDEX IX_Transactions_AccountDate ON Transactions(AccountID, TransactionDate DESC);

-- Ensure only one default account per user at a time 
CREATE UNIQUE INDEX UX_Accounts_OneDefaultPerUser
ON Accounts(UserID)
WHERE IsDefault = 1;