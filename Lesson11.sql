-- Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users,
-- catalogs и products в таблицу logs помещается время и дата создания записи,
-- название таблицы, идентификатор первичного ключа и содержимое поля name.

 USE shop;

 SELECT * FROM logs;

 DESC users;
 DESC catalogs;
 DESC products;

 DROP TABLE IF EXISTS logs;
 CREATE TABLE logs (
	created_at DATETIME DEFAULT NOW(),
	table_name VARCHAR(50) NOT NULL,
	key_id INT UNSIGNED NOT NULL,
	name_value VARCHAR(255)
 ) ENGINE = ARCHIVE;

 DROP TRIGGER IF EXISTS logs_users;
 DROP TRIGGER IF EXISTS logs_catalogs;
 DROP TRIGGER IF EXISTS logs_products;

DELIMITER /
 CREATE TRIGGER logs_users AFTER INSERT ON users
 FOR EACH ROW
 BEGIN
	 INSERT INTO logs (table_name, key_id, name_value) 
	 VALUES ('users', NEW.id, NEW.name);
 END/

 CREATE TRIGGER logs_catalogs AFTER INSERT ON catalogs
 FOR EACH ROW
 BEGIN
	 INSERT INTO logs (table_name, key_id, name_value) 
	 VALUES ('catalogs', NEW.id, NEW.name);
 END/

 CREATE TRIGGER logs_products AFTER INSERT ON products
 FOR EACH ROW
 BEGIN
	 INSERT INTO logs (table_name, key_id, name_value) 
	 VALUES ('products', NEW.id, NEW.name);
 END/

DELIMITER ;

 INSERT INTO users (name, birthday_at) VALUES
   ('Brad Pitt', '1963-12-18');

 INSERT INTO catalogs (name) VALUES
   ('Блоки питания');
 
 INSERT INTO products
   (name, description, price, catalog_id)
 VALUES
   ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1);
  
-- (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

 -- Процедура для вставки любого количества пользователей.

 DROP PROCEDURE IF EXISTS insert_users_to_users;

DELIMITER /
 CREATE PROCEDURE insert_users_to_users(IN n INT UNSIGNED DEFAULT 0)
 BEGIN
	 DECLARE i INT DEFAULT 0;
	 DECLARE user_id INT UNSIGNED;
	 
	 SET user_id = COALESCE((SELECT MAX(users.id) FROM users), 0) + 1;
	 
	 IF n > 0 THEN
	   WHILE i < n DO
	     INSERT INTO users (name, birthday_at) VALUES (CONCAT('user ', user_id), NOW());
	     SET i = i + 1;
	     SET user_id = user_id + 1;
	   END WHILE;
	 ELSE
	   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Please set how many users to insert';
 	 END IF;
 END/
 
DELIMITER ;

 CALL insert_users_to_users();
 
 SELECT * FROM users;

-- В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

SADD ip 127.0.0.1 127.0.0.2 127.0.0.3 127.0.0.3
SCARD ip

-- При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот,
-- поиск электронного адреса пользователя по его имени.

 MSET potseluev potseluev@icloud.com potseluev1998@yandex.ru potseluev
 GET potseluev
 GET potseluev1998@yandex.ru
 
