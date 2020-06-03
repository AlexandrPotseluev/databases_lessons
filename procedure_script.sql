 -- Процедура проверки правильного назначения статуса груза

 DROP PROCEDURE IF EXISTS cargo_status_сheck;
 
 DROP TABLE IF EXISTS cargo_status_сheck_table;
 CREATE TABLE cargo_status_сheck_table(
     time_check DATETIME DEFAULT NOW(),
     results TEXT
 ) ENGINE = ARCHIVE;

DELIMITER /

 CREATE PROCEDURE cargo_status_сheck()
 BEGIN
	 DECLARE done BOOLEAN DEFAULT FALSE;
     DECLARE fine VARCHAR(50);
	 DECLARE cargo_id INT;
	 DECLARE cargo_status VARCHAR(50);
	 DECLARE cargo_taken DATETIME;
	 DECLARE cargo_shipped DATETIME;
	 DECLARE cargo_delivered DATETIME;
	 DECLARE cargo_handed DATETIME;
	 DECLARE check_result TEXT;
	
	 DECLARE reading_cargo CURSOR FOR SELECT id, status_id, taken_at, shipped_at, delivered_at, handed_at FROM cargo;
	 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	 OPEN reading_cargo;
	
	 read_loop: LOOP
	   FETCH reading_cargo INTO cargo_id, cargo_status, cargo_taken, cargo_shipped, cargo_delivered, cargo_handed;
	  
	    IF done THEN
	      LEAVE read_loop;
	    END IF;
	   
  	    CASE 
	       WHEN cargo_status = 'принят' AND
	           cargo_taken IS NOT NULL AND 
	           cargo_shipped IS NULL AND 
	           cargo_delivered IS NULL AND
	           cargo_handed IS NULL
                 THEN SET fine = "is fine!";
           WHEN cargo_status = 'отправлен' AND
               cargo_taken IS NOT NULL AND 
	           cargo_shipped IS NOT NULL AND 
	           cargo_delivered IS NULL AND
	           cargo_handed IS NULL
                 THEN SET fine = "is fine!";
           WHEN cargo_status = 'доставлен' AND
               cargo_taken IS NOT NULL AND 
	           cargo_shipped IS NOT NULL AND 
	           cargo_delivered IS NOT NULL AND
	           cargo_handed IS NULL
                 THEN SET fine = "is fine!";
           WHEN cargo_status = 'выдан' AND
               cargo_taken IS NOT NULL AND 
	           cargo_shipped IS NOT NULL AND 
	           cargo_delivered IS NOT NULL AND
	           cargo_handed IS NOT NULL
                  THEN SET fine = "is fine!";
           ELSE SET fine = "is WRONG!";
  	     END CASE;
  	     
  	     SET check_result = CONCAT("Cargo id: ", cargo_id, ", satus: ", " ", fine);
  	     INSERT INTO cargo_status_сheck_table (results) VALUES (check_result);
  	  
  	  END LOOP;
  	   
  	  CLOSE reading_cargo;
  	 
  	  SELECT * FROM cargo_status_сheck_table;  
 END/
 
DELIMITER ;

