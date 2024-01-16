#!/bin/bash

rm export_osm.gpkg

ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, street, housenumber, postcode, city, geom FROM osm.address" -nln address 
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, admin_level, geom FROM osm.admin_boundary_area" -nln admin_boundary_area -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, admin_level, geom FROM osm.admin_boundary_line" -nln admin_boundary_line -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, building, name, name_en, street, housenumber, postcode, city, geom FROM osm.building" -nln building -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, type, direction, ele, geom FROM osm.elevation_point" -nln elevation_point -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, geom FROM osm.forest" -nln forest -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, geom FROM osm.grass" -nln grass -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, place, population, geom FROM osm.place" -nln place -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, leisure, tourism, historic, man_made, \"natural\", amenity, shop, public_transport, highway, railway, power, communication, landuse, geom FROM osm.poi" -nln poi -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, highway, railway, ref, service, tracktype, trail_visibility, surface, oneway, tunnel, bridge, layer, geom FROM osm.traffic" -nln traffic -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, name, name_en, geom FROM osm.water" -nln water -update
ogr2ogr -f "GPKG" export_osm.gpkg PG:service=graubrot -sql "SELECT fid, waterway, name, name_en, intermittent, tunnel, layer, geom FROM osm.waterway" -nln waterway -update