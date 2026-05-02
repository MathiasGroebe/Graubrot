
-- Calculate the isolation for elevation points and places. The isolation is the distance to the next higher peak/place with more inhabitants.

-- Create index using geography, to get correct distances			
CREATE INDEX osm_elevation_point_geo ON osm.elevation_point USING spgist ((ST_Transform(geom, 4326)::geography));

DO $$
DECLARE
r RECORD;
BEGIN
	-- Get all peaks with elevation
	FOR r IN (
		SELECT fid, ele , geom
		FROM osm.elevation_point ep 
		WHERE ep."type" IN ('peak', 'vulcano') AND ele IS NOT NULL 
	)
	-- Calculate the isolation
	LOOP
		UPDATE osm.elevation_point ep
		SET discrete_isolation = 
			(SELECT ST_Distance((ST_Transform(r.geom, 4326)::geography), (ST_Transform(q.geom, 4326)::geography))
			FROM osm.elevation_point q
			WHERE q.ele >= r.ele AND r.fid != q.fid
			ORDER BY (ST_Transform(r.geom, 4326)::geography) <-> (ST_Transform(q.geom, 4326)::geography)
			LIMIT 1 )
		WHERE r.fid = ep.fid;
	END LOOP;
	-- Add isolation for highest peak 
	UPDATE osm.elevation_point ep
	SET discrete_isolation =  30000000
	WHERE fid = (SELECT fid FROM osm.elevation_point ep  WHERE ele IS NOT NULL ORDER BY ele DESC LIMIT 1);

END;
$$ language plpgsql;

-- Create index using geography, to get correct distances			
CREATE INDEX osm_place_geo ON osm.place USING spgist ((ST_Transform(geom, 4326)::geography));


DO $$
DECLARE
r RECORD;
BEGIN
	-- Get all places with population
	FOR r IN (
		SELECT fid, population, geom
		FROM osm.place p
		WHERE population IS NOT NULL 
	)
	-- Calculate the isolation
	LOOP
		UPDATE osm.place ep
		SET discrete_isolation = 
			(SELECT ST_Distance((ST_Transform(r.geom, 4326)::geography), (ST_Transform(q.geom, 4326)::geography))
			FROM osm.place q
			WHERE q.population >= r.population AND r.fid != q.fid
			ORDER BY (ST_Transform(r.geom, 4326)::geography) <-> (ST_Transform(q.geom, 4326)::geography)
			LIMIT 1 )
		WHERE r.fid = ep.fid;
	END LOOP;
	-- Add isolation for highest population
	UPDATE osm.place 
	SET discrete_isolation =  30000000
	WHERE fid = (SELECT fid FROM osm.place WHERE population IS NOT NULL ORDER BY population DESC LIMIT 1);

END;
$$ language plpgsql;