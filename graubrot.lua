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

-- Helper functions 

local function clean_tunnel(object)
    -- Make tunnel value a bool
    local tunnel = nil
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
    local bridge = nil
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
    local oneway = false
    if object.tags.oneway == 'yes' then
        oneway = true
    elseif object.tags.oneway == 'no' then
        oneway = false
    end
    return oneway
end

function str_to_bool(str)
    if str == nil then
        return false
    end
    return string.lower(str) == 'true'
end

-- Function which fill the tables

function osm2pgsql.process_way(object)

    -- A closed way that also has the right tags for an area is a polygon.
    if object.is_closed and (object.tags.landuse == 'forest' or object.tags.natural == 'wood') then
        tables.forest:add_row({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = {
                create = 'area'
            }
        })
    end

    if object.is_closed and (object.tags.natural == 'water' or object.tags.waterway == 'riverbank') then
        tables.water:add_row({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = {
                create = 'area'
            }
        })
    end

    if object.is_closed and object.tags.building then
        tables.building:add_row({
            building = object.tags.building,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            geom = {
                create = 'area'
            }
        })
    end

    if object.tags.highway or object.tags.railway then
        tables.traffic:add_row({
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
            layer = tonumber(object.tags.layer), -- convert it to a number
            ref = object.tags.ref,
            geom = {
                create = 'line'
            }
        })
    end

    if object.tags.waterway then
        tables.waterway:add_row({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            waterway = object.tags.waterway,
            tunnel = clean_tunnel(object),
            layer = tonumber(object.tags.layer),
            intermittent = str_to_bool(object.tags.intermittent),
            geom = {
                create = 'line'
            }
        })
    end

end

function osm2pgsql.process_relation(object)

    local type = object:grab_tag('type')

    -- Store multipolygon relations as polygons
    if type == 'multipolygon' and (object.tags.landuse == 'forest' or object.tags.natural == 'forest') then
        tables.forest:add_row({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = {
                create = 'area'
            }
        })
    end

    if type == 'multipolygon' and (object.tags.natural == 'water' or object.tags.waterway == 'riverbank') then
        tables.water:add_row({
            name = object.tags.name,
            name_en = object.tags['name:en'],
            geom = {
                create = 'area'
            }
        })
    end

    if type == 'multipolygon' and object.tags.building then
        tables.building:add_row({
            building = object.tags.building,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            geom = {
                create = 'area'
            }
        })
    end

end
