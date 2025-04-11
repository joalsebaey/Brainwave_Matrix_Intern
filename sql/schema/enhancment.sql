-- Add indexes for frequently queried columns
CREATE INDEX IX_Members_Email ON Members(Email);
CREATE INDEX IX_Books_ISBN ON Books(ISBN);
CREATE INDEX IX_BookCopies_Status ON BookCopies(Status);
CREATE INDEX IX_Loans_Status_DueDate ON Loans(Status, DueDate);
CREATE INDEX IX_BookAuthors_AuthorID ON BookAuthors(AuthorID);
CREATE INDEX IX_BookCategories_CategoryID ON BookCategories(CategoryID);

-- ===================================================
-- ENHANCEMENT 2: IMPROVED CONSTRAINTS
-- ===================================================

-- Email format validation
ALTER TABLE Members
ADD CONSTRAINT CHK_Members_Email_Format CHECK (Email LIKE '%_@_%._%');

ALTER TABLE Staff
ADD CONSTRAINT CHK_Staff_Email_Format CHECK (Email LIKE '%_@_%._%');

-- Ensure due date is after checkout date
ALTER TABLE Loans
ADD CONSTRAINT CHK_Loans_DueDate CHECK (DueDate > CheckoutDate);

-- ===================================================
-- ENHANCEMENT 3: SECURITY IMPROVEMENTS
-- ===================================================

-- Create role-based access control tables
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(MAX),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

CREATE TABLE Permissions (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY,
    PermissionName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(MAX),
    Resource NVARCHAR(50) NOT NULL
);

CREATE TABLE RolePermissions (
    RoleID INT NOT NULL,
    PermissionID INT NOT NULL,
    PRIMARY KEY (RoleID, PermissionID),
    CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID) ON DELETE CASCADE,
    CONSTRAINT FK_RolePermissions_Permissions FOREIGN KEY (PermissionID) REFERENCES Permissions(PermissionID) ON DELETE CASCADE
);

-- Add role to staff table
ALTER TABLE Staff
ADD RoleID INT NULL;

ALTER TABLE Staff
ADD CONSTRAINT FK_Staff_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID) ON DELETE SET NULL;

-- Audit logging table
CREATE TABLE AuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT,
    ActionType NVARCHAR(50) NOT NULL,
    TableName NVARCHAR(50) NOT NULL,
    RecordID INT,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    LogDate DATETIME DEFAULT GETDATE(),
    IPAddress NVARCHAR(50),
    CONSTRAINT FK_AuditLog_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE SET NULL
);

-- ===================================================
-- ENHANCEMENT 4: IMPROVED PASSWORD MANAGEMENT
-- ===================================================

-- Update staff table for better password handling
ALTER TABLE Staff
ADD PasswordSalt NVARCHAR(128) NOT NULL DEFAULT NEWID();
