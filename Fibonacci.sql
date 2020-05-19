USE shop;

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
       SELECT fib_n FROM fibtable WHERE i = num;
 END / 
DELIMITER ;