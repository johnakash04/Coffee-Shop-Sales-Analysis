SELECT COUNT(*)
FROM Transactions;

SELECT *
FROM Transactions;

--Data types of different columns
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Transactions';

--Convert transaction_id column to integer
ALTER TABLE Transactions
ALTER COLUMN transaction_id INT;

--Convert transaction_time column to time
ALTER TABLE Transactions
ALTER COLUMN transaction_time TIME;

--Total Sales
SELECT ROUND(SUM(unit_price * transaction_qty), 1) AS Total_Sales
FROM Transactions
WHERE MONTH(transaction_date) = 5; --for may month 

--Total Sales KPI - MOM Difference & MOM Growth
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty), 1) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    Transactions
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

--Total Orders
SELECT COUNT(transaction_id) as Total_Orders
FROM Transactions
WHERE MONTH (transaction_date)= 5 -- for month of (CM-May)

--Total orders KPI - MOM Difference & MOM Growth
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id), 1) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    Transactions
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

--Total Quantity Sold
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM Transactions 
WHERE MONTH(transaction_date) = 5 -- for month of (CM-May)


--Total Quantity Sold KPI - MOM Difference & MOM Growth
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty), 1) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    Transactions
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


--Calender Table - Daily Sales, Quantity & Total Orders
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    Transactions
WHERE 
    transaction_date = '2023-05-18'; --For 18 May 2023



--Sales Trend Over Period
SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        Transactions
	WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query;


--Daily Sales for month selected
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    Transactions
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);

--Comparing daily sales with average sales - if greater than "Above Average" & lesser than "Below Average"
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        Transactions
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;


--Sales by weekday / weekend
SELECT 
    CASE 
        WHEN DATEPART(weekday, transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales
FROM 
    Transactions
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DATEPART(weekday, transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;

--Sales by store location
SELECT 
	store_location,
	SUM(unit_price * transaction_qty) as Total_Sales
FROM Transactions
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC

--Sales by product category
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM Transactions
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC


--Sales by products (TOP 10)
SELECT TOP 10
    product_type,
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_Sales
FROM Transactions
WHERE
    MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC


--Sales by day | Hour
SELECT 
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    Transactions
WHERE 
    DATEPART(WEEKDAY, transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND DATEPART(HOUR, transaction_time) = 8 -- Filter for hour number 8
    AND DATEPART(MONTH, transaction_date) = 5; -- Filter for May (month number 5)


--Week Sales for month of may
SELECT 
    CASE 
        WHEN DATEPART(WEEKDAY, transaction_date) = 2 THEN 'Monday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 3 THEN 'Tuesday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 4 THEN 'Wednesday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 5 THEN 'Thursday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 6 THEN 'Friday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_Sales
FROM 
    Transactions
WHERE 
    DATEPART(MONTH, transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DATEPART(WEEKDAY, transaction_date) = 2 THEN 'Monday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 3 THEN 'Tuesday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 4 THEN 'Wednesday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 5 THEN 'Thursday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 6 THEN 'Friday'
        WHEN DATEPART(WEEKDAY, transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;


--Hour Sales for month of may
SELECT 
    DATEPART(HOUR, transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_Sales
FROM 
    Transactions
WHERE 
    DATEPART(MONTH, transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    DATEPART(HOUR, transaction_time)
ORDER BY 
    DATEPART(HOUR, transaction_time);
