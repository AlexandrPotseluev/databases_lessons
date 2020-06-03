-- Пользователи услугой и клиенты

UPDATE users SET phone = CONCAT('+7',
 '(', FLOOR(1 + (RAND() * 999)), ')',
 FLOOR(1 + (RAND() * 999)), '-', FLOOR(1 + (RAND() * 99)), '-', FLOOR(1 + (RAND() * 99)));

UPDATE users
  LEFT JOIN users_profiles
    ON users.id = users_profiles.user_id 
      SET users.client = CONCAT(first_name, ' ', last_name)
        WHERE users_profiles.user_type_id = 1;
       
UPDATE users
  LEFT JOIN users_profiles
    ON users.id = users_profiles.user_id
      SET users.client = CONCAT(users_profiles.user_type_id, ' ',first_name, ' ', last_name)
        WHERE users_profiles.user_type_id = 'ИП';

UPDATE users SET client = 'Leannon Ltd' WHERE id = 3;
UPDATE users SET client = 'Stracke Ltd' WHERE id IN (24, 27);
UPDATE users SET client = 'Nikolaus Group' WHERE id IN (36, 42);
UPDATE users SET client = 'Little Ltd' WHERE id IN (69, 72, 75);
UPDATE users SET updated_at = NOW() WHERE created_at > updated_at;

UPDATE users_profiles
  RIGHT JOIN users
    ON users.id = users_profiles.user_id
      SET users_profiles.created_at = users.created_at;
  
UPDATE  documents
  RIGHT JOIN users_profiles
    ON documents.user_id = users_profiles.user_id
      SET documents.name = 'Паспорт'
            WHERE users_profiles.user_type_id = 1 AND documents.name = 'ИНН';

UPDATE  documents
  RIGHT JOIN users_profiles
    ON documents.user_id = users_profiles.user_id
      SET documents.name = 'Паспорт'
            WHERE users_profiles.user_type_id = 2 AND documents.name = 'ИНН';

UPDATE documents SET name = "ИНН" WHERE id IN (45, 63, 112, 93, 109, 51, 57, 54, 133, 121, 87);


-- Страны, города, маршруты

UPDATE routes SET updated_at = NOW() WHERE created_at > updated_at;
UPDATE routes SET to_city = FLOOR(1 + (RAND() * 20)) WHERE from_city = to_city;

-- Заказы

UPDATE orders SET to_user = FLOOR(1 + (RAND() * 100)) WHERE from_user = to_user;
UPDATE orders SET paid_by_user = FLOOR(1 + (RAND() * 100));

-- Грузы

UPDATE cargo_profiles SET cargo_type_id = FLOOR(1 + (RAND() * 4));
UPDATE cargo_profiles SET weight = FLOOR(1 + (RAND() * 10));
UPDATE cargo_profiles SET sizes = FLOOR(1 + (RAND() * 10));
UPDATE cargo_profiles SET value = (1 + (RAND() * 100000));
UPDATE cargo SET add_pack_id = NULL WHERE id > FLOOR(1 + (RAND() * 150));

UPDATE cargo SET shipped_at = NULL WHERE id > FLOOR(1 + (RAND() * 150));
UPDATE cargo SET delivered_at = NULL WHERE id > FLOOR(1 + (RAND() * 150));
UPDATE cargo SET delivered_at = NULL WHERE shipped_at IS NULL;
UPDATE cargo SET shipped_at = NOW() WHERE taken_at > shipped_at;
UPDATE cargo SET delivered_at = NOW() WHERE shipped_at > delivered_at;

ALTER TABLE cargo ADD COLUMN handed_at DATETIME;

desc cargo;
SELECT status_id, taken_at, shipped_at, delivered_at, handed_at FROM cargo c;

UPDATE cargo SET handed_at = NOW() WHERE delivered_at IS NOT NULL;
UPDATE cargo SET handed_at = NULL WHERE id > FLOOR(1 + (RAND() * 150));
UPDATE cargo SET taken_at = NOW() WHERE shipped_at IS NULL;

UPDATE cargo SET status_id = 'выдан'
  WHERE handed_at IS NOT NULL;

UPDATE cargo SET status_id = 'доставлен'
  WHERE handed_at IS NULL;
   
UPDATE cargo SET status_id = 'отправлен'
  WHERE shipped_at IS NOT NULL AND delivered_at IS NULL;
   
UPDATE cargo SET status_id = 'принят'
  WHERE shipped_at IS NULL AND delivered_at IS NULL;
   
UPDATE orders 
  JOIN cargo 
    ON cargo.order_id = orders.id 
      SET orders.created_at = cargo.taken_at;
      
UPDATE cargo
  LEFT JOIN orders
    ON cargo.order_id = orders.id
      SET orders.created_at = cargo.taken_at
        WHERE cargo.order_id IN (COUNT(cargo.order_id) > 1;

-- Офисы и жалобы

UPDATE complaints SET closed_by = NULL WHERE id > FLOOR(1 + (RAND() * 10));

UPDATE offices 
  JOIN cities
    ON offices.city_id = cities.id 
      SET offices.name = CONCAT('ПЭК', ' ', cities.name, ' (', offices.name, ') ');
     
UPDATE staff SET phone = CONCAT('+7',
 '(', FLOOR(1 + (RAND() * 999)), ')',
 FLOOR(1 + (RAND() * 999)), '-', FLOOR(1 + (RAND() * 99)), '-', FLOOR(1 + (RAND() * 99)));

UPDATE complaints
 JOIN orders
   ON complaints.order_id = orders.id 
     SET complaints.created_at = orders.created_at;
    
UPDATE complaints
 JOIN orders
   ON complaints.order_id = orders.id 
     SET complaints.user_id = orders.from_user
       WHERE complaints.id IN (1,2,3,4);

UPDATE complaints
 JOIN orders
   ON complaints.order_id = orders.id 
     SET complaints.user_id = orders.to_user
       WHERE complaints.id IN (4,5,6,7);
      
UPDATE complaints
 JOIN orders
   ON complaints.order_id = orders.id 
     SET complaints.user_id = orders.paid_by_user 
       WHERE complaints.id IN (8,9,10);
      
UPDATE orders
  JOIN cargo
    ON cargo.order_id = orders.id
      SET orders.created_at = cargo.taken_at
        WHERE orders.created_at != cargo.taken_at;     
 

    
