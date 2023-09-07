#!/bin/bash

export PGSERVICE=graubrot

osm2pgsql -O flex -S graubrot.lua berlin-latest.osm.pbf
