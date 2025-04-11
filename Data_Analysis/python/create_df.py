import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from datetime import datetime
import io
from collections import Counter

# Set the style for our visualizations
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("viridis")

# Helper function to simulate loading data from SQL database
def create_dataframes_from_data():
    """
    Create pandas DataFrames simulating the SQL tables based on the provided schema and sample data
    """
    # Authors table
    authors_data = [
        (1, 'J.K.', 'Rowling', 'British author best known for the Harry Potter series', '1965-07-31', 'British'),
        (2, 'George R.R.', 'Martin', 'American novelist known for A Song of Ice and Fire', '1948-09-20', 'American'),
        (3, 'Jane', 'Austen', 'English novelist known for Pride and Prejudice', '1775-12-16', 'English'),
        (4, 'Stephen', 'King', 'American author of horror and supernatural fiction', '1947-09-21', 'American'),
        (5, 'Agatha', 'Christie', 'English writer known for detective novels', '1890-09-15', 'English')
    ]
    authors = pd.DataFrame(authors_data, columns=['AuthorID', 'FirstName', 'LastName', 'Biography', 'DateOfBirth', 'Nationality'])
    
    # Publishers table
    publishers_data = [
        (1, 'Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
        (2, 'HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com'),
        (3, 'Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com'),
        (4, 'Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com', 'www.macmillan.com'),
        (5, 'Hachette Book Group', '1290 Avenue of the Americas, New York, NY 10104', '212-364-1100', 'info@hbgusa.com', 'www.hachettebookgroup.com')
    ]
    publishers = pd.DataFrame(publishers_data, columns=['PublisherID', 'Name', 'Address', 'Phone', 'Email', 'Website'])
    
    # Categories table
    categories_data = [
        (1, 'Fiction', 'Fictional literature including novels, short stories, etc.'),
        (2, 'Non-Fiction', 'Literature based on facts, real events, and real people'),
        (3, 'Science Fiction', 'Fiction based on imaginative concepts like futuristic science and technology'),
        (4, 'Fantasy', 'Fiction featuring magical and supernatural elements'),
        (5, 'Mystery', 'Fiction dealing with the solution of a crime or puzzle'),
        (6, 'Biography', 'Non-fictional account of a person\'s life'),
        (7, 'History', 'Non-fiction about past events'),
        (8, 'Self-Help', 'Books on personal development'),
        (9, 'Children\'s', 'Books for children'),
        (10, 'Young Adult', 'Books for teenagers and young adults')
    ]
    categories = pd.DataFrame(categories_data, columns=['CategoryID', 'Name', 'Description'])
    
    # Books table
    books_data = [
        (1, '9780747532743', 'Harry Potter and the Philosopher\'s Stone', 1, '1997-06-26', '1st', 'English', 223, 'The first novel in the Harry Potter series', 'A1-S1'),
        (2, '9780547928227', 'The Hobbit', 2, '1937-09-21', '75th Anniversary', 'English', 300, 'Fantasy novel by J.R.R. Tolkien', 'A2-S2'),
        (3, '9780141439518', 'Pride and Prejudice', 1, '1813-01-28', 'Penguin Classics', 'English', 432, 'Novel by Jane Austen', 'B1-S3'),
        (4, '9780307743657', 'The Shining', 3, '1977-01-28', 'Reprint', 'English', 688, 'Horror novel by Stephen King', 'C1-S4'),
        (5, '9780062073495', 'Murder on the Orient Express', 2, '1934-01-01', 'Reprint', 'English', 256, 'Detective novel by Agatha Christie', 'D1-S5')
    ]
    books = pd.DataFrame(books_data, columns=['BookID', 'ISBN', 'Title', 'PublisherID', 'PublicationDate', 'Edition', 'Language', 'Pages', 'Description', 'ShelfLocation'])
    
    # BookAuthors table
    book_authors_data = [
        (1, 1),  # Harry Potter - J.K. Rowling
        (3, 3),  # Pride and Prejudice - Jane Austen
        (4, 4),  # The Shining - Stephen King
        (5, 5)   # Murder on the Orient Express - Agatha Christie
    ]
    book_authors = pd.DataFrame(book_authors_data, columns=['BookID', 'AuthorID'])
    
    # BookCategories table
    book_categories_data = [
        (1, 4),   # Harry Potter - Fantasy
        (1, 10),  # Harry Potter - Young Adult
        (3, 1),   # Pride and Prejudice - Fiction
        (4, 1),   # The Shining - Fiction
        (4, 5),   # The Shining - Mystery
        (5, 1),   # Murder on the Orient Express - Fiction
        (5, 5)    # Murder on the Orient Express - Mystery
    ]
    book_categories = pd.DataFrame(book_categories_data, columns=['BookID', 'CategoryID'])
    
    # Members table
    members_data = [
        (1, 'John', 'Smith', 'john.smith@email.com', '555-123-4567', '123 Main St, Anytown, AN 12345', '1985-04-15', '2023-01-01', '2024-01-01', 'Active'),
        (2, 'Emily', 'Johnson', 'emily.j@email.com', '555-234-5678', '456 Oak Ave, Somewhere, SW 23456', '1990-07-22', '2023-02-15', '2024-02-15', 'Active'),
        (3, 'Michael', 'Williams', 'mwilliams@email.com', '555-345-6789', '789 Pine Rd, Nowhere, NW 34567', '1978-11-30', '2023-03-10', '2024-03-10', 'Active'),
        (4, 'Sarah', 'Brown', 'sarahb@email.com', '555-456-7890', '101 Elm Blvd, Anywhere, AW 45678', '1995-02-18', '2023-04-05', '2024-04-05', 'Active'),
        (5, 'David', 'Jones', 'djones@email.com', '555-567-8901', '202 Maple Dr, Elsewhere, EW 56789', '1982-09-03', '2023-05-20', '2024-05-20', 'Active')
    ]
    members = pd.DataFrame(members_data, columns=['MemberID', 'FirstName', 'LastName', 'Email', 'Phone', 'Address', 'DateOfBirth', 'MembershipDate', 'MembershipExpiry', 'MembershipStatus'])
    
    # Staff table
    staff_data = [
        (1, 'Robert', 'Anderson', 'randerson@library.com', '555-987-6543', 'Head Librarian', '2018-06-01', 'randerson', 'hashed_password_1'),
        (2, 'Jennifer', 'Thomas', 'jthomas@library.com', '555-876-5432', 'Librarian', '2019-03-15', 'jthomas', 'hashed_password_2'),
        (3, 'William', 'Martinez', 'wmartinez@library.com', '555-765-4321', 'Assistant Librarian', '2020-01-10', 'wmartinez', 'hashed_password_3'),
        (4, 'Elizabeth', 'Taylor', 'etaylor@library.com', '555-654-3210', 'Library Technician', '2021-07-01', 'etaylor', 'hashed_password_4'),
        (5, 'Richard', 'Garcia', 'rgarcia@library.com', '555-543-2109', 'Library Assistant', '2022-02-15', 'rgarcia', 'hashed_password_5')
    ]
    staff = pd.DataFrame(staff_data, columns=['StaffID', 'FirstName', 'LastName', 'Email', 'Phone', 'Position', 'HireDate', 'Username', 'PasswordHash'])
    
    # BookCopies table
    book_copies_data = [
        (1, 1, '2020-01-15', 15.99, 'Good', 'Available'),
        (2, 1, '2021-03-10', 17.99, 'New', 'Available'),
        (3, 2, '2020-02-20', 12.99, 'Good', 'Available'),
        (4, 3, '2020-03-25', 9.99, 'Fair', 'Available'),
        (5, 3, '2021-05-15', 11.99, 'New', 'Available'),
        (6, 4, '2020-04-10', 14.99, 'Good', 'Available'),
        (7, 5, '2020-05-05', 13.99, 'Good', 'Available'),
        (8, 5, '2021-06-20', 15.99, 'New', 'Available')
    ]
    book_copies = pd.DataFrame(book_copies_data, columns=['CopyID', 'BookID', 'AcquisitionDate', 'Price', 'Condition', 'Status'])
    
    # Loans table
    loans_data = [
        (1, 1, 1, 1, '2023-06-01 10:30:00', '2023-06-15 10:30:00', '2023-06-14 15:45:00', 'Returned'),
        (2, 3, 2, 2, '2023-06-05 14:15:00', '2023-06-19 14:15:00', None, 'Borrowed'),
        (3, 4, 3, 1, '2023-06-10 11:00:00', '2023-06-24 11:00:00', '2023-06-30 09:30:00', 'Returned'),
        (4, 5, 4, 3, '2023-06-15 16:30:00', '2023-06-29 16:30:00', None, 'Overdue'),
        # Add more simulated loans for better analytics
        (5, 1, 2, 1, '2023-07-01 09:30:00', '2023-07-15 09:30:00', '2023-07-12 14:00:00', 'Returned'),
        (6, 2, 3, 2, '2023-07-05 10:45:00', '2023-07-19 10:45:00', '2023-07-17 16:30:00', 'Returned'),
        (7, 3, 4, 1, '2023-07-10 11:30:00', '2023-07-24 11:30:00', None, 'Borrowed'),
        (8, 4, 5, 3, '2023-07-15 14:00:00', '2023-07-29 14:00:00', None, 'Borrowed'),
        (9, 5, 1, 2, '2023-07-20 15:45:00', '2023-08-03 15:45:00', '2023-07-30 10:15:00', 'Returned'),
        (10, 1, 3, 1, '2023-08-01 10:00:00', '2023-08-15 10:00:00', '2023-08-14 11:45:00', 'Returned'),
        (11, 2, 4, 2, '2023-08-05 13:30:00', '2023-08-19 13:30:00', '2023-08-20 09:30:00', 'Returned'),
        (12, 3, 5, 3, '2023-08-10 14:15:00', '2023-08-24 14:15:00', '2023-08-22 16:00:00', 'Returned'),
        (13, 4, 1, 1, '2023-08-15 11:00:00', '2023-08-29 11:00:00', None, 'Overdue'),
        (14, 5, 2, 2, '2023-08-20 16:30:00', '2023-09-03 16:30:00', '2023-09-01 14:45:00', 'Returned'),
        (15, 1, 4, 3, '2023-09-01 09:45:00', '2023-09-15 09:45:00', '2023-09-12 10:30:00', 'Returned'),
        (16, 2, 5, 1, '2023-09-05 11:15:00', '2023-09-19 11:15:00', '2023-09-18 15:00:00', 'Returned'),
        (17, 3, 1, 2, '2023-09-10 14:30:00', '2023-09-24 14:30:00', '2023-09-23 11:30:00', 'Returned'),
        (18, 4, 2, 3, '2023-09-15 13:00:00', '2023-09-29 13:00:00', None, 'Borrowed'),
        (19, 5, 3, 1, '2023-09-20 15:30:00', '2023-10-04 15:30:00', '2023-10-03 10:45:00', 'Returned'),
        (20, 1, 5, 2, '2023-10-01 10:15:00', '2023-10-15 10:15:00', None, 'Borrowed')
    ]
    loans = pd.DataFrame(loans_data, columns=['LoanID', 'BookID', 'MemberID', 'StaffID', 'CheckoutDate', 'DueDate', 'ReturnDate', 'Status'])
    
    # Reservations table
    reservations_data = [
        (1, 2, 5, '2023-06-20 09:45:00', '2023-06-27 09:45:00', 'Pending'),
        (2, 1, 3, '2023-06-25 13:20:00', '2023-07-02 13:20:00', 'Fulfilled'),
        (3, 3, 1, '2023-07-05 11:30:00', '2023-07-12 11:30:00', 'Pending'),
        (4, 4, 2, '2023-07-10 15:45:00', '2023-07-17 15:45:00', 'Cancelled'),
        (5, 5, 4, '2023-07-15 14:00:00', '2023-07-22 14:00:00', 'Fulfilled')
    ]
    reservations = pd.DataFrame(reservations_data, columns=['ReservationID', 'BookID', 'MemberID', 'ReservationDate', 'ExpiryDate', 'Status'])
    
    # Fines table
    fines_data = [
        (1, 3, 3, 6.00, '2023-06-30 10:00:00', '2023-07-05 11:30:00', 'Paid'),
        (2, 4, 4, 10.00, '2023-07-10 14:15:00', None, 'Pending'),
        (3, 11, 4, 1.00, '2023-08-20 10:00:00', '2023-08-25 11:45:00', 'Paid'),
        (4, 13, 1, 12.00, '2023-09-05 09:30:00', None, 'Pending')
    ]
    fines = pd.DataFrame(fines_data, columns=['FineID', 'LoanID', 'MemberID', 'Amount', 'IssuedDate', 'PaymentDate', 'Status'])
    
    # Convert string dates to datetime objects
    for df in [authors, books, members, staff, book_copies, loans, reservations, fines]:
        for col in df.columns:
            if 'Date' in col or col == 'DateOfBirth' or col == 'MembershipExpiry':
                if col in df.columns:
                    df[col] = pd.to_datetime(df[col], errors='ignore')
    
    return {
        'authors': authors,
        'publishers': publishers,
        'categories': categories,
        'books': books,
        'book_authors': book_authors,
        'book_categories': book_categories,
        'members': members,
        'staff': staff,
        'book_copies': book_copies,
        'loans': loans,
        'reservations': reservations,
        'fines': fines
    }

# Load data
data = create_dataframes_from_data()
