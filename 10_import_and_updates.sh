#!/bin/bash

## --- Import with updates --- ##

# name of pg service, which should be used to access the database
pg_service="zwiesel"
bbox="13.789586,50.810938,14.096173,50.940055"
osm_file="sachsen-251223.osm.pbf"

export PGSERVICE=$pg_service


if [ ! -f "osm_update.state" ]; then
    echo "No state found, proceeding with import."

    echo "Clipping to bounding box..."
    osmium extract -b $bbox -s smart --overwrite -o region.osm.pbf $osm_file

    echo "Import into database..."
    osm2pgsql -O flex --create --slim -x -S graubrot.lua region.osm.pbf

    echo "Creating primary keys..."
    psql -f 10_create_pk.sql

    # Create state file for future updates
    echo "Creating initial state file for updates..."
    # This sets a timestamp for the initial state, which can be used for future updates, with some buffer so get all changes
    one_week_ago=$(date -u -d '7 days ago' +"%Y-%m-%dT%H:%M:%SZ")
    pyosmium-get-changes --server https://download.geofabrik.de/europe/germany-updates/ -D $one_week_ago -f osm_update.state

    echo "Done."

else
    echo "Update database for region"
    
    # Intended for applying daily changes for a region
    # Documentation https://docs.osmcode.org/pyosmium/latest/user_manual/10-Replication-Tools/

    echo "Download, clipping, and import of changes for the region from OpenStreetMap data"

    echo "Downloading changes..."
    # Download changes; the osm_update.state file will be updated in the process
    pyosmium-get-changes --size=1000 --server https://download.geofabrik.de/europe/germany-updates/ -f osm_update.state -o $(date +%F)_germany.osc.gz


    echo "Clipping changes..."
    # Clipping the changes to the region
    osmium extract -b $bbox -s smart --overwrite -o $(date +%F)_clipped.osc.gz $(date +%F)_germany.osc.gz
    # Deleting the non-clipped data
    rm $(date +%F)_germany.osc.gz

    echo "Importing changes into the database..."
    # Importing changes into the database
    osm2pgsql -O flex --append --slim -x -S graubrot.lua $(date +%F)_clipped.osc.gz
    
    
fi



