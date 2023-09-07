CREATE SCHEMA IF NOT EXISTS osm;

CREATE SCHEMA IF NOT EXISTS map_25k;

CREATE TABLE map_25k.forest (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);

CREATE INDEX map_25k_forest_geom ON map_25k.forest USING gist(geom);

CREATE TABLE map_25k.water (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);

CREATE INDEX map_25k_water_geom ON map_25k.water USING gist(geom);

CREATE TABLE map_25k.grass (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);

CREATE INDEX map_25k_grass_geom ON map_25k.grass USING gist(geom);

CREATE TABLE map_25k.building (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);

CREATE INDEX map_25k_building_geom ON map_25k.building USING gist(geom);

CREATE TABLE map_25k.build_up_area (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);

CREATE INDEX map_25k_build_up_area_geom ON map_25k.building USING gist(geom);

CREATE TABLE IF NOT EXISTS map_25k.elevation_point (
    fid serial PRIMARY KEY,
    name TEXT,
    "type" TEXT,
    elevation NUMERIC,
    discrete_isolation NUMERIC,
    geom geometry(Point, 32633)
);

CREATE INDEX map_25k_elevation_point_geom ON map_25k.elevation_point USING gist(geom);
CREATE INDEX map_25k_elevation_point_type ON map_25k.elevation_point USING btree(type);
CREATE INDEX map_25k_elevation_point_elevation ON map_25k.elevation_point USING btree(elevation);
CREATE INDEX map_25k_elevation_point_discrete_isolation ON map_25k.elevation_point USING btree (discrete_isolation);

CREATE TABLE map_25k.poi (
fid serial PRIMARY KEY,
name TEXT,
"type" TEXT,
geom geometry(Point, 32633)
);

CREATE INDEX map_25k_poi_geom ON map_25k.poi USING gist(geom);
CREATE INDEX map_25k_poi_type ON map_25k.poi USING btree(type);