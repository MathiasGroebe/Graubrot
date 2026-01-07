#!/bin/bash

# name of pg service, which should be used to access the database
pg_service="graubrot"
schema="osm"
bbox="399752 5646857 403889 5650193" # xmin ymin xmax ymax in imported coordinate system, not alway WGS84, leave empty for no clipping 
clip=""
# output file format, short name, see https://gdal.org/drivers/vector/index.html
export_format="GPKG"
# name of output file
export_file="export_osm.gpkg"

rm -f $export_file

if [ -z "$bbox" ]; then
    echo "No bounding for clipping box given"
    echo ""
    clip=""
else

    echo "Clipping data to bounding box for export"
    echo ""
    clip="-clipsrc $bbox"

fi

ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, street, housenumber, postcode, city, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.address" -nlt POINT -nln address 
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, admin_level, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.admin_boundary_area" -nln admin_boundary_area -nlt MULTIPOLYGON -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, admin_level, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.admin_boundary_line" -nln admin_boundary_line -nlt MULTILINESTRING -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, building, name, name_en, street, housenumber, postcode, city, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.building" -nln building -nlt MULTIPOLYGON -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, type, direction, ele, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.elevation_point" -nln elevation_point -nlt POINT -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.forest" -nln forest -nlt MULTIPOLYGON -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, type, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.grass" -nln grass -nlt MULTIPOLYGON -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, place, population, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.place" -nln place -nlt POINT -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, leisure, tourism, historic, man_made, \"natural\", amenity, shop, public_transport, highway, railway, power, landuse, communication, barrier, information, tags::text, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.poi" -nln poi -nlt POINT -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, highway, railway, ref, service, tracktype, trail_visibility, surface, usage, oneway, tunnel, bridge, layer, osmc_symbols::text, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.traffic" -nln traffic -nlt MULTILINESTRING -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.water" -nln water -nlt MULTIPOLYGON -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, waterway, name, name_en, intermittent, tunnel, layer, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.waterway" -nln waterway -nlt MULTILINESTRING -update
ogr2ogr -f $export_format $export_file PG:service=$pg_service $clip -sql "SELECT fid, name, name_en, type, NULL::text AS label_wkt, NULL::numeric AS label_x, NULL::numeric AS label_y, NULL::integer AS label_rotation, TRUE::boolean AS label_visable, geom FROM $schema.built_up_area" -nln built_up_area -nlt MULTIPOLYGON -update

echo "Export finished: $export_file"