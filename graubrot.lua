print('osm2pgsql version: ' .. osm2pgsql.version)

-- Variables
local tables = {}
local import_schema = 'osm' -- Defines the import schema
local epsg_code = 32633 -- Defines the projection

-- Table defenitions
tables.forest = osm2pgsql.define_table({
    name = 'forest',
    schema = import_schema,
    ids = {
        type = 'area',
        id_column = 'area_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }}
})

tables.water = osm2pgsql.define_table({
    name = 'water',
    schema = import_schema,
    ids = {
        type = 'area',
        id_column = 'area_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }}
})

tables.grass = osm2pgsql.define_table({
    name = 'grass',
    schema = import_schema,
    ids = {
        type = 'area',
        id_column = 'area_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }}
})

tables.building = osm2pgsql.define_table({
    name = 'building',
    schema = import_schema,
    ids = {
        type = 'area',
        id_column = 'area_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'building',
        type = 'text'
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'street',
        type = 'text'
    }, {
        column = 'housenumber',
        type = 'text'
    }, {
        column = 'postcode',
        type = 'text'
    }, {
        column = 'city',
        type = 'text'
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }},
    indexes = {{
        column = 'building',
        method = 'btree'
    }, {
        column = 'geom',
        method = 'gist'

    }}
})

tables.traffic = osm2pgsql.define_table({
    name = 'traffic',
    schema = import_schema,
    ids = {
        type = 'way',
        id_column = 'way_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'highway',
        type = 'text'
    }, {
        column = 'railway',
        type = 'text'
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'service',
        type = 'text'
    }, {
        column = 'usage',
        type = 'text'
    }, {
        column = 'tracktype',
        type = 'text'
    }, {
        column = 'trail_visibility',
        type = 'text'
    }, {
        column = 'oneway',
        type = 'bool'
    }, {
        column = 'bridge',
        type = 'bool'
    }, {
        column = 'tunnel',
        type = 'bool'
    }, {
        column = 'layer',
        type = 'real'
    }, {
        column = 'ref',
        type = 'text'
    }, {
        column = 'geom',
        type = 'linestring',
        projection = epsg_code
    }},
    indexes = {{
        column = 'highway',
        method = 'btree'
    }, {
        column = 'railway',
        method = 'btree'
    }, {
        column = 'oneway',
        method = 'btree'
    }, {
        column = 'bridge',
        method = 'btree'
    }, {
        column = 'tunnel',
        method = 'btree'
    }, {
        column = 'layer',
        method = 'btree'
    }, {
        column = 'geom',
        method = 'gist'

    }}
})

tables.waterway = osm2pgsql.define_table({
    name = 'waterway',
    schema = import_schema,
    ids = {
        type = 'way',
        id_column = 'area_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'waterway',
        type = 'text'
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'intermittent',
        type = 'bool'
    }, {
        column = 'tunnel',
        type = 'bool'
    }, {
        column = 'layer',
        type = 'real'

    }, {
        column = 'geom',
        type = 'linestring',
        projection = epsg_code
    }},
    indexes = {{
        column = 'waterway',
        method = 'btree'
    }, {
        column = 'intermittent',
        method = 'btree'
    }, {
        column = 'tunnel',
        method = 'btree'

    }, {
        column = 'geom',
        method = 'gist'

    }}
})

tables.admin_boundary_line = osm2pgsql.define_table({
    name = 'admin_boundary_line',
    schema = import_schema,
    ids = {
        type = 'way',
        id_column = 'way_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'admin_level',
        type = 'integer'
    }, {
        column = 'geom',
        type = 'multilinestring',
        projection = epsg_code
    }},
    indexes = {{
        column = 'admin_level',
        method = 'btree'
    }, {
        column = 'geom',
        method = 'gist'
    }}
})

tables.admin_boundary_area = osm2pgsql.define_table({
    name = 'admin_boundary_area',
    schema = import_schema,
    ids = {
        type = 'area',
        id_column = 'area_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'admin_level',
        type = 'integer'
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }},
    indexes = {{
        column = 'admin_level',
        method = 'btree'
    }, {
        column = 'geom',
        method = 'gist'
    }}
})

tables.address = osm2pgsql.define_table({
    name = 'address',
    schema = import_schema,
    ids = {
        type = 'any',
        id_column = 'osm_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'street',
        type = 'text'
    }, {
        column = 'housenumber',
        type = 'text'
    }, {
        column = 'postcode',
        type = 'text'
    }, {
        column = 'city',
        type = 'text'
    }, {
        column = 'osm_geom',
        type = 'geometry',
        projection = epsg_code
    },{
        column = 'geom',
        create_only = true,
        sql_type = 'geometry(point, ' .. epsg_code .. ') GENERATED ALWAYS AS (ST_PointOnSurface(osm_geom)) STORED'
    }},    indexes = {{
        column = 'osm_geom',
        method = 'gist'
    }, {
        column = 'geom',
        method = 'spgist'
    }
}
})

tables.elevation_point = osm2pgsql.define_table({
    name = 'elevation_point',
    schema = import_schema,
    ids = {
        type = 'node',
        id_column = 'node_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'type',
        type = 'text'
    }, {
        column = 'direction',
        type = 'text'
    }, {
        column = 'ele',
        type = 'real'
    }, {
        column = 'geom',
        type = 'point',
        projection = epsg_code
    }},
    indexes = {{
        column = 'type',
        method = 'btree'
    }, {
        column = 'ele',
        method = 'btree'

    }, {
        column = 'geom',
        method = 'spgist'
    }}
})

tables.place = osm2pgsql.define_table({
    name = 'place',
    schema = import_schema,
    ids = {
        type = 'node',
        id_column = 'node_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'place',
        type = 'text'
    }, {
        column = 'population',
        type = 'integer'
    }, {
        column = 'tags',
        type = 'jsonb'
    }, {
        column = 'geom',
        type = 'point',
        projection = epsg_code
    }},
    indexes = {{
        column = 'place',
        method = 'btree'
    }, {
        column = 'population',
        method = 'btree'

    }, {
        column = 'geom',
        method = 'spgist'
    }}
})

tables.poi = osm2pgsql.define_table({
    name = 'poi',
    schema = import_schema,
    ids = {
        type = 'any',
        id_column = 'osm_id'
    },
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'
    }, {
        column = 'leisure',
        type = 'text'
    }, {
        column = 'tourism',
        type = 'text'
    }, {
        column = 'historic',
        type = 'text'
    }, {
        column = 'man_made',
        type = 'text'
    }, {
        column = 'natural',
        type = 'text'
    }, {
        column = 'amenity',
        type = 'text'
    }, {
        column = 'shop',
        type = 'text'
    }, {
        column = 'public_transport',
        type = 'text'
    }, {
        column = 'highway',
        type = 'text'
    }, {
        column = 'railway',
        type = 'text'
    }, {        
        column = 'barrier',
        type = 'text'
    }, {
        column = 'information',
        type = 'text'
    }, {
        column = 'tags',
        type = 'jsonb'
    }, {
        column = 'osm_geom',
        type = 'geometry',
        projection = epsg_code
    }, {
        column = 'geom',
        create_only = true,
        sql_type = 'geometry(point, ' .. epsg_code .. ') GENERATED ALWAYS AS (ST_PointOnSurface(osm_geom)) STORED'
    }},
    indexes = {{
        column = 'leisure',
        method = 'btree'
    }, {
        column = 'tourism',
        method = 'btree'
    }, {
        column = 'historic',
        method = 'btree'
    }, {
        column = 'man_made',
        method = 'btree'
    }, {
        column = 'natural',
        method = 'btree'
    }, {
        column = 'amenity',
        method = 'btree'
    }, {
        column = 'shop',
        method = 'btree'
    }, {
        column = 'public_transport',
        method = 'btree'
    }, {
        column = 'highway',
        method = 'btree'
    }, {
        column = 'railway',
        method = 'btree'        
    }, {
        column = 'barrier',
        method = 'btree'
    }, {
        column = 'information',
        method = 'btree'
    }, {
        column = 'osm_geom',
        method = 'gist'
    }, {
        column = 'geom',
        method = 'spgist'
    }}
})

-- Helper functions 

local function clean_tunnel(object)
    -- Make tunnel value a bool
    local tunnel = false
    if object.tags.tunnel == 'yes' then
        tunnel = true
    elseif object.tags.tunnel == 'culvert' then
        tunnel = true
    elseif object.tags.tunnel == 'building_passage' then
        tunnel = true
    elseif object.tags.tunnel == 'flooded' then
        tunnel = true
    elseif object.tags.tunnel == 'no' then
        tunnel = false
    elseif object.tags.tunnel == 'covered' then
        tunnel = true
    elseif object.tags.tunnel == 'avalanche_protector' then
        tunnel = true
    elseif object.tags.tunnel == 'passage' then
        tunnel = true
    end
    return tunnel
end

local function clean_bridge(object)
    -- Make bridge a bool
    local bridge = false
    if object.tags.bridge == 'yes' then
        bridge = true
    elseif object.tags.bridge == 'viaduct' then
        bridge = true
    elseif object.tags.bridge == 'boardwalk' then
        bridge = true
    elseif object.tags.bridge == 'aqueduct' then
        bridge = true
    elseif object.tags.bridge == 'no' then
        bridge = false
    elseif object.tags.bridge == 'covered' then
        bridge = true
    elseif object.tags.bridge == 'cantilever' then
        bridge = true
    elseif object.tags.bridge == 'trestle' then
        bridge = true
    end
    return bridge
end

local function clean_oneway(object)
    -- Make Oneway a bool
    local oneway = false
    if object.tags.oneway == 'yes' then
        oneway = true
    elseif object.tags.oneway == 'no' then
        oneway = false
    end
    return oneway
end

local function clean_layer(object)
    -- Make layer a number
    layer = 0
    if object.tags.layer then
        layer = tonumber(object.tags.layer)
    end

    return layer
end

function str_to_bool(str)
    if str == nil then
        return false
    end
    return string.lower(str) == 'true'
end

-- Helper function to remove some of the tags we usually are not interested in.
-- Returns true if there are no tags left.
function clean_tags(tags)
    tags.odbl = nil
    tags.created_by = nil
    tags.source = nil
    tags['source:ref'] = nil

    return next(tags) == nil
end

-- Function which fill the tables

function osm2pgsql.process_node(object)

    if clean_tags(object.tags) then
        return
    end

    if object.tags['addr:housenumber'] or object.tags['addr:street'] then
        tables.address:insert({
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            osm_geom = object:as_point()
        })
    end

    if object.tags.natural == 'peak' or object.tags.natural == 'vulcano' or object.tags.natural == 'saddle' then
        tables.elevation_point:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            type = object.tags.natural,
            ele = tonumber(object.tags.ele),
            direction = object.tags.direction,
            geom = object:as_point()
        })
    end

    if object.tags.tourism == 'viewpoint' then
        tables.elevation_point:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            type = object.tags.tourism,
            ele = tonumber(object.tags.ele),
            direction = object.tags.direction,
            geom = object:as_point()
        })
    end

    if object.tags.place then
        tables.place:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            place = object.tags.place,
            population = tonumber(object.tags.population),
            tags = object.tags,
            geom = object:as_point()
        })
    end

    if object.tags.amenity or object.tags.leisure or object.tags.tourism or object.tags.man_made or object.tags.historic or
        object.tags.natural or object.tags.shop or object.tags.barrier or object.tags.public_transport then
        tables.poi:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            leisure = object.tags.leisure,
            tourism = object.tags.tourism,
            historic = object.tags.historic,
            man_made = object.tags.man_made,
            natural = object.tags.natural,
            amenity = object.tags.amenity,
            religion = object.tags.religion,
            highway = object.tags.highway,
            railway = object.tags.railway,
            public_transport = object.tags.public_transport,
            shop = object.tags.shop,
            barrier = object.tags.barrier,
            information = object.tags.information,
            tags = object.tags,
            osm_geom = object:as_point()
        })
    end

end

function osm2pgsql.process_way(object)

    if clean_tags(object.tags) then
        return
    end

    if object.is_closed and (object.tags['addr:housenumber'] or object.tags['addr:street']) then
        tables.address:insert({
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            osm_geom = object:as_multipolygon()
        })
    end    
    
    if object.is_closed and (object.tags.landuse == 'forest' or object.tags.natural == 'wood') then
        tables.forest:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = object:as_multipolygon()
        })
    end

    if object.is_closed and (object.tags.natural == 'water' or object.tags.waterway == 'riverbank') then
        tables.water:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = object:as_multipolygon()
        })
    end

    if object.is_closed and
        (object.tags.natural == 'meadow' or object.tags.natural == 'heath' or object.tags.natural == 'grassland' or
            object.tags.landuse == 'meadow' or object.tags.landuse == 'grass' or object.tags.leisure == 'park' or object.tags.landuse == 'recreation_ground') then
        tables.grass:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = object:as_multipolygon()
        })
    end

    if object.is_closed and object.tags.building then
        tables.building:insert({
            building = object.tags.building,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            geom = object:as_multipolygon()
        })
    end

    if object.tags.highway or object.tags.railway then
        tables.traffic:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            highway = object.tags.highway,
            railway = object.tags.railway,
            service = object.tags.service,
            usage = object.tags.usage,
            tracktype = object.tags.tracktype,
            oneway = clean_oneway(object), -- make it a bool
            bridge = clean_bridge(object), -- make it a bool
            tunnel = clean_tunnel(object), -- make it a bool
            layer = clean_layer(object), -- convert it to a number
            ref = object.tags.ref,
            geom = object:as_multilinestring()
        })
    end

    if object.tags.waterway then
        tables.waterway:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            waterway = object.tags.waterway,
            tunnel = clean_tunnel(object),
            layer = tonumber(object.tags.layer),
            intermittent = str_to_bool(object.tags.intermittent),
            geom = object:as_multilinestring()
        })
    end

    if object.tags.boundary == 'administrative' then
        tables.admin_boundary_line:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            admin_level = tonumber(object.tags.admin_level),
            geom = object:as_multilinestring()
        })
    end

    if object.is_closed and
        (object.tags.amenity or object.tags.leisure or object.tags.tourism or object.tags.man_made or
            object.tags.historic or object.tags.natural or object.tags.shop or object.tags.barrier or
            object.tags.public_transport) then
        tables.poi:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            leisure = object.tags.leisure,
            tourism = object.tags.tourism,
            historic = object.tags.historic,
            man_made = object.tags.man_made,
            natural = object.tags.natural,
            amenity = object.tags.amenity,
            religion = object.tags.religion,
            highway = object.tags.highway,
            railway = object.tags.railway,
            public_transport = object.tags.public_transport,
            shop = object.tags.shop,
            barrier = object.tags.barrier,
            information = object.tags.information,
            tags = object.tags,
            osm_geom = object:as_multipolygon()
        })
    end

    if object.tags.amenity or object.tags.leisure or object.tags.tourism or object.tags.man_made or object.tags.historic or
        object.tags.natural or object.tags.shop or object.tags.barrier or object.tags.public_transport then
        tables.poi:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            leisure = object.tags.leisure,
            tourism = object.tags.tourism,
            historic = object.tags.historic,
            man_made = object.tags.man_made,
            natural = object.tags.natural,
            amenity = object.tags.amenity,
            religion = object.tags.religion,
            highway = object.tags.highway,
            railway = object.tags.railway,
            public_transport = object.tags.public_transport,
            shop = object.tags.shop,
            barrier = object.tags.barrier,
            information = object.tags.information,
            tags = object.tags,
            osm_geom = object:as_multilinestring()
        })
    end

end

function osm2pgsql.process_relation(object)

    if clean_tags(object.tags) then
        return
    end

    local type = object:grab_tag('type')

    -- Store multipolygon relations as polygons

    if type == 'multipolygon' and (object.tags['addr:housenumber'] or object.tags['addr:street']) then
        tables.address:insert({
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            osm_geom = object:as_multipolygon()
        })
    end

    if type == 'multipolygon' and (object.tags.landuse == 'forest' or object.tags.natural == 'wood') then
        tables.forest:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = object:as_multipolygon()
        })
    end

    if type == 'multipolygon' and (object.tags.natural == 'water' or object.tags.waterway == 'riverbank') then
        tables.water:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = object:as_multipolygon()
        })
    end

    if type == 'multipolygon' and
        (object.tags.natural == 'meadow' or object.tags.natural == 'heath' or object.tags.natural == 'grassland' or
            object.tags.landuse == 'meadow' or object.tags.landuse == 'grass' or object.tags.leisure == 'park' or object.tags.landuse == 'recreation_ground') then
        tables.grass:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = object:as_multipolygon()
        })
    end

    if type == 'multipolygon' and object.tags.building then
        tables.building:insert({
            building = object.tags.building,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            geom = object:as_multipolygon()
        })
    end

    if object.tags.boundary == 'administrative' then
        tables.admin_boundary_area:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            admin_level = tonumber(object.tags.admin_level),
            geom = object:as_multipolygon()
        })
    end

    if type == 'multipolygon' and
        (object.tags.amenity or object.tags.leisure or object.tags.tourism or object.tags.man_made or
            object.tags.historic or object.tags.natural or object.tags.shop or object.tags.barrier or
            object.tags.public_transport) then
        tables.poi:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            leisure = object.tags.leisure,
            tourism = object.tags.tourism,
            historic = object.tags.historic,
            man_made = object.tags.man_made,
            natural = object.tags.natural,
            amenity = object.tags.amenity,
            religion = object.tags.religion,
            highway = object.tags.highway,
            railway = object.tags.railway,
            public_transport = object.tags.public_transport,
            shop = object.tags.shop,
            barrier = object.tags.barrier,
            information = object.tags.information,
            tags = object.tags,
            osm_geom = object:as_multipolygon()
        })
    end

    if object.tags.amenity or object.tags.leisure or object.tags.tourism or object.tags.man_made or object.tags.historic or
        object.tags.natural or object.tags.shop or object.tags.barrier or object.tags.public_transport then
        tables.poi:insert({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            leisure = object.tags.leisure,
            tourism = object.tags.tourism,
            historic = object.tags.historic,
            man_made = object.tags.man_made,
            natural = object.tags.natural,
            amenity = object.tags.amenity,
            religion = object.tags.religion,
            highway = object.tags.highway,
            railway = object.tags.railway,
            public_transport = object.tags.public_transport,
            shop = object.tags.shop,
            barrier = object.tags.barrier,
            information = object.tags.information,
            tags = object.tags,
            osm_geom = object:as_multilinestring()
        })
    end

end
