 -- Отслеживание движение груза для отправки клиентам изменений его статуса

DROP TRIGGER IF EXISTS cargo_status_changes;

DELIMITER /

 CREATE TRIGGER cargo_status_changes AFTER INSERT ON cargo
 FOR EACH ROW
 BEGIN
	 INSERT INTO cargo_status_changes (cargo_id, cargo_status) 
	 VALUES (NEW.id, NEW.status_id);
 END/

DELIMITER ;