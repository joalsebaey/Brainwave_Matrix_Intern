-- ENHANCEMENT 5: E-BOOK SUPPORT
-- ===================================================

-- Create table for digital resource types
CREATE TABLE DigitalResourceTypes (
    ResourceTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX)
);

-- Insert basic digital resource types
INSERT INTO DigitalResourceTypes (TypeName, Description)
VALUES 
('E-Book', 'Electronic version of a printed book'),
('Audiobook', 'Audio recording of a book or other work'),
('Article', 'Digital article from periodicals'),
('Video', 'Educational video resources');

-- Create table for digital resources
CREATE TABLE DigitalResources (
    ResourceID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NULL, -- Can be linked to a physical book or standalone
    Title NVARCHAR(255) NOT NULL,
    ResourceTypeID INT NOT NULL,
    FilePath NVARCHAR(MAX) NOT NULL,
    FileSize BIGINT,
    Format NVARCHAR(20) NOT NULL, -- PDF, EPUB, MP3, etc.
    DurationMinutes INT NULL, -- For audio/video
    UploadDate DATETIME DEFAULT GETDATE(),
    AccessCount INT DEFAULT 0,
    CONSTRAINT FK_DigitalResources_Books FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE SET NULL,
    CONSTRAINT FK_DigitalResources_Types FOREIGN KEY (ResourceTypeID) REFERENCES DigitalResourceTypes(ResourceTypeID)
);

-- Create table for digital loans
CREATE TABLE DigitalLoans (
    DigitalLoanID INT IDENTITY(1,1) PRIMARY KEY,
    ResourceID INT NOT NULL,
    MemberID INT NOT NULL,
    CheckoutDate DATETIME NOT NULL DEFAULT GETDATE(),
    ExpiryDate DATETIME NOT NULL, -- When access should expire
    IsReturned BIT DEFAULT 0, -- Early return is possible
    CONSTRAINT FK_DigitalLoans_Resources FOREIGN KEY (ResourceID) REFERENCES DigitalResources(ResourceID),
    CONSTRAINT FK_DigitalLoans_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

-- ===================================================
-- ENHANCEMENT 6: BOOK REVIEW SYSTEM
-- ===================================================

CREATE TABLE BookReviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    Rating TINYINT NOT NULL, -- 1-5 stars
    ReviewText NVARCHAR(MAX),
    ReviewDate DATETIME DEFAULT GETDATE(),
    IsApproved BIT DEFAULT 0, -- Requires moderator approval
    CONSTRAINT CHK_BookReviews_Rating CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT FK_BookReviews_Books FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE CASCADE,
    CONSTRAINT FK_BookReviews_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE,
    CONSTRAINT UQ_BookReviews_Member_Book UNIQUE (MemberID, BookID) -- One review per book per member
);

-- View for book ratings summary
CREATE VIEW BookRatings AS
SELECT 
    b.BookID,
    b.Title,
    COUNT(br.ReviewID) AS ReviewCount,
    AVG(CAST(br.Rating AS FLOAT)) AS AverageRating,
    (SELECT COUNT(*) FROM BookReviews WHERE BookID = b.BookID AND Rating = 5) AS FiveStarCount,
    (SELECT COUNT(*) FROM BookReviews WHERE BookID = b.BookID AND Rating = 4) AS FourStarCount,
    (SELECT COUNT(*) FROM BookReviews WHERE BookID = b.BookID AND Rating = 3) AS ThreeStarCount,
    (SELECT COUNT(*) FROM BookReviews WHERE BookID = b.BookID AND Rating = 2) AS TwoStarCount,
    (SELECT COUNT(*) FROM BookReviews WHERE BookID = b.BookID AND Rating = 1) AS OneStarCount
FROM 
    Books b
LEFT JOIN 
    BookReviews br ON b.BookID = br.BookID AND br.IsApproved = 1
GROUP BY 
    b.BookID, b.Title;
GO

-- ===================================================
-- ENHANCEMENT 7: IMPROVED FINE MANAGEMENT
-- ===================================================

-- Add payment tracking table
CREATE TABLE FinePayments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    FineID INT NOT NULL,
    PaymentAmount DECIMAL(10, 2) NOT NULL,
    PaymentMethod NVARCHAR(20) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    ReceivedBy INT NULL, -- Staff who received payment
    TransactionReference NVARCHAR(100), -- For credit card or electronic payments
    Notes NVARCHAR(MAX),
    CONSTRAINT FK_FinePayments_Fines FOREIGN KEY (FineID) REFERENCES Fines(FineID),
    CONSTRAINT FK_FinePayments_Staff FOREIGN KEY (ReceivedBy) REFERENCES Staff(StaffID) ON DELETE SET NULL
);

-- Updated stored procedure to handle partial payments
CREATE OR ALTER PROCEDURE PayFine
    @FineID INT,
    @PaymentAmount DECIMAL(10, 2),
    @PaymentMethod NVARCHAR(20),
    @StaffID INT,
    @TransactionReference NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CurrentAmount DECIMAL(10, 2);
        DECLARE @PaidAmount DECIMAL(10, 2);
        DECLARE @RemainingAmount DECIMAL(10, 2);
        
        -- Get current fine amounts
        SELECT @CurrentAmount = Amount,
               @PaidAmount = ISNULL((
                   SELECT SUM(PaymentAmount) 
                   FROM FinePayments 
                   WHERE FineID = @FineID
               ), 0)
        FROM Fines
        WHERE FineID = @FineID AND Status != 'Paid';
        
        IF @CurrentAmount IS NULL
        BEGIN
            RAISERROR('Invalid fine ID or fine already fully paid.', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Calculate remaining amount
        SET @RemainingAmount = @CurrentAmount - @PaidAmount;
        
        -- Check if payment amount is valid
        IF @PaymentAmount <= 0 OR @PaymentAmount > @RemainingAmount
        BEGIN
            RAISERROR('Invalid payment amount. Amount must be between 0 and %f.', 16, 1, @RemainingAmount);
            ROLLBACK;
            RETURN;
        END
        
        -- Record payment
        INSERT INTO FinePayments (
            FineID, 
            PaymentAmount, 
            PaymentMethod, 
            ReceivedBy, 
            TransactionReference
        )
        VALUES (
            @FineID, 
            @PaymentAmount, 
            @PaymentMethod, 
            @StaffID, 
            @TransactionReference
        );
        
        -- Update fine status if fully paid
        IF @PaymentAmount >= @RemainingAmount
        BEGIN
            UPDATE Fines
            SET Status = 'Paid',
                PaymentDate = GETDATE()
            WHERE FineID = @FineID;
        END
        
        COMMIT;
        
        -- Return payment info
        SELECT 
            'Payment successful' AS Result,
            @PaymentAmount AS AmountPaid,
            (@CurrentAmount - @PaidAmount - @PaymentAmount) AS RemainingBalance,
            CASE 
                WHEN (@CurrentAmount - @PaidAmount - @PaymentAmount) <= 0 THEN 'Fully Paid'
                ELSE 'Partially Paid'
            END AS PaymentStatus;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO
