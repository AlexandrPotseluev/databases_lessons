-- Lesson 7

USE lesson_5;

SELECT * FROM orders;
SELECT * FROM orders_products;
SELECT * FROM products;
SELECT * FROM catalogs;
SELECT * FROM users;

UPDATE orders SET created_at = updated_at WHERE created_at > updated_at;

SELECT user_id FROM orders;

-- Список тех, кто совершил хотябы 1 заказ (то есть попал а таблицу orders)
SELECT name FROM users WHERE id IN (SELECT user_id FROM orders);

-- Список товаров и разделов каталога, которые им соответствуют
SELECT
  id,
  name,
  (SELECT name FROM catalogs WHERE products.catalog_id = catalogs.id) AS catalog_name
FROM products;

-- Вывести русские названия городов, соответствующих английским в таблице flights

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
  id SERIAL PRIMARY KEY,
  from_city VARCHAR(100) NOT NULL,
  to_city VARCHAR(100) NOT NULL
  );

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  lable VARCHAR(100) NOT NULL,
  name VARCHAR(100) NOT NULL
  );
 
SELECT * FROM flights;
SELECT * FROM cities;

INSERT INTO flights (from_city, to_city) VALUES
('moscow', 'omsk'),
('novgorod', 'kazan'),
('irkutsk', 'moscow'),
('omsk', 'irkutsk'),
('moscow', 'kazan');

INSERT INTO cities (lable, name) VALUES
('moscow', 'москва'),
('irkutsk', 'иркутск'),
('novgorod', 'новгород'),
('kazan', 'казань'),
('omsk', 'омск');

SELECT
	f.id,
	l1.name AS from_city,
	l2.name AS to_city
FROM
	flights AS f
JOIN
	cities AS l1
JOIN
	cities AS l2
ON f.from_city = l1.lable AND f.to_city = l2.lable
ORDER BY f.id;