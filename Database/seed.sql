/* ===========================================================
   SEED DATA (clean, GO-safe, schema unchanged)
   - Option 1 pets: use PetStatusImages + UserPets existing enum
   - Accounts: OCBC Savings Card, Trust Debit Card, DBS Credit Card, Cash Wallet
   - Transactions: 30 per user per month (Sep 2025 → Jan 2026) + attachments + Gmail tracker
   =========================================================== */

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;

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
-- USER SUBSCRIPTIONS (FK-safe: by Email + SubscriptionName)
----------------------------------------------------
INSERT INTO UserSubscriptions (UserID, SubscriptionID, IsActive, StartDate)
SELECT u.UserID, s.SubscriptionID, 1, SYSUTCDATETIME()
FROM (VALUES
  ('alice@mail.com','Premium'),
  ('bob@mail.com','Free'),
  ('charlie@mail.com','EcoPlus'),
  ('diana@mail.com','Premium'),
  ('ethan@mail.com','Free')
) v(Email, SubscriptionName)
JOIN Users u ON u.Email = v.Email
JOIN Subscriptions s ON s.SubscriptionName = v.SubscriptionName;

----------------------------------------------------
-- ACCOUNTS (card-style per user)
----------------------------------------------------
INSERT INTO Accounts (UserID, AccountName, AccountType, Balance, IsGmailSyncEnabled, IsDefault)
SELECT u.UserID, 'OCBC Savings Card', 'Savings',
       CASE u.Email
           WHEN 'alice@mail.com'   THEN 2500
           WHEN 'bob@mail.com'     THEN 1800
           WHEN 'charlie@mail.com' THEN 1200
           WHEN 'diana@mail.com'   THEN 3200
           WHEN 'ethan@mail.com'   THEN 1600
       END,
       0,
       1
FROM Users u;

INSERT INTO Accounts (UserID, AccountName, AccountType, Balance, IsGmailSyncEnabled, IsDefault)
SELECT u.UserID, 'Trust Debit Card', 'Digital',
       CASE u.Email
           WHEN 'alice@mail.com'   THEN 300
           WHEN 'bob@mail.com'     THEN 220
           WHEN 'charlie@mail.com' THEN 160
           WHEN 'diana@mail.com'   THEN 480
           WHEN 'ethan@mail.com'   THEN 600
       END,
       0,
       0
FROM Users u;

INSERT INTO Accounts (UserID, AccountName, AccountType, Balance, IsGmailSyncEnabled, IsDefault)
SELECT u.UserID, 'DBS Credit Card', 'Credit',
       0,
       CASE WHEN u.Email IN ('alice@mail.com','diana@mail.com') THEN 1 ELSE 0 END,
       0
FROM Users u;

INSERT INTO Accounts (UserID, AccountName, AccountType, Balance, IsGmailSyncEnabled, IsDefault)
SELECT u.UserID, 'Cash Wallet', 'Cash',
       CASE u.Email
           WHEN 'alice@mail.com'   THEN 180
           WHEN 'bob@mail.com'     THEN 120
           WHEN 'charlie@mail.com' THEN 90
           WHEN 'diana@mail.com'   THEN 250
           WHEN 'ethan@mail.com'   THEN 140
       END,
       0,
       0
FROM Users u;

----------------------------------------------------
-- ACCOUNT IMAGES (same image filename per card type)
----------------------------------------------------
INSERT INTO AccountImages (AccountID, ImagePath)
SELECT a.AccountID,
       CASE a.AccountName
           WHEN 'Trust Debit Card'   THEN '/images/Account/trust.png'
           WHEN 'DBS Credit Card'    THEN '/images/Account/dbs_credit.png'
           WHEN 'OCBC Savings Card'  THEN '/images/Account/ocbc_savings.png'
           WHEN 'Cash Wallet'        THEN '/images/Account/cash.png'
           ELSE '/Image/Account/default.png'
       END
FROM Accounts a;

----------------------------------------------------
-- CATEGORIES (constant 10)
----------------------------------------------------
INSERT INTO Categories (CategoryName, EcoWeight, IsEssential, IconPath)
VALUES
('Housing',0.95,1,'/images/icons/housing.png'),
('Food',0.80,1,'/images/icons/food.png'),
('Transportation',0.75,1,'/images/icons/transport.png'),
('Utilities',0.90,1,'/images/icons/utilities.png'),
('Healthcare',0.90,1,'/images/icons/healthcare.png'),
('Education',0.95,1,'/images/icons/education.png'),
('Shopping',0.40,0,'/images/icons/shopping.png'),
('Entertainment',0.30,0,'/images/icons/entertainment.png'),
('Savings',1.00,1,'/images/icons/savings.png'),
('Misc',0.50,0,'/images/icons/misc.png');


/* ===========================================================
   TRANSACTIONS (FULL GENERATED DATA)
   - 30 tx per user per month (Sep 2025 → Jan 2026)
   - Uses all 4 accounts per user
   - Attachments: /Image/Transaction/...
   - GmailTransactionTracker linked to GMAIL tx
   =========================================================== */

DECLARE @Months TABLE (YearMonth CHAR(7), MonthStart DATE);
INSERT INTO @Months VALUES
('2025-09','2025-09-01'),
('2025-10','2025-10-01'),
('2025-11','2025-11-01'),
('2025-12','2025-12-01'),
('2026-01','2026-01-01');

DECLARE @UserAccounts TABLE (
    UserID INT NOT NULL,
    AccKey VARCHAR(20) NOT NULL,   -- 'SAV','DIG','CRD','CSH'
    AccountID INT NOT NULL
);

INSERT INTO @UserAccounts (UserID, AccKey, AccountID)
SELECT u.UserID, 'SAV', a.AccountID
FROM Users u
JOIN Accounts a ON a.UserID = u.UserID AND a.AccountName = 'OCBC Savings Card';

INSERT INTO @UserAccounts (UserID, AccKey, AccountID)
SELECT u.UserID, 'DIG', a.AccountID
FROM Users u
JOIN Accounts a ON a.UserID = u.UserID AND a.AccountName = 'Trust Debit Card';

INSERT INTO @UserAccounts (UserID, AccKey, AccountID)
SELECT u.UserID, 'CRD', a.AccountID
FROM Users u
JOIN Accounts a ON a.UserID = u.UserID AND a.AccountName = 'DBS Credit Card';

INSERT INTO @UserAccounts (UserID, AccKey, AccountID)
SELECT u.UserID, 'CSH', a.AccountID
FROM Users u
JOIN Accounts a ON a.UserID = u.UserID AND a.AccountName = 'Cash Wallet';

;WITH
Nums AS (
    SELECT 1 AS n
    UNION ALL SELECT n+1 FROM Nums WHERE n < 30
),
Base AS (
    SELECT u.UserID, m.YearMonth, m.MonthStart, n.n
    FROM Users u
    CROSS JOIN @Months m
    CROSS JOIN Nums n
),
TxPlan AS (
    SELECT
        b.UserID, b.YearMonth, b.MonthStart, b.n,
        CASE WHEN b.n IN (1,2) THEN 'INCOME' ELSE 'EXPENSE' END AS TransactionType,
        CASE
            WHEN b.n IN (1,2) THEN 9
            ELSE CASE ((b.n - 3) % 9) + 1
                    WHEN 9 THEN 10
                    ELSE ((b.n - 3) % 9) + 1
                 END
        END AS CategoryID,
        CASE
            WHEN b.n IN (1,2) THEN 'SAV'
            ELSE CASE ((b.n + b.UserID) % 4)
                    WHEN 0 THEN 'DIG'
                    WHEN 1 THEN 'CRD'
                    WHEN 2 THEN 'CSH'
                    ELSE 'SAV'
                 END
        END AS AccKey,
        CASE (b.n % 3)
            WHEN 0 THEN 'MANUAL'
            WHEN 1 THEN 'GMAIL'
            ELSE 'IMPORT'
        END AS Source,
        DATEADD(
            DAY,
            ((b.n * 2 + b.UserID * 3) % DAY(EOMONTH(b.MonthStart))),
            CAST(b.MonthStart AS DATETIME2)
        ) AS TransactionDate
    FROM Base b
)
INSERT INTO Transactions
(AccountID, CategoryID, Amount, TransactionType, TransactionDate, Merchant, Description, Source)
SELECT
    ua.AccountID,
    p.CategoryID,
    CAST(
        CASE
            WHEN p.TransactionType = 'INCOME' THEN
                CASE
                    WHEN p.n = 1 THEN
                        (CASE p.UserID
                            WHEN (SELECT UserID FROM Users WHERE Email='alice@mail.com')   THEN 3300
                            WHEN (SELECT UserID FROM Users WHERE Email='bob@mail.com')     THEN 2700
                            WHEN (SELECT UserID FROM Users WHERE Email='charlie@mail.com') THEN 2100
                            WHEN (SELECT UserID FROM Users WHERE Email='diana@mail.com')   THEN 3800
                            WHEN (SELECT UserID FROM Users WHERE Email='ethan@mail.com')   THEN 2800
                         END)
                        + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 401)
                    ELSE
                        150 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 351)
                END
            ELSE
                CASE p.CategoryID
                    WHEN 1 THEN  (600 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 901))
                    WHEN 2 THEN  (8 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 45))
                                * (CASE WHEN p.UserID IN ((SELECT UserID FROM Users WHERE Email='alice@mail.com'),
                                                         (SELECT UserID FROM Users WHERE Email='diana@mail.com')) THEN 2 ELSE 1 END)
                    WHEN 3 THEN  (2 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 18))
                                * (CASE WHEN p.UserID = (SELECT UserID FROM Users WHERE Email='diana@mail.com') THEN 3 ELSE 2 END)
                    WHEN 4 THEN  (50 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 201))
                    WHEN 5 THEN  (10 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 160))
                    WHEN 6 THEN  (20 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 250))
                    WHEN 7 THEN  (12 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 220))
                                * (CASE WHEN p.UserID = (SELECT UserID FROM Users WHERE Email='alice@mail.com') THEN 2 ELSE 1 END)
                    WHEN 8 THEN  (8 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 120))
                    WHEN 10 THEN (5 + (ABS(CHECKSUM(CONCAT(p.UserID,'|',p.YearMonth,'|',p.n))) % 100))
                    ELSE 25
                END
        END AS DECIMAL(18,2)
    ) AS Amount,
    p.TransactionType,
    p.TransactionDate,
    CASE
        WHEN p.TransactionType = 'INCOME' THEN CASE WHEN p.n = 1 THEN 'Employer Payroll' ELSE 'PayNow Transfer' END
        ELSE CASE p.CategoryID
            WHEN 1 THEN 'Housing'
            WHEN 2 THEN CASE (p.n % 5)
                WHEN 0 THEN 'NTUC'
                WHEN 1 THEN 'FairPrice'
                WHEN 2 THEN 'McDonalds'
                WHEN 3 THEN 'Starbucks'
                ELSE 'Kopitiam' END
            WHEN 3 THEN CASE (p.n % 4)
                WHEN 0 THEN 'Grab'
                WHEN 1 THEN 'Gojek'
                WHEN 2 THEN 'ComfortDelGro'
                ELSE 'MRT' END
            WHEN 4 THEN CASE (p.n % 4)
                WHEN 0 THEN 'SP Group'
                WHEN 1 THEN 'PUB'
                WHEN 2 THEN 'SingTel'
                ELSE 'StarHub' END
            WHEN 5 THEN CASE (p.n % 3)
                WHEN 0 THEN 'Guardian'
                WHEN 1 THEN 'Watsons'
                ELSE 'Clinic' END
            WHEN 6 THEN CASE (p.n % 3)
                WHEN 0 THEN 'Coursera'
                WHEN 1 THEN 'Udemy'
                ELSE 'School Fees' END
            WHEN 7 THEN CASE (p.n % 5)
                WHEN 0 THEN 'Shopee'
                WHEN 1 THEN 'Lazada'
                WHEN 2 THEN 'Amazon'
                WHEN 3 THEN 'Uniqlo'
                ELSE 'Decathlon' END
            WHEN 8 THEN CASE (p.n % 4)
                WHEN 0 THEN 'Netflix'
                WHEN 1 THEN 'Spotify'
                WHEN 2 THEN 'Golden Village'
                ELSE 'Cinema' END
            WHEN 10 THEN 'Misc'
            ELSE 'Unknown' END
    END AS Merchant,
    CASE
        WHEN p.TransactionType = 'INCOME' THEN CASE WHEN p.n = 1 THEN CONCAT('Monthly salary - ', p.YearMonth)
                                                   ELSE CONCAT('Side income - ', p.YearMonth) END
        ELSE CONCAT('Auto-seeded expense (', p.YearMonth, ')')
    END AS Description,
    p.Source
FROM TxPlan p
JOIN @UserAccounts ua
  ON ua.UserID = p.UserID
 AND ua.AccKey = p.AccKey
OPTION (MAXRECURSION 0);

INSERT INTO TransactionAttachments (TransactionID, FilePath, FileType)
SELECT t.TransactionID,
       CONCAT('/Image/Transaction/tx_', t.TransactionID, '.jpg'),
       'image'
FROM Transactions t
WHERE t.TransactionDate >= '2025-09-01'
  AND t.TransactionDate <  '2026-02-01'
  AND (t.TransactionID % 8) = 0;

;WITH GmailTx AS (
    SELECT
        u.UserID,
        t.TransactionID,
        t.Merchant,
        t.Amount,
        t.TransactionDate,
        ROW_NUMBER() OVER (PARTITION BY u.UserID ORDER BY t.TransactionID) AS rn
    FROM Transactions t
    JOIN Accounts a ON a.AccountID = t.AccountID
    JOIN Users u ON u.UserID = a.UserID
    WHERE t.Source = 'GMAIL'
      AND t.TransactionDate >= '2025-09-01'
      AND t.TransactionDate <  '2026-02-01'
),
Pick AS (
    SELECT * FROM GmailTx WHERE rn <= 40
)
INSERT INTO GmailTransactionTracker
(UserID, EmailMessageID, ParsedMerchant, ParsedAmount, ParsedDate, LinkedTransactionID, Status)
SELECT
    p.UserID,
    CONCAT('u', p.UserID, '_msg_', RIGHT(CONCAT('0000', p.rn), 4)),
    p.Merchant,
    p.Amount,
    p.TransactionDate,
    p.TransactionID,
    'Linked'
FROM Pick p;

----------------------------------------------------
-- INCOME (FK-safe: links to each user's OCBC Savings Card)
----------------------------------------------------
INSERT INTO Income (UserID, AccountID, YearMonth, Amount, Source)
SELECT u.UserID, a.AccountID, v.YearMonth, v.Amount, v.Source
FROM (VALUES
('alice@mail.com','2025-09',3500,'Salary'),('alice@mail.com','2025-10',3600,'Salary'),
('alice@mail.com','2025-11',3500,'Salary'),('alice@mail.com','2025-12',4200,'Bonus'),('alice@mail.com','2026-01',3400,'Salary'),

('bob@mail.com','2025-09',2800,'Salary'),('bob@mail.com','2025-10',2850,'Salary'),
('bob@mail.com','2025-11',2800,'Salary'),('bob@mail.com','2025-12',3000,'Bonus'),('bob@mail.com','2026-01',2750,'Salary'),

('charlie@mail.com','2025-09',2200,'Salary'),('charlie@mail.com','2025-10',2250,'Salary'),
('charlie@mail.com','2025-11',2200,'Salary'),('charlie@mail.com','2025-12',2500,'Bonus'),('charlie@mail.com','2026-01',2100,'Salary'),

('diana@mail.com','2025-09',4000,'Salary'),('diana@mail.com','2025-10',4100,'Salary'),
('diana@mail.com','2025-11',4000,'Salary'),('diana@mail.com','2025-12',4800,'Bonus'),('diana@mail.com','2026-01',3900,'Salary'),

('ethan@mail.com','2025-09',3000,'Salary'),('ethan@mail.com','2025-10',3050,'Salary'),
('ethan@mail.com','2025-11',3000,'Salary'),('ethan@mail.com','2025-12',3300,'Bonus'),('ethan@mail.com','2026-01',2900,'Salary')
) v(Email, YearMonth, Amount, Source)
JOIN Users u ON u.Email = v.Email
JOIN Accounts a ON a.UserID = u.UserID AND a.AccountName='OCBC Savings Card' AND a.AccountType='Savings';


----------------------------------------------------
-- BUDGETS (kept as your current)
----------------------------------------------------
INSERT INTO Budgets (UserID, YearMonth, TotalAmount)
VALUES
(1,'2025-09',2000),(1,'2025-10',2100),(1,'2025-11',2000),(1,'2025-12',2500),(1,'2026-01',1900),
(2,'2025-09',1500),(2,'2025-10',1550),(2,'2025-11',1500),(2,'2025-12',1800),(2,'2026-01',1450),
(3,'2025-09',1000),(3,'2025-10',1050),(3,'2025-11',1000),(3,'2025-12',1300),(3,'2026-01',950),
(4,'2025-09',2500),(4,'2025-10',2600),(4,'2025-11',2500),(4,'2025-12',3000),(4,'2026-01',2400),
(5,'2025-09',1800),(5,'2025-10',1850),(5,'2025-11',1800),(5,'2025-12',2200),(5,'2026-01',1700);

----------------------------------------------------
-- BUDGET ENVELOPES (kept as your current)
----------------------------------------------------
INSERT INTO BudgetEnvelopes (BudgetID, CategoryID, MonthlyLimit)
SELECT b.BudgetID, v.CategoryID, v.Limit
FROM Budgets b
JOIN (VALUES
(1,'2025-09',2,500),(1,'2025-09',3,300),(1,'2025-09',7,400),
(1,'2025-10',2,450),(1,'2025-10',4,350),(1,'2025-10',7,300),
(1,'2025-11',2,520),(1,'2025-11',6,250),(1,'2025-11',7,380),
(1,'2025-12',2,600),(1,'2025-12',7,600),(1,'2025-12',3,250),
(1,'2026-01',2,480),(1,'2026-01',4,320),(1,'2026-01',5,200),

(2,'2025-09',2,400),(2,'2025-09',3,300),(2,'2025-09',4,200),
(2,'2025-10',2,420),(2,'2025-10',3,350),(2,'2025-10',4,220),
(2,'2025-11',2,410),(2,'2025-11',3,370),(2,'2025-11',4,230),
(2,'2025-12',2,380),(2,'2025-12',4,260),(2,'2025-12',7,300),
(2,'2026-01',2,290),(2,'2026-01',3,250),(2,'2026-01',4,210),

(3,'2025-09',2,220),(3,'2025-09',4,260),(3,'2025-09',5,180),
(3,'2025-10',2,240),(3,'2025-10',4,280),(3,'2025-10',5,190),
(3,'2025-11',2,230),(3,'2025-11',4,270),(3,'2025-11',5,200),
(3,'2025-12',2,300),(3,'2025-12',4,320),(3,'2025-12',5,220),
(3,'2026-01',2,210),(3,'2026-01',4,250),(3,'2026-01',5,170),

(4,'2025-09',2,520),(4,'2025-09',3,330),(4,'2025-09',7,450),
(4,'2025-10',2,540),(4,'2025-10',3,350),(4,'2025-10',7,470),
(4,'2025-11',2,530),(4,'2025-11',5,390),(4,'2025-11',7,460),
(4,'2025-12',2,650),(4,'2025-12',7,700),(4,'2025-12',5,420),
(4,'2026-01',2,500),(4,'2026-01',3,320),(4,'2026-01',7,410),

(5,'2025-09',2,360),(5,'2025-09',4,280),(5,'2025-09',7,340),
(5,'2025-10',2,380),(5,'2025-10',4,300),(5,'2025-10',7,360),
(5,'2025-11',2,370),(5,'2025-11',4,290),(5,'2025-11',7,350),
(5,'2025-12',2,450),(5,'2025-12',4,330),(5,'2025-12',7,420),
(5,'2026-01',2,340),(5,'2026-01',4,260),(5,'2026-01',7,310)
) v(UserID, YearMonth, CategoryID, Limit)
ON v.UserID = b.UserID AND v.YearMonth = b.YearMonth;

----------------------------------------------------
-- BUDGET PROGRESS (kept as your current)
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
    (1,'2025-09',2,410),(1,'2025-09',3,220),(1,'2025-09',7,360),
    (1,'2025-10',2,390),(1,'2025-10',4,300),(1,'2025-10',7,260),
    (1,'2025-11',2,480),(1,'2025-11',6,210),(1,'2025-11',7,350),
    (1,'2025-12',2,580),(1,'2025-12',7,590),(1,'2025-12',3,230),
    (1,'2026-01',2,450),(1,'2026-01',4,270),(1,'2026-01',5,180),

    (2,'2025-09',2,300),(2,'2025-09',4,200),(2,'2025-09',3,180),
    (2,'2025-10',2,320),(2,'2025-10',4,220),(2,'2025-10',3,190),
    (2,'2025-11',2,310),(2,'2025-11',4,230),(2,'2025-11',3,200),
    (2,'2025-12',2,380),(2,'2025-12',4,260),(2,'2025-12',7,300),
    (2,'2026-01',2,290),(2,'2026-01',4,210),(2,'2026-01',3,170),

    (3,'2025-09',2,220),(3,'2025-09',4,260),(3,'2025-09',5,180),
    (3,'2025-10',2,240),(3,'2025-10',4,280),(3,'2025-10',5,190),
    (3,'2025-11',2,230),(3,'2025-11',4,270),(3,'2025-11',5,200),
    (3,'2025-12',2,300),(3,'2025-12',4,320),(3,'2025-12',5,220),
    (3,'2026-01',2,210),(3,'2026-01',4,250),(3,'2026-01',5,170),

    (4,'2025-09',2,520),(4,'2025-09',3,330),(4,'2025-09',7,450),
    (4,'2025-10',2,540),(4,'2025-10',3,350),(4,'2025-10',7,470),
    (4,'2025-11',2,530),(4,'2025-11',5,390),(4,'2025-11',7,460),
    (4,'2025-12',2,650),(4,'2025-12',7,700),(4,'2025-12',5,420),
    (4,'2026-01',2,500),(4,'2026-01',3,320),(4,'2026-01',7,410),

    (5,'2025-09',2,360),(5,'2025-09',4,280),(5,'2025-09',7,340),
    (5,'2025-10',2,380),(5,'2025-10',4,300),(5,'2025-10',7,360),
    (5,'2025-11',2,370),(5,'2025-11',4,290),(5,'2025-11',7,350),
    (5,'2025-12',2,450),(5,'2025-12',4,330),(5,'2025-12',7,420),
    (5,'2026-01',2,340),(5,'2026-01',4,260),(5,'2026-01',7,310)
) v(UserID, YearMonth, CategoryID, Spent)
ON v.UserID = b.UserID AND v.YearMonth = b.YearMonth AND v.CategoryID = be.CategoryID;




----------------------------------------------------
-- PETS (schema unchanged)
----------------------------------------------------
INSERT INTO Pets (PetName, Description)
VALUES
('Eco Chick','Loves green spending'),
('Saver Duck','Protects savings'),
('Budget Bunny','Tracks expenses');

----------------------------------------------------
-- PET STATUS IMAGES (schema unchanged)
-- Full set: each pet × (Happy, Normal, Sad, Excited)
----------------------------------------------------
INSERT INTO PetStatusImages (PetID, PetStatus, ImagePath)
SELECT p.PetID, s.PetStatus,
       CONCAT('/images/Pet/',
              REPLACE(LOWER(p.PetName), ' ', '_'),
              '_',
              LOWER(s.PetStatus),
              '.png')
FROM Pets p
CROSS JOIN (VALUES ('Happy'),('Normal'),('Sad'),('Excited')) s(PetStatus);

----------------------------------------------------
-- USER PETS (use only allowed enum: Happy/Normal/Sad/Excited)
----------------------------------------------------
INSERT INTO UserPets (UserID, PetID, XP, EcoScore, LastActiveDate, InactiveDays, PetStatus, IsPetSubscribed)
SELECT u.UserID,
       p.PetID,
       v.XP, v.EcoScore,
       SYSUTCDATETIME(),
       v.InactiveDays,
       v.PetStatus,
       v.IsPetSubscribed
FROM (VALUES
('alice@mail.com','Eco Chick',   120,80,0,'Happy',   1),
('bob@mail.com','Saver Duck',     90,70,1,'Normal',  0),
('charlie@mail.com','Budget Bunny',60,60,2,'Sad',    0),
('diana@mail.com','Eco Chick',   200,90,0,'Excited', 1),
('ethan@mail.com','Saver Duck',  110,75,1,'Normal',  0)
) v(Email, PetName, XP, EcoScore, InactiveDays, PetStatus, IsPetSubscribed)
JOIN Users u ON u.Email = v.Email
JOIN Pets p ON p.PetName = v.PetName;

----------------------------------------------------
-- BADGES (15)
----------------------------------------------------
INSERT INTO Badges (BadgeName, Description, IconPath, XPReward)
VALUES
('First Save','Saved your first $100','/images/Badge/badge1.png',50),
('Streak Starter','Logged transactions 3 days in a row','/images/Badge/badge2.png',40),
('Budget Keeper','Stayed under budget for 1 month','/images/Badge/badge3.png',120),
('No-Spend Day','Completed a no-spend day','/images/Badge/badge4.png',60),
('Eco Hero','High eco score in a month','/images/Badge/badge5.png',100),
('Savings Builder','Saved 10% of income','/images/Badge/badge6.png',90),
('Bill Boss','Paid utilities on time','/images/Badge/badge7.png',70),
('Food Planner','Kept food spending steady','/images/Badge/badge8.png',80),
('Transport Tamer','Reduced transport costs','/images/Badge/badge9.png',90),
('Health First','Tracked healthcare spending','/images/Badge/badge10.png',60),
('Learning Learner','Budgeted for education','/images/Badge/badge11.png',70),
('Shop Smarter','Reduced shopping spend','/images/Badge/badge12.png',100),
('Entertainment Balanced','Stayed within fun budget','/images/Badge/badge13.png',80),
('Consistency Champ','Budgeted 3 months straight','/images/Badge/badge14.png',150),
('Master Planner','Completed full budget setup','/images/Badge/badge15.png',200);

----------------------------------------------------
-- USER BADGES (GO-safe, no variables)
----------------------------------------------------
INSERT INTO UserBadges (UserID, BadgeID, EarnedOn)
SELECT u.UserID, b.BadgeID, SYSUTCDATETIME()
FROM (VALUES
  ('alice@mail.com','First Save'),
  ('alice@mail.com','Eco Hero'),
  ('bob@mail.com','First Save'),
  ('diana@mail.com','Master Planner')
) v(Email, BadgeName)
JOIN Users u  ON u.Email = v.Email
JOIN Badges b ON b.BadgeName = v.BadgeName;

----------------------------------------------------
-- CHALLENGES (15, FK-safe by CategoryName)
----------------------------------------------------
INSERT INTO Challenges (Title, Description, TargetAmount, CategoryID, XPReward, IsSystemGenerated)
SELECT v.Title, v.Description, v.TargetAmount, c.CategoryID, v.XPReward, v.IsSystemGenerated
FROM (VALUES
('Spend Less on Food','Keep food spending under target',250,'Food',80,1),
('Eco Transport Week','Choose greener transport options',150,'Transportation',100,1),
('Utilities Saver','Reduce utilities spending',180,'Utilities',90,1),
('Healthcare Buffer','Set aside for healthcare',120,'Healthcare',70,1),
('Learning Fund','Budget for education',100,'Education',70,1),
('No Shopping Week','Avoid shopping for a week',120,'Shopping',120,0),
('Entertainment Cutback','Lower entertainment spend',90,'Entertainment',80,0),
('Emergency Savings','Put money into savings category',300,'Savings',140,1),
('Misc Cleanup','Reduce misc spending',60,'Misc',60,0),
('Home Basics','Keep housing essentials steady',400,'Housing',110,1),
('Coffee Control','Limit cafe/coffee purchases',70,'Food',70,0),
('Public Transport Choice','Prefer MRT/bus this month',120,'Transportation',90,0),
('Pay Bills Early','Pay utilities early this month',150,'Utilities',75,0)
) v(Title, Description, TargetAmount, CategoryName, XPReward, IsSystemGenerated)
JOIN Categories c ON c.CategoryName = v.CategoryName;

INSERT INTO Challenges (Title, Description, TargetAmount, CategoryID, XPReward, IsSystemGenerated)
VALUES
('Zero Waste Habit','General eco habit challenge',50,NULL,60,1),
('Track Everything','Log all spending for 14 days',1,NULL,100,1);

----------------------------------------------------
-- USER CHALLENGES (GO-safe, no variables)
----------------------------------------------------
INSERT INTO UserChallenges (UserID, ChallengeID, ProgressAmount, IsCompleted, CompletedOn)
SELECT u.UserID, ch.ChallengeID, v.ProgressAmount, v.IsCompleted, v.CompletedOn
FROM (VALUES
('alice@mail.com','Spend Less on Food',120.00,0,NULL),
('bob@mail.com','Eco Transport Week',150.00,1,SYSUTCDATETIME()),
('charlie@mail.com','No Shopping Week',80.00,0,NULL),
('diana@mail.com','Spend Less on Food',200.00,1,SYSUTCDATETIME())
) v(Email, ChallengeTitle, ProgressAmount, IsCompleted, CompletedOn)
JOIN Users u       ON u.Email = v.Email
JOIN Challenges ch ON ch.Title = v.ChallengeTitle;

----------------------------------------------------
-- LEADERBOARD STATS (GO-safe, no variables)
----------------------------------------------------
INSERT INTO LeaderboardStats (UserID, YearMonth, SavingsPercentage, FinancialLiteracyScore)
SELECT u.UserID, v.YearMonth, v.SavingsPct, v.Score
FROM (VALUES
('alice@mail.com','2025-09',25.5,80),('alice@mail.com','2025-10',28.0,82),('alice@mail.com','2025-11',27.0,81),('alice@mail.com','2025-12',30.0,85),('alice@mail.com','2026-01',26.5,79),
('bob@mail.com','2025-09',30.0,85),('bob@mail.com','2025-10',31.0,86),('bob@mail.com','2025-11',29.5,84),('bob@mail.com','2025-12',32.0,87),('bob@mail.com','2026-01',28.0,83),
('charlie@mail.com','2025-09',18.2,70),('charlie@mail.com','2025-10',19.0,72),('charlie@mail.com','2025-11',20.0,73),('charlie@mail.com','2025-12',21.5,74),('charlie@mail.com','2026-01',17.5,69),
('diana@mail.com','2025-09',35.0,90),('diana@mail.com','2025-10',36.0,91),('diana@mail.com','2025-11',34.5,89),('diana@mail.com','2025-12',38.0,92),('diana@mail.com','2026-01',33.0,88),
('ethan@mail.com','2025-09',22.0,75),('ethan@mail.com','2025-10',23.0,76),('ethan@mail.com','2025-11',21.5,74),('ethan@mail.com','2025-12',24.0,77),('ethan@mail.com','2026-01',20.5,73)
) v(Email, YearMonth, SavingsPct, Score)
JOIN Users u ON u.Email = v.Email;

----------------------------------------------------
-- ECO SCORES (GO-safe, no variables)
----------------------------------------------------
INSERT INTO EcoScores (UserID, YearMonth, Score)
SELECT u.UserID, v.YearMonth, v.Score
FROM (VALUES
('alice@mail.com','2025-09',82),('alice@mail.com','2025-10',85),('alice@mail.com','2025-11',83),('alice@mail.com','2025-12',88),('alice@mail.com','2026-01',81),
('bob@mail.com','2025-09',75),('bob@mail.com','2025-10',78),('bob@mail.com','2025-11',77),('bob@mail.com','2025-12',80),('bob@mail.com','2026-01',74),
('charlie@mail.com','2025-09',68),('charlie@mail.com','2025-10',70),('charlie@mail.com','2025-11',71),('charlie@mail.com','2025-12',72),('charlie@mail.com','2026-01',66),
('diana@mail.com','2025-09',90),('diana@mail.com','2025-10',92),('diana@mail.com','2025-11',91),('diana@mail.com','2025-12',95),('diana@mail.com','2026-01',89),
('ethan@mail.com','2025-09',78),('ethan@mail.com','2025-10',80),('ethan@mail.com','2025-11',79),('ethan@mail.com','2025-12',82),('ethan@mail.com','2026-01',76)
) v(Email, YearMonth, Score)
JOIN Users u ON u.Email = v.Email;

----------------------------------------------------
-- MERCHANT RULES (CategoryID by name, optional user-specific)
----------------------------------------------------
INSERT INTO MerchantRules (MerchantKeyword, CategoryID, UserID)
SELECT v.Keyword, c.CategoryID, u.UserID
FROM (VALUES
('NTUC','Food',NULL),
('FairPrice','Food',NULL),
('McDonalds','Food',NULL),
('Starbucks','Food',NULL),

('Grab','Transportation',NULL),
('Gojek','Transportation',NULL),
('ComfortDelGro','Transportation',NULL),

('SP Group','Utilities',NULL),
('PUB','Utilities',NULL),
('SingTel','Utilities',NULL),

('Guardian','Healthcare',NULL),
('Watsons','Healthcare',NULL),

('Coursera','Education',NULL),
('Udemy','Education',NULL),

('Shopee','Shopping',NULL),
('Lazada','Shopping',NULL),
('Amazon','Shopping',NULL),
('Uniqlo','Shopping',NULL),

('Netflix','Entertainment',NULL),
('Spotify','Entertainment',NULL),

-- user-specific
('DBS PayLah','Transportation','alice@mail.com'),
('Decathlon','Shopping','bob@mail.com'),
('Challenger','Shopping','ethan@mail.com')
) v(Keyword, CategoryName, UserEmail)
JOIN Categories c ON c.CategoryName = v.CategoryName
LEFT JOIN Users u ON u.Email = v.UserEmail;
