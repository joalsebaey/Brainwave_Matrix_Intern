-- Stored Procedure: Get Member Loan History (FIXED)
CREATE PROCEDURE GetMemberLoanHistory
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        l.LoanID, 
        b.Title, 
        b.ISBN, 
        a.FirstName + ' ' + a.LastName AS Author,
        l.CheckoutDate, 
        l.DueDate, 
        l.ReturnDate, 
        l.Status,
        CASE 
            WHEN l.ReturnDate IS NULL AND l.DueDate < GETDATE() 
            THEN DATEDIFF(DAY, l.DueDate, GETDATE()) 
            ELSE 0 
        END AS DaysOverdue,
        ISNULL(f.Amount, 0) AS FineAmount,
        ISNULL(f.Status, 'None') AS FineStatus
    FROM Loans l
    JOIN Books b ON l.BookID = b.BookID
    JOIN BookAuthors ba ON b.BookID = ba.BookID
    JOIN Authors a ON ba.AuthorID = a.AuthorID
    LEFT JOIN Fines f ON l.LoanID = f.LoanID
    WHERE l.MemberID = @MemberID
    ORDER BY l.CheckoutDate DESC;
END
GO

-- Stored Procedure: Generate Overdue Notices
CREATE PROCEDURE GenerateOverdueNotices
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Update loan status for overdue books
    UPDATE Loans
    SET Status = 'Overdue'
    WHERE ReturnDate IS NULL 
      AND DueDate < GETDATE()
      AND Status = 'Borrowed';
    
    -- Select overdue loans for notification
    SELECT 
        m.MemberID,
        m.FirstName + ' ' + m.LastName AS MemberName,
        m.Email,
        m.Phone,
        b.Title,
        l.CheckoutDate,
        l.DueDate,
        DATEDIFF(DAY, l.DueDate, GETDATE()) AS DaysOverdue,
        DATEDIFF(DAY, l.DueDate, GETDATE()) * 1.00 AS EstimatedFine -- $1 per day
    FROM Loans l
    JOIN Books b ON l.BookID = b.BookID
    JOIN Members m ON l.MemberID = m.MemberID
    WHERE l.ReturnDate IS NULL 
      AND l.DueDate < GETDATE()
    ORDER BY m.MemberID, l.DueDate;
END
GO

-- Stored Procedure: Pay Fine
CREATE PROCEDURE PayFine
    @FineID INT,
    @PaymentAmount DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentAmount DECIMAL(10, 2);
    
    -- Get current fine amount
    SELECT @CurrentAmount = Amount
    FROM Fines
    WHERE FineID = @FineID AND Status = 'Pending';
    
    IF @CurrentAmount IS NULL
    BEGIN
        RAISERROR('Invalid fine ID or fine already paid.', 16, 1);
        RETURN;
    END
    
    -- Check if payment amount is correct
    IF @PaymentAmount <> @CurrentAmount
    BEGIN
        RAISERROR('Payment amount does not match fine amount.', 16, 1);
        RETURN;
    END
    
    -- Update fine status
    UPDATE Fines
    SET Status = 'Paid',
        PaymentDate = GETDATE()
    WHERE FineID = @FineID;
    
    PRINT 'Fine payment of $' + CAST(@PaymentAmount AS VARCHAR) + ' has been processed successfully.';
END
GO

-- Stored Procedure: Generate Library Statistics Report
CREATE PROCEDURE GenerateLibraryStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Collection statistics
    SELECT
        (SELECT COUNT(*) FROM Books) AS TotalBooks,
        (SELECT COUNT(*) FROM BookCopies) AS TotalCopies,
        (SELECT COUNT(*) FROM BookCopies WHERE Status = 'Available') AS AvailableCopies,
        (SELECT COUNT(*) FROM Categories) AS TotalCategories,
        (SELECT COUNT(*) FROM Authors) AS TotalAuthors;
    
    -- Membership statistics
    SELECT
        (SELECT COUNT(*) FROM Members) AS TotalMembers,
        (SELECT COUNT(*) FROM Members WHERE MembershipStatus = 'Active') AS ActiveMembers,
        (SELECT COUNT(*) FROM Members WHERE MembershipStatus = 'Expired') AS ExpiredMembers,
        (SELECT COUNT(*) FROM Members WHERE MembershipStatus = 'Suspended') AS SuspendedMembers;
    
    -- Loan statistics
    SELECT
        (SELECT COUNT(*) FROM Loans) AS TotalLoans,
        (SELECT COUNT(*) FROM Loans WHERE Status = 'Borrowed') AS CurrentLoans,
        (SELECT COUNT(*) FROM Loans WHERE Status = 'Overdue') AS OverdueLoans,
        (SELECT COUNT(*) FROM Loans WHERE ReturnDate BETWEEN DATEADD(DAY, -30, GETDATE()) AND GETDATE()) AS ReturnedLast30Days;
    
    -- Fine statistics
    SELECT
        (SELECT COUNT(*) FROM Fines) AS TotalFines,
        (SELECT COUNT(*) FROM Fines WHERE Status = 'Pending') AS PendingFines,
        (SELECT SUM(Amount) FROM Fines WHERE Status = 'Pending') AS PendingFinesAmount,
        (SELECT SUM(Amount) FROM Fines WHERE Status = 'Paid' AND PaymentDate BETWEEN DATEADD(DAY, -30, GETDATE()) AND GETDATE()) AS CollectedLast30Days;
    
    -- Top 5 borrowed books
    SELECT TOP 5
        b.Title,
        COUNT(l.LoanID) AS BorrowCount
    FROM Books b
    JOIN Loans l ON b.BookID = l.BookID
    GROUP BY b.Title
    ORDER BY BorrowCount DESC;
    
    -- Top 5 active members
    SELECT TOP 5
        m.FirstName + ' ' + m.LastName AS MemberName,
        COUNT(l.LoanID) AS LoanCount
    FROM Members m
    JOIN Loans l ON m.MemberID = l.MemberID
    GROUP BY m.MemberID, m.FirstName, m.LastName
    ORDER BY LoanCount DESC;
    
    -- Most popular categories
    SELECT TOP 5
        c.Name AS CategoryName,
        COUNT(l.LoanID) AS LoanCount
    FROM Categories c
    JOIN BookCategories bc ON c.CategoryID = bc.CategoryID
    JOIN Books b ON bc.BookID = b.BookID
    JOIN Loans l ON b.BookID = l.BookID
    GROUP BY c.CategoryID, c.Name
    ORDER BY LoanCount DESC;
END
GO
