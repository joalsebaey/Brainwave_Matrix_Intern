-- Insert sample authors
INSERT INTO Authors (FirstName, LastName, Biography, DateOfBirth, Nationality)
VALUES 
('J.K.', 'Rowling', 'British author best known for the Harry Potter series', '1965-07-31', 'British'),
('George R.R.', 'Martin', 'American novelist known for A Song of Ice and Fire', '1948-09-20', 'American'),
('Jane', 'Austen', 'English novelist known for Pride and Prejudice', '1775-12-16', 'English'),
('Stephen', 'King', 'American author of horror and supernatural fiction', '1947-09-21', 'American'),
('Agatha', 'Christie', 'English writer known for detective novels', '1890-09-15', 'English');
GO

-- Insert sample publishers
INSERT INTO Publishers (Name, Address, Phone, Email, Website)
VALUES 
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com'),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com', 'www.macmillan.com'),
('Hachette Book Group', '1290 Avenue of the Americas, New York, NY 10104', '212-364-1100', 'info@hbgusa.com', 'www.hachettebookgroup.com');
GO

-- Insert sample categories
INSERT INTO Categories (Name, Description)
VALUES 
('Fiction', 'Fictional literature including novels, short stories, etc.'),
('Non-Fiction', 'Literature based on facts, real events, and real people'),
('Science Fiction', 'Fiction based on imaginative concepts like futuristic science and technology'),
('Fantasy', 'Fiction featuring magical and supernatural elements'),
('Mystery', 'Fiction dealing with the solution of a crime or puzzle'),
('Biography', 'Non-fictional account of a person''s life'),
('History', 'Non-fiction about past events'),
('Self-Help', 'Books on personal development'),
('Children''s', 'Books for children'),
('Young Adult', 'Books for teenagers and young adults');
GO

-- Insert sample books
INSERT INTO Books (ISBN, Title, PublisherID, PublicationDate, Edition, Language, Pages, Description, ShelfLocation)
VALUES 
('9780747532743', 'Harry Potter and the Philosopher''s Stone', 1, '1997-06-26', '1st', 'English', 223, 'The first novel in the Harry Potter series', 'A1-S1'),
('9780547928227', 'The Hobbit', 2, '1937-09-21', '75th Anniversary', 'English', 300, 'Fantasy novel by J.R.R. Tolkien', 'A2-S2'),
('9780141439518', 'Pride and Prejudice', 1, '1813-01-28', 'Penguin Classics', 'English', 432, 'Novel by Jane Austen', 'B1-S3'),
('9780307743657', 'The Shining', 3, '1977-01-28', 'Reprint', 'English', 688, 'Horror novel by Stephen King', 'C1-S4'),
('9780062073495', 'Murder on the Orient Express', 2, '1934-01-01', 'Reprint', 'English', 256, 'Detective novel by Agatha Christie', 'D1-S5');
GO

-- Associate books with authors
INSERT INTO BookAuthors (BookID, AuthorID)
VALUES 
(1, 1), -- Harry Potter - J.K. Rowling
(3, 3), -- Pride and Prejudice - Jane Austen
(4, 4), -- The Shining - Stephen King
(5, 5); -- Murder on the Orient Express - Agatha Christie
GO

-- Associate books with categories
INSERT INTO BookCategories (BookID, CategoryID)
VALUES 
(1, 4), -- Harry Potter - Fantasy
(1, 10), -- Harry Potter - Young Adult
(3, 1), -- Pride and Prejudice - Fiction
(4, 1), -- The Shining - Fiction
(4, 5), -- The Shining - Mystery
(5, 1), -- Murder on the Orient Express - Fiction
(5, 5); -- Murder on the Orient Express - Mystery
GO

-- Insert sample members
INSERT INTO Members (FirstName, LastName, Email, Phone, Address, DateOfBirth, MembershipDate, MembershipExpiry)
VALUES 
('John', 'Smith', 'john.smith@email.com', '555-123-4567', '123 Main St, Anytown, AN 12345', '1985-04-15', '2023-01-01', '2024-01-01'),
('Emily', 'Johnson', 'emily.j@email.com', '555-234-5678', '456 Oak Ave, Somewhere, SW 23456', '1990-07-22', '2023-02-15', '2024-02-15'),
('Michael', 'Williams', 'mwilliams@email.com', '555-345-6789', '789 Pine Rd, Nowhere, NW 34567', '1978-11-30', '2023-03-10', '2024-03-10'),
('Sarah', 'Brown', 'sarahb@email.com', '555-456-7890', '101 Elm Blvd, Anywhere, AW 45678', '1995-02-18', '2023-04-05', '2024-04-05'),
('David', 'Jones', 'djones@email.com', '555-567-8901', '202 Maple Dr, Elsewhere, EW 56789', '1982-09-03', '2023-05-20', '2024-05-20');
GO

-- Insert sample staff
INSERT INTO Staff (FirstName, LastName, Email, Phone, Position, HireDate, Username, PasswordHash)
VALUES 
('Robert', 'Anderson', 'randerson@library.com', '555-987-6543', 'Head Librarian', '2018-06-01', 'randerson', 'hashed_password_1'),
('Jennifer', 'Thomas', 'jthomas@library.com', '555-876-5432', 'Librarian', '2019-03-15', 'jthomas', 'hashed_password_2'),
('William', 'Martinez', 'wmartinez@library.com', '555-765-4321', 'Assistant Librarian', '2020-01-10', 'wmartinez', 'hashed_password_3'),
('Elizabeth', 'Taylor', 'etaylor@library.com', '555-654-3210', 'Library Technician', '2021-07-01', 'etaylor', 'hashed_password_4'),
('Richard', 'Garcia', 'rgarcia@library.com', '555-543-2109', 'Library Assistant', '2022-02-15', 'rgarcia', 'hashed_password_5');
GO

-- Insert book copies
INSERT INTO BookCopies (BookID, AcquisitionDate, Price, Condition)
VALUES 
(1, '2020-01-15', 15.99, 'Good'),
(1, '2021-03-10', 17.99, 'New'),
(2, '2020-02-20', 12.99, 'Good'),
(3, '2020-03-25', 9.99, 'Fair'),
(3, '2021-05-15', 11.99, 'New'),
(4, '2020-04-10', 14.99, 'Good'),
(5, '2020-05-05', 13.99, 'Good'),
(5, '2021-06-20', 15.99, 'New');
GO

-- Insert sample loans
INSERT INTO Loans (BookID, MemberID, StaffID, CheckoutDate, DueDate, ReturnDate, Status)
VALUES 
(1, 1, 1, '2023-06-01 10:30:00', '2023-06-15 10:30:00', '2023-06-14 15:45:00', 'Returned'),
(3, 2, 2, '2023-06-05 14:15:00', '2023-06-19 14:15:00', NULL, 'Borrowed'),
(4, 3, 1, '2023-06-10 11:00:00', '2023-06-24 11:00:00', '2023-06-30 09:30:00', 'Returned'),
(5, 4, 3, '2023-06-15 16:30:00', '2023-06-29 16:30:00', NULL, 'Overdue');
GO

-- Insert sample reservations
INSERT INTO Reservations (BookID, MemberID, ReservationDate, ExpiryDate, Status)
VALUES 
(2, 5, '2023-06-20 09:45:00', '2023-06-27 09:45:00', 'Pending'),
(1, 3, '2023-06-25 13:20:00', '2023-07-02 13:20:00', 'Fulfilled');
GO
