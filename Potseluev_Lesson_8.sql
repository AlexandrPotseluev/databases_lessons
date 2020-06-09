 -- Подсчитать общее количество лайков десяти самым молодым пользователям
 -- (сколько лайков получили 10 самых молодых пользователей)

SELECT -- С использованием JOIN
  COUNT(likes.id)
FROM likes
RIGHT JOIN profiles
  ON 
   profiles.user_id = likes.target_id
  AND 
   likes.target_type_id = 2
GROUP BY profiles.user_id
ORDER BY profiles.birthday DESC LIMIT 10;

SELECT COUNT(id) AS top10_young_likes -- Вложенный запрос
 FROM likes 
  WHERE (
    target_type_id = (SELECT id FROM target_types WHERE name LIKE 'users')
      AND
       target_id IN (SELECT * FROM
        (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) 
           AS age)
  );

 -- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT        -- С использованием JOIN
  gender,
  COUNT(likes.id) AS total_likes 
FROM profiles
JOIN likes
ON profiles.user_id = likes.user_id
GROUP BY gender
ORDER BY total_likes DESC LIMIT 1;

SELECT  -- Вложенный запрос
   (SELECT
     CASE (gender)
       WHEN 'm' THEN 'men'
       WHEN 'f' THEN 'women'
     END
    FROM profiles
    WHERE profiles.user_id = likes.user_id) AS gender,
    COUNT(id) AS total_likes
 FROM likes 
 GROUP BY gender
 ORDER BY total_likes DESC LIMIT 1;

-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети

SELECT -- С использованием JOIN
  CONCAT(first_name, " ", last_name) AS user_name, 
  COUNT(likes.id) AS total_likes
FROM users
JOIN likes
  ON users.id = likes.user_id
GROUP BY user_id
HAVING total_likes < AVG(total_likes)
ORDER BY total_likes LIMIT 10;


-- Вложенный запрос
SELECT
 (SELECT CONCAT(first_name, ' ', last_name) 
    FROM users 
      WHERE users.id = likes.user_id) AS low_activity_users,
 COUNT(id) AS total_likes
FROM likes
GROUP BY user_id
HAVING total_likes < AVG(total_likes)
ORDER BY total_likes LIMIT 10;