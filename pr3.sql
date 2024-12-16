CREATE OR REPLACE FUNCTION check_camera_name()
RETURNS TRIGGER AS $$
BEGIN
    IF LOWER(NEW.name) = ANY(
        ARRAY(SELECT LOWER(name) FROM cameras)
    ) THEN
        RAISE EXCEPTION 'The camera % is already in the table.', NEW.name
        USING HINT = 'Please check your spelling or update the existing row if needed.';
    ELSE 
        RAISE NOTICE 'The new camera % is added to "cameras" table.', NEW.name;
        RAISE LOG 'New camera % is added to "cameras" table.', NEW.name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_camera_name_trigger
    BEFORE INSERT ON cameras
    FOR EACH ROW
EXECUTE FUNCTION check_camera_name();


BEGIN;

    UPDATE cameras SET name = 'F200'
        WHERE name = 'F250';
    SELECT * FROM cameras
    LIMIT 10;

SAVEPOINT savepoint_250to200;

    INSERT INTO cameras(name, type) VALUES
    ('L535', 'Lidar Camera');
    SELECT * FROM cameras
    LIMIT 10;

SAVEPOINT savepoint_newcam;

ROLLBACK TO savepoint_200to250;

    SELECT DISTINCT type FROM cameras;
    INSERT INTO cameras(name, type) VALUES
    ('L535', 'LiDAR Camera');
    SELECT * FROM cameras
    LIMIT 10;

COMMIT;
