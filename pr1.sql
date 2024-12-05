-- basic table creation


CREATE TABLE cameras (
	id       SERIAL PRIMARY KEY UNIQUE NOT NULL, 
    name     VARCHAR UNIQUE NOT NULL,
	series   VARCHAR,
    type     VARCHAR NOT NULL,
    has_imu  BOOLEAN,
    has_infr BOOLEAN,
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
    is_compiling BOOLEAN NOT NULL
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


