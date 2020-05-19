-- В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

USE shop;
USE sample;

SELECT * FROM users;

START TRANSACTION;
INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
COMMIT;

-- Создайте представление, которое выводит название name товарной позиции из таблицы products
-- и соответствующее название каталога name из таблицы catalogs.

DROP VIEW IF EXISTS prod_cat;
CREATE VIEW prod_cat (prod_id, prod_name, catalog_name) AS
SELECT
   p.id,
   p.name,
   c.name
FROM products AS p
LEFT JOIN catalogs AS c
ON p.catalog_id = c.id;

SELECT * FROM prod_cat;

-- Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро",
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
-- с 18:00 до 00:00 — "Добрый вечер",
-- с 00:00 до 6:00 — "Доброй ночи".

DROP PROCEDURE IF EXISTS hello;
DELIMITER /
CREATE PROCEDURE hello()
BEGIN
    CASE
      WHEN CURRENT_TIME() BETWEEN '06:00:00' AND '12:00:00' THEN SELECT 'Доброе утро';
	  WHEN CURRENT_TIME() BETWEEN '12:00:00' AND '18:00:00' THEN SELECT 'Добрый день';
	  WHEN CURRENT_TIME() BETWEEN '18:00:00' AND '00:00:00' THEN SELECT 'Добрый вечер';
	  ELSE SELECT 'Доброй ночи';
	END CASE;
END / 
DELIMITER ;

CALL hello();

-- (по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17.
-- Составьте запрос, который выводит полный список дат за август,
-- выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.

USE shop;

DROP TABLE IF EXISTS dates;
CREATE TABLE dates (
  id SERIAL PRIMARY KEY,
  created_at DATE
);

INSERT INTO dates (created_at) VALUES
  ('2018-08-01'),
  ('2016-08-04'),
  ('2018-08-16'),
  ('2018-08-17');

SELECT * FROM dates;
SELECT DAYOFMONTH(created_at) FROM dates;

WITH RECURSIVE tbl (aug_date) AS
  (
   SELECT 1
   UNION ALL
   SELECT aug_date + 1
   FROM tbl WHERE aug_date < 31
  )
SELECT
 aug_date,
 IF (aug_date = DAYOFMONTH(dates.created_at), '1', '0') AS tobe_or_nottobe
FROM tbl
LEFT JOIN dates
ON aug_date = DAYOFMONTH(dates.created_at);

-- В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
-- Допустимо присутствие обоих полей или одно из них.
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

SELECT * FROM products;
SELECT * FROM catalogs;

DROP TRIGGER IF EXISTS check_prod_name_update;
DROP TRIGGER IF EXISTS check_prod_name_insert;

DELIMITER /
CREATE TRIGGER check_prod_name_update BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	CASE
	  WHEN NEW.name IS NULL AND NEW.description IS NULL THEN 
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 
	     'UPDATE canceled. Please set NOT NULL VALUE at least for name or description';
	END CASE;
END/

CREATE TRIGGER check_prod_name_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	DECLARE notnull_desc TEXT;
	CASE
	  WHEN NEW.catalog_id IS NULL AND NEW.description IS NULL THEN
        SET notnull_desc = 'is not defined';
	  WHEN NEW.catalog_id IS NOT NULL AND NEW.description IS NULL THEN
	    SELECT name INTO notnull_desc FROM catalogs WHERE id = NEW.catalog_id;
	  ELSE SET notnull_desc = NEW.description;
	END CASE;
    SET NEW.description = COALESCE(NEW.description, notnull_desc);
END/

DELIMITER ;

UPDATE products SET
  name = NULL,
  description = NULL
WHERE id = 7;

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  (NULL, NULL, 7890.00, 1),
  (NULL, 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, NULL),
  ('AMD FX-8320E', NULL, 4780.00, NULL);

-- (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи.
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел.
-- Вызов функции FIBONACCI(10) должен возвращать число 55.

DROP PROCEDURE IF EXISTS FIBONACCI;
DELIMITER /
CREATE PROCEDURE FIBONACCI(IN num INT)
BEGIN
	 WITH RECURSIVE fibtable (i, n, fib_n) AS
      (
       SELECT 1, 0, 1
       UNION ALL
       SELECT i + 1, fib_n, n + fib_n
       FROM fibtable WHERE i < num
      )
      SELECT fib_n FROM fibonacci WHERE i = num;
END / 
DELIMITER ;

CALL FIBONACCI(10);

