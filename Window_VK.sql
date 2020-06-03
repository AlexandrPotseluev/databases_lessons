-- Построить запрос, который будет выводить следующие столбцы:
 -- 1. имя группы
 -- 2. среднее количество пользователей в группах
 -- 3. самый молодой пользователь в группе
 -- 4. самый старший пользователь в группе
 -- 5. общее количество пользователей в группе
 -- 6. всего пользователей в системе
 -- 7. отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

USE vk;

SELECT DISTINCT communities.name,
    (SELECT COUNT(id) FROM users) / (SELECT COUNT(id) FROM communities) AS average_users,
    FIRST_VALUE(users.first_name) OVER w_young AS young_first_name,
    FIRST_VALUE(users.last_name) OVER w_young AS young_last_name,
    FIRST_VALUE(users.first_name) OVER w_old AS old_first_name,
    FIRST_VALUE(users.last_name) OVER w_old AS old_last_name,
    COUNT(communities_users.user_id) OVER w AS users_group,
    (SELECT COUNT(id) FROM users) AS users_total,
    COUNT(communities_users.user_id) OVER w / (SELECT COUNT(id) FROM users) * 100 AS '%%'
  FROM communities
    LEFT JOIN communities_users
      ON communities.id = communities_users.community_id
        LEFT JOIN profiles
          ON profiles.user_id = communities_users.user_id
            LEFT JOIN users
              ON users.id = communities_users.user_id
                WINDOW w AS (PARTITION BY communities.name),
                       w_young AS (PARTITION BY communities.name ORDER BY profiles.birthday DESC),
                       w_old AS (PARTITION BY communities.name ORDER BY profiles.birthday);
                
               