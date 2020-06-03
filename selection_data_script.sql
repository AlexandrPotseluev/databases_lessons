-- Клиенты

DESC users;
DESC users_profiles;
DESC documents;

-- Грузы и заказы

DESC cargo;
DESC cargo_profiles;
DESC cargo_types;
DESC add_packaging;
DESC orders;

-- Маршруты

DESC cities;
DESC routes;

-- ПЭК

DESC offices;
DESC staff;
DESC complaints;


-- Выборки, которые использовал для проверки данных

SELECT
  client,
  first_name,
  last_name,
  users_profiles.user_type_id 
FROM users
  LEFT JOIN users_profiles
    ON users.id = users_profiles.user_id
      WHERE users_profiles.user_type_id = 'ИП';
     
SELECT
  status_id,
  COUNT(id) AS cargo
FROM cargo
GROUP BY status_id
ORDER BY status_id;

SELECT
 cargo.id,
 cargo.order_id,
 cargo.taken_at,
 orders.created_at 
  FROM orders
    LEFT JOIN cargo
      ON cargo.order_id = orders.id
        WHERE cargo.taken_at != orders.created_at
          ORDER BY order_id;
         
-- Выборка состава и стоимости грузов для конкретного заказа:

 SELECT
  orders.id AS order_id, 
  cargo.id AS cargo_id,
  cargo_profiles.weight AS weight_kg,
  cargo_profiles.sizes AS size_m3,
  cargo.items AS quant_it,
  routes.base_price AS price_1kg_1it,
  add_packaging.name AS add_pack,
  add_packaging.base_price AS pack_price_1m3,
  (cargo_profiles.weight * cargo.items * routes.base_price)
  + 
  (cargo_profiles.sizes * add_packaging.base_price) AS total_income
  FROM cargo_profiles
    RIGHT JOIN cargo ON cargo.id = cargo_profiles.cargo_id
      RIGHT JOIN orders ON cargo.order_id = orders.id
        LEFT JOIN routes ON orders.route_id = routes.id
          LEFT JOIN add_packaging ON cargo.add_pack_id = add_packaging.id
            WHERE orders.id = 12;

-- Создание предтавления 2х прайсл-листов для одного города:

 CREATE OR REPLACE VIEW from_moscow_price (delivery_type, from_city, to_city, days, base_price) AS
 SELECT
  routes.types,
  f.name,
  b.name,
  routes.days,
  routes.base_price AS 1kg_delivery_price
  FROM routes
    JOIN cities AS f
      JOIN cities AS b
        ON routes.from_city = f.id AND routes.to_city = b.id
          WHERE f.name LIKE 'Москва'
            ORDER BY routes.types;

 CREATE OR REPLACE VIEW to_moscow_price (delivery_type, from_city, to_city, days, base_price) AS
 SELECT
  routes.types,
  f.name,
  b.name,
  routes.days,
  routes.base_price AS 1kg_delivery_price
  FROM routes
    JOIN cities AS f
      JOIN cities AS b
        ON routes.from_city = f.id AND routes.to_city = b.id
          WHERE b.name LIKE 'Москва'
            ORDER BY routes.types;

(SELECT * FROM to_moscow_price)
UNION ALL
(SELECT * FROM to_moscow_price);

SELECT 

-- Проверка правильного значения статуса груза с помощью процедуры:

CALL cargo_status_сheck();


 
