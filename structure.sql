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