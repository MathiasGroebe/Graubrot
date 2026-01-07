#!/bin/bash

# name of pg service, which should be used to access the database
pg_service="graubrot"
# xmin, ymin, xmax, ymax
bbox="13.435591,50.874256,13.712653,51.045631" #Tharandt
# raw OSM file (PBF or OSM-XML) 
input_osm="sachsen-latest.osm.pbf"

export PGSERVICE=$pg_service

echo "Clip to bounding box..."
osmium extract -b $bbox -s smart --overwrite -o region.osm.pbf $input_osm
echo "Import into database..."
osm2pgsql -O flex -S graubrot.lua region.osm.pbf 