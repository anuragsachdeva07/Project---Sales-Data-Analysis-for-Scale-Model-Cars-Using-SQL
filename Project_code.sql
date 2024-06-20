
	
-- Relational tables in this database are linked through the following common attributes.
/* products and orderdetails tables are linked through the common attribute "productCode".
     products and productlines tables are linked through the common attribute "productLine".
     orders and orderdetails tables are linked through the common attribute "orderNumber".
      customers and orders tables are linked through the common attribute "customerNumber".
      customers and payments tables are linked through the common attribute "customerNumber".
	  customers and employees tables are linked through the common attributes "employeeNumber" or " salesRepEmployeeNumber".
	  employees  table  self reference the table  table itself for attributes "employeeNumber" and "reportsTo".
	  employees and offices tables are linked through the common attribute "officeCode".*/
	  
	-- Code for Table Description is as follows;
	
SELECT "Customers" AS table_name, 
(SELECT COUNT(*) 
FROM pragma_table_info('customers')) AS number_of_attributes,
(SELECT COUNT(*) 
FROM customers)AS number_of_rows

UNION ALL 

SELECT "Products" AS table_name,
(SELECT COUNT(*)
 FROM pragma_table_info('products')) AS number_of_attributes,
(SELECT COUNT (*)
 FROM products) AS number_of_rows
 
UNION ALL  
 
 SELECT "ProductLines" AS table_name,
(SELECT COUNT(*)
 FROM pragma_table_info('productLines')) AS number_of_attributes,
(SELECT COUNT (*)
 FROM ProductLines) AS number_of_rows
 
UNION ALL 

SELECT "Orders" AS table_name,
(SELECT COUNT(*)
 FROM pragma_table_info('orders')) AS number_of_attributes, 
(SELECT COUNT (*)
 FROM orders) AS number_of_rows
 
 
 UNION ALL 
 
 SELECT "OrderDetails" AS table_name,
(SELECT COUNT(*)
 FROM pragma_table_info('orderDetails')) AS number_of_attributes, 
(SELECT COUNT (*)
 FROM products) AS number_of_rows
 
 
 UNION ALL 
 
 SELECT "Payments" AS table_name,
(SELECT COUNT(*)
 FROM pragma_table_info('payments')) AS number_of_attributes, 
(SELECT COUNT (*)
 FROM payments) AS number_of_rows
 
 UNION ALL 
 
 SELECT "Employees" AS table_name,
(SELECT COUNT(*)
 FROM pragma_table_info('Employees')) AS number_of_attributes,
(SELECT COUNT (*)
 FROM employees) AS number_of_rows
 
 
 UNION ALL 
 
 SELECT "Offices" AS table_name,
(SELECT COUNT(*)
 FROM pragma_table_info('offices')) AS number_of_attributes,
(SELECT COUNT (*)
 FROM offices) AS number_of_rows;
 

/*--Prioriy products for restocking 
-- Priority products for restocking was found out as the products that have high performance and in the brink of being out of stock .
--low_stock = SUM( quantityOrdered)/quantityInStock
--product_performance= SUM(quantityOrdered * priceEach) */

WITH 
LowStockProducts AS(

SELECT  p.productCode AS product_code,p.productLine AS product_line, 
		ROUND((SUM(od.quantityOrdered)/p.quantityInStock*1.0),2) AS low_stock
FROM products AS p
JOIN orderdetails AS od
ON p.productCode = od.productCode
GROUP BY p.productCode                                                  
),

ProductPerformence AS(
SELECT  p.productCode AS product_code,p.productName AS product_name,
SUM(od.quantityOrdered * od.priceEach) AS product_performance
FROM products AS p
JOIN orderdetails AS od
ON p.productCode = od.productCode
GROUP BY p.productCode                                         
)

SELECT pp.product_Code,pp.product_name,lp.product_line,
       lp.low_stock,
       pp.product_performance

FROM LowStockProducts AS lp
JOIN ProductPerformence AS pp
ON lp.product_Code = pp.product_code
ORDER BY  lp.low_stock DESC
LIMIT 10;             

													  
--Top five VIP customers
WITH 
customer_profit AS 
(SELECT o.customerNumber AS customer_number, 
       SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit 
FROM orders AS o
JOIN orderdetails AS od
ON o.orderNumber = od.orderNumber
JOIN products AS p
ON p.productCode = od.productCode
GROUP BY o.customerNumber
ORDER BY profit )

SELECT c.contactLastName, c.contactFirstName, c.city, c.country,
       cp.profit
FROM customers AS c
JOIN customer_profit AS cp
ON C.customerNumber = cp.customer_number
ORDER BY profit DESC
LIMIT 5;

--Top five least-engaging customers 
WITH 
customer_profit AS 
(SELECT o.customerNumber AS customer_number, 
       SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit 
FROM orders AS o
JOIN orderdetails AS od
ON o.orderNumber = od.orderNumber
JOIN products AS p
ON p.productCode = od.productCode
GROUP BY o.customerNumber
ORDER BY profit)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country,
       cp.profit
FROM customers AS c
JOIN customer_profit AS cp
ON C.customerNumber = cp.customer_number
ORDER BY profit
LIMIT 5;


/*
--To determine how much money we can spend acquiring new customers, we compute the Customer Lifetime Value (LTV) 
--which represents the average amount of money a customer generates. 
--We can then determine how much we can spend on marketing. 
*/

--AVG profit genertaed by customers 
WITH 
customer_profit AS 
(SELECT o.customerNumber AS customer_number, 
       SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit 
FROM orders AS o
JOIN orderdetails AS od
ON o.orderNumber = od.orderNumber
JOIN products AS p
ON p.productCode = od.productCode
GROUP BY o.customerNumber
ORDER BY profit)
 
 SELECT AVG(profit) AS avg_profit 
 FROM customer_profit;

/* Based on the analysis, Product Line of "Classic cars"  have the highest performance with the lowest stock. 
1968 Ford Mustang is the product is the leading product.
Top five VIP customers are from countries Spain, USA, Australia and France.
 Top two VIP customers have generated a profit above 200,000 which is significantly higher value compared to profit
 generated by next top three VIP customers which is in the range of 60,000- 73,000.
 Least engaged customers are from the countries USA,Italy, France and UK in which the least generated profit by a customer is below 3000.
 Hence the company has generated an average profit of 39039.594388 from a customer in their LTV, investing on acquiring more customers 
 to the cmpany could increase the profit generated, with taking critical factors such as
  country with highest sales */
 
