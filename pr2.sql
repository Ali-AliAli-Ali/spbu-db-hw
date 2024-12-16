CREATE OR REPLACE VIEW camera_sdk_compatty AS
    SELECT DISTINCT cameras.name AS camera, cameras.type AS camera_type, sdk_versions.name AS sdk 
        FROM cameras JOIN sdk_cameras_compatty 
            ON cameras.id = sdk_cameras_compatty.camera
        JOIN ros_sdk_compatty 
            ON sdk_cameras_compatty.sdk = ros_sdk_compatty.sdk
        JOIN ros_versions 
            ON ros_sdk_compatty.ros = ros_versions.id
        JOIN sdk_versions 
            ON ros_sdk_compatty.sdk = sdk_versions.id
    ORDER BY camera;

SELECT * FROM camera_sdk_compatty
    WHERE sdk = (
        SELECT MAX(sdk) FROM camera_sdk_compatty
    )
LIMIT 20;


WITH ros_options AS (
    SELECT MAX(ubu_version) AS ubuntu, full_name AS ros FROM ros_versions
        GROUP BY full_name
        ORDER BY full_name
)
SELECT * FROM ros_options 
    WHERE ubuntu >= '20'
LIMIT 10;


EXPLAIN ANALYZE
WITH camera_sdk_names AS (
    SELECT DISTINCT cameras.name AS camera, cameras.type AS camera_type, sdk_versions.name AS sdk 
        FROM cameras JOIN sdk_cameras_compatty 
            ON cameras.id = sdk_cameras_compatty.camera
        JOIN ros_sdk_compatty 
            ON sdk_cameras_compatty.sdk = ros_sdk_compatty.sdk
        JOIN ros_versions 
            ON ros_sdk_compatty.ros = ros_versions.id
        JOIN sdk_versions 
            ON ros_sdk_compatty.sdk = sdk_versions.id
)
SELECT camera_sdk_names.camera, camera_sdk_names.camera_type, camera_sdk_names.sdk, does_compile AS can_be_executed
    FROM camera_sdk_names JOIN sdk_versions 
        ON camera_sdk_names.sdk = sdk_versions.name
ORDER BY camera, sdk;

