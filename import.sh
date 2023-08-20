#!/bin/bash

export PGSERVICE=osm-berlin

osm2pgsql -O flex -S graubrot.lua berlin-latest.osm.pbf
