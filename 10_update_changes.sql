-- Updates changes layer with information for delete objects.
DO $$
DECLARE
r RECORD;
BEGIN
	FOR r IN (
		SELECT c.fid,c.osm_id, o.layer, o.geom  
		FROM osm.changes c LEFT JOIN osm.all_objects o ON c.osm_id = o.osm_id AND c."version" = o."version"
		WHERE c."action" = 'D' AND c.layer IS NULL
        ORDER BY c.fid
	)
	LOOP
		-- If object not present remove from changes. Happens, because deleted objects come with not further tags and need to be matched
		IF r.layer IS NULL THEN 
		DELETE FROM osm.changes WHERE fid = r.fid;
		ELSE 
		-- If present, add layer information
		UPDATE osm.changes 
		SET (layer, object_geom) = (r.layer, r.geom)
		WHERE fid = r.fid;
		END IF;
	END LOOP;
END;
$$ language plpgsql;