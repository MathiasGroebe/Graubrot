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
			osm.building --WHERE geom && st_geometryfromtext('POLYGON((390292.9840225501684472 5818353.7415813272818923, 391188.64492927165701985 5818353.7415813272818923, 391188.64492927165701985 5819023.35923915077000856, 390292.9840225501684472 5819023.35923915077000856, 390292.9840225501684472 5818353.7415813272818923))', 32633) 
	),
	dissolve AS (
		-- Flächen zusammenfassen
		SELECT
			ROW_NUMBER() OVER() AS fid,
			ST_Union(geom) AS geom
		FROM
			clustering
		GROUP BY
			cluster_id
	),
	buffer_simplify AS (
		-- Vereinfachung mittel Buffer
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
		-- Reduzierung von Punkten und Vereinfachung 
		SELECT
			fid,
			ST_SimplifyVW(geom, 3) AS geom
		FROM
			buffer_simplify
	),
	make_valid AS (
		-- nur valide Gebäude verwenden
		SELECT
			fid,
			geom
		FROM
			simplify
		WHERE
			ST_IsEmpty(geom) = FALSE -- filtert kollabierte Geometrien
	),
	filter1 AS (
		-- schmale und große Gebäude wieder hinzufügen
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
		-- kleine Gebäude als rotierte Quadrate hinzufügen
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
SELECT
	ST_Multi(geom) -- Zusammenführen der Ergebnisse 
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