#!/bin/bash

# name of pg service, which should be used to access the database
pg_service="tmp"
schema="osm"
# xmin, ymin, xmax, ymax
bbox="11.8723,50.1713,15.0419,51.6851" 
# raw OSM file (PBF or OSM-XML) 
input_osm="sachsen-latest.osm.pbf"

export PGSERVICE=$pg_service

# echo "Clip to bounding box..."
# osmium extract -b $bbox -s smart --overwrite -o region.osm.pbf $input_osm

# echo "Import into database..."
# osm2pgsql -O flex -S graubrot.lua region.osm.pbf 

echo "Importing land and water polygons"
ogr2ogr PG:service=$pg_service -lco FID=fid -lco GEOMETRY_NAME=geom land-polygons-split-4326/land_polygons.shp -nln $schema.land -nlt MULTIPOLYGON -overwrite 
ogr2ogr PG:service=$pg_service -lco FID=fid -lco GEOMETRY_NAME=geom water-polygons-split-4326/water_polygons.shp -nln $schema.ocean -nlt MULTIPOLYGON -overwrite

# echo "Creating primary keys..."
# psql -f 10_create_pk.sql

# echo  "Calculating isolation..."
# psql -f 10_isolation.sql

echo "Import finished"
