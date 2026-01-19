CREATE TABLE Roles (
    RoleId INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Permissions (
    PermissionId INT IDENTITY PRIMARY KEY,
    Code NVARCHAR(100) NOT NULL UNIQUE,
    Name NVARCHAR(150) NOT NULL
);

CREATE TABLE RolePermissions (
    RoleId INT NOT NULL,
    PermissionId INT NOT NULL,
    PRIMARY KEY (RoleId, PermissionId),
    CONSTRAINT FK_RolePermissions_Role FOREIGN KEY (RoleId) REFERENCES Roles(RoleId),
    CONSTRAINT FK_RolePermissions_Permission FOREIGN KEY (PermissionId) REFERENCES Permissions(PermissionId)
);

CREATE TABLE Users (
    UserId INT IDENTITY PRIMARY KEY,
    UserName NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARBINARY(256) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE UserRoles (
    UserId INT NOT NULL,
    RoleId INT NOT NULL,
    PRIMARY KEY (UserId, RoleId),
    CONSTRAINT FK_UserRoles_User FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_UserRoles_Role FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);

CREATE TABLE Customers (
    CustomerId INT IDENTITY PRIMARY KEY,
    CustomerCode INT NOT NULL UNIQUE,
    CustomerPublicId AS ('TW-' + RIGHT('000000' + CAST(CustomerCode AS VARCHAR(6)), 6)) PERSISTED,
    FullName NVARCHAR(150) NOT NULL,
    Mobile NVARCHAR(20) NOT NULL UNIQUE,
    CNIC NVARCHAR(30),
    Address NVARCHAR(250),
    Status BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy INT NOT NULL,
    CONSTRAINT FK_Customers_Users FOREIGN KEY (CreatedBy) REFERENCES Users(UserId)
);

CREATE TABLE CustomerAccounts (
    AccountId INT IDENTITY PRIMARY KEY,
    CustomerId INT NOT NULL UNIQUE,
    CurrencyCode CHAR(3) NOT NULL DEFAULT 'SAR',
    Status BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CustomerAccounts_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

CREATE TABLE LedgerEntries (
    LedgerId BIGINT IDENTITY PRIMARY KEY,
    AccountId INT NOT NULL,
    TxnDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Debit DECIMAL(18,2) NOT NULL DEFAULT 0,
    Credit DECIMAL(18,2) NOT NULL DEFAULT 0,
    CurrencyCode CHAR(3) NOT NULL DEFAULT 'SAR',
    Reference NVARCHAR(100),
    Description NVARCHAR(250),
    CreatedBy INT NOT NULL,
    CONSTRAINT FK_LedgerEntries_Account FOREIGN KEY (AccountId) REFERENCES CustomerAccounts(AccountId),
    CONSTRAINT FK_LedgerEntries_User FOREIGN KEY (CreatedBy) REFERENCES Users(UserId)
);

CREATE TABLE ExternalBranches (
    ExternalBranchId INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE InternalBranches (
    InternalBranchId INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE SubBranches (
    SubBranchId INT IDENTITY PRIMARY KEY,
    InternalBranchId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_SubBranches_Internal FOREIGN KEY (InternalBranchId) REFERENCES InternalBranches(InternalBranchId)
);

CREATE TABLE Orders (
    OrderId INT IDENTITY PRIMARY KEY,
    OrderCode NVARCHAR(20) NOT NULL UNIQUE,
    OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CustomerId INT NOT NULL,
    ReceiverName NVARCHAR(150) NOT NULL,
    ReceiverMobile NVARCHAR(20) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL CHECK (Amount > 0),
    Charges DECIMAL(18,2) NOT NULL DEFAULT 0,
    Total AS (Amount + Charges) PERSISTED,
    PaymentMode NVARCHAR(20) NOT NULL CHECK (PaymentMode IN ('Cash', 'Online', 'FromAccount')),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Open',
    ExternalBranchId INT NOT NULL,
    InternalBranchId INT NOT NULL,
    SubBranchId INT NOT NULL,
    Remarks NVARCHAR(250),
    CreatedBy INT NOT NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    CONSTRAINT FK_Orders_ExternalBranch FOREIGN KEY (ExternalBranchId) REFERENCES ExternalBranches(ExternalBranchId),
    CONSTRAINT FK_Orders_InternalBranch FOREIGN KEY (InternalBranchId) REFERENCES InternalBranches(InternalBranchId),
    CONSTRAINT FK_Orders_SubBranch FOREIGN KEY (SubBranchId) REFERENCES SubBranches(SubBranchId),
    CONSTRAINT FK_Orders_User FOREIGN KEY (CreatedBy) REFERENCES Users(UserId)
);

CREATE TABLE Settings (
    SettingKey NVARCHAR(100) PRIMARY KEY,
    SettingValue NVARCHAR(250) NOT NULL
);

CREATE TABLE AuditLog (
    AuditId BIGINT IDENTITY PRIMARY KEY,
    UserId INT NOT NULL,
    Action NVARCHAR(100) NOT NULL,
    Entity NVARCHAR(50) NOT NULL,
    EntityId NVARCHAR(50) NOT NULL,
    Description NVARCHAR(250),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_AuditLog_User FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE VIEW vwCustomerBalance AS
SELECT
    ca.CustomerId,
    SUM(le.Credit) - SUM(le.Debit) AS Balance
FROM CustomerAccounts ca
LEFT JOIN LedgerEntries le ON ca.AccountId = le.AccountId
GROUP BY ca.CustomerId;

CREATE INDEX IX_LedgerEntries_AccountDate ON LedgerEntries(AccountId, TxnDate);
CREATE UNIQUE INDEX IX_Customers_Mobile ON Customers(Mobile);
CREATE INDEX IX_Orders_Customer ON Orders(CustomerId);
