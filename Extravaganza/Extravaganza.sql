-- we are going to merge the following tables (with all the info that we need):

SELECT amount, rental_table.rental_id, rental_table.rental_date, customer_table.customer_id, first_name, last_name, city
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id;

-- Query to determine most rented film category per user - you need subqueries with row_number (see Felipe's example)

CREATE TABLE table4
SELECT concat(first_name,' ',last_name) as customer_name, customer_table.customer_id, count(name) as count_name, name as category
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
GROUP by customer_name,name,customer_id
ORDER by customer_name, count(name) desc;

CREATE TABLE table5
SELECT customer_id , customer_name, max(count_name) as max_count
FROM table4
GROUP BY customer_name, customer_id;

SELECT a.customer_name, a.customer_id, b.max_count, a.category
FROM table4 as a
JOIN table5 as b on a.customer_name = b.customer_name and a.count_name = b.max_count and a.customer_id = b.customer_id;

SELECT a.customer_name,b.max_count, a.category,a.customer_id, row_number() over (partition by a.customer_id order by b.max_count desc) as ranking
FROM table4 as a
JOIN table5 as b on a.customer_name = b.customer_name and a.count_name = b.max_count and a.customer_id = b.customer_id;

SELECT customer_id,customer_name,max_count,category
FROM (SELECT a.customer_name,b.max_count, a.category,a.customer_id, row_number() over (partition by a.customer_id order by b.max_count desc) as ranking
FROM table4 as a
JOIN table5 as b on a.customer_name = b.customer_name and a.count_name = b.max_count and a.customer_id = b.customer_id) as sub1
WHERE ranking = 1;

SELECT customer_id,category
FROM (SELECT a.customer_name,b.max_count, a.category,a.customer_id, row_number() over (partition by a.customer_id order by b.max_count desc) as ranking
FROM table4 as a
JOIN table5 as b on a.customer_name = b.customer_name and a.count_name = b.max_count and a.customer_id = b.customer_id) as sub1
WHERE ranking = 1;

-- Total films rented per customer

SELECT customer_table.customer_id, count(rental_table.rental_id) as number_of_films_rented
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
GROUP by customer_table.customer_id;

-- Total money spent per customer

SELECT customer_table.customer_id, sum(amount) as total_money_spent
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
GROUP by customer_table.customer_id;

-- How many films where rented last month (May 2005)

SELECT customer_table.customer_id, count(rental_table.rental_id) as films_rented_may_2005
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
WHERE date_format(convert(rental_table.rental_date,date),'%Y') = 2005 AND date_format(convert(rental_table.rental_date,date),'%M') = 'May'
GROUP by customer_table.customer_id;

-- If the customer rented a movie this month (JUNE/2005) 

SELECT customer_table.customer_id, 
CASE
WHEN (date_format(convert(rental_table.rental_date,date),'%Y') = 2005 AND date_format(convert(rental_table.rental_date,date),'%M') = 'June') then 'YES'
END AS 'Did he/she rent a film this month?'
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
WHERE (date_format(convert(rental_table.rental_date,date),'%Y') = 2005 AND date_format(convert(rental_table.rental_date,date),'%M') = 'June')
GROUP BY customer_table.customer_id, 2;


-- 

--  creating tables for each quaries - Joinig all the tables

-- 1. 

CREATE TABLE query1
SELECT customer_id,category
FROM (SELECT a.customer_name,b.max_count, a.category,a.customer_id, row_number() over (partition by a.customer_id order by b.max_count desc) as ranking
FROM table4 as a
JOIN table5 as b on a.customer_name = b.customer_name and a.count_name = b.max_count and a.customer_id = b.customer_id) as sub1
WHERE ranking = 1;

-- 2. 

CREATE TABLE query2
SELECT customer_table.customer_id, count(rental_table.rental_id) as number_of_films_rented
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
GROUP by customer_table.customer_id;

-- 3.

CREATE TABLE query3
SELECT customer_table.customer_id, sum(amount) as total_money_spent
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
GROUP by customer_table.customer_id;

-- 4. 

CREATE TABLE query4
SELECT customer_table.customer_id, count(rental_table.rental_id) as films_rented_may_2005
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
WHERE date_format(convert(rental_table.rental_date,date),'%Y') = 2005 AND date_format(convert(rental_table.rental_date,date),'%M') = 'May'
GROUP by customer_table.customer_id;

-- 5.

CREATE TABLE query5
SELECT customer_table.customer_id, 
CASE
WHEN (date_format(convert(rental_table.rental_date,date),'%Y') = 2005 AND date_format(convert(rental_table.rental_date,date),'%M') = 'June') then 'YES'
END AS 'question'
FROM sakila.payment as payment_table
JOIN sakila.rental as rental_table on payment_table.customer_id = rental_table.customer_id
JOIN sakila.customer as customer_table on rental_table.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id
JOIN sakila.inventory as inventory_table on inventory_table.inventory_id = rental_table.inventory_id
JOIN sakila.film_category as film_category on inventory_table.film_id = film_category.film_id
JOIN sakila.category as category_table on category_table.category_id= film_category.category_id
WHERE (date_format(convert(rental_table.rental_date,date),'%Y') = 2005 AND date_format(convert(rental_table.rental_date,date),'%M') = 'June')
GROUP BY customer_table.customer_id, 2;


-- Joining all the tables

SELECT table_query1.customer_id, city, category, number_of_films_rented, total_money_spent, films_rented_may_2005, question
FROM query1 as table_query1 
JOIN query2 as table_query2 on table_query1.customer_id = table_query2.customer_id
JOIN query3 as table_query3 on table_query2.customer_id = table_query3.customer_id
JOIN query4 as table_query4 on table_query3.customer_id = table_query4.customer_id
JOIN query5 as table_query5 on table_query4.customer_id = table_query5.customer_id
JOIN sakila.customer as customer_table on table_query1.customer_id = customer_table.customer_id 
JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
JOIN sakila.city as city_table on address_table.city_id = city_table.city_id;

-- trying to get all the ROWS -- even if I get some null values

SELECT table_query1.customer_id, city, category, number_of_films_rented, total_money_spent, films_rented_may_2005, question
FROM query1 as table_query1 
LEFT JOIN query2 as table_query2 on table_query1.customer_id = table_query2.customer_id
LEFT JOIN query3 as table_query3 on table_query2.customer_id = table_query3.customer_id
LEFT JOIN query4 as table_query4 on table_query1.customer_id = table_query4.customer_id
LEFT JOIN query5 as table_query5 on table_query1.customer_id = table_query5.customer_id
LEFT JOIN sakila.customer as customer_table on table_query1.customer_id = customer_table.customer_id 
LEFT JOIN sakila.address as address_table on customer_table.address_id = address_table.address_id
LEFT JOIN sakila.city as city_table on address_table.city_id = city_table.city_id;









