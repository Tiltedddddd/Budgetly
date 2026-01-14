-- ==========================================
-- BudgetlyDB Seed Data
-- ==========================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;

----------------------------------------------------
-- MONTHS (helper table)
----------------------------------------------------
DECLARE @Months TABLE (YearMonth CHAR(7), MonthStart DATE);
INSERT INTO @Months VALUES
('2025-09','2025-09-01'),
('2025-10','2025-10-01'),
('2025-11','2025-11-01'),
('2025-12','2025-12-01'),
('2026-01','2026-01-01');

----------------------------------------------------
-- USERS
----------------------------------------------------
INSERT INTO Users (Email, PasswordHash, FullName, ResetDay, IsActive)
VALUES
('alice@mail.com','hash1','Alice Tan',1,1),
('bob@mail.com','hash2','Bob Lim',5,1),
('charlie@mail.com','hash3','Charlie Goh',10,1),
('diana@mail.com','hash4','Diana Lee',15,1),
('ethan@mail.com','hash5','Ethan Ng',20,1);

----------------------------------------------------
-- USER PROFILES
----------------------------------------------------
INSERT INTO UserProfiles (UserID, DisplayName, ProfileImagePath, ThemePreference, NotificationEnabled)
SELECT UserID,
       CASE Email
           WHEN 'alice@mail.com' THEN 'AliceT'
           WHEN 'bob@mail.com' THEN 'Bobby'
           WHEN 'charlie@mail.com' THEN 'Char'
           WHEN 'diana@mail.com' THEN 'Di'
           WHEN 'ethan@mail.com' THEN 'EthanN'
       END,
       '/img/u' + CAST(UserID AS VARCHAR) + '.png',
       CASE WHEN UserID % 2 = 0 THEN 'Dark' ELSE 'Light' END,
       1
FROM Users;

----------------------------------------------------
-- SUBSCRIPTIONS
----------------------------------------------------
INSERT INTO Subscriptions (SubscriptionName, Description)
VALUES
('Free','Basic access'),
('Premium','Advanced analytics'),
('EcoPlus','Eco gamification perks');

----------------------------------------------------
-- USER SUBSCRIPTIONS
----------------------------------------------------
INSERT INTO UserSubscriptions (UserID, SubscriptionID, IsActive, StartDate)
VALUES
(1,2,1,SYSUTCDATETIME()),
(2,1,1,SYSUTCDATETIME()),
(3,3,1,SYSUTCDATETIME()),
(4,2,1,SYSUTCDATETIME()),
(5,1,1,SYSUTCDATETIME());

----------------------------------------------------
-- ACCOUNTS
----------------------------------------------------
INSERT INTO Accounts (UserID, AccountName, AccountType, Balance, IsGmailSyncEnabled, IsDefault)
VALUES
(1,'DBS Savings','Savings',2500,1,1),
(2,'UOB Savings','Savings',1800,0,1),
(3,'Cash Wallet','Cash',200,0,1),
(4,'POSB Savings','Savings',3200,1,1),
(5,'PayNow Wallet','Digital',600,0,1);

----------------------------------------------------
-- ACCOUNT IMAGES
----------------------------------------------------
INSERT INTO AccountImages (AccountID, ImagePath)
SELECT AccountID, '/img/acc' + CAST(AccountID AS VARCHAR) + '.png'
FROM Accounts;

----------------------------------------------------
-- CATEGORIES
----------------------------------------------------
INSERT INTO Categories (CategoryName, EcoWeight, IsEssential, IconPath)
VALUES
('Housing',0.95,1,'/icons/housing.png'),
('Food',0.80,1,'/icons/food.png'),
('Transportation',0.75,1,'/icons/transport.png'),
('Utilities',0.90,1,'/icons/utilities.png'),
('Healthcare',0.90,1,'/icons/healthcare.png'),
('Education',0.95,1,'/icons/education.png'),
('Shopping',0.40,0,'/icons/shopping.png'),
('Entertainment',0.30,0,'/icons/entertainment.png'),
('Savings',1.00,1,'/icons/savings.png'),
('Misc',0.50,0,'/icons/misc.png');

----------------------------------------------------
-- TRANSACTIONS
----------------------------------------------------
INSERT INTO Transactions
(AccountID, CategoryID, Amount, TransactionType, TransactionDate, Merchant, Description, Source)
VALUES
(1,2,120.50,'EXPENSE','2025-09-06','NTUC','Groceries','MANUAL'),
(1,2,45.00,'EXPENSE','2025-09-10','McDonalds','Meal','GMAIL'),
(1,7,150.00,'EXPENSE','2025-10-12','Shopee','Shopping','GMAIL'),
(1,2,35.00,'EXPENSE','2025-11-08','Starbucks','Coffee','GMAIL');

DECLARE @Tx_NTUC INT = (SELECT TransactionID FROM Transactions WHERE Merchant='NTUC');
DECLARE @Tx_McD INT = (SELECT TransactionID FROM Transactions WHERE Merchant='McDonalds');
DECLARE @Tx_Shopee INT = (SELECT TransactionID FROM Transactions WHERE Merchant='Shopee');
DECLARE @Tx_Starbucks INT = (SELECT TransactionID FROM Transactions WHERE Merchant='Starbucks');

----------------------------------------------------
-- TRANSACTION ATTACHMENTS
----------------------------------------------------
INSERT INTO TransactionAttachments (TransactionID, FilePath, FileType)
VALUES
(@Tx_NTUC,'/att/ntuc.jpg','image'),
(@Tx_McD,'/att/mcd.jpg','image'),
(@Tx_Shopee,'/att/shopee.pdf','pdf');

----------------------------------------------------
-- GMAIL TRANSACTION TRACKER
----------------------------------------------------
SET IDENTITY_INSERT GmailTransactionTracker ON;

INSERT INTO GmailTransactionTracker (GmailID, UserID, EmailMessageID, ParsedMerchant, ParsedAmount, ParsedDate, LinkedTransactionID, Status)
VALUES
(1,1,'msg001','McDonalds',45,SYSUTCDATETIME(),@Tx_McD,'Linked'),
(2,1,'msg002','Shopee',150,SYSUTCDATETIME(),@Tx_Shopee,'Linked'),
(3,1,'msg003','Starbucks',35,SYSUTCDATETIME(),@Tx_Starbucks,'Linked');

SET IDENTITY_INSERT GmailTransactionTracker OFF;


----------------------------------------------------
-- INCOME
----------------------------------------------------
INSERT INTO Income (UserID, AccountID, YearMonth, Amount, Source)
VALUES
-- User 1
(1,1,'2025-09',3500,'Salary'),(1,1,'2025-10',3600,'Salary'),
(1,1,'2025-11',3500,'Salary'),(1,1,'2025-12',4200,'Bonus'),(1,1,'2026-01',3400,'Salary'),
-- User 2
(2,2,'2025-09',2800,'Salary'),(2,2,'2025-10',2850,'Salary'),
(2,2,'2025-11',2800,'Salary'),(2,2,'2025-12',3000,'Bonus'),(2,2,'2026-01',2750,'Salary'),
-- User 3
(3,3,'2025-09',2200,'Salary'),(3,3,'2025-10',2250,'Salary'),
(3,3,'2025-11',2200,'Salary'),(3,3,'2025-12',2500,'Bonus'),(3,3,'2026-01',2100,'Salary'),
-- User 4
(4,4,'2025-09',4000,'Salary'),(4,4,'2025-10',4100,'Salary'),
(4,4,'2025-11',4000,'Salary'),(4,4,'2025-12',4800,'Bonus'),(4,4,'2026-01',3900,'Salary'),
-- User 5
(5,5,'2025-09',3000,'Salary'),(5,5,'2025-10',3050,'Salary'),
(5,5,'2025-11',3000,'Salary'),(5,5,'2025-12',3300,'Bonus'),(5,5,'2026-01',2900,'Salary');

----------------------------------------------------
-- BUDGETS
----------------------------------------------------
INSERT INTO Budgets (UserID, YearMonth, TotalAmount)
VALUES
-- Users 1-5, multi-month
(1,'2025-09',2000),(1,'2025-10',2100),(1,'2025-11',2000),(1,'2025-12',2500),(1,'2026-01',1900),
(2,'2025-09',1500),(2,'2025-10',1550),(2,'2025-11',1500),(2,'2025-12',1800),(2,'2026-01',1450),
(3,'2025-09',1000),(3,'2025-10',1050),(3,'2025-11',1000),(3,'2025-12',1300),(3,'2026-01',950),
(4,'2025-09',2500),(4,'2025-10',2600),(4,'2025-11',2500),(4,'2025-12',3000),(4,'2026-01',2400),
(5,'2025-09',1800),(5,'2025-10',1850),(5,'2025-11',1800),(5,'2025-12',2200),(5,'2026-01',1700);

----------------------------------------------------
-- BUDGET ENVELOPES
----------------------------------------------------
-- Make sure each user has all categories that will appear in BudgetProgress
INSERT INTO BudgetEnvelopes (BudgetID, CategoryID, MonthlyLimit)
SELECT b.BudgetID, v.CategoryID, v.Limit
FROM Budgets b
JOIN (VALUES
-- USER 1
(1,'2025-09',2,500),(1,'2025-09',3,300),(1,'2025-09',7,400),
(1,'2025-10',2,450),(1,'2025-10',4,350),(1,'2025-10',7,300),
(1,'2025-11',2,520),(1,'2025-11',6,250),(1,'2025-11',7,380),
(1,'2025-12',2,600),(1,'2025-12',7,600),(1,'2025-12',3,250),
(1,'2026-01',2,480),(1,'2026-01',4,320),(1,'2026-01',5,200),
-- USER 2
(2,'2025-09',2,400),(2,'2025-09',3,300),(2,'2025-09',4,200),
(2,'2025-10',2,420),(2,'2025-10',3,350),(2,'2025-10',4,220),
(2,'2025-11',2,410),(2,'2025-11',3,370),(2,'2025-11',4,230),
(2,'2025-12',2,380),(2,'2025-12',4,260),(2,'2025-12',7,300),
(2,'2026-01',2,290),(2,'2026-01',3,250),(2,'2026-01',4,210),
-- USER 3
(3,'2025-09',2,220),(3,'2025-09',4,260),(3,'2025-09',5,180),
(3,'2025-10',2,240),(3,'2025-10',4,280),(3,'2025-10',5,190),
(3,'2025-11',2,230),(3,'2025-11',4,270),(3,'2025-11',5,200),
(3,'2025-12',2,300),(3,'2025-12',4,320),(3,'2025-12',5,220),
(3,'2026-01',2,210),(3,'2026-01',4,250),(3,'2026-01',5,170),
-- USER 4
(4,'2025-09',2,520),(4,'2025-09',3,330),(4,'2025-09',7,450),
(4,'2025-10',2,540),(4,'2025-10',3,350),(4,'2025-10',7,470),
(4,'2025-11',2,530),(4,'2025-11',5,390),(4,'2025-11',7,460),
(4,'2025-12',2,650),(4,'2025-12',7,700),(4,'2025-12',5,420),
(4,'2026-01',2,500),(4,'2026-01',3,320),(4,'2026-01',7,410),
-- USER 5
(5,'2025-09',2,360),(5,'2025-09',4,280),(5,'2025-09',7,340),
(5,'2025-10',2,380),(5,'2025-10',4,300),(5,'2025-10',7,360),
(5,'2025-11',2,370),(5,'2025-11',4,290),(5,'2025-11',7,350),
(5,'2025-12',2,450),(5,'2025-12',4,330),(5,'2025-12',7,420),
(5,'2026-01',2,340),(5,'2026-01',4,260),(5,'2026-01',7,310)
) v(UserID, YearMonth, CategoryID, Limit)
ON v.UserID = b.UserID AND v.YearMonth = b.YearMonth;

----------------------------------------------------
-- BUDGET PROGRESS
----------------------------------------------------
INSERT INTO BudgetProgress (BudgetID, CategoryID, SpentAmount, RemainingAmount, LastUpdated)
SELECT
    be.BudgetID,
    be.CategoryID,
    v.Spent,
    be.MonthlyLimit - v.Spent,
    EOMONTH(DATEFROMPARTS(LEFT(b.YearMonth,4), RIGHT(b.YearMonth,2), 1))
FROM BudgetEnvelopes be
JOIN Budgets b ON b.BudgetID = be.BudgetID
JOIN (
    VALUES
    -- USER 1
    (1,'2025-09',2,410),(1,'2025-09',3,220),(1,'2025-09',7,360),
    (1,'2025-10',2,390),(1,'2025-10',4,300),(1,'2025-10',7,260),
    (1,'2025-11',2,480),(1,'2025-11',6,210),(1,'2025-11',7,350),
    (1,'2025-12',2,580),(1,'2025-12',7,590),(1,'2025-12',3,230),
    (1,'2026-01',2,450),(1,'2026-01',4,270),(1,'2026-01',5,180),
    -- USER 2
    (2,'2025-09',2,300),(2,'2025-09',4,200),(2,'2025-09',3,180),
    (2,'2025-10',2,320),(2,'2025-10',4,220),(2,'2025-10',3,190),
    (2,'2025-11',2,310),(2,'2025-11',4,230),(2,'2025-11',3,200),
    (2,'2025-12',2,380),(2,'2025-12',4,260),(2,'2025-12',7,300),
    (2,'2026-01',2,290),(2,'2026-01',4,210),(2,'2026-01',3,170),
    -- USER 3
    (3,'2025-09',2,220),(3,'2025-09',4,260),(3,'2025-09',5,180),
    (3,'2025-10',2,240),(3,'2025-10',4,280),(3,'2025-10',5,190),
    (3,'2025-11',2,230),(3,'2025-11',4,270),(3,'2025-11',5,200),
    (3,'2025-12',2,300),(3,'2025-12',4,320),(3,'2025-12',5,220),
    (3,'2026-01',2,210),(3,'2026-01',4,250),(3,'2026-01',5,170),
    -- USER 4
    (4,'2025-09',2,520),(4,'2025-09',3,330),(4,'2025-09',7,450),
    (4,'2025-10',2,540),(4,'2025-10',3,350),(4,'2025-10',7,470),
    (4,'2025-11',2,530),(4,'2025-11',5,390),(4,'2025-11',7,460),
    (4,'2025-12',2,650),(4,'2025-12',7,700),(4,'2025-12',5,420),
    (4,'2026-01',2,500),(4,'2026-01',3,320),(4,'2026-01',7,410),
    -- USER 5
    (5,'2025-09',2,360),(5,'2025-09',4,280),(5,'2025-09',7,340),
    (5,'2025-10',2,380),(5,'2025-10',4,300),(5,'2025-10',7,360),
    (5,'2025-11',2,370),(5,'2025-11',4,290),(5,'2025-11',7,350),
    (5,'2025-12',2,450),(5,'2025-12',4,330),(5,'2025-12',7,420),
    (5,'2026-01',2,340),(5,'2026-01',4,260),(5,'2026-01',7,310)
) v(UserID, YearMonth, CategoryID, Spent)
ON v.UserID = b.UserID AND v.YearMonth = b.YearMonth AND v.CategoryID = be.CategoryID;

----------------------------------------------------
-- PETS
----------------------------------------------------
INSERT INTO Pets (PetName, Description)
VALUES
('Eco Chick','Loves green spending'),
('Saver Duck','Protects savings'),
('Budget Bunny','Tracks expenses');

----------------------------------------------------
-- USER PETS
----------------------------------------------------
INSERT INTO UserPets (UserID, PetID, XP, EcoScore, LastActiveDate, InactiveDays, PetStatus, IsPetSubscribed)
VALUES
(1,1,120,80,SYSUTCDATETIME(),0,'Happy',1),
(2,2,90,70,SYSUTCDATETIME(),1,'Normal',0),
(3,3,60,60,SYSUTCDATETIME(),2,'Sad',0),
(4,1,200,90,SYSUTCDATETIME(),0,'Excited',1),
(5,2,110,75,SYSUTCDATETIME(),1,'Normal',0);

----------------------------------------------------
-- PET STATUS IMAGES
----------------------------------------------------
INSERT INTO PetStatusImages (PetID, PetStatus, ImagePath)
VALUES
(1,'Happy','/pet/happy1.png'),
(1,'Sad','/pet/sad1.png'),
(2,'Normal','/pet/normal2.png'),
(3,'Excited','/pet/excited3.png');

----------------------------------------------------
-- BADGES
----------------------------------------------------
INSERT INTO Badges (BadgeName, Description, IconPath, XPReward)
VALUES
('First Save','Saved first $100','/badge/save.png',50),
('Eco Hero','High eco score','/badge/eco.png',100),
('Budget Master','Stayed under budget','/badge/budget.png',150);

----------------------------------------------------
-- USER BADGES
----------------------------------------------------
INSERT INTO UserBadges (UserID, BadgeID, EarnedOn)
VALUES
(1,1,SYSUTCDATETIME()),
(1,2,SYSUTCDATETIME()),
(2,1,SYSUTCDATETIME()),
(4,3,SYSUTCDATETIME());

----------------------------------------------------
-- CHALLENGES
----------------------------------------------------
INSERT INTO Challenges (Title, Description, TargetAmount, CategoryID, XPReward, IsSystemGenerated)
VALUES
('Spend Less Dining','Reduce dining expenses',200,2,80,1),
('Eco Transport','Use greener transport',150,3,100,1),
('No Shopping Week','Avoid shopping',100,7,120,0);

----------------------------------------------------
-- USER CHALLENGES
----------------------------------------------------
INSERT INTO UserChallenges (UserID, ChallengeID, ProgressAmount, IsCompleted, CompletedOn)
VALUES
(1,1,120,0,NULL),
(2,2,150,1,SYSUTCDATETIME()),
(3,3,80,0,NULL),
(4,1,200,1,SYSUTCDATETIME());

----------------------------------------------------
-- LEADERBOARD STATS
----------------------------------------------------
INSERT INTO LeaderboardStats (UserID, YearMonth, SavingsPercentage, FinancialLiteracyScore)
VALUES
-- User 1
(1,'2025-09',25.5,80),(1,'2025-10',28.0,82),(1,'2025-11',27.0,81),(1,'2025-12',30.0,85),(1,'2026-01',26.5,79),
-- User 2
(2,'2025-09',30.0,85),(2,'2025-10',31.0,86),(2,'2025-11',29.5,84),(2,'2025-12',32.0,87),(2,'2026-01',28.0,83),
-- User 3
(3,'2025-09',18.2,70),(3,'2025-10',19.0,72),(3,'2025-11',20.0,73),(3,'2025-12',21.5,74),(3,'2026-01',17.5,69),
-- User 4
(4,'2025-09',35.0,90),(4,'2025-10',36.0,91),(4,'2025-11',34.5,89),(4,'2025-12',38.0,92),(4,'2026-01',33.0,88),
-- User 5
(5,'2025-09',22.0,75),(5,'2025-10',23.0,76),(5,'2025-11',21.5,74),(5,'2025-12',24.0,77),(5,'2026-01',20.5,73);

----------------------------------------------------
-- ECO SCORES
----------------------------------------------------
INSERT INTO EcoScores (UserID, YearMonth, Score)
VALUES
-- User 1
(1,'2025-09',82),(1,'2025-10',85),(1,'2025-11',83),(1,'2025-12',88),(1,'2026-01',81),
-- User 2
(2,'2025-09',75),(2,'2025-10',78),(2,'2025-11',77),(2,'2025-12',80),(2,'2026-01',74),
-- User 3
(3,'2025-09',68),(3,'2025-10',70),(3,'2025-11',71),(3,'2025-12',72),(3,'2026-01',66),
-- User 4
(4,'2025-09',90),(4,'2025-10',92),(4,'2025-11',91),(4,'2025-12',95),(4,'2026-01',89),
-- User 5
(5,'2025-09',78),(5,'2025-10',80),(5,'2025-11',79),(5,'2025-12',82),(5,'2026-01',76);

----------------------------------------------------
-- MERCHANT RULES
----------------------------------------------------
INSERT INTO MerchantRules (MerchantKeyword, CategoryID)
VALUES
('NTUC',2),('Grab',3),('McDonalds',2),('Shopee',7),('SP Group',4);

-- ==========================================
-- END OF SEED SCRIPT
-- ==========================================
