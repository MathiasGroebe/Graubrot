print('osm2pgsql version: ' .. osm2pgsql.version)

local function generate_uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

-- Variables
local tables = {}
local import_schema = 'osm' -- Defines the import schema
local epsg_code = 25833 -- Defines the projection
local w2r = {}
local file_reading_in_progress = true

local function format_date(ts)
    return os.date('!%Y-%m-%dT%H:%M:%SZ', ts)
end

-- Table definitions

tables.changes = osm2pgsql.define_table({
    name = 'changes',
    schema = import_schema,
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    }, {
        column = 'osm_type',
        type = 'text'        
    }, {
        column = 'version',
        type = 'integer'    
    }, {
        column = 'layer',
        type = 'text'
    }, {
        column = 'change_uuid',
        type = 'text'
    }, {
        column = 'name',
        type = 'text'
    }, {        
        column = 'action',
        type = 'text'
    }, {        
        column = 'reviewed',
        type = 'text'        
    }, {
        column = 'edit_timestamp',
        sql_type = 'timestamp'
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'
    }, {        
        column = 'object_geom',
        type = 'geometry',
        projection = epsg_code        
    },{
        column = 'geom',
        create_only = true,
        sql_type = "geometry(polygon, " .. epsg_code .. ") GENERATED ALWAYS AS (CASE WHEN ST_GeometryType(object_geom) = 'ST_Point' THEN ST_Envelope(ST_Buffer(object_geom, 10)) ELSE ST_Envelope(object_geom) END) STORED"
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    },
    {
        column = 'osm_id',
        method = 'btree'
    },
    {
        column = 'reviewed',
        method = 'btree'
    },    
    {
        column = 'object_geom',
        method = 'gist'
    },
    {
        column = 'geom',
        method = 'gist'
    }
}
})


tables.forest = osm2pgsql.define_table({
    name = 'forest',
    schema = import_schema,
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{
        column = 'change_uuid',
        type = 'text'
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
        column = 'last_edit',
        sql_type = 'timestamp',
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'        
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'
    },    
    {
        column = 'geom',
        method = 'gist'
    }}
})

tables.water = osm2pgsql.define_table({
    name = 'water',
    schema = import_schema,
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{        
        column = 'change_uuid',
        type = 'text'
    }, {        
        column = 'name',
        type = 'text'
    }, {
        column = 'name_en',
        type = 'text'    },
    {
        column = 'label_visible',
        type = 'bool',
        create_only = true          
    }, {
        column = 'label_text',
        type = 'text',
        create_only = true    
    }, {
        column = 'label_x',
        type = 'real',
        create_only = true      
    }, {
        column = 'label_y',
        type = 'real',
        create_only = true   
    }, {
        column = 'label_rotation',
        type = 'real',
        create_only = true
    }, {
        column = 'last_edit',
        sql_type = 'timestamp'
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'        
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }}
})

tables.grass = osm2pgsql.define_table({
    name = 'grass',
    schema = import_schema,
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{ 
        column = 'change_uuid',
        type = 'text'
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
        column = 'last_edit',
        sql_type = 'timestamp',
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'        
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }}
})

-- Table defenitions
tables.built_up_area = osm2pgsql.define_table({
    name = 'built_up_area',
    schema = import_schema,
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{       
        column = 'change_uuid',
        type = 'text'
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
        column = 'last_edit',
        sql_type = 'timestamp',
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'        
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }}
})

tables.building = osm2pgsql.define_table({
    name = 'building',
    schema = import_schema,
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{    
        column = 'change_uuid',
        type = 'text'
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
        column = 'label_visible',
        type = 'bool',
        create_only = true         
    }, {
        column = 'label_text',
        type = 'text',
        create_only = true       
    }, {
        column = 'label_x',
        type = 'real',
        create_only = true
    }, {
        column = 'label_y',
        type = 'real',
        create_only = true
    }, {
        column = 'label_rotation',
        type = 'real',
        create_only = true
    }, {
        column = 'last_edit',
        sql_type = 'timestamp'        
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'        
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }, {
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
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{     
        column = 'change_uuid',
        type = 'text'
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
        column = 'ref',
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
        column = 'surface',
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
        column = 'z_order',
        type = 'real'
    }, {
        column = 'label_visible',
        type = 'bool',
        create_only = true           
    }, {
        column = 'label_text',
        type = 'text',
        create_only = true
    }, {
        column = 'label_x',
        type = 'real',
        create_only = true
    }, {
        column = 'label_y',
        type = 'real',
        create_only = true
    }, {
        column = 'label_rotation',
        type = 'real',
        create_only = true
    }, {
        column = 'last_edit',
        sql_type = 'timestamp' 
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'                       
    }, { 
        column = 'osmc_symbols', 
        type = 'jsonb' 
    },{ 
        column = 'rel_ids', 
        sql_type = 'int8[]' 
    }, {
        column = 'geom',
        type = 'linestring',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'     
    },{
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
        column = 'z_order',
        method = 'btree'        
    }, {
        column = 'geom',
        method = 'gist'
    }, {
        expression = '(NOT tunnel AND NOT bridge)',
        method = 'btree'
    }, {
        expression = '(NOT ST_IsSimple(geom))',
        method = 'btree'
    }}
})

tables.waterway = osm2pgsql.define_table({
    name = 'waterway',
    schema = import_schema,
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{      
        column = 'change_uuid',
        type = 'text'
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
        column = 'label_visible',
        type = 'bool',
        create_only = true
    }, {
        column = 'label_text',
        type = 'text',
        create_only = true
    }, {
        column = 'label_x',
        type = 'real',
        create_only = true
    }, {
        column = 'label_y',
        type = 'real',
        create_only = true
    }, {
        column = 'label_rotation',
        type = 'real',
        create_only = true
    }, {
        column = 'last_edit',
        sql_type = 'timestamp'        
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'                       
    }, {
        column = 'geom',
        type = 'linestring',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }, {
        column = 'waterway',
        method = 'btree'
    }, {
        column = 'intermittent',
        method = 'btree'
    }, {
        column = 'tunnel',
        method = 'btree'
    }, {
        column = 'layer',
        method = 'btree'
    }, {        
        expression = '(NOT ST_IsSimple(geom))',
        method = 'btree'
    }, {
        column = 'geom',
        method = 'gist'
    }}
})

tables.admin_boundary_line = osm2pgsql.define_table({
    name = 'admin_boundary_line',
    schema = import_schema,
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{
        column = 'change_uuid',
        type = 'text'
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
        column = 'last_edit',
        sql_type = 'timestamp',
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'                       
    }, {
        column = 'geom',
        type = 'multilinestring',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }, {
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
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{
        column = 'change_uuid',
        type = 'text'
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
        column = 'label_visible',
        type = 'bool',
        create_only = true            
    }, {
        column = 'label_text',
        type = 'text',
        create_only = true
    }, {
        column = 'label_x',
        type = 'real',
        create_only = true
    }, {
        column = 'label_y',
        type = 'real',
        create_only = true
    }, {
        column = 'label_rotation',
        type = 'real',
        create_only = true
    }, {
        column = 'last_edit',
        sql_type = 'timestamp'    
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'            
    }, {
        column = 'geom',
        type = 'multipolygon',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }, {
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
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{
        column = 'change_uuid',
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
        column = 'last_edit',
        sql_type = 'timestamp'
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'        
    }, {
        column = 'osm_geom',
        type = 'geometry',
        projection = epsg_code
    },{
        column = 'geom',
        create_only = true,
        sql_type = 'geometry(point, ' .. epsg_code .. ') GENERATED ALWAYS AS (ST_PointOnSurface(osm_geom)) STORED'
    }},    
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }, {
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
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{
        column = 'change_uuid',
        type = 'text'
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
        column = 'label_visible',
        type = 'bool',
        create_only = true          
    }, {
        column = 'label_text',
        type = 'text',
        create_only = true
    }, {
        column = 'label_x',
        type = 'real',
        create_only = true
    }, {
        column = 'label_y',
        type = 'real',
        create_only = true
    }, {
        column = 'label_rotation',
        type = 'real'
    }, {
        column = 'last_edit',
        sql_type = 'timestamp' 
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'               
    }, {
        column = 'geom',
        type = 'point',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'         
    }, {
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
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{
        column = 'change_uuid',
        type = 'text'
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
        type = 'integer',
        create_only = true
    }, {
        column = 'label_visible',
        type = 'bool',
        create_only = true
    }, {
        column = 'label_text',
        type = 'text',
        create_only = true
    }, {
        column = 'label_x',
        type = 'real',
        create_only = true
    }, {
        column = 'label_y',
        type = 'real',
        create_only = true
    }, {
        column = 'label_rotation',
        type = 'real',
        create_only = true
    }, {
        column = 'last_edit',
        sql_type = 'timestamp'
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'        
    }, {
        column = 'tags',
        type = 'jsonb'
    }, {
        column = 'geom',
        type = 'point',
        projection = epsg_code
    }},
    indexes = {{
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'        
    }, {
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
    ids = nil,
    columns = {{
        column = 'fid',
        sql_type = 'serial',
        create_only = true
    }, {
        column = 'osm_id',
        type = 'bigint'
    },{
        column = 'version',
        type = 'integer'
    },{
        column = 'approved',
        type = 'bool',
    },{
        column = 'change_uuid',
        type = 'text'
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
        column = 'power',
        type = 'text'
    }, {
        column = 'communication',
        type = 'text'
    }, {
        column = 'landuse',
        type = 'text'                        
    }, {
        column = 'label_visible',
        type = 'bool',
        create_only = true         
    }, {
        column = 'label_text',
        type = 'text',
        create_only = true      
    }, {
        column = 'label_x',
        type = 'real',
        create_only = true
    }, {
        column = 'label_y',
        type = 'real',
        create_only = true
    }, {
        column = 'label_rotation',
        type = 'real',
        create_only = true
    }, {
        column = 'last_edit',
        sql_type = 'timestamp'
    }, {
        column = 'import_timestamp',
        sql_type = 'timestamp'
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
        column = 'fid',
        method = 'btree',
        unique = true
    }, {
        column = 'osm_id',
        method = 'btree'
    }, {
        column = 'approved',
        method = 'btree'           
    }, {
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
        column = 'power',
        method = 'btree'        
    }, {
        column = 'communication',
        method = 'btree'
    }, {
        column = 'landuse',
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
    if type(layer) == "number" then 
        return layer
    else
        return 0
    end
end

local function grass_type(object)

    if object.tags.natural then
        return object.tags.natural
    end

    if object.tags.landuse then 
        return object.tags.landuse
    end 

    if object.tags.leisure then
        return object.tags.leisure
    else
        return ''
    end

end

local function forest_type(object)

    if object.tags.natural == 'wood' then 
        return 'wood' 
    end

    if object.tags.landuse == 'forst' then 
        return 'forest' 
    else return 'forest' 
    end 
    
end

local function z_order_calculation(object)
    -- Calculate z_order 
    -- layer *10; bridge +10, tunnel -10
    -- ranking (0...9): motorway:9, path:0
    -- default = 0
    -- See: https://github.com/osm2pgsql-dev/osm2pgsql/blob/master/style.lua and 
    -- https://imposm.org/docs/imposm3/latest/mapping.html#wayzorder

    z_order = 0

    if object.tags.railway then z_order = 5 end
    if object.tags.highway == 'minor' then z_order = 3 end
    if object.tags.highway == 'road' then z_order = 3 end
    if object.tags.highway == 'unclassified' then z_order = 3 end
    if object.tags.highway == 'residential' then z_order = 3 end
    if object.tags.highway == 'tertiary' then z_order = 4 end
    if object.tags.highway == 'tertiary_link' then z_order = 4 end
    if object.tags.highway == 'secondary' then z_order = 6 end
    if object.tags.highway == 'secondary_link' then z_order = 6 end
    if object.tags.highway == 'primary' then z_order = 7 end
    if object.tags.highway == 'primary_link' then z_order = 7 end
    if object.tags.highway == 'trunk' then z_order = 8 end
    if object.tags.highway == 'trunk_link' then z_order = 8 end
    if object.tags.highway == 'motorway' then z_order = 9 end
    if object.tags.highway == 'motorway_link' then z_order = 9 end

    bridge = clean_bridge(object)
    tunnel = clean_tunnel(object)
    layer = clean_layer(object)

    if bridge then z_order = z_order + 10 end 
    if tunnel then z_order = z_order -10 end
    z_order = z_order + layer * 10

    return z_order
end

local function add_object_change(object, object_layer, object_geom, change_uuid)
    -- In this example only changes while updating the database are recorded.
    -- This happens in 'append' mode.
    if osm2pgsql.mode == 'append' then
        tables.changes:insert{
            osm_type = object.type,
            osm_id = object.id,
            version = object.version,
            action = (object.version == 1) and 'A' or 'M',
            edit_timestamp = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            layer = object_layer,
            change_uuid = change_uuid,
            object_geom = object_geom, 
        }
    end
end

local function add_deleted_object(object)
    tables.changes:insert{
        osm_type = object.type,
        osm_id = object.id,
        version = object.version,
        action = 'D',
        -- Timestamp of the import day, otherwise it would show the timestamp of the last update of the object.
        edit_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }
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

function osm2pgsql.select_relation_members(relation)
    -- Only interested in relations with type=route
    if relation.tags.type == 'route' and relation.tags.route == 'hiking' then
        return { ways = osm2pgsql.way_member_ids(relation) }
    end
end


-- Function which fill the tables

function osm2pgsql.process_node(object)

    if clean_tags(object.tags) then
        return
    end

    if object.tags['addr:housenumber'] or object.tags['addr:street'] then
        new_uuid = generate_uuid()
        tables.address:insert({ 
            osm_id = object.id,
            version = object.version,
            change_uuid = new_uuid,
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            osm_geom = object:as_point()
        })

        add_object_change(object, "address", object:as_point(), new_uuid)
    end

    if object.tags.natural == 'peak' or object.tags.natural == 'vulcano' or object.tags.natural == 'saddle' then
        new_uuid = generate_uuid()
        tables.elevation_point:insert({
            osm_id = object.id,
            version = object.version, 
            change_uuid = new_uuid,           
            name = object.tags.name,
            name_en = object.tags['name:en'],
            type = object.tags.natural,
            ele = tonumber(object.tags.ele),
            direction = object.tags.direction,
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_point()
        })

        add_object_change(object, "elevation_point", object:as_point(), new_uuid)
    end

    if object.tags.tourism == 'viewpoint' then
        new_uuid = generate_uuid()
        tables.elevation_point:insert({
            osm_id = object.id,
            version = object.version, 
            change_uuid = new_uuid,           
            name = object.tags.name,
            name_en = object.tags['name:en'],
            type = object.tags.tourism,
            ele = tonumber(object.tags.ele),
            direction = object.tags.direction,
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_point()
        })

        add_object_change(object, "elevation_point", object:as_point(), new_uuid)
    end

    if object.tags.place then
        new_uuid = generate_uuid()
        tables.place:insert({
            osm_id = object.id,
            version = object.version, 
            change_uuid = new_uuid,           
            name = object.tags.name,
            name_en = object.tags['name:en'],
            place = object.tags.place,
            population = tonumber(object.tags.population),
            tags = object.tags,
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_point()
        })

        add_object_change(object, "place", object:as_point(), new_uuid)
    end

    if object.tags.amenity or object.tags.leisure or object.tags.tourism or object.tags.man_made or object.tags.historic or
    object.tags.natural or object.tags.shop or object.tags.barrier or object.tags.public_transport or object.tags.power or 
    object.tags.communication or object.tags.landuse then
        new_uuid = generate_uuid()
        tables.poi:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
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
            power = object.tags.power,
            communication = object.tags.communication,
            landuse = object.tags.landuse,
            tags = object.tags,
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            osm_geom = object:as_point()
        })

        add_object_change(object, "poi", object:as_point(), new_uuid)
    end

end

function osm2pgsql.process_way(object)

    if clean_tags(object.tags) then
        return
    end

    if object.is_closed and (object.tags['addr:housenumber'] or object.tags['addr:street']) then
        new_uuid = generate_uuid()
        tables.address:insert({
            osm_id = object.id,
            version = object.version, 
            change_uuid = new_uuid,           
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            osm_geom = object:as_multipolygon()
        })

        add_object_change(object, "address", object:as_multipolygon(), new_uuid)
    end    
    
    if object.is_closed and (object.tags.landuse == 'forest' or object.tags.natural == 'wood') then
        new_uuid = generate_uuid()
        tables.forest:insert({
            osm_id = object.id,
            version = object.version,
            change_uuid = new_uuid,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            type = forest_type(object),
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "forest", object:as_multipolygon(), new_uuid)
    end

    if object.is_closed and (object.tags.natural == 'water' or object.tags.waterway == 'riverbank') then
        new_uuid = generate_uuid()
        tables.water:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "water", object:as_multipolygon(), new_uuid)
    end

    if object.is_closed and
        (object.tags.natural == 'meadow' or object.tags.natural == 'heath' or object.tags.natural == 'grassland' or
            object.tags.landuse == 'meadow' or object.tags.landuse == 'grass' or object.tags.leisure == 'park' or 
            object.tags.landuse == 'recreation_ground' or object.tags.landuse == 'cemetery' or object.tags.landuse == 'allotments' or
            object.tags.leisure == 'pitch' ) then
        new_uuid = generate_uuid()
        tables.grass:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
            name = object.tags.name,
            type = grass_type(object),
            name_en = object.tags['name:en'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "grass", object:as_multipolygon(), new_uuid)
    end

    if object.is_closed and
        ( object.tags.landuse == 'institutional' or object.tags.landuse == 'garages' or object.tags.landuse == 'railway' or 
            object.tags.landuse == 'commercial' or object.tags.landuse == 'education' or object.tags.landuse == 'fairground' or 
            object.tags.landuse == 'industrial' or object.tags.landuse == 'residential' or object.tags.landuse == 'retail') then
        new_uuid = generate_uuid()
        tables.built_up_area:insert({
            osm_id = object.id,
            version = object.version, 
            change_uuid = new_uuid,           
            name = object.tags.name,
            type = object.tags.landuse,
            name_en = object.tags['name:en'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "built_up_area", object:as_multipolygon(), new_uuid)

    end    

    if object.is_closed and object.tags.building then
        new_uuid = generate_uuid()
        tables.building:insert({
            osm_id = object.id,
            version = object.version,
            change_uuid = new_uuid,          
            building = object.tags.building,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "building", object:as_multipolygon(), new_uuid)
    end

    if object.tags.highway or object.tags.railway then
        new_uuid = generate_uuid()
        row = {
            osm_id = object.id,
            version = object.version, 
            change_uuid = new_uuid,           
            name = object.tags.name,
            name_en = object.tags['name:en'],
            ref = object.tags.ref,
            highway = object.tags.highway,
            railway = object.tags.railway,
            service = object.tags.service,
            usage = object.tags.usage,
            tracktype = object.tags.tracktype,
            surface = object.tags.surface,
            oneway = clean_oneway(object), -- make it a bool
            bridge = clean_bridge(object), -- make it a bool
            tunnel = clean_tunnel(object), -- make it a bool
            layer = clean_layer(object), -- convert it to a number
            z_order = z_order_calculation(object),
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multilinestring()
        }

        local d = w2r[object.id]
        if d then
            local refs = {}
            local ids = {}
            for rel_id, rel_ref in pairs(d) do
                refs[#refs + 1] = rel_ref
                ids[#ids + 1] = rel_id
            end
            table.sort(refs)
            table.sort(ids)
            row.osmc_symbols = refs
            row.rel_ids = '{' .. table.concat(ids, ',') .. '}'
        end

        tables.traffic:insert(row)
        add_object_change(object, "traffic", object:as_multilinestring(), new_uuid)
    end

    if object.tags.waterway then
        new_uuid = generate_uuid()
        tables.waterway:insert({
            osm_id = object.id,
            version = object.version,
            change_uuid = new_uuid,          
            name = object.tags.name,
            name_en = object.tags['name:en'],
            waterway = object.tags.waterway,
            tunnel = clean_tunnel(object),
            layer = clean_layer(object),
            intermittent = str_to_bool(object.tags.intermittent),
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multilinestring()
        })

        add_object_change(object, "waterway", object:as_multilinestring(), new_uuid)
                
    end

    if object.tags.boundary == 'administrative' then
        new_uuid = generate_uuid()
        tables.admin_boundary_line:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            admin_level = tonumber(object.tags.admin_level),
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multilinestring()
        })

        add_object_change(object, "admin_boundary_line", object:as_multilinestring(), new_uuid)

    end

    if (object.tags.amenity or object.tags.leisure or object.tags.tourism or object.tags.man_made or object.tags.historic or
        object.tags.natural or object.tags.shop or object.tags.barrier or object.tags.public_transport or object.tags.power or 
        object.tags.communication or object.tags.landuse) then

        new_uuid = generate_uuid()

        if object.is_closed then
            geometry = object:as_multipolygon()
        else
            geometry = object:as_linestring()
        end

        tables.poi:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
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
            power = object.tags.power,
            communication = object.tags.communication,
            landuse = object.tags.landuse,
            tags = object.tags,
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            osm_geom = geometry
        })

        add_object_change(object, "poi", geometry, new_uuid)

    end

end

function osm2pgsql.process_relation(object)

    if clean_tags(object.tags) then
        return
    end

    local type = object:grab_tag('type')

    -- Store multipolygon relations as polygons

    if type == 'multipolygon' and (object.tags['addr:housenumber'] or object.tags['addr:street']) then
        new_uuid = generate_uuid()
        tables.address:insert({
            osm_id = object.id,
            version = object.version,  
            change_uuid = new_uuid,          
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            osm_geom = object:as_multipolygon()
        })

        add_object_change(object, "address", object:as_multipolygon(), new_uuid)
    end

    if type == 'multipolygon' and (object.tags.landuse == 'forest' or object.tags.natural == 'wood') then
        new_uuid = generate_uuid()
        tables.forest:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
            osm_id = object.id,
            version = object.version,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            type = forest_type(object),
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })
        add_object_change(object, "forest", object:as_multipolygon(), new_uuid)
    end

    if type == 'multipolygon' and (object.tags.natural == 'water' or object.tags.waterway == 'riverbank') then
        new_uuid = generate_uuid()
        tables.water:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "water", object:as_multipolygon(), new_uuid)
    end

    if type == 'multipolygon' and
        ( object.tags.landuse == 'institutional' or object.tags.landuse == 'garages' or object.tags.landuse == 'railway' or 
            object.tags.landuse == 'commercial' or object.tags.landuse == 'education' or object.tags.landuse == 'fairground' or 
            object.tags.landuse == 'industrial' or object.tags.landuse == 'residential' or object.tags.landuse == 'retail') then
        new_uuid = generate_uuid()
        tables.built_up_area:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
            name = object.tags.name,
            type = object.tags.landuse,
            name_en = object.tags['name:en'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "built_up_area", object:as_multipolygon(), new_uuid)
    end 

    if type == 'multipolygon' and
    (object.tags.natural == 'meadow' or object.tags.natural == 'heath' or object.tags.natural == 'grassland' or
    object.tags.landuse == 'meadow' or object.tags.landuse == 'grass' or object.tags.leisure == 'park' or 
    object.tags.landuse == 'recreation_ground' or object.tags.landuse == 'cemetery' or object.tags.landuse == 'allotments') then
        new_uuid = generate_uuid()
        tables.grass:insert({
            osm_id = object.id,
            version = object.version, 
            change_uuid = new_uuid,           
            name = object.tags.name,
            type = grass_type(object),
            name_en = object.tags['name:en'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "grass", object:as_multipolygon(), new_uuid)
    end

    if type == 'multipolygon' and object.tags.building then
        new_uuid = generate_uuid()
        tables.building:insert({
            osm_id = object.id,
            version = object.version,            
            change_uuid = new_uuid,
            building = object.tags.building,
            name = object.tags.name,
            name_en = object.tags['name:en'],
            street = object.tags['addr:street'],
            housenumber = object.tags['addr:housenumber'],
            postcode = object.tags['addr:postcode'],
            city = object.tags['addr:city'],
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })

        add_object_change(object, "building", object:as_multipolygon(), new_uuid)

    end

    if object.tags.boundary == 'administrative' then
        new_uuid = generate_uuid()
        tables.admin_boundary_area:insert({
            osm_id = object.id,
            version = object.version,
            change_uuid = new_uuid,          
            name = object.tags.name,
            name_en = object.tags['name:en'],
            admin_level = tonumber(object.tags.admin_level),
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            geom = object:as_multipolygon()
        })
   
        add_object_change(object, "admin_boundary_area", object:as_multipolygon(), new_uuid)
    end

    if (object.tags.amenity or object.tags.leisure or object.tags.tourism or object.tags.man_made or object.tags.historic or
        object.tags.natural or object.tags.shop or object.tags.barrier or object.tags.public_transport or object.tags.power or 
        object.tags.communication or object.tags.landuse) then
        new_uuid = generate_uuid()
        if type == 'multipolygon' then
            geometry = object:as_multipolygon()
        else
            geometry = object:as_multilinestring()
        end

        tables.poi:insert({
            osm_id = object.id,
            version = object.version,
            change_uuid = new_uuid,            
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
            power = object.tags.power,
            communication = object.tags.communication,
            landuse = object.tags.landuse,
            tags = object.tags,
            last_edit = format_date(object.timestamp),
            import_timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            osm_geom = geometry
        })

        add_object_change(object, "poi", geometry, new_uuid)

    end


    if type == 'route' and object.tags.route == 'hiking' then
        for _, member in ipairs(object.members) do
            if member.type == 'w' then
                if not w2r[member.ref] then
                    w2r[member.ref] = {}
                end
                w2r[member.ref][object.id] = object.tags['osmc:symbol']
            end
        end
    end


end

-- Track changes of delete objects
osm2pgsql.process_deleted_node = add_deleted_object
osm2pgsql.process_deleted_way = add_deleted_object
osm2pgsql.process_deleted_relation = add_deleted_object

function osm2pgsql.after_relations()
  -- This callback is called after the last relation has been read from
  -- the input file. As objects are guaranteed to come in order
  -- node/way/relation, file reading is done at that point.
  file_reading_in_progress = false
end
