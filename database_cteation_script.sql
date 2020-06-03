-- Логистическая компания ПЭК предоставляет услуги по перевозки грузов из одного терминала в другой.
-- Предполагаю, что лигистическая специфика выглядит следующим образом.
-- Есть 3 основных сущности пользователей услуги: Клиент (тот, кто платит), отправитель груза и получатель.
-- Все 3 сущности могут быть как одним человеком, так и все 3 - разными.
-- Получатель груза может имень несколько документов по которому получает груз, главное, чтобы он был указан для получения.
-- В один заказ может входить несколько грузов и каждый может иметь свои характеристики.
-- После прохождения грузом каждого этапа, информация о его статусе отправляетя любому из сощностей пользователей.
-- Могут быть ошибки при доставке одного или нескольких грузов. Их необходимо учитывать, чтобы найти груз клиента.


DROP DATABASE IF EXISTS pecom;
CREATE DATABASE pecom;

USE pecom;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  client VARCHAR(100) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  phone VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

 DROP TABLE IF EXISTS users_profiles;
 CREATE TABLE users_profiles (
   user_id INT UNSIGNED NOT NULL,
   user_type_id ENUM('Физ. лицо', 'ИП', 'Юр. лицо') NOT NULL,
   document_id INT UNSIGNED NOT NULL,
   created_at DATETIME DEFAULT NOW(),
   updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
 );

 DROP TABLE IF EXISTS cities;
 CREATE TABLE cities (
   id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(50) NOT NULL,
   coutry_id ENUM('Россия', 'Казахстан', 'Китай', 'Евросоюз') NOT NULL
 );

DROP TABLE IF EXISTS offices;
CREATE TABLE offices (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  city_id INT UNSIGNED NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

DROP TABLE IF EXISTS documents;
CREATE TABLE documents (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  docnumber INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL
);

DROP TABLE IF EXISTS routes;
CREATE TABLE routes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_city INT UNSIGNED NOT NULL,
  to_city INT UNSIGNED NOT NULL,
  types ENUM('авто', 'авиа', 'экспресс') NOT NULL,
  days INT UNSIGNED NOT NULL,
  base_price DECIMAL (8,2) NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_user INT UNSIGNED NOT NULL,
  to_user INT UNSIGNED NOT NULL,
  paid_by_user INT UNSIGNED NOT NULL,
  route_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

DROP TABLE IF EXISTS cargo;
CREATE TABLE cargo (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  items INT UNSIGNED NOT NULL,
  add_pack_id INT UNSIGNED,
  order_id INT UNSIGNED NOT NULL,
  status_id ENUM('принят', 'отправлен', 'в пути', 'доставлен', 'выдан') NOT NULL,
  taken_at DATETIME DEFAULT NOW(),
  shipped_at DATETIME,
  delivered_at DATETIME
);

DROP TABLE IF EXISTS cargo_status_changes;
 CREATE TABLE logs_orders (
	created_at DATETIME DEFAULT NOW(),
	cargo_id INT UNSIGNED NOT NULL,
	cargo_status ENUM('принят', 'отправлен', 'в пути', 'доставлен', 'выдан') NOT NULL
 ) ENGINE = ARCHIVE;

DROP TABLE IF EXISTS cargo_profiles;
CREATE TABLE cargo_profiles (
  cargo_id INT UNSIGNED NOT NULL,
  cargo_type_id ENUM('стандартный', 'хрупкий', 'с терморежимом', 'жидкий') NOT NULL,
  weight DECIMAL (8,2) DEFAULT 1,
  sizes INT UNSIGNED NOT NULL,
  value DECIMAL (11,2) DEFAULT 100,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

DROP TABLE IF EXISTS add_packaging;
CREATE TABLE add_packaging (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  base_price DECIMAL (6,2) NOT NULL
);

DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  office_id INT UNSIGNED NOT NULL,
  phone VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

DROP TABLE IF EXISTS complaints;
CREATE TABLE complaints (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  order_id INT UNSIGNED NOT NULL,
  head VARCHAR(255),
  body TEXT NOT NULL,
  accepted_by INT UNSIGNED NOT NULL,
  closed_by INT UNSIGNED,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

ALTER TABLE users_profiles
  ADD CONSTRAINT users_profiles_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT users_profiles_document_id_fk 
    FOREIGN KEY (document_id) REFERENCES documents(id)
      ON DELETE CASCADE;
      
ALTER TABLE offices
  ADD CONSTRAINT offices_cities_id_fk
    FOREIGN KEY (city_id) REFERENCES cities(id)
      ON DELETE CASCADE;
      
ALTER TABLE documents
  ADD CONSTRAINT documents_users_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

ALTER TABLE routes
  ADD CONSTRAINT routes_from_city_fk 
    FOREIGN KEY (from_city) REFERENCES cities(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT routes_to_city_fk 
    FOREIGN KEY (to_city) REFERENCES cities(id)
      ON DELETE CASCADE;
     
ALTER TABLE orders
  ADD CONSTRAINT orders_from_user_fk 
    FOREIGN KEY (from_user) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT orders_to_user_fk 
    FOREIGN KEY (to_user) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT orders_paid_by_user_fk 
    FOREIGN KEY (paid_by_user) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT orders_route_id_fk 
    FOREIGN KEY (route_id) REFERENCES routes(id)
      ON DELETE CASCADE;
     
ALTER TABLE cargo
  ADD CONSTRAINT cargo_add_pack_id_fk 
    FOREIGN KEY (add_pack_id) REFERENCES add_packaging(id)
      ON DELETE SET NULL,
  ADD CONSTRAINT cargo_order_id_fk 
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON DELETE CASCADE;
 
 ALTER TABLE cargo_profiles
  ADD CONSTRAINT cargo_profiles_cargo_id_fk 
    FOREIGN KEY (cargo_id) REFERENCES cargo(id)
      ON DELETE CASCADE;
     
ALTER TABLE staff
  ADD CONSTRAINT staff_office_id_fk 
    FOREIGN KEY (office_id) REFERENCES offices(id)
      ON DELETE CASCADE;

ALTER TABLE complaints
  ADD CONSTRAINT complaints_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT complaints_order_id_fk 
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT complaints_accepted_by_fk 
    FOREIGN KEY (accepted_by) REFERENCES staff(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT complaints_closed_by_fk 
    FOREIGN KEY (closed_by) REFERENCES staff(id)
      ON DELETE SET NULL;

-- Индексы

CREATE UNIQUE INDEX users_email_idx ON users(email);
CREATE UNIQUE INDEX users_phone_idx ON users(phone);
CREATE UNIQUE INDEX users_client_phone_idx ON users(client, phone);
CREATE UNIQUE INDEX users_client_email_idx ON users(client, email);
CREATE INDEX users_profiles_user_id_document_id_idx ON users_profiles(user_id, document_id);

CREATE INDEX cargo_id_items_idx ON cargo(id, items);
CREATE INDEX cargo_id_add_pack_id_idx ON cargo(id, add_pack_id);
CREATE INDEX cargo_id_order_id_idx ON cargo(id, order_id);
CREATE INDEX cargo_profiles_cargo_id_weight_idx ON cargo_profiles(cargo_id, weight);
CREATE INDEX cargo_profiles_cargo_id_sizes_idx ON cargo_profiles(cargo_id, sizes);

CREATE INDEX orders_id_route_id_idx ON orders(id, route_id);
CREATE INDEX orders_from_user_to_user_paid_by_user_idx ON orders(from_user, to_user, paid_by_user);

CREATE INDEX routes_id_base_price_idx ON routes(id, base_price);
CREATE INDEX routes_from_city_to_city_idx ON routes(id, from_city, to_city);

CREATE INDEX offices_id_city_id_address_idx ON offices(id, city_id, address);
CREATE UNIQUE INDEX offices_phone_idx ON offices(phone);
CREATE UNIQUE INDEX offices_email_idx ON offices(email);
CREATE INDEX staff_first_name_last_name_idx ON staff(first_name, last_name);
CREATE INDEX staff_id_office_id_idx ON staff(id, office_id);


 