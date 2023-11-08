
/**
Copyright (c), Mapbox All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

**/

/******************************************************************************
### Sieve ###
Filters small rings (both inner and outer) from a multipolygon based on area.
__Parameters:__
- `geometry` g - A multipolygon
- `float` area_threshold - the minimum ring area to keep.
__Returns:__ `geometry` - a polygon or multipolygon
******************************************************************************/
create or replace function Sieve (g geometry, area_threshold float)
    returns geometry
    language sql immutable as
$func$
    with exploded as (
        -- First use ST_Dump to explode the input multipolygon
        -- to individual polygons.
        select (ST_Dump(g)).geom
    ), rings as (
        -- Next use ST_DumpRings to turn all of the inner and outer rings
        -- into their own separate polygons.
        select (ST_DumpRings(geom)).geom from exploded
    ) select
        -- Finally, build the multipolygon back up using only the rings
        -- that are larger than the specified threshold area.
            ST_SetSRID(ST_BuildArea(ST_Collect(geom)), ST_SRID(g))
        from rings
        where ST_Area(geom) > area_threshold;
$func$ PARALLEL SAFE;


/******************************************************************************
### OrientedEnvelope ###
Returns an oriented minimum-bounding rectangle for a geometry.
__Parameters:__
- `geometry` g - A geometry.
__Returns:__ `geometry(polygon)`
******************************************************************************/
create or replace function OrientedEnvelope (g geometry)
    returns geometry(polygon)
    language plpgsql immutable as
$func$
declare
    p record;
    p0 geometry(point);
    p1 geometry(point);
    ctr geometry(point);
    angle_min float;
    angle_cur float;
    area_min float;
    area_cur float;
begin
    -- Approach is based on the rotating calipers method:
    -- <https://en.wikipedia.org/wiki/Rotating_calipers>
    g := ST_ConvexHull(g);
    ctr := ST_Centroid(g);
    for p in (select (ST_DumpPoints(g)).geom) loop
        p0 := p1;
        p1 := p.geom;
        if p0 is null then
            continue;
        end if;
        angle_cur := ST_Azimuth(p0, p1) - pi()/2;
        area_cur := ST_Area(ST_Envelope(ST_Rotate(g, angle_cur, ctr)));
        if area_cur < area_min or area_min is null then
            area_min := area_cur;
            angle_min := angle_cur;
        end if;
    end loop;
    return ST_Rotate(ST_Envelope(ST_Rotate(g, angle_min, ctr)), -angle_min, ctr);
end;
$func$ PARALLEL SAFE;

-- Extension for orientation

/******************************************************************************
### Orientiation ###
__Returns:__ `numeric`
******************************************************************************/
drop function if exists feature_orientation;
create or replace function feature_orientation (g geometry)
    returns numeric
    language plpgsql immutable as
$func$
declare
    p record;
    p0 geometry(point);
    p1 geometry(point);
    ctr geometry(point);
    angle_min float;
    angle_cur float;
    area_min float;
    area_cur float;
begin
    -- Approach is based on the rotating calipers method:
    -- <https://en.wikipedia.org/wiki/Rotating_calipers>
    g := ST_ConvexHull(g);
    ctr := ST_Centroid(g);
    for p in (select (ST_DumpPoints(g)).geom) loop
        p0 := p1;
        p1 := p.geom;
        if p0 is null then
            continue;
        end if;
        angle_cur := ST_Azimuth(p0, p1) - pi()/2;
        area_cur := ST_Area(ST_Envelope(ST_Rotate(g, angle_cur, ctr)));
        if area_cur < area_min or area_min is null then
            area_min := area_cur;
            angle_min := angle_cur;
        end if;
    end loop;
    return degrees(angle_min) + 90 ;
end;
$func$ PARALLEL SAFE;

/**
Taken from https://github.com/MathiasGroebe/discrete_isolation

**/


CREATE OR REPLACE FUNCTION discrete_isolation(peak_table text, peak_table_geom_column_name text, elevation_column text, peak_geometry geometry, elevation_value numeric) returns decimal as
$$
DECLARE isolation_value decimal;
BEGIN

IF elevation_value IS NULL THEN RETURN NULL;

ELSE
	
	EXECUTE  'SELECT ST_Distance(''' || peak_geometry::text || '''::geometry, ' || peak_table_geom_column_name || ') as distance
	FROM ' || peak_table || '
	WHERE '|| elevation_column ||' > ' || elevation_value || '
	ORDER BY distance
	LIMIT 1' INTO isolation_value;

	IF isolation_value IS NULL THEN RETURN 30000000; -- set value for the highest peak
	END IF;

RETURN isolation_value;
END IF;

END;
$$ LANGUAGE plpgsql PARALLEL SAFE;

-- Second version of the function with a reduced complexity by limiting the search radius

CREATE OR REPLACE FUNCTION discrete_isolation(peak_table text, peak_table_geom_column_name text, elevation_column text, peak_geometry geometry, elevation_value numeric, max_search_radius numeric) returns decimal as
$$
DECLARE isolation_value decimal;
BEGIN

IF elevation_value IS NULL THEN RETURN NULL;

ELSE
	
	EXECUTE  'SELECT ST_Distance(''' || peak_geometry::text || '''::geometry, ' || peak_table_geom_column_name || ') as distance
	FROM ' || peak_table || '
	WHERE '|| elevation_column ||' > ' || elevation_value || ' AND ST_DWithin(''' || peak_geometry::text || '''::geometry, ' || peak_table_geom_column_name ||', ' || max_search_radius || ')
	ORDER BY distance
	LIMIT 1' INTO isolation_value;

	IF isolation_value IS NULL THEN RETURN max_search_radius; -- set value maxium distance
	END IF;

RETURN isolation_value;
END IF;

END;
$$ LANGUAGE plpgsql PARALLEL SAFE;


CREATE OR REPLACE FUNCTION find_death_ends(edge_table text, node_table text, name_schema text, iterations integer) RETURNS void AS $$
DECLARE
    v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
BEGIN

	raise notice 'Iterative finding of continued death ends';
	raise notice 'Prepare data';

	-- make sure to reset values
	EXECUTE format('UPDATE %I.%I SET death_end = 0, death_end_length = ST_Length(geom)',
				  name_schema, edge_table); 

	raise notice 'Death end loop: 1';
	
	-- identify death ends
	EXECUTE format('UPDATE %I.%I v SET death_end = 1 WHERE v.edges_count = 1', 
				   name_schema, node_table);
				
	-- bring information about death ends to edges
	EXECUTE format('UPDATE %I.%I e SET death_end = 1 FROM %I.%I v WHERE v.death_end = 1 AND (e.start_node = v.fid OR e.end_node = v.fid)',
				   name_schema, edge_table, name_schema, node_table);
			
	-- search for further death ends
	FOR counter IN 2..iterations LOOP
		
		raise notice 'Death end loop: %', counter;
		
		EXECUTE format('UPDATE %I.%I v SET death_end = $1, death_end_length = e.death_end_length FROM %I.%I e WHERE v.edges_count = 2 AND e.death_end = $1 - 1 AND (e.start_node = v.fid OR e.end_node = v.fid) AND v.death_end = 0 ', 
					   name_schema, node_table, name_schema, edge_table) USING counter; 
		
		EXECUTE format('UPDATE %I.%I e SET death_end = $1, death_end_length = e.death_end_length + v.death_end_length FROM %I.%I v WHERE (e.start_node = v.fid OR e.end_node = v.fid) AND v.death_end = $1 AND e.death_end = 0 ',
					  name_schema, edge_table, name_schema, node_table) USING counter;
		
	END LOOP;

	FOR counter2 IN REVERSE iterations..1 LOOP
	
		raise notice 'Death end length loop: %', counter2;
	
		EXECUTE format('UPDATE %I.%I v SET death_end_length = e.death_end_length FROM %I.%I e WHERE (e.start_node = v.fid OR e.end_node = v.fid) AND v.death_end = $1 AND e.death_end = $1;',
					  name_schema, node_table, name_schema, edge_table) USING counter2; 
		
		IF counter2 != 0 THEN
	    	EXECUTE format('UPDATE %I.%I e SET death_end_length = v.death_end_length FROM %I.%I v WHERE (e.start_node = v.fid OR e.end_node = v.fid) AND v.death_end = $1 AND e.death_end = $1 - 1;',
						   name_schema, edge_table, name_schema, node_table) USING counter2;
		END IF;
		
	END LOOP;


EXCEPTION WHEN OTHERS THEN

    GET STACKED DIAGNOSTICS
      v_state   = returned_sqlstate,
      v_msg     = message_text,
      v_detail  = pg_exception_detail,
      v_hint    = pg_exception_hint,
      v_context = pg_exception_context;

    RAISE NOTICE 'Exception:
      state   : %
      message : %
      detail  : %
      hint    : %
      context : %', v_state, v_msg, v_detail, v_hint, v_context;
	
END;
$$
LANGUAGE plpgsql;
