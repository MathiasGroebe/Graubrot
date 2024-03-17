#!/bin/bash

# name of pg service, which should be used to access the database
pg_service="graubrot"
# output file format, short name, see https://gdal.org/drivers/vector/index.html
export_format="GPKG"
# name of output file
export_file="export_osm.gpkg"

rm -f $export_file

ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, street, housenumber, postcode, city, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.address" -nln address 
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, admin_level, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.admin_boundary_area" -nln admin_boundary_area -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, admin_level, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.admin_boundary_line" -nln admin_boundary_line -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, building, name, name_en, street, housenumber, postcode, city, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.building" -nln building -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, type, direction, ele, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.elevation_point" -nln elevation_point -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.forest" -nln forest -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.grass" -nln grass -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, place, population, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.place" -nln place -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, leisure, tourism, historic, man_made, \"natural\", amenity, shop, public_transport, highway, railway, power, communication, landuse, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.poi" -nln poi -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, highway, railway, ref, service, tracktype, trail_visibility, surface, oneway, tunnel, bridge, layer, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.traffic" -nln traffic -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, name, name_en, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.water" -nln water -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service -sql "SELECT fid, waterway, name, name_en, intermittent, tunnel, layer, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM osm.waterway" -nln waterway -update

