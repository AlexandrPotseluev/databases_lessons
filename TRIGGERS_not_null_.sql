USE shop;

DROP TRIGGER IF EXISTS check_prod_name_update;
DROP TRIGGER IF EXISTS check_prod_name_insert;

DELIMITER /
CREATE TRIGGER check_prod_name_update BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	CASE
	  WHEN NEW.name IS NULL AND NEW.description IS NULL THEN 
 	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 
 	     'UPDATE canceled. Please set NOT NULL VALUE at least for name or description';
 	END CASE;
END/

CREATE TRIGGER check_prod_name_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
 	DECLARE notnull_desc TEXT;
 	CASE
 	  WHEN NEW.catalog_id IS NULL AND NEW.description IS NULL THEN
         SET notnull_desc = 'is not defined';
 	  WHEN NEW.catalog_id IS NOT NULL AND NEW.description IS NULL THEN
 	    SELECT name INTO notnull_desc FROM catalogs WHERE id = NEW.catalog_id;
 	  ELSE SET notnull_desc = NEW.description;
 	END CASE;
     SET NEW.description = COALESCE(NEW.description, notnull_desc);
END/

DELIMITER ;