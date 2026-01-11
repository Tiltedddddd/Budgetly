SET NOCOUNT ON;

-- USERS
INSERT INTO Users (Email, PasswordHash, FullName, ResetDay, IsActive)
VALUES
('alice@mail.com','hash1','Alice Tan',1,1),
('bob@mail.com','hash2','Bob Lim',5,1),
('charlie@mail.com','hash3','Charlie Goh',10,1),
('diana@mail.com','hash4','Diana Lee',15,1),
('ethan@mail.com','hash5','Ethan Ng',20,1);

-- USER PROFILES
INSERT INTO UserProfiles (UserID, DisplayName, ProfileImagePath, ThemePreference, NotificationEnabled)
VALUES
(1,'AliceT','/img/u1.png','Light',1),
(2,'Bobby','/img/u2.png','Dark',1),
(3,'Char','/img/u3.png','Green',0),
(4,'Di','/img/u4.png','Dark',1),
(5,'EthanN','/img/u5.png','Light',1);

-- SUBSCRIPTIONS
INSERT INTO Subscriptions (SubscriptionName, Description)
VALUES
('Free','Basic access'),
('Premium','Advanced analytics'),
('EcoPlus','Eco gamification perks');

-- USER SUBSCRIPTIONS
INSERT INTO UserSubscriptions (UserID, SubscriptionID, IsActive, StartDate, EndDate)
VALUES
(1,2,1,SYSUTCDATETIME(),NULL),
(2,1,1,SYSUTCDATETIME(),NULL),
(3,3,1,SYSUTCDATETIME(),NULL),
(4,2,1,SYSUTCDATETIME(),NULL),
(5,1,1,SYSUTCDATETIME(),NULL);

-- ACCOUNTS (IsDefault included)
INSERT INTO Accounts (UserID, AccountName, AccountType, Balance, IsGmailSyncEnabled, IsDefault)
VALUES
(1,'DBS Savings','Savings',2500,1,1),
(1,'OCBC Card','Credit',-320,1,0),
(1,'Trust Travel','Credit',-320,1,0),
(2,'UOB Savings','Savings',1800,0,1),
(3,'Cash Wallet','Cash',200,0,1),
(4,'POSB Savings','Savings',3200,1,1),
(5,'PayNow Wallet','Digital',600,0,1);

-- ACCOUNT IMAGES
INSERT INTO AccountImages (AccountID, ImagePath)
VALUES
(1,'/img/acc1.png'),
(2,'/img/acc2.png'),
(3,'/img/acc3.png'),
(4,'/img/acc4.png'),
(5,'/img/acc5.png'),
(6,'/img/acc6.png');

-- CATEGORIES (IDs will be 1..10 in this order)
INSERT INTO Categories (CategoryName, EcoWeight, IsEssential, IconPath)
VALUES
('Housing',0.95,1,'/icons/housing.png'),              -- category 1 no img yet
('Food',0.80,1,'/Content/images/icons/foodIcon.png'),         -- 2
('Transportation',0.75,1,'/Content/images/icons/transportIcon.png'),     -- category 3
('Utilities',0.90,1,'/Content/images/icons/utilitiesIcon.png'),          -- category 4
('Healthcare',0.90,1,'/Content/images/icons/healthcareIcon.png'),         -- category 5
('Education',0.95,1,'/icons/education.png'),          -- 6 no img yet
('Shopping',0.40,0,'/Content/images/icons/shoppingIcon.png'),            -- category 7
('Entertainment',0.30,0,'/icons/entertainment.png'),  -- category 8 no img yet
('Savings & Investments',1.00,1,'/icons/savings.png'),-- category 9 no img yet
('Miscellaneous',0.50,0,'/icons/misc.png');           -- category 10 no img yet


-- TRANSACTIONS (NO UserID; must use MANUAL/GMAIL and INCOME/EXPENSE)
INSERT INTO Transactions (AccountID, CategoryID, Amount, TransactionType, TransactionDate, Merchant, Description, Source)
VALUES
(1,2,120.50,'EXPENSE',SYSUTCDATETIME(),'NTUC','Weekly groceries','MANUAL'),
(1,3,12.00,'EXPENSE',SYSUTCDATETIME(),'Grab','Ride','MANUAL'),
(1,7,50.00,'EXPENSE',SYSUTCDATETIME(),'Shopee','Online purchase','GMAIL'),
(1,3,12.00,'EXPENSE',SYSUTCDATETIME(),'Gojek','Ride','MANUAL'),
(1,7,50.00,'EXPENSE',SYSUTCDATETIME(),'Lazada','Online purchase','GMAIL'),
(1,3,12.00,'EXPENSE',SYSUTCDATETIME(),'TADA','Ride','MANUAL'),
(1,7,50.00,'EXPENSE',SYSUTCDATETIME(),'Taobao','Online purchase','GMAIL'),
(2,2,45.00,'EXPENSE',SYSUTCDATETIME(),'McDonalds','Lunch','GMAIL'),
(2,5,5.00,'EXPENSE',SYSUTCDATETIME(),'OneCare','Medical Certificate','GMAIL'),
(3,3,80.00,'EXPENSE',SYSUTCDATETIME(),'Grab','Ride','MANUAL'),
(4,7,150.00,'EXPENSE',SYSUTCDATETIME(),'Shopee','Online shopping','GMAIL'),
(5,4,200.00,'EXPENSE',SYSUTCDATETIME(),'SP Group','Electricity bill','MANUAL'),
(6,2,35.00,'EXPENSE',SYSUTCDATETIME(),'Starbucks','Coffee','MANUAL');

DECLARE @Tx_NTUC INT = (SELECT TOP 1 TransactionID FROM Transactions WHERE Merchant='NTUC' ORDER BY TransactionID DESC);
DECLARE @Tx_McD  INT = (SELECT TOP 1 TransactionID FROM Transactions WHERE Merchant='McDonalds' ORDER BY TransactionID DESC);
DECLARE @Tx_Shopee INT = (SELECT TOP 1 TransactionID FROM Transactions WHERE Merchant='Shopee' ORDER BY TransactionID DESC);
DECLARE @Tx_Starbucks INT = (SELECT TOP 1 TransactionID FROM Transactions WHERE Merchant='Starbucks' ORDER BY TransactionID DESC);


-- ATTACHMENTS
INSERT INTO TransactionAttachments (TransactionID, FilePath, FileType)
VALUES
(@Tx_NTUC,'/att/receipt1.jpg','image'),
(@Tx_McD,'/att/receipt2.jpg','image'),
(@Tx_Shopee,'/att/receipt3.pdf','pdf');


-- GMAIL TRACKER
INSERT INTO GmailTransactionTracker (UserID, EmailMessageID, ParsedMerchant, ParsedAmount, ParsedDate, LinkedTransactionID, Status)
VALUES
(1,'msg001','McDonalds',45.00,SYSUTCDATETIME(),@Tx_McD,'Linked'),
(3,'msg002','Shopee',150.00,SYSUTCDATETIME(),@Tx_Shopee,'Linked'),
(5,'msg003','Starbucks',35.00,SYSUTCDATETIME(),@Tx_Starbucks,'Linked');



-- INCOME
INSERT INTO Income (UserID, AccountID, YearMonth, Amount, Source)
VALUES
(1,1,'2025-01',3500,'Salary'),
(2,3,'2025-01',2800,'Salary'),
(3,4,'2025-01',2200,'Allowance'),
(4,5,'2025-01',4000,'Salary'),
(5,6,'2025-01',3000,'Freelance');

-- BUDGETS (NO Title)
INSERT INTO Budgets (UserID, YearMonth, TotalAmount)
VALUES
(1,'2025-01',2000),
(2,'2025-01',1500),
(3,'2025-01',1000),
(4,'2025-01',2500),
(5,'2025-01',1800);

DECLARE @B1 INT = (SELECT BudgetID FROM Budgets WHERE UserID=1 AND YearMonth='2025-01');
DECLARE @B2 INT = (SELECT BudgetID FROM Budgets WHERE UserID=2 AND YearMonth='2025-01');
DECLARE @B3 INT = (SELECT BudgetID FROM Budgets WHERE UserID=3 AND YearMonth='2025-01');
DECLARE @B4 INT = (SELECT BudgetID FROM Budgets WHERE UserID=4 AND YearMonth='2025-01');
DECLARE @B5 INT = (SELECT BudgetID FROM Budgets WHERE UserID=5 AND YearMonth='2025-01');


-- BUDGET ENVELOPES (BudgetIDs 1..5 on fresh DB)
INSERT INTO BudgetEnvelopes (BudgetID, CategoryID, MonthlyLimit)
VALUES
(@B1,2,500),
(@B1,3,300),
(@B2,2,200),
(@B3,4,400),
(@B4,5,600);

-- BUDGET PROGRESS
INSERT INTO BudgetProgress (BudgetID, CategoryID, SpentAmount, RemainingAmount, LastUpdated)
VALUES
(@B1,2,120.50,379.50,SYSUTCDATETIME()),
(@B1,3,45.00,255.00,SYSUTCDATETIME()),
(@B2,2,80.00,120.00,SYSUTCDATETIME()),
(@B3,4,150.00,250.00,SYSUTCDATETIME()),
(@B4,5,200.00,400.00,SYSUTCDATETIME());

-- PETS
INSERT INTO Pets (PetName, Description)
VALUES
('Eco Chick','Loves green spending'),
('Saver Duck','Protects savings'),
('Budget Bunny','Tracks expenses');

-- USER PETS
INSERT INTO UserPets (UserID, PetID, XP, EcoScore, LastActiveDate, InactiveDays, PetStatus, IsPetSubscribed)
VALUES
(1,1,120,80,SYSUTCDATETIME(),0,'Happy',1),
(2,2,90,70,SYSUTCDATETIME(),1,'Normal',0),
(3,3,60,60,SYSUTCDATETIME(),2,'Sad',0),
(4,1,200,90,SYSUTCDATETIME(),0,'Excited',1),
(5,2,110,75,SYSUTCDATETIME(),1,'Normal',0);

-- PET STATUS IMAGES
INSERT INTO PetStatusImages (PetID, PetStatus, ImagePath)
VALUES
(1,'Happy','/pet/happy1.png'),
(1,'Sad','/pet/sad1.png'),
(2,'Normal','/pet/normal2.png'),
(3,'Excited','/pet/excited3.png');

-- BADGES
INSERT INTO Badges (BadgeName, Description, IconPath, XPReward)
VALUES
('First Save','Saved first $100','/badge/save.png',50),
('Eco Hero','High eco score','/badge/eco.png',100),
('Budget Master','Stayed under budget','/badge/budget.png',150);

-- USER BADGES
INSERT INTO UserBadges (UserID, BadgeID, EarnedOn)
VALUES
(1,1,SYSUTCDATETIME()),
(1,2,SYSUTCDATETIME()),
(2,1,SYSUTCDATETIME()),
(4,3,SYSUTCDATETIME());

-- CHALLENGES
INSERT INTO Challenges (Title, Description, TargetAmount, CategoryID, XPReward, IsSystemGenerated)
VALUES
('Spend Less Dining','Reduce dining expenses',200,2,80,1),
('Eco Transport','Use greener transport',150,3,100,1),
('No Shopping Week','Avoid shopping',100,7,120,0);

-- USER CHALLENGES
INSERT INTO UserChallenges (UserID, ChallengeID, ProgressAmount, IsCompleted, CompletedOn)
VALUES
(1,1,120,0,NULL),
(2,2,150,1,SYSUTCDATETIME()),
(3,3,80,0,NULL),
(4,1,200,1,SYSUTCDATETIME());

-- LEADERBOARD STATS
INSERT INTO LeaderboardStats (UserID, YearMonth, SavingsPercentage, FinancialLiteracyScore)
VALUES
(1,'2025-01',25.50,80),
(2,'2025-01',30.00,85),
(3,'2025-01',18.20,70),
(4,'2025-01',35.00,90),
(5,'2025-01',22.00,75);

-- ECO SCORES
INSERT INTO EcoScores (UserID, YearMonth, Score)
VALUES
(1,'2025-01',82),
(2,'2025-01',75),
(3,'2025-01',68),
(4,'2025-01',90),
(5,'2025-01',78);

-- MERCHANT RULES
INSERT INTO MerchantRules (MerchantKeyword, CategoryID, UserID)
VALUES
('NTUC',2,NULL),
('Grab',3,NULL),
('McDonalds',2,NULL),
('Shopee',7,NULL),
('SP Group',4,NULL);
