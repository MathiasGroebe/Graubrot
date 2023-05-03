# Graubrot
A osm2pgsql configuration for the flex-backend for everyday use. Imports common objects for make a simple big scale map with no generlization. It tries to clean the attributes to create a easy to handle data model. Part of the repository is also a sample rendering using QGIS. Please scroll down for further explanations.

## Running

###  Quickstart

1. Create a PostgrSQL Database
2. Enable PostGIS by executing ```CREATE EXTENSION POSTGIS```
3. Create a schema for the data import ```CREATE SCHEMA osm```. You can also use another Schema. It is just the default value.
4. Make sure that you have recent version of osm2pgsql. Minimum is osm2pgsql version 1.8!
5. Run ```osm2pgsql -c -O flex -S graubrot.lua -d postgres://USER:PASS@HOST/DB_NAME  sachsen-latest.osm.pbf```

### Hints

- The example is build for EPSG:32633 which works well for Saxony in Germany to demonstrate the reprojection feature. You can change it to another suitable system in the ```graubrot.lua``` by the ```epsg_code``` variable.
- It is better to use enviroment variables for accessing the database. Check the [libpg-parameter](https://www.postgresql.org/docs/current/libpq-envars.html).
- Indexes are build for rows, which are designed to categories the features in a map style. 
- It is possible to do alway a reimport with of the data. You can use it also with minutly, hourly or daily updates. Check the [documentation](https://osm2pgsql.org/doc/manual.html#updating-an-existing-database) for details.
- Feel free to suggest improvments or modify it for you own use. It should demonstrate what is possible and beware of starting everyone from scratch.


## Layers and attributes 

###  Forest

Forest layer with name of the objects, by combining the two common classifications.

```mermaid
graph TD;
    landuse=forest-->forest;
    natural=wood-->forest
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---       |
| area_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| geom | Multipolygon geometry | GiST | Multipolygon geometry of the OSM object |

### Water

Water area layer with name of the objects, by combining the two common classifications.

```mermaid
graph TD;
    natural=water-->water;
    waterway=riverbank-->water;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| area_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| geom | Multipolygon geometry | GiST| Multipolygon geometry of the OSM object |

### Grass

Area layer for different kind of grass like vegetation with name of the objects.

```mermaid
graph TD;
    natural=meadow-->grass;
    natural=heath-->grass;
    natural=grassland-->grass;
    landuse=meadow-->grass;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| area_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| geom | Multipolygon geometry | GiST| Multipolygon geometry of the OSM object |

### Building

Buildings layer with name, and adress of the objects.

```mermaid
graph TD;
    buidling=*-->building;
    
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| area_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| building | text | B-Tree | Content of the ```building``` tag | 
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| street | text | | Content of the ```addr:street``` tag | 
| housenumber | text | | Content of the ```addr:housenumber``` tag | 
| postcode | text | | Content of the ```addr:postcode``` tag | 
| city | text | | Content of the ```addr:city``` tag | 
| geom | Multipolygon geometry | GiST | Multipolygon geometry of the OSM object |

### Traffic

Line layer with roads and railways with name of the objects, and essential other tags in a cleaned way.

```mermaid
graph TD;
    highway=*-->traffic;
    railway=*-->traffic;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| way_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| highway | text | B-Tree | Content of the ```highway``` tag | 
| railway | text | B-Tree | Content of the ```railway``` tag | 
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| service | text | | Content of the ```service``` tag | 
| usage | text | | Content of the ```usage``` tag | 
| tracktype | text | | Content of the ```tracktype``` tag | 
| trail_visibility | text | | Content of the ```trail_visibility``` tag |
| oneway | bool | B-Tree | Content of the ```oneway``` tag converted to a bool | 
| bridge | bool | B-Tree | Content of the ```bridge``` tag converted to a bool | 
| tunnel | bool | B-Tree |  Content of the ```tunnel``` tag converted to a bool | 
| layer | real | B-Tree | Content of the ```layer``` tag converted to a number | 
| ref | bool | | Content of the ```ref``` tag | 
| geom | Linestring geometry | GiST | Linestring geometry of the OSM object |

### Waterway

Waterway linstring layer with name of the objects, and common attributes.

```mermaid
graph TD;
    waterway=*-->waterway;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| way_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| waterway | text | B-Tree | Content of the ```oneway``` tag |
| intermittent | bool | B-Tree | Content of the ```intermittent``` tag converted to a bool | 
| tunnel | bool | B-Tree |  Content of the ```tunnel``` tag converted to a bool | 
| layer | real | | Content of the ```layer``` tag converted to a number | 
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| geom | Linestring geometry | GiST| Linestring geometry of the OSM object |

### Address

Address point layer with street, housenumber, postcode, and city.

```mermaid
graph TD;
    addr:housenumber-->address;
    addr:street-->address;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| node_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| street | text | | Content of the ```addr:street``` tag | 
| housenumber | text | | Content of the ```addr:housenumber``` tag | 
| postcode | text | | Content of the ```addr:postcode``` tag | 
| city | text | | Content of the ```addr:city``` tag | 
| geom | Point geometry | GiST | Multipolygon geometry of the OSM object |


### Elevation point

Peaks, vulcanos, saddles and view points in one table with their elevation.

```mermaid
graph TD;
    natural=peak-->elevation_point;
    natural=vulcano-->elevation_point;
    natural=saddle-->elevation_point;
    tourism=viewpoint-->elevation_point;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| node_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| type | text | B-Tree | Content of the ```natural``` tag or the ```tourism``` tag | 
| direction | text | | Content of the ```direction``` tag | 
| ele | real | B-Tree | Content of the ```ele``` tag converted to a number | 
| geom | Point geometry | GiST | Multipolygon geometry of the OSM object |


### Admin boundary line

Administrative boundaries as lines. Useful for rendering.

```mermaid
graph TD;
    boundary=administrative-->admin_boundary_line;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| way_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| admin_level | text | B-Tree | Content of the ```admin_level``` tag | 

### Admin boundary area

Administrative boundaries as lines. Useful for processing and analysis.

```mermaid
graph TD;
    boundary=administrative-->admin_boundary_area;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| area_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| admin_level | text | B-Tree | Content of the ```admin_level``` tag | 

### POI 

Collects many tags and offer them as a point geometry.

```mermaid
graph TD;
    amenity=*-->poi;
    leisure=*-->poi;
    tourism=*-->poi;
    man_made=*-->poi;
    historic=*-->poi;
    natural=*-->poi;
    natural=*-->poi;
    barrier=*-->poi;
    public_transport=*-->poi;
```

| Attribute | Type | Index | Describtion |
| :---      | :--- | :---  | :---        |
| osm_id | int | | Id of OSM object, needed for running updates |
| fid | int | | Feature id |
| name | text | | Name of the object |
| name_en | text | | Englisch name of the object | 
| leisure | text | B-Tree | Content of the ```leisure``` tag | 
| tourism | text | B-Tree | Content of the ```tourism``` tag | 
| historic | text | B-Tree | Content of the ```historic``` tag | 
| man_made | text | B-Tree | Content of the ```man_made``` tag | 
| natural | text | B-Tree | Content of the ```natural``` tag | 
| amenity| text | B-Tree | Content of the ```amenity``` tag | 
| shop | text | B-Tree | Content of the ```shop``` tag | 
| public_transport | text | B-Tree | Content of the ```public_transport``` tag | 
| highway | text | B-Tree | Content of the ```highway``` tag | 
| barrier | text | B-Tree | Content of the ```barrier``` tag | 
| information | text | B-Tree | Content of the ```information``` tag | 
| tags | JSONB | | All tags of the OSM object |
| osm_geom | Geometry collection | GiST | Geometry of the OSM object |
| geom | Point geometry | | Point geometry of the OSM object generatet via ST_PointOnSurface on demand |

## QGIS Demo Project

![Sample rending with QGIS](qgis_rendering.png)

There is a QGIS Demo project visualizing some of the imported OpenStreetMap aming a map at the scale 1:10,000 for Saxony in Germany. The project use a the ```pg_service.conf``` file, expecting a service called "graubrot". Create the following connection in the file. There are tutorials how to use it on [Linux](https://www.postgresql.org/docs/current/libpq-pgservice.html) and [Windows](https://gis.stackexchange.com/questions/393485/how-to-open-qgis-project-without-being-asked-for-postgis-credentials-every-time).

    [graubrot]
    host=localhost
    port=5432
    dbname=graubrot
    user=a_user
    password=a_password

The color can be easily adjusted by chaning the project colors in QGIS. Feel free to further adjust the map to your needs, other scales and so on. It should make the start easier.
