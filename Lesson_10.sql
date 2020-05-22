-- Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения
-- и добавить необходимые индексы.

USE vk;

DESC users;
DESC likes;
DESC friendship;
DESC target_types;
DESC communities_users;
DESC communities;
DESC posts;
DESC media_types;
DESC media;
DESC profiles;
DESC messages;

CREATE UNIQUE INDEX users_email_idx ON users(email);
CREATE UNIQUE INDEX users_phone_idx ON users(phone);
CREATE INDEX users_id_first_name_last_name_idx ON users(id, first_name, last_name);
CREATE INDEX users_first_name_last_name_photo_id_idx ON users(first_name, last_name, photo_id);
CREATE INDEX profiles_birthday_idx ON profiles(birthday);
CREATE INDEX profiles_birthday_user_id_idx ON profiles(birthday, user_id);
CREATE INDEX profiles_city_idx ON profiles(city);
CREATE INDEX profiles_user_id_city_idx ON profiles(user_id, city);
CREATE INDEX posts_head_idx ON posts(head);
CREATE INDEX media_filename_idx ON media(filename);
CREATE INDEX messages_from_user_id_to_user_id_idx ON messages(from_user_id, to_user_id);
CREATE INDEX messages_from_user_id_community_id_idx ON messages(from_user_id, community_id);
CREATE INDEX communities_users_user_id_community_id_idx ON communities_users(user_id, community_id);


-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый старший пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

SELECT * FROM communities;
SELECT * FROM communities_users;

 SELECT DISTINCT communities.name,
   COUNT(users.id) OVER() / COUNT(communities.id) OVER w AS average_users,
   MAX(CONCAT(profiles.birthday," (",users.first_name," ",users.last_name,") ")) OVER w AS youngest_user,
   MIN(CONCAT(profiles.birthday," (",users.first_name," ",users.last_name,") ")) OVER w AS oldest_user,
   COUNT(users.id) OVER w AS users_group,
   COUNT(users.id) OVER() AS users_total,
   COUNT(users.id) OVER w / COUNT(users.id) OVER() * 100 AS '%%'
 FROM communities
   JOIN communities_users
     ON communities.id = communities_users.community_id
       JOIN profiles
         ON profiles.user_id = communities_users.user_id
           JOIN users
             ON users.id = communities_users.user_id
               WINDOW w AS (PARTITION BY communities.name);
    
-- Проверка "самый молодой и пожилой пользователь"

 SELECT
   users.first_name,
   users.last_name,
   profiles.birthday,
   communities.name 
   FROM profiles
     JOIN users
       ON profiles.user_id = users.id
        JOIN communities_users
          ON profiles.user_id = communities_users.user_id
            JOIN communities
              ON communities.id = communities_users.community_id
         WHERE communities.id = 1
         ORDER BY profiles.birthday;

