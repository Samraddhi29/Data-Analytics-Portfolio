CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

CREATE TABLE IF NOT EXISTS retail_transactions(
  Transaction_ID VARCHAR(50) PRIMARY KEY,
  Date DATE,
  Customer_ID VARCHAR(50),
  Gender VARCHAR(10),
  Age INT,
  Product_Category VARCHAR(100),
  Quantity INT,
  Price_per_Unit DECIMAL(10,2),
  Total_Amount DECIMAL(12,2)
);
SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

-- LOAD DATA LOCAL INFILE 'retail_sales_dataset.csv'
-- INTO TABLE retail_transactions FIELDS TERMINATED BY ','  ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

CREATE TABLE IF NOT EXISTS customers AS SELECT DISTINCT Customer_ID, Gender, Age FROM retail_transactions;

CREATE TABLE IF NOT EXISTS products AS SELECT DISTINCT Product_Category, Price_per_Unit FROM retail_transactions;

ALTER TABLE customers ADD COLUMN Customer_Key INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE products ADD COLUMN Product_Key INT AUTO_INCREMENT PRIMARY KEY;

-- Total revenue per product category 
SELECT p.Product_Category, SUM(rt.Total_Amount) AS Total_Revenue FROM retail_transactions rt JOIN products p ON 
rt.Product_Category=p.Product_Category GROUP BY p.Product_Category;

--  Number of customers by gender
SELECT Gender, COUNT(DISTINCT Customer_ID) AS Customer_Count FROM customers GROUP BY Gender;

-- Total quantity sold per product category
SELECT Product_Category, SUM(Quantity) AS Total_Quantity_Sold FROM retail_transactions GROUP BY Product_Category;

-- Total number of transactions by month
SELECT DATE_FORMAT(Date, '%Y-%m') AS Month, COUNT(*) AS Transactions FROM retail_transactions GROUP BY Month ORDER BY Month;

-- Average price per unit by product category
SELECT Product_Category, AVG(Price_per_Unit) AS Avg_Price FROM products GROUP BY Product_Category;

-- Average spending per customer 
SELECT Customer_ID, SUM(Total_Amount) AS Total_Spent FROM retail_transactions GROUP BY Customer_ID ORDER BY Total_Spent DESC;

-- Average spending by gender
SELECT c.Gender, AVG(spent) AS Avg_Spending
FROM(
  SELECT Customer_ID, SUM(Total_Amount) AS spent FROM retail_transactions GROUP BY Customer_ID
) AS customer_spending
JOIN customers c ON customer_spending.Customer_ID=c.Customer_ID GROUP BY c.Gender;

-- Top 5 customers by total spending
SELECT c.Customer_ID, c.Gender, SUM(rt.Total_Amount) AS Total_Spent FROM retail_transactions rt JOIN customers c ON 
rt.Customer_ID=c.Customer_ID GROUP BY c.Customer_ID, c.Gender ORDER BY Total_Spent DESC LIMIT 5;

-- Top product categories by revenue
SELECT p.Product_Category, SUM(rt.Total_Amount) AS Revenue FROM retail_transactions rt JOIN products p ON 
rt.Product_Category=p.Product_Category GROUP BY p.Product_Category ORDER BY Revenue DESC;

-- Monthly revenue for a electronics product category
SELECT DATE_FORMAT(Date, '%Y-%m') AS Month, SUM(Total_Amount) AS Monthly_Revenue FROM retail_transactions WHERE 
Product_Category='Electronics' GROUP BY Month ORDER BY Month;

-- For clothing
SELECT DATE_FORMAT(Date, '%Y-%m') AS Month, SUM(Total_Amount) AS Monthly_Revenue FROM retail_transactions WHERE 
Product_Category='Clothing' GROUP BY Month ORDER BY Month;

-- For beauty
SELECT DATE_FORMAT(Date, '%Y-%m') AS Month, SUM(Total_Amount) AS Monthly_Revenue FROM retail_transactions WHERE 
Product_Category='Beauty' GROUP BY Month ORDER BY Month;

-- Number of customers in each age group
SELECT 
  CASE 
    WHEN Age < 20 THEN 'Under 20'
    WHEN Age BETWEEN 20 AND 29 THEN '20-29'
    WHEN Age BETWEEN 30 AND 39 THEN '30-39'
    ELSE '40 and above'
  END AS Age_Group,
COUNT(DISTINCT Customer_ID) AS Num_Customers FROM customers GROUP BY Age_Group;

-- Customers with total spending above average
WITH CustomerSpend AS (
  SELECT Customer_ID, SUM(Total_Amount) AS Total_Spent
  FROM retail_transactions
  GROUP BY Customer_ID
),
AverageSpend AS (
  SELECT AVG(Total_Spent) AS Avg_Spend FROM CustomerSpend
)
SELECT cs.Customer_ID, cs.Total_Spent FROM CustomerSpend cs, AverageSpend a WHERE cs.Total_Spent > a.Avg_Spend ORDER BY cs.Total_Spent DESC;

-- Product categories revenue changes in last two months
WITH RevenueByMonth AS (
    SELECT Product_Category, DATE_FORMAT(Date, '%Y-%m') AS Month, SUM(Total_Amount) AS Revenue FROM retail_transactions GROUP BY 
    Product_Category, Month
),
LastTwoMonths AS (
    SELECT DISTINCT Month FROM RevenueByMonth ORDER BY Month DESC LIMIT 2
)
SELECT r1.Product_Category, r1.Revenue AS Last_Month_Revenue, r2.Revenue AS Previous_Month_Revenue, (r1.Revenue-r2.Revenue) AS Revenue_Growth
FROM RevenueByMonth r1 JOIN RevenueByMonth r2 ON r1.Product_Category=r2.Product_Category WHERE r1.Month > r2.Month AND r1.Month IN 
(SELECT Month FROM LastTwoMonths) AND r2.Month IN (SELECT Month FROM LastTwoMonths) ORDER BY Revenue_Growth DESC;

-- Find customer segments by age group and their total spending on each product category
SELECT
  CASE
    WHEN c.Age < 20 THEN 'Under 20'
    WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
    WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
    ELSE '40 and above'
  END AS Age_Group,
p.Product_Category, SUM(rt.Total_Amount) AS Total_Spending
FROM retail_transactions rt JOIN customers c ON rt.Customer_ID = c.Customer_ID JOIN products p ON rt.Product_Category = p.Product_Category
GROUP BY Age_Group, p.Product_Category ORDER BY Age_Group, Total_Spending DESC;

-- Find customers who purchased from more than 3 different product categories
SELECT Customer_ID, COUNT(DISTINCT Product_Category) AS Categories_Bought FROM retail_transactions GROUP BY Customer_ID HAVING 
Categories_Bought>3;

-- Month-over-month percentage growth in total revenue
WITH MonthlyRevenue AS (
  SELECT DATE_FORMAT(Date, '%Y-%m') AS Month, SUM(Total_Amount) AS Revenue FROM retail_transactions GROUP BY Month
),
RankedMonths AS (
  SELECT Month, Revenue, ROW_NUMBER() OVER (ORDER BY Month) AS rn FROM MonthlyRevenue
)
SELECT cur.Month, cur.Revenue, prev.Revenue AS Prev_Revenue, ((cur.Revenue - prev.Revenue)/prev.Revenue)*100 AS Percent_Growth
FROM RankedMonths cur JOIN RankedMonths prev ON cur.rn=prev.rn+1 ORDER BY cur.Month;

-- Top 5 customers by average transaction value
SELECT c.Customer_ID, AVG(rt.Total_Amount) AS Avg_Transaction_Value FROM retail_transactions rt JOIN customers c ON 
rt.Customer_ID=c.Customer_ID GROUP BY c.Customer_ID ORDER BY Avg_Transaction_Value DESC LIMIT 5;

-- Rank products by total revenue
SELECT Product_Category, SUM(Total_Amount) AS Total_Revenue, RANK() OVER (ORDER BY SUM(Total_Amount) DESC) AS Revenue_Rank FROM 
retail_transactions GROUP BY Product_Category;
