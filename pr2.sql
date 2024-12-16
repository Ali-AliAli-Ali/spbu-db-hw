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

'''
Sort  (cost=21565.12..21872.04 rows=122767 width=97) (actual time=0.559..0.564 rows=18 loops=1)
  Sort Key: cameras.name, sdk_versions_1.name
  Sort Method: quicksort  Memory: 25kB
  ->  Merge Join  (cost=2623.99..4471.40 rows=122767 width=97) (actual time=0.501..0.518 rows=18 loops=1)
        Merge Cond: ((sdk_versions.name)::text = (sdk_versions_1.name)::text)
        ->  Sort  (cost=82.01..84.96 rows=1180 width=33) (actual time=0.102..0.103 rows=11 loops=1)
              Sort Key: sdk_versions.name
              Sort Method: quicksort  Memory: 25kB
              ->  Seq Scan on sdk_versions  (cost=0.00..21.80 rows=1180 width=33) (actual time=0.027..0.031 rows=11 loops=1)
        ->  Sort  (cost=2541.98..2594.00 rows=20808 width=96) (actual time=0.395..0.399 rows=18 loops=1)
              Sort Key: sdk_versions_1.name
              Sort Method: quicksort  Memory: 25kB
              ->  HashAggregate  (cost=841.47..1049.55 rows=20808 width=96) (actual time=0.276..0.370 rows=18 loops=1)
                    Group Key: cameras.name, cameras.type, sdk_versions_1.name
                    Batches: 1  Memory Usage: 793kB
                    ->  Merge Join  (cost=363.09..685.41 rows=20808 width=96) (actual time=0.199..0.228 rows=58 loops=1)
                          Merge Cond: (sdk_cameras_compatty.sdk = ros_sdk_compatty.sdk)
                          ->  Sort  (cost=171.88..176.98 rows=2040 width=68) (actual time=0.099..0.102 rows=46 loops=1)
                                Sort Key: sdk_cameras_compatty.sdk
                                Sort Method: quicksort  Memory: 26kB
                                ->  Hash Join  (cost=23.95..59.74 rows=2040 width=68) (actual time=0.063..0.084 rows=46 loops=1)
                                      Hash Cond: (sdk_cameras_compatty.camera = cameras.id)
                                      ->  Seq Scan on sdk_cameras_compatty  (cost=0.00..30.40 rows=2040 width=8) (actual time=0.019..0.023 rows=46 loops=1)
                                      ->  Hash  (cost=16.20..16.20 rows=620 width=68) (actual time=0.023..0.023 rows=7 loops=1)
                                            Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                            ->  Seq Scan on cameras  (cost=0.00..16.20 rows=620 width=68) (actual time=0.014..0.016 rows=7 loops=1)
                          ->  Sort  (cost=191.21..196.31 rows=2040 width=40) (actual time=0.097..0.102 rows=55 loops=1)
                                Sort Key: ros_sdk_compatty.sdk
                                Sort Method: quicksort  Memory: 25kB
                                ->  Hash Join  (cost=37.82..79.06 rows=2040 width=40) (actual time=0.077..0.088 rows=13 loops=1)
                                      Hash Cond: (ros_sdk_compatty.sdk = sdk_versions_1.id)
                                      ->  Hash Join  (cost=1.27..37.14 rows=2040 width=4) (actual time=0.044..0.051 rows=13 loops=1)
                                            Hash Cond: (ros_sdk_compatty.ros = ros_versions.id)
                                            ->  Seq Scan on ros_sdk_compatty  (cost=0.00..30.40 rows=2040 width=8) (actual time=0.012..0.013 rows=13 loops=1)
                                            ->  Hash  (cost=1.12..1.12 rows=12 width=4) (actual time=0.022..0.022 rows=12 loops=1)
                                                  Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                                  ->  Seq Scan on ros_versions  (cost=0.00..1.12 rows=12 width=4) (actual time=0.013..0.015 rows=12 loops=1)
                                      ->  Hash  (cost=21.80..21.80 rows=1180 width=36) (actual time=0.017..0.017 rows=11 loops=1)
                                            Buckets: 2048  Batches: 1  Memory Usage: 17kB
                                            ->  Seq Scan on sdk_versions sdk_versions_1  (cost=0.00..21.80 rows=1180 width=36) (actual time=0.009..0.011 rows=11 loops=1)
Planning Time: 0.846 ms
Execution Time: 1.420 ms
'''