create database if not exists adventureworks;
use adventureworks;
select * from fact_internet_sales_new;
select * from dimproduct;
select * from dimproductcategory;
select * from dimproductsubcategory;
select * from dimsalesterritory;

-- data clean 1 row delete 11
Delete from dimsalesterritory
where  salesterritorykey = 11
limit 1;

select * from dimcustomer;
select * from factinternetsales;
select * from fact_internet_sales_new;

-- Que.0) union two file of factinternetsales and fact_internet_sales_new
-- Que.0)
create table sales as 
select * from factinternetsales 
union all 
select * from fact_internet_sales_new;

select * from Sales;

-- Que.1) Lookup the productname from the Product sheet to Sales sheet.
-- Que.1)
SELECT s.*,
       p.EnglishProductName 
FROM Sales AS s
LEFT JOIN DimProduct AS p
USING (ProductKey)
where englishproductname is not null;

-- Que.2) Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.
-- Que.2)
select  s.*,
	   concat(c. FirstName, " ", c. MiddleName, " ",  c. lastname, " ") as customerfullname
from sales as s
left join dimcustomer as c
using (customerkey);

-- Unit Price from Product sheet to Sales sheet.
SELECT s.*,
       p.`Unit Price`
FROM Sales AS s
LEFT JOIN DimProduct AS p
USING (ProductKey)
WHERE p.`Unit Price` IS NOT NULL;

-- Que.3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey)
-- Que.3.   
   /* A.Year
   B.Monthno
   C.Monthfullname
   D.Quarter(Q1,Q2,Q3,Q4)
   E. YearMonth ( YYYY-MMM)
   F. Weekdayno
   G.Weekdayname
   H.FinancialMOnth 
   I. Financial Quarter */
select *, Date(orderdatekey) as Date , 
          year(orderdatekey) as years, 
          month(orderdatekey) as Monthno, 
          monthname(orderdatekey) as Monthname, 
          concat('Q', quarter(orderdatekey)) as Quarter,
          concat(year(orderdatekey), "-", month(orderdatekey)) as Yearmonth,
          DAYNAME(orderdatekey) AS weekdayname,
          WEEKDAY(orderdatekey) + 1 AS weekday_number,
          
          month(orderdatekey) as financial_month ,
                       case
						when month(orderdatekey) between 4 and 6 then "FQ1"
					    when month(orderdatekey) between 7 and 9  then "FQ2"
                        when month(orderdatekey) between 10 and 12 then "FQ3"
                        Else "FQ4" 
                        END AS FINANCIAL_QUARTER
FROM sales;


-- Que. 4.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)
-- Que. 4
select *,
       unitprice,
       orderquantity,
       discountamount,
       (unitprice * orderquantity) - (unitprice * orderquantity * discountamount) as totalsales
from sales;
	
-- Que. 5.Calculate the Productioncost uning the columns(unit cost ,order quantity)
-- Que. 5
select *,
       productStandardcost,
       orderquantity,
       (ProductStandardCost * OrderQuantity) As Productioncost
from sales;

-- Que. 6. Calculate the profit.
-- Que. 6.

SELECT 
    t1.*,
    (t1.TotalSales - t1.ProductionCost) AS Profit
FROM (
    SELECT 
        s.*,
        (s.UnitPrice * s.OrderQuantity) 
            - (s.UnitPrice * s.OrderQuantity * s.DiscountAmount) AS TotalSales,
        (s.ProductStandardCost * s.OrderQuantity) AS ProductionCost
    FROM Sales AS s
) AS t1;






SELECT 
    s.*,
    c.CustomerFullName,
    p.`Unit Price`,
    DATE(s.orderdatekey) AS Date,
    YEAR(s.orderdatekey) AS Year_,
    MONTH(s.orderdatekey) AS MonthNo,
    MONTHNAME(s.orderdatekey) AS MonthFullName,
    CONCAT('Q', QUARTER(s.orderdatekey)) AS Quarter,
    CONCAT(YEAR(s.orderdatekey), '-', LEFT(MONTHNAME(s.orderdatekey),3)) AS YearMonth,
    DAYNAME(s.orderdatekey) AS WeekdayName,
    WEEKDAY(s.orderdatekey) + 1 AS WeekdayNo,
    MONTH(s.orderdatekey) AS FinancialMonth,
    CASE
        WHEN MONTH(s.orderdatekey) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(s.orderdatekey) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(s.orderdatekey) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END AS FinancialQuarter
FROM Sales AS s
LEFT JOIN (
    SELECT 
        CustomerKey,
        CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS CustomerFullName
    FROM DimCustomer
) AS c USING (CustomerKey)
LEFT JOIN (
    SELECT 
        ProductKey,
        `Unit Price`
    FROM DimProduct
    WHERE `Unit Price` IS NOT NULL
) AS p USING (ProductKey);






