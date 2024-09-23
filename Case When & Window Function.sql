CREATE DATABASE Latihan;

DESC sales;

/* 1. Buatlah query untuk memunculkan jenis produk yang memiliki 
kuantitas penjualan yang lebih besar dari rerata penjualan */

SELECT
		a.product_id,
        product_name,
        total_amount,
		ROUND(AVG(total_amount) OVER(),0) AS rerata_penjualan
	FROM 
		products a 
	LEFT JOIN 
		sales B ON a.product_id = b.product_id
	ORDER BY 
		total_amount 
	DESC;

/*2. Dengan menggunakan RANK() tentukan customer dengan total amount terbanyak pada setiap country */

	SELECT
		a.customer_id,
        a.customer_name,
        a.country,
        SUM(b.total_amount) AS total_amount,
        RANK() OVER(PARTITION BY SUM(b.total_amount) ORDER BY SUM(b.total_amount) DESC ) AS `Rank Customer`
	FROM
		customers a
	LEFT JOIN 
		sales b ON a.customer_id = b.customer_id
	GROUP BY 
    a.customer_id, a.customer_name
	ORDER BY 
    total_amount DESC;

	
        
/*
3. Buat kategori customer berdasarkan total quantity dan amountnya sebagai berikut :
	Low 	: total quantity 1-2 dan total amount <=100
	Medium 	: total quantity 3-5 dan total amount 101-300
	High	: total quantity >5 dan total amount >300

*/

SELECT 
	a.customer_id,
	a.customer_name, 
    SUM(b.quantity) AS total_quantity, 
    SUM(b.total_amount) AS total_amount,
CASE 
	WHEN SUM(b.quantity) BETWEEN 1 AND 2 AND SUM(b.total_amount) <= 100 THEN 'Low'
	WHEN SUM(b.quantity) BETWEEN 3 AND 5 AND SUM(b.total_amount) BETWEEN 101 AND 300 THEN 'Medium'
	WHEN SUM(b.quantity) > 5 AND SUM(b.total_amount) > 300 THEN 'High'
	ELSE 'Unknown' 
		END AS 'Kategory Customer'
FROM customers a
LEFT JOIN sales b ON a.customer_id = b.customer_id
GROUP BY 1,2;


/*
 4. Buatlah query dengan SELECT, SUM(), and the window function SUM() OVER () untuk menghitung kontribusi
	penjualan per produk terhadap keseluruhan penjualan, baik dari segi kuantitas maupun amount.
*/

SELECT 
    product_name,
    product_id,
    total_quantity_per_product,
    total_amount_per_product,
    total_quantity_all_products,
    total_amount_all_products,
    ROUND(total_quantity_per_product / total_quantity_all_products * 100, 2) AS contribution_quantity_percentage,
    ROUND(total_amount_per_product / total_amount_all_products * 100, 2) AS contribution_amount_percentage
FROM (
    SELECT 
        p.product_name,
        s.product_id,
        SUM(s.quantity) AS total_quantity_per_product,
        SUM(s.total_amount) AS total_amount_per_product,
        SUM(SUM(s.quantity)) OVER () AS total_quantity_all_products,
        SUM(SUM(s.total_amount)) OVER () AS total_amount_all_products
    FROM 
        sales s
    JOIN 
        products p ON s.product_id = p.product_id
    GROUP BY 
        s.product_id, p.product_name
) AS subquery;