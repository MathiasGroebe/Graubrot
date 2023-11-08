-- Forest
TRUNCATE map_25k.forest;

INSERT INTO
	map_25k.forest (geom) WITH expand AS (
		SELECT
			ST_Buffer(geom, 10) AS geom
		FROM
			osm.forest
	),
	clustering AS (
		SELECT
			ST_ClusterDBSCAN(geom, 0, 1) OVER() AS cluster_id,
			geom
		FROM
			expand
	),
	dissolve AS (
		SELECT
			ST_Union(geom) AS geom
		FROM
			clustering
		GROUP BY
			cluster_id
	),
	shrink AS (
		SELECT
			ST_Buffer(
				ST_Buffer(geom, -20),
				10
			) AS geom
		FROM
			dissolve
	),
	single_feature AS (
		SELECT
			(ST_Dump(geom)).geom AS geom
		FROM
			shrink
	),
	min_area AS (
		SELECT
			*
		FROM
			single_feature
		WHERE
			ST_Area(geom) > 306
	),
	sieve AS (
		SELECT
			Sieve(geom, 156) AS geom
		FROM
			min_area
	),
	simplify AS (
		SELECT
			ST_Simplify(geom, 5) AS geom
		FROM
			sieve
	)
SELECT
	ST_Multi(geom)
FROM
	simplify;

-- Water
TRUNCATE map_25k.water;

INSERT INTO
	map_25k.water (geom) WITH expand AS (
		SELECT
			ST_Buffer(geom, 10) AS geom
		FROM
			osm.water
	),
	clustering AS (
		SELECT
			ST_ClusterDBSCAN(geom, 0, 1) OVER() AS cluster_id,
			geom
		FROM
			expand
	),
	dissolve AS (
		SELECT
			ST_Union(geom) AS geom
		FROM
			clustering
		GROUP BY
			cluster_id
	),
	shrink AS (
		SELECT
			ST_Buffer(
				ST_Buffer(geom, -20),
				10
			) AS geom
		FROM
			dissolve
	),
	single_feature AS (
		SELECT
			(ST_Dump(geom)).geom AS geom
		FROM
			shrink
	),
	min_area AS (
		SELECT
			*
		FROM
			single_feature
		WHERE
			ST_Area(geom) > 306
	),
	sieve AS (
		SELECT
			Sieve(geom, 156) AS geom
		FROM
			min_area
	),
	simplify AS (
		SELECT
			ST_Simplify(geom, 5) AS geom
		FROM
			sieve
	)
SELECT
	ST_Multi(geom)
FROM
	simplify;

TRUNCATE map_25k.grass;

INSERT INTO
	map_25k.grass (geom) WITH expand AS (
		SELECT
			ST_Buffer(geom, 10) AS geom
		FROM
			osm.grass
	),
	clustering AS (
		SELECT
			ST_ClusterDBSCAN(geom, 0, 1) OVER() AS cluster_id,
			geom
		FROM
			expand
	),
	dissolve AS (
		SELECT
			ST_Union(geom) AS geom
		FROM
			clustering
		GROUP BY
			cluster_id
	),
	shrink AS (
		SELECT
			ST_Buffer(
				ST_Buffer(geom, -20),
				10
			) AS geom
		FROM
			dissolve
	),
	single_feature AS (
		SELECT
			(ST_Dump(geom)).geom AS geom
		FROM
			shrink
	),
	min_area AS (
		SELECT
			*
		FROM
			single_feature
		WHERE
			ST_Area(geom) > 306
	),
	sieve AS (
		SELECT
			Sieve(geom, 156) AS geom
		FROM
			min_area
	),
	simplify AS (
		SELECT
			ST_Simplify(geom, 5) AS geom
		FROM
			sieve
	)
SELECT
	ST_Multi(geom)
FROM
	simplify;

TRUNCATE map_25k.building;

INSERT INTO
	map_25k.building (geom) WITH clustering AS (
		-- angrenzende Flächen finden
		SELECT
			ST_ClusterDBSCAN(geom, 0, 1) OVER() AS cluster_id,
			geom
		FROM
			osm.building 
	),
	dissolve AS (
		SELECT
			ROW_NUMBER() OVER() AS fid,
			ST_Union(geom) AS geom
		FROM
			clustering
		GROUP BY
			cluster_id
	),
	buffer_simplify AS (
		SELECT
			fid,
			ST_Buffer(
				ST_Buffer(
					ST_Buffer(
						ST_Buffer(geom, -3, 'endcap=flat join=mitre'),
						1,
						'endcap=flat join=mitre'
					),
					5,
					'endcap=flat join=mitre'
				),
				-3,
				'endcap=flat join=mitre'
			) AS geom
		FROM
			dissolve
	),
	simplify AS (
		-- Redue number of points
		SELECT
			fid,
			ST_SimplifyVW(geom, 3) AS geom
		FROM
			buffer_simplify
	),
	make_valid AS (
		SELECT
			fid,
			geom
		FROM
			simplify
		WHERE
			ST_IsEmpty(geom) = FALSE -- Remove collapsed geometries
	),
	filter1 AS (
		-- Add big narrow buildings again
		SELECT
			fid,
			ST_SimplifyVW(geom, 3) AS geom
		FROM
			dissolve b
		WHERE
			NOT EXISTS (
				SELECT
					1
				FROM
					make_valid bs
				WHERE
					b.fid = bs.fid
			)
			AND ST_Area(geom) >= 100
	),
	filter2 AS (
		-- Show too small buildings by an abstract rotated square
		SELECT
			fid,
			ST_Rotate(
				ST_Buffer(ST_Centroid(geom), 4, 'endcap=square'),
				radians(0 - feature_orientation(geom)),
				ST_Centroid(geom)
			) AS geom
		FROM
			dissolve b
		WHERE
			NOT EXISTS (
				SELECT
					1
				FROM
					make_valid bs
				WHERE
					b.fid = bs.fid
			)
			AND ST_Area(geom) < 100
			AND ST_Area(geom) > 50
	)
SELECT -- Merge all kinds togehter
	ST_Multi(geom) 
FROM
	make_valid
UNION
ALL
SELECT
	ST_Multi(geom)
FROM
	filter1
UNION
ALL
SELECT
	ST_Multi(geom)
FROM
	filter2;


----
-- Peaks

INSERT INTO map_25k.elevation_point (name, "type", elevation, geom)
SELECT name, "type", round(ele), geom
FROM osm.elevation_point ep 
WHERE "type" IN ('peak', 'vulcano') AND ele IS NOT NULL;

UPDATE map_25k.elevation_point 
SET discrete_isolation = discrete_isolation('map_25k.elevation_point', 'geom', 'elevation', geom, elevation);

----
-- Buildup area
TRUNCATE map_25k.build_up_area;
INSERT INTO map_25k.build_up_area (geom)
WITH 
buffering AS (
	SELECT fid, ST_Buffer(geom, 40, 'endcap=flat join=mitre') AS geom
	FROM osm.building
),
clustering AS (
	SELECT geom, ST_ClusterDBSCAN(geom, 0, 1) OVER() AS cid
	FROM buffering 
),
merging AS (
	SELECT ST_Union(geom) AS geom 
	FROM clustering 
	GROUP BY cid 
),
simplifying AS (
	SELECT ST_SimplifyVW(ST_Buffer(ST_Buffer(ST_SimplifyVW(ST_Buffer(geom, 20, 'endcap=flat join=mitre'), 400), -1, 'endcap=flat join=mitre'), -39, 'endcap=flat join=mitre'), 400) AS geom
	FROM merging 
),
single_feature AS (
	SELECT (ST_Dump(geom)).geom AS geom
	FROM simplifying
)
SELECT geom
FROM single_feature
WHERE ST_Area(geom) > 8000;

---- POI

INSERT INTO map_25k.poi (name, geom, "type")
SELECT name, geom, 'guidepost'
FROM osm.poi p 
WHERE information = 'guidepost' AND tags ->> 'tourism' = 'information';

INSERT INTO map_25k.poi (name, geom, "type")
SELECT name, geom, 'picnic_site'
FROM osm.poi p 
WHERE tags ->> 'tourism' = 'picnic_site';

INSERT INTO map_25k.poi (name, geom, "type")
SELECT name, geom, 'shelter'
FROM osm.poi p 
WHERE amenity = 'shelter';

INSERT INTO map_25k.poi (name, geom, "type")
SELECT name, geom, 'bench'
FROM osm.poi p 
WHERE amenity = 'bench';

INSERT INTO map_25k.poi (name, geom, "type")
SELECT name, geom, 'bus_stop'
FROM osm.poi p 
WHERE highway = 'bus_stop';

INSERT INTO map_25k.poi (name, geom, "type")
SELECT name, geom, railway 
FROM osm.poi p 
WHERE railway IN ('station', 'halt');

--- Admin bounary 
INSERT INTO map_25k.admin_boundary_line (name, admin_level, geom)
SELECT name, admin_level, ST_SimplifyPreserveTopology(geom, 10) AS geom  
FROM osm.admin_boundary_line abl;

--- Places

INSERT INTO map_25k.place (name, place, population, geom)
SELECT name, place, population, geom 
FROM osm.place p;

UPDATE map_25k.place 
SET discrete_isolation = discrete_isolation('map_25k.place', 'geom', 'population', geom, population);

--- Traffic

TRUNCATE tmp.interesection_points;

INSERT INTO tmp.interesection_points (geom)
SELECT DISTINCT ST_Multi(ST_Intersection(t1.geom, t2.geom)) AS geom
FROM osm.traffic t1 JOIN osm.traffic t2 ON
ST_Crosses(t1.geom, t2.geom) OR ST_Touches(t1.geom, t2.geom) 
AND t1.fid != t2.fid AND t1.layer = t2.layer 
AND NOT t1.bridge AND NOT t2.tunnel AND NOT t2.bridge AND NOT t1.tunnel;

INSERT INTO tmp.interesection_points (geom)
WITH points AS (
		SELECT fid, ST_StartPoint(geom) AS geom
		FROM osm.traffic
		WHERE ST_IsSimple(geom) = FALSE 
		UNION 
		SELECT fid, ST_EndPoint(geom) AS geom
		FROM osm.traffic
		WHERE ST_IsSimple(geom) = FALSE 
	),
	distinct_points AS (
		SELECT DISTINCT fid, geom
		FROM points
	)
SELECT ST_Multi(geom)
FROM distinct_points;

TRUNCATE map_25k.traffic_edges;

INSERT INTO map_25k.traffic_edges ("name", "ref", highway, railway, oneway, bridge, tunnel, layer, geom)
-- Split
SELECT "name", "ref", highway, railway, oneway, bridge, tunnel, layer,
(ST_Dump(ST_CollectionExtract(ST_Split(geom,
(SELECT ST_Union(p.geom) FROM tmp.interesection_points AS p WHERE ST_Intersects(p.geom, t.geom))
					 ), 2))).geom AS geom
FROM osm.traffic AS t
UNION ALL
-- Not to split
SELECT "name", "ref", highway, railway, oneway, bridge, tunnel, layer, geom 
FROM osm.traffic AS t
WHERE NOT EXISTS (SELECT 1 FROM tmp.interesection_points AS p WHERE ST_Intersects(p.geom, t.geom));

TRUNCATE map_25k.traffic_nodes;
-- Nodes from start and end points
INSERT INTO map_25k.traffic_nodes (geom)
WITH 
	points AS (
	SELECT ST_StartPoint(geom) AS geom
	FROM map_25k.traffic_edges 
	UNION 
	SELECT ST_EndPoint(geom) AS geom
	FROM map_25k.traffic_edges 
	),
	distinct_points AS (
	SELECT DISTINCT geom
	FROM points
	)
SELECT geom 
FROM points;


-- Set start node
UPDATE map_25k.traffic_edges l
SET start_node = p.fid 
FROM map_25k.traffic_nodes p
WHERE ST_Intersects(ST_StartPoint(l.geom), p.geom);

-- Set end node
UPDATE map_25k.traffic_edges l
SET end_node = p.fid 
FROM map_25k.traffic_nodes p
WHERE ST_Intersects(ST_EndPoint(l.geom), p.geom);

-- Count edges at node
WITH collect AS (
	SELECT start_node AS node
	FROM map_25k.traffic_edges
	UNION ALL 
	SELECT end_node AS node 
	FROM map_25k.traffic_edges
), agg AS (
	SELECT node, count(*) AS cnt
	FROM collect
	GROUP BY node
)
UPDATE map_25k.traffic_nodes p
SET edges_count = cnt
FROM agg
WHERE p.fid = node;