#!/bin/bash

# name of pg service, which should be used to access the database
pg_service="tmp"
# xmin, ymin, xmax, ymax
bbox="13.711196,51.035285,13.75321,51.059702" #Tharandt
# raw OSM file (PBF or OSM-XML) 
input_osm="sachsen-latest.osm.pbf"

export PGSERVICE=$pg_service

echo "Clip to bounding box..."
osmium extract -b $bbox -s smart --overwrite -o region.osm.pbf $input_osm
echo "Import into database..."
osm2pgsql -O flex -S graubrot.lua region.osm.pbf 