USE vk;

-- Создать и заполнить таблицы лайков и постов

DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO posts
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 10)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;

DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');
 
INSERT INTO likes 
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;

-- Создать все необходимые внешние ключи и диаграмму отношений 

DESC profiles;
DESC messages;
DESC media;
DESC friendship;
DESC friendship_statuses;
DESC communities;
DESC communities_users;
DESC likes;
DESC posts;
DESC target_types;
DESC media;


ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id)
      ON DELETE SET NULL,
  ADD CONSTRAINT messages_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE SET NULL;
     
 ALTER TABLE messages 
   DROP FOREIGN KEY messages_from_user_id_fk,
   DROP FOREIGN KEY messages_to_user_id_fk,
   DROP FOREIGN KEY messages_community_id_fk;
   
ALTER TABLE communities_users 
  ADD CONSTRAINT commities_users_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT commities_users_communities_id_fk
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE CASCADE;
 
ALTER TABLE media
  ADD CONSTRAINT media_type_id_fk 
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT media_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;
     
ALTER TABLE friendship
  ADD CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT friendship_friend_id_fk 
    FOREIGN KEY (friend_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT friendship_status_id_fk 
   FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
      ON DELETE CASCADE;
     
ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT posts_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE SET NULL,
  ADD CONSTRAINT posts_media_id_fk 
   FOREIGN KEY (media_id) REFERENCES media(id)
      ON DELETE SET NULL;
 
ALTER TABLE likes 
  ADD CONSTRAINT likes_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
     ON DELETE CASCADE, 
  ADD CONSTRAINT likes_target_type_id_fk 
    FOREIGN KEY (target_type_id) REFERENCES target_types(id)
      ON DELETE CASCADE;

UPDATE messages SET community_id = NULL 
  WHERE community_id >  FLOOR(1 + RAND() * 20);

UPDATE messages SET to_user_id = NULL 
  WHERE to_user_id >  FLOOR(1 + RAND() * 100)
    AND community_id IS not NULL;
   
UPDATE messages SET community_id = 
 (SELECT community_id FROM communities_users
    WHERE communities_users.user_id = messages.from_user_id ORDER BY RAND() LIMIT 1)
  WHERE to_user_id IS NULL;
 
UPDATE messages SET to_user_id = 
  (SELECT user_id FROM communities_users
    WHERE communities_users.community_id = messages.community_id ORDER BY RAND() LIMIT 1)
  WHERE from_user_id = to_user_id;
 
SELECT * FROM likes;
SELECT * FROM friendship;
SELECT * FROM target_types;
SELECT * FROM communities_users;
SELECT * FROM communities;
SELECT * FROM posts p;
SELECT * FROM media_types mt ;
SELECT * FROM media m;
SELECT * FROM profiles p;
SELECT * FROM users u;

UPDATE posts SET community_id = NULL 
  WHERE community_id >  FLOOR(1 + RAND() * 20);
 
UPDATE posts SET community_id = 
  (SELECT community_id FROM communities_users
    WHERE communities_users.user_id = posts.user_id ORDER BY RAND() LIMIT 1)
  WHERE community_id IS NOT NULL;
 
UPDATE posts SET media_id = 
  (SELECT id FROM media
    WHERE media.user_id = posts.user_id ORDER BY RAND() LIMIT 1)
  WHERE media_id IS NOT NULL;
 
 UPDATE likes SET target_type_id = 
  (SELECT id FROM target_types ORDER BY RAND() LIMIT 1);
 
 UPDATE likes SET user_id = 
  (SELECT id FROM users ORDER BY RAND() LIMIT 1);

 -- Подсчитать общее количество лайков десяти самым молодым пользователям
 -- (сколько лайков получили 10 самых молодых пользователей)

SELECT COUNT(id) AS top10_young_likes
 FROM likes 
  WHERE
  (
    target_type_id = (SELECT id FROM target_types WHERE name LIKE 'users')
    AND
    target_id IN
    (SELECT * FROM
        (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) 
         AS age)
  );
      
 -- Определить кто больше поставил лайков (всего) - мужчины или женщины?
 
 SELECT
   COUNT(id) AS total_likes,
   (SELECT
     CASE (gender)
       WHEN 'm' THEN 'man'
       WHEN 'f' THEN 'women'
     END
    FROM profiles
    WHERE profiles.user_id = likes.user_id) AS gender
 FROM likes 
 GROUP BY gender;

-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети

SELECT
 (SELECT CONCAT(first_name, ' ', last_name) 
    FROM users 
      WHERE users.id = likes.user_id) AS low_activity_users,
 COUNT(id) AS total_likes
FROM likes
GROUP BY user_id
HAVING total_likes < 3
ORDER BY total_likes LIMIT 10;
 