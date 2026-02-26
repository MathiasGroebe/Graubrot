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