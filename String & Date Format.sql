# 1. Buatlah query untuk membuat kolom tahun dan bulan secara terpisah untuk kolom birth_date.
SELECT 
SUBSTRING(birth_date,1,4) AS Tahun,
SUBSTRING(birth_date,6,2) AS Bulan,
SUBSTRING(birth_date,9,3) AS Hari
FROM employees;

# 2. Buatlah query untuk memunculkan karyawan dengan masa kerja 5-10 tahun.
SELECT employee_id,CONCAT(first_name,' ',last_name) AS Employee, hire_date
FROM Employees
WHERE TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) BETWEEN 5 AND 10;

/* 3. Buatlah query untuk memunculkan nama dan department dari masing-masing
karyawan dengan format “Last Name, First Name_Department*/
SELECT last_name, first_name, department_name
FROM Employees a
JOIN departments b ON a.department_id = b.department_id;

# 4. Buatlah query untuk memunculkan karyawan yang berulang tahun pada bulan ini
SELECT employee_id, 
CONCAT(first_name,' ',last_name) AS Employee,
MONTHNAME(birth_date) AS nama_bulan
FROM employees
WHERE MONTH(birth_date) = CURDATE();






