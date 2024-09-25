USE shop;

/* SOAL 1 : Tampilkan 2 barang termahal */

SELECT * FROM MsProduct ORDER BY Price DESC LIMIT 2;

/* SOAL 2 : Tampilkan detail toko yang sudah official diurutkan dari nama pemilik toko terbesar [A - Z]
			Note : 1. Tidak boleh pake kolom isOfficial
				   2. Pake kolom IDShop digit terakhir
							Y : Official
							N : Tidak official */
                            
SELECT * FROM trShop WHERE RIGHT(IDShop,1) = 'Y' ORDER BY Owner ASC;

/* SOAL 3 : Buatlah view bernama 'vw_CreditCardDoneTransaction', menampilkan detail transaksi
			yang sudah selesai dan menggunakan Credit Card */
CREATE VIEW vw_CreditCardDoneTransaction
AS
SELECT * FROM trTransaction WHERE PaymentMethod = 'Credit Card' AND Done = 1;

SELECT * FROM vw_CreditCardDoneTransaction;

/* SOAL 4 : Tampilkan nama pemilik toko OFFICIAL dengan format [kode toko + nama belakang pemilik toko] */
SELECT CONCAT(IDShop, ' ', SUBSTR(Owner, LOCATE(' ', Owner), LENGTH(Owner))) AS 'Owner Name' FROM trShop WHERE isOfficial = 1;

/* SOAL 5 : Tampilkan kode product, nama product, stock product, price dengan format ['Rp. ' + Price] 
			dari product yang memiliki stock lebih dari 50 */
SELECT IDProduct, Name, Stock, CONCAT('Rp. ', Price) AS Price FROM MsProduct WHERE Stock > 50;


/* SOAL 6 : Tampilkan kode toko, nama toko dengan format nama_toko + official/non-official, 
			owner, alamat yang memiliki harga lebih dari 100000 */
SELECT DISTINCT a.IDShop, CONCAT(a.Name, CASE WHEN isOfficial = 1 THEN ' (Official)' ELSE ' (Non-Official)' END) AS Name, Owner
FROM trShop a
JOIN MsProduct b ON a.IDShop = b.IDShop
WHERE Price > 100000;

/* SOAL 7 : Tampilkan kode transaksi, kode product, kode customer, transaction date dengan format dd mm yyyy,
			qty, total price, payment method dari transaksi yang terjadi dibulan September dan November */
SELECT IDTransaction, IDProduct, IDCustomer, DATE_FORMAT(TransactionDate, '%d %M %Y') AS "Transaction Date", qty, totalprice, paymentmethod
FROM TrTransaction
WHERE MONTH(TransactionDate) IN (9, 11);
-- WHERE  MONTH(TransactionDate) = 9 OR MONTH(TransactionDate) = 11

/* SOAL 8 : Tampilkan nama metode transaksi,jumlah transaksi yang menggunakan metode
			debit (Payment Count) dari toko yang sudah official */
SELECT PaymentMethod, COUNT(IDTransaction) AS 'Payment Count'
FROM TrTransaction
JOIN MsProduct ON TrTransaction.IDProduct = MsProduct.IDProduct
JOIN TrShop ON MsProduct.IDShop = TrShop.IDShop
WHERE isOfficial = 1 AND PaymentMethod = 'Debit'
GROUP BY PaymentMethod;

/* QUERY UNTUK CEK SOAL NOMOR 8 */
SELECT * 
FROM TrTransaction a
JOIN MsProduct b ON a.IDProduct = b.IDProduct
JOIN trshop c ON b.IDShop = c.IDShop
WHERE PaymentMethod = 'Debit';
/* ============================ */

SELECT * FROM trcustomer;

/* SOAL 9 : Tampilkan kode customer, nama customer, PhoneNumber, dan email
			yang memiliki nama dengan minimal 3 kata*/
SELECT IDCustomer, Name, PhoneNumber, Email
FROM TrCustomer
WHERE Name LIKE '% % %';

/* SOAL 10 : Buatlah Stored Procedure yang bernama 'Search_Product' yang menerima input/parameter
			 nama barang, dan menampilkan nama toko yang menjual barang tersebut, kode barang,
			 nama barang, stock, harga
			  */			  
DELIMITER $$
CREATE PROCEDURE Search_Product(IN Input_param VARCHAR(255))
BEGIN
    SELECT b.Name as 'Shop Name', a.IDProduct as 'Product ID', a.Name as 'Product Name', a.Stock, a.Price
    FROM MsProduct a
    JOIN TrShop b ON a.idshop = b.IDShop
    WHERE a.Name = Input_param;
END $$
DELIMITER ;

CALL Search_Product('Tooth brush');

/* SOAL 11 : Buatlah Stored Procedure bernama 'GetAverageReviewByProductName' yang menerima inputan/parameter
			 nama product, yang berfungsi untuk menampilkan nama product, rata2 review star dari
			 nama barang yang diinput */
DELIMITER $$
CREATE PROCEDURE GetAverageReviewByProductName(IN Input_param VARCHAR(255))
BEGIN
    SELECT b.Name as 'Product Name', AVG(a.Star) as 'Average Review Star'
    FROM TrReview a
    JOIN MsProduct b ON a.IDProduct = b.IDProduct
    WHERE b.Name = Input_param
    GROUP BY b.Name;
END $$
DELIMITER ;

CALL GetAverageReviewByProductName ('Fidget Box');

SELECT * FROM msproduct;
SELECT * FROM trreview WHERE idproduct = 2;

/* SOAL 12 : Buatlah Stored Procedure bernama 'Search_Shop', menerima inputan/parameter
			 nama toko ATAU nama owner yang berfungsi untuk menampilkan data toko sesuai dengan
			 toko/owner yang diinput*/
DELIMITER $$
CREATE PROCEDURE Search_Shop(IN Input_param VARCHAR(255))
BEGIN
    SELECT * FROM TrShop
    WHERE Name LIKE concat('%', Input_param, '%') OR 
    Owner LIKE concat('%', Input_param, '%');
END $$
DELIMITER ;

CALL Search_Shop ('Nao');

/* SOAL 13 : Buatlah Stored Procedure yang bernama 'GetTotalStockAndSoldProduct', tidak menerima input/parameter
			 yang berfungsi untuk menampilkan seluruh detail product dan 
			 [Total Stock + Sold] = total stock product + jumlah product tersebut yang telah dijual*/
DELIMITER $$
CREATE PROCEDURE GetTotalStockAndSoldProduct()
BEGIN
    SELECT b.IDProduct, b.IDShop, b.Name, b.Price, (b.Stock + a.TotalQty) AS 'Total Stock + Sold'
    FROM (
        SELECT IDProduct, COALESCE(SUM(Qty), 0) AS TotalQty -- NULL
        FROM TrTransaction
        GROUP BY IDProduct
    ) a
    JOIN MsProduct b ON a.IDProduct = b.IDProduct;
END $$
DELIMITER ;

CALL GetTotalStockAndSoldProduct();

/* SOAL 14 : Buatlah Stored Procedure dengan nama 'CountProductInCustomerCart' yang menerima parameter
			 nama product, yang berfungsi untuk menampilkan nama product dan [Count Customer] = jumlah
			 customer yang menyimpan product tersebut di cart customer */
DELIMITER $$
CREATE PROCEDURE CountProductInCustomerCart(IN Name VARCHAR(255))
BEGIN
    SELECT b.Name, COALESCE(a.CountCustomer, 0) AS 'Count Customer'
    FROM (
        SELECT IDProduct, COUNT(IDCustomer) AS CountCustomer
        FROM TrCart
        GROUP BY IDProduct
    ) a
    RIGHT JOIN MsProduct b ON a.IDProduct = b.IDProduct
    WHERE b.Name = Name;
END $$
DELIMITER ;

CALL CountProductInCustomerCart('Door');

SELECT * FROM msproduct WHERE idproduct = 25;

SELECT idproduct, COUNT(idproduct)
FROM trcart
GROUP BY idproduct
ORDER BY COUNT(idproduct) DESC;

/* SOAL 15 : Buatlah Stored Procedure yang bernama 'CalculateCustomerPoint' yang menerima input/parameter
			 nama customer, yang berfungsi untuk memberikan poin kepada customer yang telah 
			 menghabiskan uang untuk berbelanja dengan ketentuan berikut
			 Note : 1. apabila customer menghabiskan < Rp. 100,000 -> mendapat poin 0
					2. apabila customer menghabiskan Rp. 100,000 - Rp. 499,000 -> mendapat poin 20
					3. apabila customer menghabiskan Rp. 500,000 - Rp. 999,000 -> mendapat poin 50
					4. apabila customer menghabiskan > Rp. 1,000,000-> mendapat poin 100 */
DELIMITER $$
CREATE PROCEDURE CalculateCustomerPoint(IN Customer_Name VARCHAR(255))
BEGIN
DECLARE Total_Spending BIGINT;

SET Total_Spending = (SELECT SUM(TotalPrice) FROM TrTransaction a JOIN TrCustomer b ON a.IDCustomer = b.IDCustomer WHERE Name = Customer_Name GROUP BY a.IDCustomer);

SELECT CASE
  WHEN Total_Spending < 100000 OR Total_Spending IS NULL THEN 0
  WHEN Total_Spending >= 100000 AND Total_Spending < 500000 THEN 20
  WHEN Total_Spending >= 500000 AND Total_Spending < 1000000 THEN 50 -- <= 999999
  ELSE 100
END AS Point;
END$$
DELIMITER ;

SELECT * FROM trcustomer;

CALL CalculateCustomerPoint('Christiana Willis Cockle');

/* QUERY BUAT TESTING */
SELECT SUM(TotalPrice)
FROM TrCustomer a
JOIN TrTransaction b ON a.IDCustomer = b.IDCustomer
WHERE Name = 'Christiana Willis Cockle'
GROUP BY Name;

/* ================= */

SELECT * FROM TrTransaction;
SELECT * FROM TrCustomer;
