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

    INSERT INTO cameras(name, type)
    SELECT DISTINCT 'L535', type FROM cameras 
        WHERE series = 'L500';
    SELECT * FROM cameras
    LIMIT 10;

COMMIT;



CREATE OR REPLACE FUNCTION catch_imu_infr_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.has_imu != OLD.has_imu) OR (NEW.has_infr != OLD.has_infr) THEN
        RAISE EXCEPTION 'The fields you are trying to update are set automatically according to camera name.'
        USING HINT = 'Please change the name to reset the fields.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER catch_opts_change_trigger
    BEFORE UPDATE ON cameras
    FOR EACH ROW
EXECUTE FUNCTION catch_imu_infr_change();


BEGIN;
    UPDATE cameras SET has_imu = False 
        WHERE name = 'D435if';
COMMIT;