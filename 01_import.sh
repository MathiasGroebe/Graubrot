#!/bin/bash

export PGSERVICE=graubrot
bbox="13.662356,50.792525,13.888777,50.89853" 

echo "Clip to bounding box..."
osmium extract -b $bbox --overwrite -o region.osm.pbf sachsen-latest.osm.pbf 
echo "Import into database..."
osm2pgsql -O flex -S graubrot.lua region.osm.pbf 