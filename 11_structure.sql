CREATE SCHEMA IF NOT EXISTS osm;
CREATE SCHEMA IF NOT EXISTS map_25k;
CREATE SCHEMA IF NOT EXISTS tmp

DROP TABLE IF EXISTS map_25k.forest;
CREATE TABLE map_25k.forest (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);
CREATE INDEX map_25k_forest_geom ON map_25k.forest USING gist(geom);

DROP TABLE IF EXISTS map_25k.water;
CREATE TABLE map_25k.water (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);
CREATE INDEX map_25k_water_geom ON map_25k.water USING gist(geom);

DROP TABLE IF EXISTS map_25k.grass;
CREATE TABLE map_25k.grass (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);
CREATE INDEX map_25k_grass_geom ON map_25k.grass USING gist(geom);

DROP TABLE IF EXISTS map_25k.building;
CREATE TABLE map_25k.building (
    fid serial PRIMARY KEY,
    geom geometry(Multipolygon, 32633)
);
CREATE INDEX map_25k_building_geom ON map_25k.building USING gist(geom);

DROP TABLE IF EXISTS map_25k.build_up_area;
CREATE TABLE map_25k.build_up_area (
    fid serial PRIMARY KEY,
    geom geometry(Polygon, 32633)
);
CREATE INDEX map_25k_build_up_area_geom ON map_25k.build_up_area USING gist(geom);

DROP TABLE IF EXISTS map_25k.elevation_point;
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

DROP TABLE IF EXISTS map_25k.poi;
CREATE TABLE map_25k.poi (
fid serial PRIMARY KEY,
name TEXT,
"type" TEXT,
geom geometry(Point, 32633)
);
CREATE INDEX map_25k_poi_geom ON map_25k.poi USING gist(geom);
CREATE INDEX map_25k_poi_type ON map_25k.poi USING btree(type);

DROP TABLE IF EXISTS map_25k.admin_boundary_line;
CREATE TABLE map_25k.admin_boundary_line (
    fid serial PRIMARY KEY,
    name TEXT,
    admin_level integer,
    geom geometry(Linestring, 32633)
);
CREATE INDEX map_25k_admin_boundary_line_geom ON map_25k.admin_boundary_line USING gist(geom);
CREATE INDEX map_25k_admin_boundary_line_level ON map_25k.admin_boundary_line (admin_level);

DROP TABLE IF EXISTS map_25k.place;
CREATE TABLE map_25k.place (
    fid serial PRIMARY KEY,
    name TEXT,
    place TEXT,
    population integer,
    discrete_isolation NUMERIC,
    geom geometry(Point, 32633)
);
CREATE INDEX map_25k_place_geom ON map_25k.place USING spgist (geom);
CREATE INDEX map_25k_place_place ON map_25k.place USING btree (place);
CREATE INDEX map_25k_place_population ON map_25k.place USING btree (population);
CREATE INDEX map_25k_place_discrete_isolation ON map_25k.place USING btree (discrete_isolation);

DROP TABLE IF EXISTS tmp.interesection_points;
CREATE TABLE tmp.interesection_points
(geom geometry(MultiPoint, 32633));
CREATE INDEX tmp_interesection_points_geom ON tmp.interesection_points USING gist (geom);

DROP TABLE IF EXISTS map_25k.traffic_edges;
CREATE TABLE map_25k.traffic_edges
(
	fid bigserial PRIMARY KEY,
	name TEXT,
	"ref" TEXT,
	highway TEXT,
	railway TEXT, 
	oneway boolean,
	bridge boolean,
	tunnel boolean, 
	layer NUMERIC,
    start_node integer,
    end_node integer,
	geom geometry(Linestring, 32633)
);
CREATE INDEX map_25k_traffic_edges_geom ON map_25k.traffic_edges USING gist (geom);
CREATE INDEX map_25k_traffic_edges_bridge ON map_25k.traffic_edges USING btree (bridge);
CREATE INDEX map_25k_traffic_edges_tunnel ON map_25k.traffic_edges USING btree (tunnel);
CREATE INDEX map_25k_traffic_edges_layer ON map_25k.traffic_edges USING btree (layer);
CREATE INDEX map_25k_traffic_edges_start_node ON map_25k.traffic_edges USING btree (start_node);
CREATE INDEX map_25k_traffic_edges_end_node ON map_25k.traffic_edges USING btree (end_node);

DROP TABLE IF EXISTS map_25k.traffic_nodes;
CREATE TABLE map_25k.traffic_nodes
(
	fid bigserial PRIMARY KEY,
	edges_count integer DEFAULT 0,
	geom geometry(Point, 32633)
);
CREATE INDEX map_25k_traffic_nodes_geom ON map_25k.traffic_nodes USING gist (geom);
CREATE INDEX map_25k_traffic_nodes_edges_count ON map_25k.traffic_nodes USING btree (edges_count);