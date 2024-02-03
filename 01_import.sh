#!/bin/bash

export PGSERVICE=graubrot

osmium extract -b 13.662356,50.792525,13.888777,50.89853 -o region.osm.pbf sachsen-latest.osm.pbf 
osm2pgsql -O flex -S graubrot.lua region.osm.pbf 