/* Data cleaning & Data exploration
Data Visualisation: Tableau
Dataset collected on Kaggle
Walmart Datasets

This is the historical data that covers sales from 2010-02-05 to 2012-11-01, in the file WalmartStoresales.
Within this file you will find the following fields:\

Store - the store number
Date - the week of sales
Weekly_Sales - sales for the given store
Holiday_Flag - whether the week is a special holiday week 1 – Holiday week 0 – Non-holiday week
Temperature - Temperature on the day of sale
Fuel_Price - Cost of fuel in the region
CPI – consumer price index
Unemployment - unemployment rate
Holiday Events\
Super Bowl: 12-Feb-10, 11-Feb-11, 10-Feb-12, 8-Feb-13\
Labour Day: 10-Sep-10, 9-Sep-11, 7-Sep-12, 6-Sep-13\
Thanksgiving: 26-Nov-10, 25-Nov-11, 23-Nov-12, 29-Nov-13\
Christmas: 31-Dec-10, 30-Dec-11, 28-Dec-12, 27-Dec-13
*/


--Select the table

SELECT * FROM Walmart;

--Let's start by cleaning our data

ALTER TABLE Walmart
ADD Converted_date date;

UPDATE Walmart
SET Converted_date = cast(Date as date);

ALTER TABLE Walmart
DROP COLUMN Date;

--Let's convert the temperature from degrees fahrenheit to celsius

UPDATE Walmart
SET Temperature =  ROUND((((Temperature -32)*5)/9), 2);


--Number Of Stores
WITH TEMP AS (
SELECT DISTINCT Store AS Store1 FROM Walmart
)
SELECT COUNT(Store1) AS 'Number Of Stores' FROM TEMP;

--Total Sales By Store

SELECT Store, SUM(Weekly_Sales) AS 'Total Sales By Store' 
FROM Walmart
GROUP BY Store
ORDER BY Store;

--Yearly Sales
SELECT YEAR(Converted_date) AS Year, Store, SUM(Weekly_Sales) AS 'Yearly Sales' 
FROM Walmart
GROUP BY Store, YEAR(Converted_date)--MONTH(Converted_date)
ORDER BY Store, YEAR(Converted_date);--MONTH(Converted_date);

--Monthly Sales
CREATE VIEW Monthly_Sales AS
 WITH TEMP1 AS (
SELECT MONTH(Converted_date) AS Month, YEAR(Converted_date) AS Year, Store, SUM(Weekly_Sales) AS 'Monthly_Sales' 
FROM Walmart
GROUP BY Store, MONTH(Converted_date), YEAR(Converted_date))

SELECT Store, Monthly_Sales, Year,
CASE
WHEN Month = 1 THEN 'Jan'
WHEN Month = 2 THEN 'Feb'
WHEN Month = 3 THEN 'Mar'
WHEN Month = 4 THEN 'Apr'
WHEN Month = 5 THEN 'May'
WHEN Month = 6 THEN 'June'
WHEN Month = 7 THEN 'July'
WHEN Month = 8 THEN 'Aug'
WHEN Month = 9 THEN 'Sep'
WHEN Month = 10 THEN 'Oct'
WHEN Month = 11 THEN 'Nov'
WHEN Month = 12 THEN 'Dec'
ELSE 'Nothing'
END As Months
FROM TEMP1;


--SALES GROWTH

CREATE VIEW Total_Sales AS
SELECT YEAR(Converted_date) AS Year, Store, SUM(Weekly_Sales) AS 'Yearly Sales' 
FROM Walmart
GROUP BY Store, YEAR(Converted_date);

CREATE VIEW Yearly_S_2010 AS
SELECT Store, [Yearly Sales] As Yearly_Sales_2010 FROM Total_Sales WHERE Year = 2010;

CREATE VIEW Yearly_S_2011 AS
SELECT Store As Store_1, [Yearly Sales] As Yearly_Sales_2011 FROM Total_Sales WHERE Year = 2011;

CREATE VIEW Yearly_S_2012 AS
SELECT Store As Store_2, [Yearly Sales] As Yearly_Sales_2012 FROM Total_Sales WHERE Year = 2012;

CREATE VIEW TEMP1 AS
SELECT * FROM Yearly_S_2010
JOIN Yearly_S_2011 ON Yearly_S_2010.Store = Yearly_S_2011.Store_1
JOIN Yearly_S_2012 ON Yearly_S_2011.Store_1 = Yearly_S_2012.Store_2;

CREATE VIEW Yearly_Sales_2010_2012 AS
SELECT Store, Yearly_Sales_2010,Yearly_Sales_2011, Yearly_Sales_2012 FROM TEMP1;

CREATE VIEW Sales_Growth AS
WITH TEMP2 AS (
SELECT Store, ROUND(((Yearly_Sales_2011-Yearly_Sales_2010)/Yearly_Sales_2010)*100, 2) AS SGRTH_2010_2011,
ROUND(((Yearly_Sales_2012-Yearly_Sales_2011)/Yearly_Sales_2011)*100, 2) AS SGRTH_2011_2012,
ROUND(((Yearly_Sales_2012-Yearly_Sales_2010)/Yearly_Sales_2010)*100, 2) AS SGRTH_2010_2012
FROM Yearly_Sales_2010_2012)
SELECT Store, SGRTH_2010_2011, SGRTH_2011_2012, SGRTH_2010_2012,
CASE
WHEN SGRTH_2010_2012 LIKE '-%' THEN 'Negative Growth'
ELSE 'Positive Growth'
END AS 'GROWTH 2010-2012'
FROM TEMP2;

SELECT * FROM Sales_Growth;




