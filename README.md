
# Graubrot

A osm2pgsql configuration for the flex-backend for everyday use. Imports common objects for make a simple big scale map with no generlization. It tries to clean the attributes to create a easy to handle data model. Part of the repository is also a sample rendering using QGIS. 

## Features

- Import of OSM data into a custom cleaned data for easy usage of OpenStreetMap data
- Custom projection possible
- QGIS Project for rendering and easy start of map making
- Prepeared generalization for 1:25,000 

## Running

### Quickstart

1. Create a PostgrSQL Database
2. Enable PostGIS by executing ```CREATE EXTENSION POSTGIS```
3. Create a schema for the data import ```CREATE SCHEMA osm```. You can also use another Schema. It is just the default value.
4. Make sure that you have recent version of osm2pgsql. Minimum is osm2pgsql version 1.8.
5. Run ```osm2pgsql -c -O flex -S graubrot.lua -d postgres://USER:PASS@HOST/DB_NAME  sachsen-latest.osm.pbf```

### Hints

- The example is build for EPSG:32633 which works well for Saxony in Germany to demonstrate the reprojection feature. You can change it to another suitable system in the ```graubrot.lua``` by the ```epsg_code``` variable.
- It is better to use enviroment variables for accessing the database. Check the [libpg-parameter](https://www.postgresql.org/docs/current/libpq-envars.html).
- Indexes are build for rows, which are designed to categories the features in a map style. 
- It is possible to do alway a reimport with of the data. You can use it also with minutly, hourly or daily updates. Check the [documentation](https://osm2pgsql.org/doc/manual.html#updating-an-existing-database) for details.
- If you need nice-looking contourlines for you map, take a look at my repository [Smooth-Contours](https://github.com/MathiasGroebe/Smooth-Contours).
- Feel free to suggest improvments or modify it for you own use. It should demonstrate what is possible and beware of starting everyone from scratch.

## QGIS Demo Project

![Sample rending with QGIS](qgis_rendering.png)

There is a QGIS Demo project visualizing some of the imported OpenStreetMap aming a map at the scale 1:10,000 for Saxony in Germany. The project use a the ```pg_service.conf``` file, expecting a service called "graubrot". Create the following connection in the file. There are tutorials how to use it on [Linux](https://www.postgresql.org/docs/current/libpq-pgservice.html) and [Windows](https://gis.stackexchange.com/questions/393485/how-to-open-qgis-project-without-being-asked-for-postgis-credentials-every-time).

    [graubrot]
    host=localhost
    port=5432
    dbname=graubrot
    user=a_user
    password=a_password

The color can be easily adjusted by chaning the project colors in QGIS. Feel free to further adjust the map to your needs, other scales and so on. It should make the start easier. If you have adjusted the projection use the [ChangeDataSource](https://plugins.qgis.org/plugins/changeDataSource/) Plugin to reload the layer adjust the projection for each layer.
