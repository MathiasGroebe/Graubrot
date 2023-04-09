# Graubrot
A osm2pgsql configuration for the flex-backend for everyday use. Imports common objects for make a simple big scale map with no generlization. It tries to clean the attributes to create a easy to handle data model.

## Running

###  Quickstart

1. Create a PostgrSQL Database
2. Enable PostGIS by executing ```CREATE EXTENSION POSTGIS```
3. Create a schema for the data import ```CREATE SCHEMA osm```. You can also use another Schema. It is just the default value.
4. Run ```osm2pgsql -c -O flex -S graubrot.lua -d postgres://USER:PASS@HOST/DB_NAME  YOUR_OSM_FILE.osm.pbf```

### Hints

- Security
- Index 
- ...


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
    waterway=riverbank-->water
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
    railway=*-->traffic
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
    waterway=*-->waterway
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



TODO:: POI + Peak
