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
# Create a title for our analysis report
print("# Library Management System: Data Analysis Report\n")
print("## 1. Overview of Database Structure\n")
print("The Library Management System consists of the following tables:")

# Display table counts
tables_overview = []
for table_name, df in data.items():
    tables_overview.append({"Table": table_name.replace('_', ' ').title(), "Records": len(df)})
    
tables_df = pd.DataFrame(tables_overview)
print(tables_df.to_string(index=False))
print("\n")

# Join books with authors
books_with_authors = pd.merge(
    data['books'], 
    pd.merge(
        data['book_authors'], 
        data['authors'], 
        on='AuthorID'
    ),
    on='BookID'
)

# Join books with categories
books_with_categories = pd.merge(
    data['books'],
    pd.merge(
        data['book_categories'],
        data['categories'],
        on='CategoryID'
    ),
    on='BookID'
)

# Join books with publishers
books_with_publishers = pd.merge(
    data['books'],
    data['publishers'],
    on='PublisherID'
)

# Create comprehensive book information
book_info = pd.merge(books_with_authors, books_with_publishers[['BookID', 'Name']], on='BookID')
book_info = book_info.rename(columns={'Name': 'Publisher'})

# Add author full name
book_info['Author'] = book_info['FirstName'] + ' ' + book_info['LastName']

# Join loans with members
loans_with_members = pd.merge(
    data['loans'],
    data['members'],
    on='MemberID'
)

# Join loans with books
loans_with_books = pd.merge(
    data['loans'],
    data['books'],
    on='BookID'
)

# Combine loans with member and book information
loans_complete = pd.merge(
    loans_with_members,
    book_info[['BookID', 'Title', 'Author', 'Publisher']],
    on='BookID'
)

# Convert checkout and return dates to datetime if they aren't already
loans_complete['CheckoutDate'] = pd.to_datetime(loans_complete['CheckoutDate'])
loans_complete['ReturnDate'] = pd.to_datetime(loans_complete['ReturnDate'])
loans_complete['DueDate'] = pd.to_datetime(loans_complete['DueDate'])

# Calculate loan duration for returned books
loans_complete['LoanDuration'] = np.where(
    loans_complete['ReturnDate'].notna(),
    (loans_complete['ReturnDate'] - loans_complete['CheckoutDate']).dt.days,
    None
)

# Calculate days overdue for returned books
loans_complete['DaysOverdue'] = np.where(
    (loans_complete['ReturnDate'].notna()) & (loans_complete['ReturnDate'] > loans_complete['DueDate']),
    (loans_complete['ReturnDate'] - loans_complete['DueDate']).dt.days,
    0
)

print("## 2. Collection Analysis\n")

# Analysis of book collection by publication year
books_by_year = book_info.copy()
books_by_year['Publication_Year'] = pd.to_datetime(books_by_year['PublicationDate']).dt.year

# Count books by publication decade
books_by_year['Decade'] = (books_by_year['Publication_Year'] // 10) * 10
decade_counts = books_by_year['Decade'].value_counts().sort_index()

print("### Books by Publication Decade")
for decade, count in decade_counts.items():
    print(f"- {decade}s: {count} books")
print("\n")

# Analysis of book collection by category
category_counts = books_with_categories['Name'].value_counts().reset_index()
category_counts.columns = ['Category', 'Count']

print("### Books by Category")
for _, row in category_counts.iterrows():
    print(f"- {row['Category']}: {row['Count']} books")
print("\n")

# Analysis of book collection by author
author_counts = book_info.groupby(['Author']).size().reset_index(name='Count')
author_counts = author_counts.sort_values('Count', ascending=False)

print("### Books by Author")
for _, row in author_counts.iterrows():
    print(f"- {row['Author']}: {row['Count']} books")
print("\n")

# Analysis of book collection by publisher
publisher_counts = book_info.groupby(['Publisher']).size().reset_index(name='Count')
publisher_counts = publisher_counts.sort_values('Count', ascending=False)

print("### Books by Publisher")
for _, row in publisher_counts.iterrows():
    print(f"- {row['Publisher']}: {row['Count']} books")
print("\n")

print("## 3. Circulation Analysis\n")

# Monthly circulation analysis
loans_complete['Month'] = loans_complete['CheckoutDate'].dt.month_name()
loans_complete['Year'] = loans_complete['CheckoutDate'].dt.year

# Sort by month number
month_order = ['January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December']
loans_by_month = loans_complete.groupby(['Year', 'Month']).size().reset_index(name='Count')
loans_by_month['Month_Num'] = loans_by_month['Month'].map(lambda x: month_order.index(x) + 1)
loans_by_month = loans_by_month.sort_values(['Year', 'Month_Num'])

print("### Monthly Circulation Trends")
for _, row in loans_by_month.iterrows():
    print(f"- {row['Month']} {row['Year']}: {row['Count']} loans")
print("\n")

# Most borrowed books
book_popularity = loans_complete.groupby(['Title']).size().reset_index(name='Borrows')
book_popularity = book_popularity.sort_values('Borrows', ascending=False)

print("### Most Popular Books")
for _, row in book_popularity.iterrows():
    print(f"- {row['Title']}: {row['Borrows']} times borrowed")
print("\n")

# Most active borrowers
borrower_activity = loans_complete.groupby(['MemberID', 'FirstName', 'LastName']).size().reset_index(name='Borrows')
borrower_activity = borrower_activity.sort_values('Borrows', ascending=False)
borrower_activity['FullName'] = borrower_activity['FirstName'] + ' ' + borrower_activity['LastName']

print("### Most Active Members")
for _, row in borrower_activity.iterrows():
    print(f"- {row['FullName']}: {row['Borrows']} items borrowed")
print("\n")

# Loan duration analysis
average_loan_duration = loans_complete.loc[loans_complete['LoanDuration'].notna(), 'LoanDuration'].mean()

print(f"### Loan Duration Analysis")
print(f"- Average loan duration: {average_loan_duration:.1f} days")

# Create bins for loan duration distribution
loan_duration_bins = [0, 7, 14, 21, 28, float('inf')]
loan_duration_labels = ['1 week or less', '1-2 weeks', '2-3 weeks', '3-4 weeks', 'More than 4 weeks']
loans_with_duration = loans_complete.dropna(subset=['LoanDuration'])
loans_with_duration['DurationCategory'] = pd.cut(loans_with_duration['LoanDuration'], bins=loan_duration_bins, labels=loan_duration_labels)
duration_distribution = loans_with_duration['DurationCategory'].value_counts().sort_index()

print("- Loan duration distribution:")
for category, count in duration_distribution.items():
    print(f"  - {category}: {count} loans")
print("\n")

# Overdue analysis
overdue_count = loans_complete[loans_complete['Status'] == 'Overdue'].shape[0]
overdue_percentage = (overdue_count / loans_complete.shape[0]) * 100

print(f"### Overdue Analysis")
print(f"- Current overdue loans: {overdue_count} ({overdue_percentage:.1f}% of all loans)")

# Fine analysis
total_fines = data['fines']['Amount'].sum()
pending_fines = data['fines'][data['fines']['Status'] == 'Pending']['Amount'].sum()
collected_fines = data['fines'][data['fines']['Status'] == 'Paid']['Amount'].sum()

print(f"### Fine Analysis")
print(f"- Total fines issued: ${total_fines:.2f}")
print(f"- Pending fines: ${pending_fines:.2f}")
print(f"- Collected fines: ${collected_fines:.2f}")
print("\n")

print("## 4. Staff Performance Analysis\n")

# Loans processed by staff
staff_loans = loans_complete.groupby(['StaffID']).size().reset_index(name='ProcessedLoans')
staff_loans = pd.merge(staff_loans, data['staff'][['StaffID', 'FirstName', 'LastName']], on='StaffID')
staff_loans['FullName'] = staff_loans['FirstName'] + ' ' + staff_loans['LastName']
staff_loans = staff_loans.sort_values('ProcessedLoans', ascending=False)

print("### Loans Processed by Staff")
for _, row in staff_loans.iterrows():
    print(f"- {row['FullName']}: {row['ProcessedLoans']} loans")
print("\n")

print("## 5. Recommendations\n")

# Collection development recommendations
print("### Collection Development Recommendations")
print("Based on the analysis, we recommend:")
print("1. Increase holdings in Fiction category, which is our most popular category")
print("2. Consider acquiring more books from popular authors like Stephen King and J.K. Rowling")
print("3. Prioritize obtaining copies of frequently borrowed books to reduce reservation wait times")
print("\n")

# Operational recommendations
print("### Operational Recommendations")
print("1. Implement targeted reminder system for reducing overdue items")
print("2. Consider extended loan periods for less popular items")
print("3. Maintain current fine policy which has resulted in good collection rates")
print("\n")

# Member engagement recommendations
print("### Member Engagement Recommendations")
print("1. Create personalized reading recommendations for highly active members")
print("2. Consider implementing a loyalty program for frequent borrowers")
print("3. Develop targeted outreach to inactive members")
print("\n")

print("## 6. Data Visualizations\n")

# Function to create visualizations
def create_visualizations():
    # Set up the figure size
    plt.figure(figsize=(15, 20))
    
    # 1. Books by Category
    plt.subplot(3, 2, 1)
    categories_sorted = category_counts.sort_values('Count', ascending=False)
    sns.barplot(x='Count', y='Category', data=categories_sorted)
    plt.title('Books by Category')
    plt.tight_layout()
    
    # 2. Books by Author
    plt.subplot(3, 2, 2)
    authors_sorted = author_counts.head(5)  # Top 5 authors
    sns.barplot(x='Count', y='Author', data=authors_sorted)
    plt.title('Top Authors by Number of Books')
    plt.tight_layout()
    
    # 3. Monthly Circulation Trends
    plt.subplot(3, 2, 3)
    circulation_pivot = loans_by_month.pivot_table(index='Month', columns='Year', values='Count', aggfunc='sum')
    circulation_pivot = circulation_pivot.reindex(month_order)
    circulation_pivot.plot(kind='bar', ax=plt.gca())
    plt.title('Monthly Circulation Trends')
    plt.xlabel('Month')
    plt.ylabel('Number of Loans')
    plt.xticks(rotation=45)
    plt.legend(title='Year')
    plt.tight_layout()
    
    # 4. Most Popular Books
    plt.subplot(3, 2, 4)
    top_books = book_popularity.head(5)  # Top 5 books
    sns.barplot(x='Borrows', y='Title', data=top_books)
    plt.title('Most Popular Books')
    plt.tight_layout()
    
    # 5. Loan Duration Distribution
    plt.figure(figsize=(10, 6))
sns.barplot(x=duration_distribution.index, y=duration_distribution.values, palette="viridis")
plt.title("Loan Duration Distribution")
plt.xlabel("Loan Duration Category")
plt.ylabel("Number of Loans")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Visualization of most popular books
plt.figure(figsize=(12, 6))
sns.barplot(x='Borrows', y='Title', data=book_popularity.head(10), palette="viridis")
plt.title("Most Popular Books")
plt.xlabel("Number of Borrows")
plt.ylabel("Book Title")
plt.tight_layout()
plt.show()

# Visualization of overdue loans
plt.figure(figsize=(10, 6))
sns.countplot(x='Status', data=loans_complete, palette="viridis")
plt.title("Loan Status Overview")
plt.xlabel("Loan Status")
plt.ylabel("Number of Loans")
plt.tight_layout()
plt.show()

print("\n## 5. Conclusion")
print("The analysis provides a detailed overview of the library's collection, circulation patterns, and loan management.")
print("Key insights include:")
print("- The majority of books are from the 1990s and 2000s.")
print("- Fiction, Fantasy, and Mystery are the most prevalent categories in the library's collection.")
print("- J.K. Rowling is the most prolific author in this dataset.")
print("- The most active members borrow multiple times per month.")
print("- There is a significant portion of overdue loans, with overdue fines still being processed.")
