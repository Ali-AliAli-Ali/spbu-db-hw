CREATE OR REPLACE VIEW camera_sdk_names AS
    SELECT cameras.name AS camera, cameras.type AS camera_type, sdk_versions.name AS sdk 
        FROM cameras JOIN sdk_cameras_compatty 
            ON cameras.id = sdk_cameras_compatty.camera
        JOIN sdk_versions 
            ON sdk_cameras_compatty.sdk = sdk_versions.id
    ORDER BY camera, sdk;

SELECT * FROM camera_sdk_names
    WHERE sdk = (
        SELECT MAX(sdk) FROM camera_sdk_names
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
WITH sdk_imu_support AS (
    SELECT sdk_versions.name AS sdk, BOOL_OR(cameras.has_imu) AS supports_imu, BOOL_OR(cameras.has_infr) AS supports_infr 
        FROM cameras 
            JOIN sdk_cameras_compatty 
                ON cameras.id = sdk_cameras_compatty.camera
            JOIN sdk_versions 
                ON sdk_cameras_compatty.sdk = sdk_versions.id
        GROUP BY sdk_versions.name
        ORDER BY sdk_versions.name
)
SELECT sdk, (supports_imu AND supports_infr) AS supports_imu_infr
    FROM sdk_imu_support
    GROUP BY sdk, supports_imu, supports_infr
    ORDER BY sdk;

'''
Group  (cost=126.62..137.61 rows=200 width=35) (actual time=0.252..0.264 rows=11 loops=1)
  Group Key: sdk_versions.name, (bool_or(cameras.has_imu)), (bool_or(cameras.has_infr))
  ->  Incremental Sort  (cost=126.62..136.11 rows=200 width=34) (actual time=0.251..0.254 rows=11 loops=1)
        Sort Key: sdk_versions.name, (bool_or(cameras.has_imu)), (bool_or(cameras.has_infr))
        Presorted Key: sdk_versions.name
        Full-sort Groups: 1  Sort Method: quicksort  Average Memory: 25kB  Peak Memory: 25kB
        ->  Sort  (cost=126.61..127.11 rows=200 width=34) (actual time=0.228..0.231 rows=11 loops=1)
              Sort Key: sdk_versions.name
              Sort Method: quicksort  Memory: 25kB
              ->  HashAggregate  (cost=116.97..118.97 rows=200 width=34) (actual time=0.186..0.193 rows=11 loops=1)
                    Group Key: sdk_versions.name
                    Batches: 1  Memory Usage: 40kB
                    ->  Hash Join  (cost=60.50..101.67 rows=2040 width=34) (actual time=0.119..0.158 rows=46 loops=1)
                          Hash Cond: (sdk_cameras_compatty.sdk = sdk_versions.id)
                          ->  Hash Join  (cost=23.95..59.74 rows=2040 width=6) (actual time=0.052..0.076 rows=46 loops=1)
                                Hash Cond: (sdk_cameras_compatty.camera = cameras.id)
                                ->  Seq Scan on sdk_cameras_compatty  (cost=0.00..30.40 rows=2040 width=8) (actual time=0.014..0.019 rows=46 loops=1)
                                ->  Hash  (cost=16.20..16.20 rows=620 width=6) (actual time=0.022..0.022 rows=8 loops=1)
                                      Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                      ->  Seq Scan on cameras  (cost=0.00..16.20 rows=620 width=6) (actual time=0.014..0.017 rows=8 loops=1)
                          ->  Hash  (cost=21.80..21.80 rows=1180 width=36) (actual time=0.046..0.047 rows=11 loops=1)
                                Buckets: 2048  Batches: 1  Memory Usage: 17kB
                                ->  Seq Scan on sdk_versions  (cost=0.00..21.80 rows=1180 width=36) (actual time=0.032..0.035 rows=11 loops=1)
Planning Time: 0.445 ms
Execution Time: 0.430 ms
'''