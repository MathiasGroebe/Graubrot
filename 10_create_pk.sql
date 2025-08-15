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