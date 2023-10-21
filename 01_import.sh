#!/bin/bash

export PGSERVICE=graubrot

osm2pgsql -O flex -S graubrot.lua -b 13.576881,50.77216,13.842782,50.911776  sachsen-latest.osm.pbf
