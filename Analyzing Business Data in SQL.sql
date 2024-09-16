
# 1.Buatlah query untuk menghitung cost, revenue dan profit per product!

WITH revenue AS (
	SELECT product.product_name, SUM(sales.revenue) AS sal_in_revenue
	FROM sales 
	JOIN product ON sales.product_id = product.product_id
    GROUP BY product_name),
	cost AS (
		SELECT  product.product_name, SUM(sales.cost) AS sal_in_cost
		FROM sales 
		JOIN product ON sales.product_id = product.product_id
        GROUP BY product_name ),
			nameProduct AS (
			SELECT DISTINCT sales.product_id, product.product_name
            FROM sales
            JOIN product ON sales.product_id = product.product_id
            )
	SELECT nameproduct.product_id, 
    nameproduct.product_name, 
    CONCAT('$', FORMAT(cost.sal_in_cost,0)) AS Cost,
    CONCAT('$', FORMAT(revenue.sal_in_revenue,0)) AS Revenue,
	CONCAT('$', FORMAT(revenue.sal_in_revenue - cost.sal_in_cost,0)) AS profit
    FROM nameProduct
    JOIN cost ON cost.product_name = nameproduct.product_name
    JOIN revenue ON revenue.product_name = nameProduct.product_name;
    
-- 2. Buatlah query untuk membandingkan Average Revenue per User (ARPU) setiap bulan!

SELECT DATE_FORMAT(sale_date, '%M') AS 'Month',
FORMAT(SUM(revenue) / COUNT(DISTINCT customer_id),2) AS 'ARPU'
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%M')
ORDER BY 'month' ASC;

/*
Analisis Singkat:
- Januari memiliki ARPU tertinggi (22,866.67), yang menunjukkan bahwa pengguna pada bulan ini 
  memberikan pendapatan rata-rata yang lebih besar.
- Februari memiliki ARPU yang jauh lebih rendah (4,666.67), menunjukkan penurunan pendapatan 
  rata-rata per pengguna dibandingkan Januari.
- Maret menunjukkan peningkatan ARPU menjadi 17,500.00 dibandingkan Februari. 

Tren ini dapat memberikan informasi penting untuk analisis bisnis, seperti identifikasi periode dengan
pendapatan per pengguna tertinggi dan strategi untuk meningkatkan ARPU di bulan-bulan dengan pendapatan 
lebih rendah.
*/

-- 3. Buatlah query untuk menghitung Daily Active User dan Monthly Active User! 

-- DAU
	SELECT 
    DATE_FORMAT(sale_date, '%Y %m %d') AS date, 
    COUNT(DISTINCT customer_id) AS daily_active_users
	FROM sales
	GROUP BY sale_date;
    
-- MAU  
	SELECT 
	DATE_FORMAT(sale_date, '%Y-%m') AS month, 
	COUNT(DISTINCT customer_id) AS monthly_active_users
	FROM sales
	GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
	ORDER BY 'month';
    
/*4. Buatlah query untuk menghitung komponen berikut ini dari jumlah order (total quantity sold) per customer 
Min 
Quartile 1 (Q1)
Quartile 2 (Q2)
Quartile 3 (Q3)
Max */

WITH customer_orders AS (
SELECT 
customer_id, 
SUM(quantity_sold) AS total_quantity_sold
FROM sales
GROUP BY customer_id
),
percentile_values AS (
SELECT 
total_quantity_sold,
NTILE(4) OVER (ORDER BY total_quantity_sold) AS quartile
FROM customer_orders
)
SELECT 
    MIN(total_quantity_sold) AS min_order,
    MAX(total_quantity_sold) AS max_order,
    MAX(CASE WHEN quartile = 1 THEN total_quantity_sold END) AS Q1,
    MAX(CASE WHEN quartile = 2 THEN total_quantity_sold END) AS Q2,
    MAX(CASE WHEN quartile = 3 THEN total_quantity_sold END) AS Q3
FROM 
    percentile_values;



/*
5. Menghitung outliers 
*/
WITH customer_orders AS (
SELECT 
customer_id, 
SUM(quantity_sold) AS total_quantity_sold
FROM sales
GROUP BY customer_id
),
percentile_values AS (
SELECT 
total_quantity_sold,
NTILE(4) OVER (ORDER BY total_quantity_sold) AS quartile
FROM customer_orders
),
quartile_stats AS (
SELECT 
MIN(total_quantity_sold) AS min_order,
MAX(total_quantity_sold) AS max_order,
MAX(CASE WHEN quartile = 1 THEN total_quantity_sold END) AS Q1,
MAX(CASE WHEN quartile = 2 THEN total_quantity_sold END) AS Q2,
MAX(CASE WHEN quartile = 3 THEN total_quantity_sold END) AS Q3
FROM percentile_values
)
SELECT 
    customer_id, 
    total_quantity_sold,
    CASE 
        WHEN total_quantity_sold < (Q1 - 1.5 * (Q3 - Q1)) THEN 'Below Lower Bound (Outlier)'
        WHEN total_quantity_sold > (Q3 + 1.5 * (Q3 - Q1)) THEN 'Above Upper Bound (Outlier)'
        ELSE 'Within Range'
    END AS outlier_status
FROM customer_orders, quartile_stats;

/*
Customer A001 dengan total quantity sold 48 dikategorikan sebagai "Above Upper Bound (Outlier)".
Customer A002 dengan total quantity sold 88 juga dikategorikan sebagai "Above Upper Bound (Outlier)".

Ini berarti total quantity sold mereka jauh lebih tinggi dibandingkan dengan customer lainnya, sehingga
dianggap outlier karena berada di atas batas kuartil (upper bound).

Outlier semacam ini bisa memberikan informasi penting, misalnya:

a. Customer dengan pembelian yang sangat besar (mungkin pelanggan utama).
b. Anomali atau kesalahan data (perlu diperiksa lebih lanjut).
*/
    
    
    
    
    
