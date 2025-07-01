#!/bin/bash

# name of pg service, which should be used to access the database
pg_service="rmv"
schema="osm"
# output file format, short name, see https://gdal.org/drivers/vector/index.html
export_format="GPKG"
# name of output file
export_file="export_osm.gpkg"

rm -f $export_file

ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, street, housenumber, postcode, city, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.address" -nln address 
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, admin_level, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.admin_boundary_area" -nln admin_boundary_area -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, admin_level, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.admin_boundary_line" -nln admin_boundary_line -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, building, name, name_en, street, housenumber, postcode, city, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.building" -nln building -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, type, direction, ele, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.elevation_point" -nln elevation_point -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.forest" -nln forest -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.grass" -nln grass -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, place, population, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.place" -nln place -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, leisure, tourism, historic, man_made, \"natural\", amenity, shop, public_transport, highway, railway, power, communication, landuse, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.poi" -nln poi -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, highway, railway, ref, service, tracktype, trail_visibility, surface, usage, oneway, tunnel, bridge, layer, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.traffic" -nln traffic -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.water" -nln water -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, waterway, name, name_en, intermittent, tunnel, layer, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.waterway" -nln waterway -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, type, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.built_up_area" -nln built_up_area -update

