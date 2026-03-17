-- Create primiary keys 
ALTER TABLE osm.address ADD PRIMARY KEY (fid);
ALTER TABLE osm.admin_boundary_area ADD PRIMARY KEY (fid);
ALTER TABLE osm.admin_boundary_line ADD PRIMARY KEY (fid);
ALTER TABLE osm.building ADD PRIMARY KEY (fid);
ALTER TABLE osm.built_up_area ADD PRIMARY KEY (fid);
ALTER TABLE osm.elevation_point ADD PRIMARY KEY (fid);
ALTER TABLE osm.forest ADD PRIMARY KEY (fid);
ALTER TABLE osm.grass ADD PRIMARY KEY (fid);
ALTER TABLE osm.place ADD PRIMARY KEY (fid);
ALTER TABLE osm.poi ADD PRIMARY KEY (fid);
ALTER TABLE osm.traffic ADD PRIMARY KEY (fid);
ALTER TABLE osm.water ADD PRIMARY KEY (fid);
ALTER TABLE osm.waterway ADD PRIMARY KEY (fid);
ALTER TABLE osm.changes ADD PRIMARY KEY (fid);

-- Set approved to true for objects after the first import.
UPDATE osm.address SET approved = true;
UPDATE osm.admin_boundary_area SET approved = true;
UPDATE osm.admin_boundary_line SET approved = true;
UPDATE osm.building SET approved = true;
UPDATE osm.built_up_area SET approved = true;
UPDATE osm.elevation_point SET approved = true;
UPDATE osm.forest SET approved = true;
UPDATE osm.grass SET approved = true;
UPDATE osm.place SET approved = true;
UPDATE osm.poi SET approved = true;
UPDATE osm.traffic SET approved = true;
UPDATE osm.water SET approved = true;
UPDATE osm.waterway SET approved = true;

-- Create view for all objects to handle delete objects
-- DROP VIEW osm.all_objects;
CREATE VIEW osm.all_objects AS
SELECT osm_id, 'adress' AS layer, fid AS o_fid, "version", change_uuid, approved, geom   
FROM osm.address 
UNION ALL 
SELECT osm_id, 'admin_boundary_area' AS layer, fid AS o_fid, "version", change_uuid, approved, geom  
FROM osm.admin_boundary_area 
UNION ALL 
SELECT osm_id, 'admin_boundary_line' AS layer, fid AS o_fid, "version", change_uuid, approved, geom
FROM osm.admin_boundary_line 
UNION ALL 
SELECT osm_id, 'building' AS layer, "version", fid AS o_fid, change_uuid, approved, geom
FROM osm.building 
UNION ALL 
SELECT osm_id, 'built_up_area' AS layer, fid AS o_fid, "version", change_uuid, approved, geom
FROM osm.built_up_area 
UNION ALL 
SELECT osm_id, 'elevation_point' AS layer, fid AS o_fid, "version", change_uuid, approved, geom
FROM osm.elevation_point
UNION ALL 
SELECT osm_id, 'forest' AS layer, "version", fid AS o_fid, change_uuid, approved, geom
FROM osm.forest 
UNION ALL 
SELECT osm_id, 'grass' AS layer, "version", fid AS o_fid, change_uuid, approved, geom
FROM osm.grass 
UNION ALL 
SELECT osm_id, 'place' AS layer, "version", fid AS o_fid, change_uuid, approved, geom
FROM osm.place 
UNION ALL 
SELECT osm_id, 'poi' ASlayer, "version", fid AS o_fid, change_uuid, approved, geom 
FROM osm.poi 
UNION ALL 
SELECT osm_id, 'traffic' AS layer, "version", fid AS o_fid, change_uuid, approved, geom
FROM osm.traffic 
UNION ALL 
SELECT osm_id, 'water' AS layer, "version", fid AS o_fid, change_uuid, approved, geom
FROM osm.water 
UNION ALL 
SELECT osm_id, 'waterway' ASlayer, "version", fid AS o_fid, change_uuid, approved, geom
FROM osm.waterway;