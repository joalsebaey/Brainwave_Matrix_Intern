-- Create the Library Management System Database
CREATE DATABASE LibraryManagementSystem;
GO

USE LibraryManagementSystem;
GO

-- Authors Table
CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Biography NVARCHAR(MAX),
    DateOfBirth DATE,
    Nationality NVARCHAR(50)
);
GO

-- Publishers Table
CREATE TABLE Publishers (
    PublisherID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(MAX),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Website NVARCHAR(100)
);
GO

-- Categories Table
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX)
);
GO

-- Books Table
CREATE TABLE Books (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    ISBN NVARCHAR(20) UNIQUE NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    PublisherID INT,
    PublicationDate DATE,
    Edition NVARCHAR(20),
    Language NVARCHAR(30),
    Pages INT,
    Description NVARCHAR(MAX),
    ShelfLocation NVARCHAR(50),
    CoverImageURL NVARCHAR(255),
    AddedDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20) CHECK (Status IN ('Available', 'Borrowed', 'Reserved', 'Lost', 'Under Repair')) DEFAULT 'Available',
    CONSTRAINT FK_Books_Publishers FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID) ON DELETE SET NULL
);
GO

-- Book-Author Relationship (Many-to-Many)
CREATE TABLE BookAuthors (
    BookID INT,
    AuthorID INT,
    PRIMARY KEY (BookID, AuthorID),
    CONSTRAINT FK_BookAuthors_Books FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    CONSTRAINT FK_BookAuthors_Authors FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID) ON DELETE CASCADE
);
GO

-- Book-Category Relationship (Many-to-Many)
CREATE TABLE BookCategories (
    BookID INT,
    CategoryID INT,
    PRIMARY KEY (BookID, CategoryID),
    CONSTRAINT FK_BookCategories_Books FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    CONSTRAINT FK_BookCategories_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE CASCADE
);
GO

-- Members Table
CREATE TABLE Members (
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(MAX),
    DateOfBirth DATE,
    MembershipDate DATE NOT NULL,
    MembershipExpiry DATE,
    MembershipStatus NVARCHAR(20) CHECK (MembershipStatus IN ('Active', 'Expired', 'Suspended', 'Cancelled')) DEFAULT 'Active'
);
GO

-- Staff Table
CREATE TABLE Staff (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(MAX),
    Position NVARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(10, 2),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL
);
GO

-- Loans Table
CREATE TABLE Loans (
    LoanID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    StaffID INT,
    CheckoutDate DATETIME NOT NULL DEFAULT GETDATE(),
    DueDate DATETIME NOT NULL,
    ReturnDate DATETIME NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Borrowed', 'Returned', 'Overdue', 'Lost')) DEFAULT 'Borrowed',
    CONSTRAINT FK_Loans_Books FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    CONSTRAINT FK_Loans_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE,
    CONSTRAINT FK_Loans_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE SET NULL
);
GO

-- Reservations Table
CREATE TABLE Reservations (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    ReservationDate DATETIME NOT NULL DEFAULT GETDATE(),
    ExpiryDate DATETIME NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Pending', 'Fulfilled', 'Cancelled', 'Expired')) DEFAULT 'Pending',
    CONSTRAINT FK_Reservations_Books FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    CONSTRAINT FK_Reservations_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE
);
GO

-- Fines Table
CREATE TABLE Fines (
    FineID INT IDENTITY(1,1) PRIMARY KEY,
    LoanID INT NOT NULL,
    MemberID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    IssuedDate DATETIME NOT NULL DEFAULT GETDATE(),
    PaymentDate DATETIME NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Pending', 'Paid', 'Waived')) DEFAULT 'Pending',
    CONSTRAINT FK_Fines_Loans FOREIGN KEY (LoanID) REFERENCES Loans(LoanID) ON DELETE CASCADE,
    CONSTRAINT FK_Fines_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE
);
GO

-- Book Copy Table (for tracking multiple copies of same book)
CREATE TABLE BookCopies (
    CopyID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    AcquisitionDate DATE NOT NULL,
    Price DECIMAL(10, 2),
    Condition NVARCHAR(20) CHECK (Condition IN ('New', 'Good', 'Fair', 'Poor')) DEFAULT 'New',
    Status NVARCHAR(20) CHECK (Status IN ('Available', 'Borrowed', 'Reserved', 'Lost', 'Under Repair')) DEFAULT 'Available',
    CONSTRAINT FK_BookCopies_Books FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE
);
GO

-- Create a view for available books
CREATE VIEW AvailableBooks AS
SELECT b.BookID, b.Title, b.ISBN, COUNT(bc.CopyID) AS AvailableCopies
FROM Books b
JOIN BookCopies bc ON b.BookID = bc.BookID
WHERE bc.Status = 'Available'
GROUP BY b.BookID, b.Title, b.ISBN;
GO

-- Create a view for overdue loans
CREATE VIEW OverdueLoans AS
SELECT l.LoanID, b.Title, m.FirstName, m.LastName, m.Email, 
       l.CheckoutDate, l.DueDate, 
       DATEDIFF(DAY, l.DueDate, GETDATE()) AS DaysOverdue
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Members m ON l.MemberID = m.MemberID
WHERE l.ReturnDate IS NULL AND l.DueDate < GETDATE();
GO

-- Create a trigger to update book status when borrowed
CREATE TRIGGER AfterLoanInsert
ON Loans
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE b
    SET Status = 'Borrowed'
    FROM Books b
    INNER JOIN inserted i ON b.BookID = i.BookID;
END;
GO

-- Create a trigger to update book status when returned
CREATE TRIGGER AfterLoanReturn
ON Loans
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(ReturnDate)
    BEGIN
        UPDATE b
        SET Status = 'Available'
        FROM Books b
        INNER JOIN inserted i ON b.BookID = i.BookID
        WHERE i.ReturnDate IS NOT NULL AND i.Status = 'Returned';
    END
END;
GO

-- Create a trigger to auto-calculate fines for overdue books
CREATE TRIGGER CalculateOverdueFine
ON Loans
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DaysLate INT
    DECLARE @FineAmount DECIMAL(10,2)
    
    IF UPDATE(ReturnDate)
    BEGIN
        INSERT INTO Fines (LoanID, MemberID, Amount, IssuedDate)
        SELECT 
            i.LoanID, 
            i.MemberID, 
            DATEDIFF(DAY, i.DueDate, i.ReturnDate) * 1.00, -- $1 per day late
            GETDATE()
        FROM inserted i
        WHERE i.ReturnDate IS NOT NULL 
          AND i.ReturnDate > i.DueDate
          AND NOT EXISTS (SELECT 1 FROM Fines WHERE LoanID = i.LoanID);
    END
END;
GO
