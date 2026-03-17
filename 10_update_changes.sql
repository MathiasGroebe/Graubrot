-- Updates changes layer with information for delete objects.
DO $$
DECLARE
r RECORD;
BEGIN
	FOR r IN (
		SELECT c.fid, c.osm_id, o.o_fid, o.layer, o.VERSION, o.change_uuid, o.geom  
		FROM osm.changes c JOIN osm.all_objects o ON c.osm_id = o.osm_id 
		WHERE c."action" = 'D'
		ORDER BY layer, osm_id, o_fid, "version" ASC -- Ordering to just in case of multiple versions of the same object, we applie the oldest to delete
	)
	LOOP
		-- If object not present remove from changes. Happens, because deleted objects come with not further tags and need to be matched
		IF r.layer IS NULL THEN 
		DELETE FROM osm.changes WHERE fid = r.fid;
		ELSE 
		-- If present, add layer information
		UPDATE osm.changes 
		SET (layer, object_geom, change_uuid) = (r.layer, r.geom, r.change_uuid)
		WHERE fid = r.fid;
		END IF;
	END LOOP;
END;
$$ language plpgsql;