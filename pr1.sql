-- basic table creation


CREATE TABLE cameras (
	id       SERIAL PRIMARY KEY UNIQUE NOT NULL, 
    name     VARCHAR UNIQUE NOT NULL,
	series   VARCHAR,
    type     VARCHAR NOT NULL,
    has_imu  BOOLEAN DEFAULT false,
    has_infr BOOLEAN DEFAULT false,
    is_eol   BOOLEAN NOT NULL DEFAULT false
);


CREATE TABLE ros_versions (
	id           SERIAL PRIMARY KEY UNIQUE NOT NULL, 
	name         VARCHAR NOT NULL, 
    ubu_version  VARCHAR NOT NULL
);


CREATE TABLE sdk_versions (
    id           SERIAL PRIMARY KEY UNIQUE NOT NULL, 
	name         VARCHAR NOT NULL, 
    year         INT NOT NULL CHECK (year >= 2000 AND year <= date_part('year', CURRENT_DATE)),
    does_compile BOOLEAN NOT NULL
);


-- linking table creation


CREATE TABLE ros_sdk_compatty (
    id  SERIAL PRIMARY KEY UNIQUE NOT NULL, 
	ros INT REFERENCES ros_versions(id)
		ON UPDATE CASCADE 
		ON DELETE CASCADE, 
	sdk INT REFERENCES sdk_versions(id)
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);


CREATE TABLE sdk_cameras_compatty (
    id     SERIAL PRIMARY KEY UNIQUE NOT NULL, 
	sdk    INT REFERENCES sdk_versions(id)
		ON UPDATE CASCADE 
		ON DELETE CASCADE, 
	camera INT REFERENCES cameras(id)
	    ON UPDATE CASCADE 
		ON DELETE CASCADE
);


-- triggers for field setting and checking


CREATE OR REPLACE FUNCTION set_series()
RETURNS TRIGGER AS $$
BEGIN
	CASE 
		WHEN NEW.name LIKE 'D4%'  THEN NEW.series = 'D400';
		WHEN NEW.name LIKE 'L5%'  THEN NEW.series = 'L500';
		WHEN NEW.name LIKE 'F2%'  THEN NEW.series = 'F200';
		WHEN NEW.name LIKE 'SR3%' THEN NEW.series = 'SR300';
		WHEN NEW.name LIKE 'T2%'  THEN NEW.series = 'T200';
	END CASE;
    RAISE NOTICE 'The camera % series is set to %.', NEW.name, NEW.series;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER set_series_trigger
    BEFORE INSERT OR UPDATE ON cameras
    FOR EACH ROW 
EXECUTE FUNCTION set_series();


CREATE OR REPLACE FUNCTION check_type()
RETURNS TRIGGER AS $$
BEGIN
	IF NOT NEW.type = ANY(
        '{"Depth Camera", "LiDAR Camera", "Tracking Camera"}'
    ) THEN
        RAISE WARNING 'The camera % type may be written wrong.', NEW.name 
        USING HINT = 'Please check your spelling and correct the camera type if needed.';
    END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_type_trigger
    BEFORE INSERT OR UPDATE ON cameras
    FOR EACH ROW 
EXECUTE FUNCTION check_type();


CREATE OR REPLACE FUNCTION set_has_imu()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.name LIKE '%i%' THEN
        RAISE NOTICE 'The camera % seems to have an IMU. The according field is set to true', NEW.name;
        NEW.has_imu = true;
    END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER set_has_imu_trigger
    BEFORE INSERT OR UPDATE ON cameras
    FOR EACH ROW 
EXECUTE FUNCTION set_has_imu();


CREATE OR REPLACE FUNCTION set_has_infr()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.name LIKE '%f%' THEN
        RAISE NOTICE 'The camera % seems to have an IR-Pass filter. The according field is set to true', NEW.name;
        NEW.has_infr = true;
    END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER set_has_infr_trigger
    BEFORE INSERT OR UPDATE ON cameras
    FOR EACH ROW 
EXECUTE FUNCTION set_has_infr();


CREATE OR REPLACE FUNCTION check_ubuntu()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT NEW.ubu_version = ANY(
        '{"14.04", "16.04", "18.04", "20.04", "22.04", "24.04", "24.10"}'
    ) THEN
        RAISE EXCEPTION 'The Ubuntu version of % is invalid.', NEW.name
        USING HINT = 'Please enter 2 numbers (with point as a delimeter) representing the Ubuntu version.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_ubuntu_trigger
    BEFORE INSERT OR UPDATE ON ros_versions
    FOR EACH ROW
EXECUTE FUNCTION check_ubuntu();

