-- 2. Book Popularity Analysis (GetBookPopularityStats)
-- Purpose: Identify the most popular books in the collection based on circulation data
-- Parameters:
-- @TopN - Optional: Number of results to return (defaults to 10)

-- Output Includes:
-- Most borrowed books with loan counts
-- Average loan duration for each book
-- Most reserved books
-- Books with longest waiting times

-- Sample Usage:
-- EXEC GetBookPopularityStats @TopN = 15;

EXEC GetBookPopularityStats @TopN = 15;

-- ------------------------------------------------------------

-- 3. Category Popularity Analysis (GetCategoryPopularityStats)
-- Purpose: Analyze which categories are most popular with library members

-- Output Includes:
-- Total loans per category
-- Unique books per category
-- Unique members borrowing from each category
-- Loans per book ratio (efficiency metric)

-- Sample Usage:
-- EXEC GetCategoryPopularityStats;

EXEC GetCategoryPopularityStats;

-- ------------------------------------------------------------

-- 4. Member Activity Analysis (GetMemberActivityStats)
-- Purpose: Identify the most active members and their borrowing patterns
-- Parameters:
-- @TopN - Optional: Number of results to return (defaults to 10)

-- Output Includes:
-- Most active members by loan count
-- Favorite categories for each member
-- Members with highest fine amounts
-- Members with most overdue books

-- Sample Usage:
-- EXEC GetMemberActivityStats @TopN = 20;

EXEC GetMemberActivityStats @TopN = 20;

-- ------------------------------------------------------------

-- 5. Staff Performance Analysis (GetStaffPerformanceStats)
-- Purpose: Evaluate staff performance based on loan processing metrics

-- Output Includes:
-- Total loans processed by each staff member
-- Number of working days
-- Average loans processed per working day

-- Sample Usage:
-- EXEC GetStaffPerformanceStats;

EXEC GetStaffPerformanceStats;

-- ------------------------------------------------------------

-- 6. Collection Age Analysis (GetCollectionAgeAnalysis)
-- Purpose: Analyze collection freshness and usage patterns by publication date

-- Output Includes:
-- Book counts by age category
-- Copy counts by age category
-- Loan counts by age category
-- Loans per book ratio for each age category

-- Sample Usage:
-- EXEC GetCollectionAgeAnalysis;

EXEC GetCollectionAgeAnalysis;

-- ------------------------------------------------------------

-- 7. Loan Duration Analysis (GetLoanDurationAnalysis)
-- Purpose: Analyze how long members keep books and which categories have longer/shorter loan periods

-- Output Includes:
-- Average loan duration by category
-- Distribution of loan durations (0-7 days, 8-14 days, etc.)

-- Sample Usage:
-- EXEC GetLoanDurationAnalysis;

EXEC GetLoanDurationAnalysis;

-- ------------------------------------------------------------

-- 8. Fine Analysis (GetFineAnalysis)
-- Purpose: Analyze fine generation and collection patterns

-- Output Includes:
-- Total fines generated, collected, pending, and waived
-- Collection rate percentage
-- Monthly fine statistics

-- Sample Usage:
-- EXEC GetFineAnalysis;

EXEC GetFineAnalysis;

-- ------------------------------------------------------------

-- 9. Inventory Health Analysis (GetInventoryHealthAnalysis)
-- Purpose: Identify issues with collection availability and maintenance needs

-- Output Includes:
-- Books with low availability (below 30%)
-- Lost and damaged book statistics

-- Sample Usage:
-- EXEC GetInventoryHealthAnalysis;

EXEC GetInventoryHealthAnalysis;

-- ------------------------------------------------------------

-- 10. Seasonal Trend Analysis (GetSeasonalTrendAnalysis)
-- Purpose: Identify seasonal patterns in library usage and category preferences

-- Output Includes:
-- Loans, members, and books by season (Winter, Spring, Summer, Fall)
-- Top categories for each season

-- Sample Usage:
-- EXEC GetSeasonalTrendAnalysis;

EXEC GetSeasonalTrendAnalysis;
