set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.2.00.07'
,p_default_workspace_id=>20749515040658038
,p_default_application_id=>560
,p_default_owner=>'SAMPLE'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/region_type/com_jk64_report_google_map
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(218512352878463408)
,p_plugin_type=>'REGION TYPE'
,p_name=>'COM.JK64.REPORT_GOOGLE_MAP'
,p_display_name=>'JK64 Report Google Map'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_plsql_code=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'PROCEDURE set_map_extents',
'    (p_lat     IN NUMBER',
'    ,p_lng     IN NUMBER',
'    ,p_lat_min IN OUT NUMBER',
'    ,p_lat_max IN OUT NUMBER',
'    ,p_lng_min IN OUT NUMBER',
'    ,p_lng_max IN OUT NUMBER',
'    ) IS',
'BEGIN',
'    p_lat_min := LEAST   (NVL(p_lat_min, p_lat), p_lat);',
'    p_lat_max := GREATEST(NVL(p_lat_max, p_lat), p_lat);',
'    p_lng_min := LEAST   (NVL(p_lng_min, p_lng), p_lng);',
'    p_lng_max := GREATEST(NVL(p_lng_max, p_lng), p_lng);',
'END set_map_extents;',
'',
'FUNCTION latlng2ch (lat IN NUMBER, lng IN NUMBER) RETURN VARCHAR2 IS',
'BEGIN',
'  RETURN ''"lat":''',
'      || TO_CHAR(lat, ''fm999.9999999999999999'')',
'      || '',"lng":''',
'      || TO_CHAR(lng, ''fm999.9999999999999999'');',
'END latlng2ch;',
'',
'FUNCTION get_markers',
'    (p_region  IN APEX_PLUGIN.t_region',
'    ,p_lat_min IN OUT NUMBER',
'    ,p_lat_max IN OUT NUMBER',
'    ,p_lng_min IN OUT NUMBER',
'    ,p_lng_max IN OUT NUMBER',
'    ) RETURN VARCHAR2 IS',
'',
'    l_markers_data       VARCHAR2(32767);',
'    l_lat                NUMBER;',
'    l_lng                NUMBER;',
'    l_icon               VARCHAR2(4000);',
'    l_column_value_list  APEX_PLUGIN_UTIL.t_column_value_list;',
'',
'BEGIN',
'',
'    l_column_value_list := APEX_PLUGIN_UTIL.get_data',
'        (p_sql_statement  => p_region.source',
'        ,p_min_columns    => 5',
'        ,p_max_columns    => 6',
'        ,p_component_name => p_region.name',
'        ,p_max_rows       => 1000);',
'  ',
'    FOR i IN 1..l_column_value_list(1).count LOOP',
'  ',
'        IF l_markers_data IS NOT NULL THEN',
'            l_markers_data := l_markers_data || '','';',
'        END IF;',
'        ',
'        l_lat  := TO_NUMBER(l_column_value_list(1)(i));',
'        l_lng  := TO_NUMBER(l_column_value_list(2)(i));',
'        ',
'        IF l_column_value_list.EXISTS(6) THEN',
'          l_icon := l_column_value_list(6)(i);',
'        END IF;',
'  ',
'        l_markers_data := l_markers_data',
'          || ''{"id":''   || APEX_ESCAPE.js_literal(l_column_value_list(4)(i),''"'')',
'          || '',"name":'' || APEX_ESCAPE.js_literal(l_column_value_list(3)(i),''"'')',
'          || '',"info":'' || APEX_ESCAPE.js_literal(l_column_value_list(5)(i),''"'')',
'          || '',''        || latlng2ch(l_lat,l_lng)',
'          || '',"icon":'' || APEX_ESCAPE.js_literal(l_icon,''"'')',
'          || ''}'';',
'    ',
'        set_map_extents',
'          (p_lat     => l_lat',
'          ,p_lng     => l_lng',
'          ,p_lat_min => p_lat_min',
'          ,p_lat_max => p_lat_max',
'          ,p_lng_min => p_lng_min',
'          ,p_lng_max => p_lng_max',
'          );',
'      ',
'    END LOOP;',
'',
'    RETURN l_markers_data;',
'END get_markers;',
'',
'FUNCTION render_map',
'    (p_region IN APEX_PLUGIN.t_region',
'    ,p_plugin IN APEX_PLUGIN.t_plugin',
'    ,p_is_printer_friendly IN BOOLEAN',
'    ) RETURN APEX_PLUGIN.t_region_render_result IS',
'',
'    SUBTYPE plugin_attr is VARCHAR2(32767);',
'    ',
'    l_result       APEX_PLUGIN.t_region_render_result;',
'',
'    l_lat          number;',
'    l_lng          number;',
'    l_region       varchar2(100);',
'    l_script       varchar2(32767);',
'    l_markers_data varchar2(32767);',
'    l_lat_min      number;',
'    l_lat_max      number;',
'    l_lng_min      number;',
'    l_lng_max      number;',
'    l_ajax_items   varchar2(1000);',
'    l_js_params    varchar2(1000);',
'',
'    -- Plugin attributes (application level)',
'    l_api_key       plugin_attr := p_plugin.attribute_01;',
'',
'    -- Component attributes',
'    l_map_height    plugin_attr := p_region.attribute_01;',
'    l_id_item       plugin_attr := p_region.attribute_02;',
'    l_click_zoom    plugin_attr := p_region.attribute_03;    ',
'    l_sync_item     plugin_attr := p_region.attribute_04;',
'    l_markericon    plugin_attr := p_region.attribute_05;',
'    l_latlong       plugin_attr := p_region.attribute_06;',
'    l_dist_item     plugin_attr := p_region.attribute_07;',
'    l_sign_in       plugin_attr := p_region.attribute_08;',
'    l_geocode_item  plugin_attr := p_region.attribute_09;',
'    l_country       plugin_attr := p_region.attribute_10;',
'    ',
'BEGIN',
'    -- debug information will be included',
'    IF APEX_APPLICATION.g_debug then',
'        APEX_PLUGIN_UTIL.debug_region',
'          (p_plugin => p_plugin',
'          ,p_region => p_region',
'          ,p_is_printer_friendly => p_is_printer_friendly);',
'    END IF;',
'',
'    IF l_api_key IS NULL THEN',
'        l_sign_in      := ''N'';',
'        l_geocode_item := NULL;',
'    ELSE',
'        l_js_params := ''?key='' || l_api_key;',
'        IF l_sign_in = ''Y'' THEN',
'            l_js_params := l_js_params || ''&''||''signed_in=true'';',
'        END IF;',
'    END IF;',
'',
'    APEX_JAVASCRIPT.add_library',
'      (p_name           => ''js'' || l_js_params',
'      ,p_directory      => ''https://maps.googleapis.com/maps/api/''',
'      ,p_skip_extension => true);',
'',
'    APEX_JAVASCRIPT.add_library',
'      (p_name           => ''jk64plugin.min''',
'      ,p_directory      => p_plugin.file_prefix);',
'',
'    l_region := CASE',
'                WHEN p_region.static_id IS NOT NULL',
'                THEN p_region.static_id',
'                ELSE ''R''||p_region.id',
'                END;',
'    ',
'    IF p_region.source IS NOT NULL THEN',
'',
'      l_markers_data := get_markers',
'        (p_region  => p_region',
'        ,p_lat_min => l_lat_min',
'        ,p_lat_max => l_lat_max',
'        ,p_lng_min => l_lng_min',
'        ,p_lng_max => l_lng_max',
'        );',
'        ',
'    END IF;',
'    ',
'    -- if sync item is set, include its position in the initial map extent',
'    IF l_sync_item IS NOT NULL THEN',
'      l_latlong := NVL(v(l_sync_item),l_latlong);',
'    END IF;',
'    ',
'    IF l_latlong IS NOT NULL THEN',
'      l_lat := TO_NUMBER(SUBSTR(l_latlong,1,INSTR(l_latlong,'','')-1));',
'      l_lng := TO_NUMBER(SUBSTR(l_latlong,INSTR(l_latlong,'','')+1));',
'    END IF;',
'    ',
'    IF l_lat IS NOT NULL THEN',
'      set_map_extents',
'        (p_lat     => l_lat',
'        ,p_lng     => l_lng',
'        ,p_lat_min => l_lat_min',
'        ,p_lat_max => l_lat_max',
'        ,p_lng_min => l_lng_min',
'        ,p_lng_max => l_lng_max',
'        );',
'',
'    -- show entire map if no points to show',
'    ELSIF l_markers_data IS NULL THEN',
'      l_lat := 0;',
'      l_lng := 0;',
'      l_latlong := ''0,0'';',
'      l_lat_min := -90;',
'      l_lat_max := 90;',
'      l_lng_min := -180;',
'      l_lng_max := 180;',
'',
'    END IF;',
'    ',
'    IF l_sync_item IS NOT NULL THEN',
'      l_ajax_items := ''#'' || l_sync_item;',
'    END IF;',
'    IF l_dist_item IS NOT NULL THEN',
'      IF l_ajax_items IS NOT NULL THEN',
'        l_ajax_items := l_ajax_items || '','';',
'      END IF;',
'      l_ajax_items := l_ajax_items || ''#'' || l_dist_item;',
'    END IF;',
'    ',
'    l_script := ''',
'var opt_#REGION# = {',
'   container:      "map_#REGION#_container"',
'  ,regionId:       "#REGION#"',
'  ,ajaxIdentifier: "''||APEX_PLUGIN.get_ajax_identifier||''"',
'  ,ajaxItems:      "''||l_ajax_items||''"',
'  ,latlng:         "''||l_latlong||''"',
'  ,markerZoom:     ''||l_click_zoom||''',
'  ,icon:           "''||l_markericon||''"',
'  ,idItem:         "''||l_id_item||''"',
'  ,syncItem:       "''||l_sync_item||''"',
'  ,distItem:       "''||l_dist_item||''"',
'  ,geocodeItem:    "''||l_geocode_item||''"',
'  ,country:        "''||l_country||''"',
'  ,southwest:      {''||latlng2ch(l_lat_min,l_lng_min)||''}',
'  ,northeast:      {''||latlng2ch(l_lat_max,l_lng_max)||''}',
'};',
'function click_#REGION#(id) {',
'  jk64plugin_click(opt_#REGION#,id);',
'}',
'function r_#REGION#(f){/in/.test(document.readyState)?setTimeout("r_#REGION#("+f+")",9):f()}',
'r_#REGION#(function(){',
'  opt_#REGION#.mapdata = [''||l_markers_data||''];',
'  jk64plugin_initMap(opt_#REGION#);',
'  apex.jQuery("#"+opt_#REGION#.regionId).bind("apexrefresh", function(){jk64plugin_refreshMap(opt_#REGION#);});',
'});'';',
'',
'    l_script := REPLACE(l_script,''#REGION#'',l_region);',
'      ',
'    sys.htp.p(''<script>''||l_script||''</script>'');',
'    sys.htp.p(''<div id="map_''||l_region||''_container" style="min-height:''||l_map_height||''px"></div>'');',
'  ',
'    RETURN l_result;',
'END render_map;',
'',
'FUNCTION ajax',
'    (p_region IN APEX_PLUGIN.t_region',
'    ,p_plugin IN APEX_PLUGIN.t_plugin',
'    ) RETURN APEX_PLUGIN.t_region_ajax_result IS',
'',
'    SUBTYPE plugin_attr is VARCHAR2(32767);',
'',
'    l_result APEX_PLUGIN.t_region_ajax_result;',
'',
'    l_lat          NUMBER;',
'    l_lng          NUMBER;',
'    l_markers_data VARCHAR2(32767);',
'    l_lat_min      NUMBER;',
'    l_lat_max      NUMBER;',
'    l_lng_min      NUMBER;',
'    l_lng_max      NUMBER;',
'',
'    -- Component attributes',
'    l_sync_item     plugin_attr := p_region.attribute_04;',
'    l_latlong       plugin_attr := p_region.attribute_06;',
'',
'BEGIN',
'    -- debug information will be included',
'    IF APEX_APPLICATION.g_debug then',
'        APEX_PLUGIN_UTIL.debug_region',
'          (p_plugin => p_plugin',
'          ,p_region => p_region);',
'    END IF;',
'',
'    IF p_region.source IS NOT NULL THEN',
'',
'      l_markers_data := get_markers',
'        (p_region  => p_region',
'        ,p_lat_min => l_lat_min',
'        ,p_lat_max => l_lat_max',
'        ,p_lng_min => l_lng_min',
'        ,p_lng_max => l_lng_max',
'        );',
'        ',
'    END IF;',
'    ',
'    -- if sync item is set, include its position in the initial map extent',
'    IF l_sync_item IS NOT NULL THEN',
'      l_latlong := NVL(v(l_sync_item),l_latlong);',
'    END IF;',
'    ',
'    IF l_latlong IS NOT NULL THEN',
'      l_lat := TO_NUMBER(SUBSTR(l_latlong,1,INSTR(l_latlong,'','')-1));',
'      l_lng := TO_NUMBER(SUBSTR(l_latlong,INSTR(l_latlong,'','')+1));',
'    END IF;',
'    ',
'    IF l_lat IS NOT NULL THEN',
'      set_map_extents',
'        (p_lat     => l_lat',
'        ,p_lng     => l_lng',
'        ,p_lat_min => l_lat_min',
'        ,p_lat_max => l_lat_max',
'        ,p_lng_min => l_lng_min',
'        ,p_lng_max => l_lng_max',
'        );',
'',
'    -- show entire map if no points to show',
'    ELSIF l_markers_data IS NULL THEN',
'      l_lat := 0;',
'      l_lng := 0;',
'      l_latlong := ''0,0'';',
'      l_lat_min := -90;',
'      l_lat_max := 90;',
'      l_lng_min := -180;',
'      l_lng_max := 180;',
'',
'    END IF;',
'',
'    SYS.OWA_UTIL.mime_header(''text/plain'', false);',
'    SYS.HTP.p(''Cache-Control: no-cache'');',
'    SYS.HTP.p(''Pragma: no-cache'');',
'    SYS.OWA_UTIL.http_header_close;',
'    ',
'    SYS.HTP.p(''{"southwest":{''',
'      || latlng2ch(l_lat_min,l_lng_min)',
'      || ''},"northeast":{''',
'      || latlng2ch(l_lat_max,l_lng_max)',
'      || ''},"mapdata":[''',
'      || l_markers_data',
'      || '']}'');',
'',
'    RETURN l_result;',
'END ajax;'))
,p_render_function=>'render_map'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'SOURCE_SQL:AJAX_ITEMS_TO_SUBMIT'
,p_sql_min_column_count=>5
,p_sql_max_column_count=>6
,p_sql_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'<pre>SELECT lat, lng, name, id, info FROM mydata;</pre>',
'<p>',
'<em>Show each point with a selected icon:</em>',
'<p>',
'<pre>SELECT lat, lng, name, id, info, icon FROM mydata;</pre>',
'<p>',
'<em>Get only the data within a certain distance from a chosen point:</em>',
'<p>',
'<pre>',
'SELECT t.lat AS lat',
'      ,t.lng AS lng',
'      ,t.name',
'      ,t.id AS id',
'      ,t.info',
'      ,'''' AS icon',
'FROM   mytable t',
'WHERE  t.lat IS NOT NULL',
'AND    t.lng IS NOT NULL',
'AND    (:P1_LATLNG IS NULL',
'     OR :P1_RADIUS IS NULL',
'     OR SDO_GEOM.sdo_distance',
'          (geom1 => SDO_GEOMETRY',
'            (sdo_gtype     => 2001 /* 2-dimensional point */',
'            ,sdo_srid      => 8307 /* Longitude / Latitude (WGS 84) */',
'            ,sdo_point     => SDO_POINT_TYPE(t.lng, t.lat, NULL)',
'            ,sdo_elem_info => NULL',
'            ,sdo_ordinates => NULL)',
'          ,geom2 => SDO_GEOMETRY',
'            (sdo_gtype     => 2001 /* 2-dimensional point */',
'            ,sdo_srid      => 8307 /* Longitude / Latitude (WGS 84) */',
'            ,sdo_point     => SDO_POINT_TYPE',
'               (TO_NUMBER(SUBSTR(:P1_LATLNG,INSTR(:P1_LATLNG,'','')+1))',
'               ,TO_NUMBER(SUBSTR(:P1_LATLNG,1,INSTR(:P1_LATLNG,'','')-1)), NULL)',
'            ,sdo_elem_info => NULL',
'            ,sdo_ordinates => NULL)',
'          ,tol   => 0.0001 /*metres*/',
'          ,unit  => ''unit=KM'') < :P1_RADIUS)',
'</pre>'))
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'This plugin renders a Google Map, showing a number of pins based on a query you supply with Latitude, Longitude, Name (pin hovertext), id (returned to an item you specify, if required), and Info.',
'<P>',
'When the user clicks any pin, the map pans to that point, and (optionally) zooms into it. An info window pops up with the Info you supply in the query. This can include HTML code including links, for example. The markerClick event will be fired when '
||'this happens (you can create a dynamic action to respond to this if you want).',
'<P>',
'If you supply a Sync Item and a Distance item, the map will allow the user to click any point on the map, drag out the radius of a circle, and then re-run the query (e.g. to show only those pins within the indicated circle. Look at the SQL Query exam'
||'ples for how to do this.',
'<P>',
'If the query includes the 6th column (icon), it must refer to an image file that will be used instead of the standard red pin (<img src="http://maps.google.com/mapfiles/ms/icons/red-dot.png">). You can refer to pins like these, or refer to your own i'
||'mages.',
'<P>',
'If icons are supplied they need to be fully-qualified URIs to an icon image to be used. e.g.',
'<P>',
'http://maps.google.com/mapfiles/ms/icons/blue-dot.png',
'http://maps.google.com/mapfiles/ms/icons/red-dot.png',
'http://maps.google.com/mapfiles/ms/icons/purple-dot.png',
'http://maps.google.com/mapfiles/ms/icons/yellow-dot.png',
'http://maps.google.com/mapfiles/ms/icons/green-dot.png',
'http://maps.google.com/mapfiles/ms/icons/ylw-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/blue-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/grn-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/ltblu-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/pink-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/purple-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/red-pushpin.png'))
,p_version_identifier=>'0.4'
,p_about_url=>'https://github.com/jeffreykemp/jk64-plugin-reportmap'
,p_files_version=>3
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(75127295279118430)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Google API Key'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>60
,p_is_translatable=>false
,p_help_text=>'Optional. If you don''t set this, you may get a "Google Maps API warning: NoApiKeys" warning in the console log. You can add this later if required. Refer: https://developers.google.com/maps/documentation/javascript/get-api-key#get-an-api-key'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(218513145091470932)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Min. Map Height'
,p_attribute_type=>'NUMBER'
,p_is_required=>true
,p_default_value=>'400'
,p_unit=>'pixels'
,p_is_translatable=>false
,p_help_text=>'Desired height (in pixels) of the map region. Note: the width will adjust according to the available area of the containing window.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(218513489962474493)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Set Item Name to ID on Click'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'When the user clicks on a map marker, the corresponding ID from your data will be copied to this page item.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(218513827135479678)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Zoom Level on Click'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_default_value=>'13'
,p_unit=>'(0-23)'
,p_is_translatable=>false
,p_help_text=>'When the user clicks on a map marker, or adds a new marker, zoom the map to this level. Set to blank to not zoom on click.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(223598252584881112)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Synchronize with Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Position of the marker will be retrieved from and stored in this item as a Lat,Long value. Also, if the item value is changed, the marker will be moved on the map.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(223601564596927567)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Marker Icon'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'http://maps.google.com/mapfiles/ms/icons/blue-dot.png',
'http://maps.google.com/mapfiles/ms/icons/red-dot.png',
'http://maps.google.com/mapfiles/ms/icons/purple-dot.png',
'http://maps.google.com/mapfiles/ms/icons/yellow-dot.png',
'http://maps.google.com/mapfiles/ms/icons/green-dot.png',
'http://maps.google.com/mapfiles/ms/icons/ylw-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/blue-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/grn-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/ltblu-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/pink-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/purple-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/red-pushpin.png'))
,p_help_text=>'URL to the icon to show for the marker. Leave blank for the default red Google pin.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(223608185986716624)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Initial Map Position'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_unit=>'lat,long'
,p_is_translatable=>false
,p_help_text=>'Set the latitude and longitude as a pair of numbers to be used to position the map on page load, if no pin coordinates have been provided by the page item.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(223610549297416918)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Circle Radius Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(223598252584881112)
,p_depending_on_condition_type=>'NOT_NULL'
,p_help_text=>'Set to an item which contains the distance (in Kilometres) to draw a circle around the click point. Leave blank to not draw a circle. If the item is changed, the circle will be updated. If you set this attribute, you must also set Synchronize with It'
||'em.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(75129056673204272)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Enable Google Sign-In'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Set to Yes to enable Google sign-in on the map. Only works if you set the Google API Key.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(75137999717846446)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Geocode Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Set to a text item on the page. If the text item contains the name of a location or an address, a Google Maps Geocode search will be done and, if found, the map will be moved to that location and a pin shown. NOTE: requires a Google API key to be set'
||' at the application level.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(75139231492017016)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Restrict to Country code'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>10
,p_max_length=>2
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(75137999717846446)
,p_depending_on_condition_type=>'NOT_NULL'
,p_text_case=>'UPPER'
,p_examples=>'AU'
,p_help_text=>'Leave blank to allow geocoding to find any place on earth. Set to country code (see https://developers.google.com/public-data/docs/canonical/countries_csv for valid values) to restrict geocoder to that country.'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(218512669450466691)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_name=>'mapclick'
,p_display_name=>'mapClick'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(75131912087488337)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_name=>'maploaded'
,p_display_name=>'mapLoaded'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(225229248728482807)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_name=>'markerclick'
,p_display_name=>'markerClick'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E206A6B3634706C7567696E5F67656F636F646528652C69297B692E67656F636F6465287B616464726573733A247628652E67656F636F64654974656D292C636F6D706F6E656E745265737472696374696F6E733A2222213D3D652E63';
wwv_flow_api.g_varchar2_table(2) := '6F756E7472793F7B636F756E7472793A652E636F756E7472797D3A7B7D7D2C66756E6374696F6E28692C6E297B6966286E3D3D3D676F6F676C652E6D6170732E47656F636F6465725374617475732E4F4B297B76617220613D695B305D2E67656F6D6574';
wwv_flow_api.g_varchar2_table(3) := '72792E6C6F636174696F6E3B617065782E646562756728652E726567696F6E49642B222067656F636F6465206F6B22292C652E6D61702E73657443656E7465722861292C652E6D61702E70616E546F2861292C652E6D61726B65725A6F6F6D2626652E6D';
wwv_flow_api.g_varchar2_table(4) := '61702E7365745A6F6F6D28652E6D61726B65725A6F6F6D292C6A6B3634706C7567696E5F7573657250696E28652C612E6C617428292C612E6C6E672829297D656C736520617065782E646562756728652E726567696F6E49642B222067656F636F646520';
wwv_flow_api.g_varchar2_table(5) := '77617320756E7375636365737366756C20666F722074686520666F6C6C6F77696E6720726561736F6E3A20222B6E297D297D66756E6374696F6E206A6B3634706C7567696E5F72657050696E28652C69297B766172206E3D6E657720676F6F676C652E6D';
wwv_flow_api.g_varchar2_table(6) := '6170732E4D61726B6572287B6D61703A652E6D61702C706F736974696F6E3A6E657720676F6F676C652E6D6170732E4C61744C6E6728692E6C61742C692E6C6E67292C7469746C653A692E6E616D652C69636F6E3A692E69636F6E7D293B676F6F676C65';
wwv_flow_api.g_varchar2_table(7) := '2E6D6170732E6576656E742E6164644C697374656E6572286E2C22636C69636B222C66756E6374696F6E28297B617065782E646562756728652E726567696F6E49642B222072657050696E20636C69636B656420222B692E6964292C652E69773F652E69';
wwv_flow_api.g_varchar2_table(8) := '772E636C6F736528293A652E69773D6E657720676F6F676C652E6D6170732E496E666F57696E646F772C652E69772E7365744F7074696F6E73287B636F6E74656E743A692E696E666F7D292C652E69772E6F70656E28652E6D61702C74686973292C652E';
wwv_flow_api.g_varchar2_table(9) := '6D61702E70616E546F28746869732E676574506F736974696F6E2829292C652E6D61726B65725A6F6F6D2626652E6D61702E7365745A6F6F6D28652E6D61726B65725A6F6F6D292C2222213D3D652E69644974656D2626247328652E69644974656D2C69';
wwv_flow_api.g_varchar2_table(10) := '2E6964292C617065782E6A5175657279282223222B652E726567696F6E4964292E7472696767657228226D61726B6572636C69636B222C7B6D61703A652E6D61702C69643A692E69642C6E616D653A692E6E616D652C6C61743A692E6C61742C6C6E673A';
wwv_flow_api.g_varchar2_table(11) := '692E6C6E677D297D292C652E72657070696E7C7C28652E72657070696E3D5B5D292C652E72657070696E2E70757368287B69643A692E69642C6D61726B65723A6E7D297D66756E6374696F6E206A6B3634706C7567696E5F72657050696E732865297B66';
wwv_flow_api.g_varchar2_table(12) := '6F722876617220693D303B693C652E6D6170646174612E6C656E6774683B692B2B296A6B3634706C7567696E5F72657050696E28652C652E6D6170646174615B695D297D66756E6374696F6E206A6B3634706C7567696E5F636C69636B28652C69297B66';
wwv_flow_api.g_varchar2_table(13) := '6F7228766172206E3D21312C613D303B613C652E72657070696E2E6C656E6774683B612B2B29696628652E72657070696E5B615D2E69643D3D69297B6E657720676F6F676C652E6D6170732E6576656E742E7472696767657228652E72657070696E5B61';
wwv_flow_api.g_varchar2_table(14) := '5D2E6D61726B65722C22636C69636B22292C6E3D21303B627265616B7D6E7C7C617065782E646562756728652E726567696F6E49642B22206964206E6F7420666F756E643A222B69297D66756E6374696F6E206A6B3634706C7567696E5F736574436972';
wwv_flow_api.g_varchar2_table(15) := '636C6528652C69297B6966282222213D3D652E646973744974656D29696628652E64697374636972636C6529617065782E646562756728652E726567696F6E49642B22206D6F766520636972636C6522292C652E64697374636972636C652E7365744365';
wwv_flow_api.g_varchar2_table(16) := '6E7465722869292C652E64697374636972636C652E7365744D617028652E6D6170293B656C73657B766172206E3D7061727365466C6F617428247628652E646973744974656D29293B617065782E646562756728652E726567696F6E49642B2220637265';
wwv_flow_api.g_varchar2_table(17) := '61746520636972636C65207261646975733D222B6E292C652E64697374636972636C653D6E657720676F6F676C652E6D6170732E436972636C65287B7374726F6B65436F6C6F723A2223353035304646222C7374726F6B654F7061636974793A2E352C73';
wwv_flow_api.g_varchar2_table(18) := '74726F6B655765696768743A322C66696C6C436F6C6F723A2223303030304646222C66696C6C4F7061636974793A2E30352C636C69636B61626C653A21312C6564697461626C653A21302C6D61703A652E6D61702C63656E7465723A692C726164697573';
wwv_flow_api.g_varchar2_table(19) := '3A3165332A6E7D292C676F6F676C652E6D6170732E6576656E742E6164644C697374656E657228652E64697374636972636C652C227261646975735F6368616E676564222C66756E6374696F6E2869297B766172206E3D652E64697374636972636C652E';
wwv_flow_api.g_varchar2_table(20) := '67657452616469757328292F3165333B617065782E646562756728652E726567696F6E49642B2220636972636C6520726164697573206368616E67656420222B6E292C247328652E646973744974656D2C6E292C6A6B3634706C7567696E5F7265667265';
wwv_flow_api.g_varchar2_table(21) := '73684D61702865297D292C676F6F676C652E6D6170732E6576656E742E6164644C697374656E657228652E64697374636972636C652C2263656E7465725F6368616E676564222C66756E6374696F6E2869297B766172206E3D652E64697374636972636C';
wwv_flow_api.g_varchar2_table(22) := '652E67657443656E74657228292C613D6E2E6C617428292B222C222B6E2E6C6E6728293B617065782E646562756728652E726567696F6E49642B2220636972636C652063656E746572206368616E67656420222B61292C2222213D3D652E73796E634974';
wwv_flow_api.g_varchar2_table(23) := '656D262628247328652E73796E634974656D2C61292C6A6B3634706C7567696E5F726566726573684D6170286529297D297D7D66756E6374696F6E206A6B3634706C7567696E5F7573657250696E28652C692C6E297B6966286E756C6C213D3D6926266E';
wwv_flow_api.g_varchar2_table(24) := '756C6C213D3D6E297B76617220613D652E7573657270696E3F652E7573657270696E2E676574506F736974696F6E28293A6E657720676F6F676C652E6D6170732E4C61744C6E6728302C30293B696628693D3D612E6C6174282926266E3D3D612E6C6E67';
wwv_flow_api.g_varchar2_table(25) := '282929617065782E646562756728652E726567696F6E49642B22207573657270696E206E6F74206368616E67656422293B656C73657B76617220743D6E657720676F6F676C652E6D6170732E4C61744C6E6728692C6E293B652E7573657270696E3F2861';
wwv_flow_api.g_varchar2_table(26) := '7065782E646562756728652E726567696F6E49642B22206D6F7665206578697374696E672070696E20746F206E657720706F736974696F6E206F6E206D617020222B692B222C222B6E292C652E7573657270696E2E7365744D617028652E6D6170292C65';
wwv_flow_api.g_varchar2_table(27) := '2E7573657270696E2E736574506F736974696F6E2874292C6A6B3634706C7567696E5F736574436972636C6528652C7429293A28617065782E646562756728652E726567696F6E49642B2220637265617465207573657270696E20222B692B222C222B6E';
wwv_flow_api.g_varchar2_table(28) := '292C652E7573657270696E3D6E657720676F6F676C652E6D6170732E4D61726B6572287B6D61703A652E6D61702C706F736974696F6E3A742C69636F6E3A652E69636F6E7D292C6A6B3634706C7567696E5F736574436972636C6528652C7429297D7D65';
wwv_flow_api.g_varchar2_table(29) := '6C736520652E7573657270696E262628617065782E646562756728652E726567696F6E49642B22206D6F7665206578697374696E672070696E206F666620746865206D617022292C652E7573657270696E2E7365744D6170286E756C6C292C652E646973';
wwv_flow_api.g_varchar2_table(30) := '74636972636C65262628617065782E646562756728652E726567696F6E49642B22206D6F76652064697374636972636C65206F666620746865206D617022292C652E64697374636972636C652E7365744D6170286E756C6C2929297D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(31) := '206A6B3634706C7567696E5F696E69744D61702865297B617065782E646562756728652E726567696F6E49642B2220696E69744D617022293B76617220693D7B7A6F6F6D3A312C63656E7465723A6E657720676F6F676C652E6D6170732E4C61744C6E67';
wwv_flow_api.g_varchar2_table(32) := '28652E6C61746C6E67292C6D61705479706549643A676F6F676C652E6D6170732E4D61705479706549642E524F41444D41507D3B696628652E6D61703D6E657720676F6F676C652E6D6170732E4D617028646F63756D656E742E676574456C656D656E74';
wwv_flow_api.g_varchar2_table(33) := '4279496428652E636F6E7461696E6572292C69292C652E6D61702E666974426F756E6473286E657720676F6F676C652E6D6170732E4C61744C6E67426F756E647328652E736F757468776573742C652E6E6F7274686561737429292C2222213D3D652E73';
wwv_flow_api.g_varchar2_table(34) := '796E634974656D297B766172206E3D247628652E73796E634974656D293B6966286E756C6C213D3D6E26266E2E696E6465784F6628222C22293E2D31297B76617220613D6E2E73706C697428222C22293B617065782E646562756728652E726567696F6E';
wwv_flow_api.g_varchar2_table(35) := '49642B2220696E69742066726F6D206974656D20222B6E293B76617220743D6E657720676F6F676C652E6D6170732E4C61744C6E6728615B305D2C615B315D293B652E7573657270696E3D6E657720676F6F676C652E6D6170732E4D61726B6572287B6D';
wwv_flow_api.g_varchar2_table(36) := '61703A652E6D61702C706F736974696F6E3A742C69636F6E3A652E69636F6E7D292C6A6B3634706C7567696E5F736574436972636C6528652C74297D24282223222B652E73796E634974656D292E6368616E67652866756E6374696F6E28297B76617220';
wwv_flow_api.g_varchar2_table(37) := '693D746869732E76616C75653B6966286E756C6C213D3D692626766F69642030213D3D692626692E696E6465784F6628222C22293E2D31297B617065782E646562756728652E726567696F6E49642B22206974656D206368616E67656420222B69293B76';
wwv_flow_api.g_varchar2_table(38) := '6172206E3D692E73706C697428222C22293B6A6B3634706C7567696E5F7573657250696E28652C6E5B305D2C6E5B315D297D7D297D6966282222213D652E646973744974656D262624282223222B652E646973744974656D292E6368616E67652866756E';
wwv_flow_api.g_varchar2_table(39) := '6374696F6E28297B696628746869732E76616C7565297B76617220693D3165332A7061727365466C6F617428746869732E76616C7565293B652E64697374636972636C652E6765745261646975732829213D3D69262628617065782E646562756728652E';
wwv_flow_api.g_varchar2_table(40) := '726567696F6E49642B2220646973746974656D206368616E67656420222B746869732E76616C7565292C652E64697374636972636C652E736574526164697573286929297D656C736520652E64697374636972636C65262628617065782E646562756728';
wwv_flow_api.g_varchar2_table(41) := '652E726567696F6E49642B2220646973746974656D20636C656172656422292C652E64697374636972636C652E7365744D6170286E756C6C29297D292C6A6B3634706C7567696E5F72657050696E732865292C676F6F676C652E6D6170732E6576656E74';
wwv_flow_api.g_varchar2_table(42) := '2E6164644C697374656E657228652E6D61702C22636C69636B222C66756E6374696F6E2869297B766172206E3D692E6C61744C6E672E6C617428292C613D692E6C61744C6E672E6C6E6728293B617065782E646562756728652E726567696F6E49642B22';
wwv_flow_api.g_varchar2_table(43) := '206D617020636C69636B656420222B6E2B222C222B61292C2222213D3D652E73796E634974656D2626286A6B3634706C7567696E5F7573657250696E28652C6E2C61292C247328652E73796E634974656D2C6E2B222C222B61292C6A6B3634706C756769';
wwv_flow_api.g_varchar2_table(44) := '6E5F726566726573684D6170286529292C617065782E6A5175657279282223222B652E726567696F6E4964292E7472696767657228226D6170636C69636B222C7B6D61703A652E6D61702C6C61743A6E2C6C6E673A617D297D292C2222213D652E67656F';
wwv_flow_api.g_varchar2_table(45) := '636F64654974656D297B76617220723D6E657720676F6F676C652E6D6170732E47656F636F6465723B24282223222B652E67656F636F64654974656D292E6368616E67652866756E6374696F6E28297B6A6B3634706C7567696E5F67656F636F64652865';
wwv_flow_api.g_varchar2_table(46) := '2C72297D297D617065782E646562756728652E726567696F6E49642B2220696E69744D61702066696E697368656422292C617065782E6A5175657279282223222B652E726567696F6E4964292E7472696767657228226D61706C6F61646564222C7B6D61';
wwv_flow_api.g_varchar2_table(47) := '703A652E6D61707D297D66756E6374696F6E206A6B3634706C7567696E5F726566726573684D61702865297B617065782E646562756728652E726567696F6E49642B2220726566726573684D617022292C617065782E6A5175657279282223222B652E72';
wwv_flow_api.g_varchar2_table(48) := '6567696F6E4964292E747269676765722822617065786265666F72657265667265736822292C617065782E7365727665722E706C7567696E28652E616A61784964656E7469666965722C7B706167654974656D733A652E616A61784974656D737D2C7B64';
wwv_flow_api.g_varchar2_table(49) := '617461547970653A226A736F6E222C737563636573733A66756E6374696F6E2869297B617065782E646562756728652E726567696F6E49642B2220737563636573732070446174613D222B692E736F757468776573742E6C61742B222C222B692E736F75';
wwv_flow_api.g_varchar2_table(50) := '7468776573742E6C6E672B2220222B692E6E6F727468656173742E6C61742B222C222B692E6E6F727468656173742E6C6E67292C652E6D61702E666974426F756E6473287B736F7574683A692E736F757468776573742E6C61742C776573743A692E736F';
wwv_flow_api.g_varchar2_table(51) := '757468776573742E6C6E672C6E6F7274683A692E6E6F727468656173742E6C61742C656173743A692E6E6F727468656173742E6C6E677D292C652E69772626652E69772E636C6F736528292C617065782E646562756728652E726567696F6E49642B2220';
wwv_flow_api.g_varchar2_table(52) := '72656D6F766520616C6C207265706F72742070696E7322293B666F7228766172206E3D303B6E3C652E72657070696E2E6C656E6774683B6E2B2B29652E72657070696E5B6E5D2E6D61726B65722E7365744D6170286E756C6C293B696628617065782E64';
wwv_flow_api.g_varchar2_table(53) := '6562756728652E726567696F6E49642B222070446174612E6D6170646174612E6C656E6774683D222B692E6D6170646174612E6C656E677468292C652E6D6170646174613D692E6D6170646174612C6A6B3634706C7567696E5F72657050696E73286529';
wwv_flow_api.g_varchar2_table(54) := '2C2222213D3D652E73796E634974656D297B76617220613D247628652E73796E634974656D293B6966286E756C6C213D3D612626612E696E6465784F6628222C22293E2D31297B76617220743D612E73706C697428222C22293B617065782E6465627567';
wwv_flow_api.g_varchar2_table(55) := '28652E726567696F6E49642B2220696E69742066726F6D206974656D20222B61292C6A6B3634706C7567696E5F7573657250696E28652C745B305D2C745B315D297D7D617065782E6A5175657279282223222B652E726567696F6E4964292E7472696767';
wwv_flow_api.g_varchar2_table(56) := '657228226170657861667465727265667265736822297D7D292C617065782E646562756728652E726567696F6E49642B2220726566726573684D61702066696E697368656422297D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(75193041480888703)
,p_plugin_id=>wwv_flow_api.id(218512352878463408)
,p_file_name=>'jk64plugin.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
