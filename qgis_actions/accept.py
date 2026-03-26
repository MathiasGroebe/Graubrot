from qgis.core import QgsProject, QgsFeatureRequest
from qgis.utils import iface

# Get the layer and feature
project = QgsProject.instance()
layer = project.mapLayer("[% @layer_id %]")
feature = layer.getFeature(int("[% feature_id(@feature)%]"))
change_type = feature["action"]

if change_type == "A": # New object, mark it as approved

    osm_layer = project.mapLayersByName(feature["layer"])[0]
    feature_request = QgsFeatureRequest().setFilterExpression(f'"change_uuid" = \'{feature["change_uuid"]}\' ')
    osm_features = osm_layer.getFeatures(feature_request)

    for f in osm_features:
        
        # Update the feature in the OSM layer to mark it as approved
        osm_layer.startEditing()
        f["approved"] = True
        osm_layer.updateFeature(f)
        
        # Mark the change as reviewed in the changes layer
        layer.startEditing()
        feature["reviewed"] = True  
        layer.updateFeature(feature)
        
        iface.messageBar().pushMessage("Info", "Update accepted", level=0)
        
elif change_type == "M": # Modified object: set new object in his layer as approved "true", the older version as "false"
    
    osm_layer = project.mapLayersByName(feature["layer"])[0]
    feature_request = QgsFeatureRequest().setFilterExpression(f'"change_uuid" = \'{feature["change_uuid"]}\' ')
    osm_features = osm_layer.getFeatures(feature_request)

    for f in osm_features:
        
        # Update the feature in the OSM layer to mark it as approved if its not the older one
        osm_layer.startEditing()
        f["approved"] = True
        osm_layer.updateFeature(f)
        
        # Mark the older version of the feature as not approved
        # Older version is identified by the same osm_id but an older import_timestamp than the current change
        feature_old_request = QgsFeatureRequest().setFilterExpression(f'"osm_id" = {feature["osm_id"]} AND "import_timestamp" < \'{feature["import_timestamp"]}\' AND "change_uuid" != \'{feature["change_uuid"]}\'')
        old_features = osm_layer.getFeatures(feature_old_request)
        for old_f in old_features:
            old_f["approved"] = False
            osm_layer.updateFeature(old_f)
        
        # Mark the change as reviewed in the changes layer
        layer.startEditing()
        feature["reviewed"] = True  
        layer.updateFeature(feature)
        
        iface.messageBar().pushMessage("Info", "Update accepted", level=0)
        
     
elif change_type == "D": # Mark object as not approved
    
    osm_layer = project.mapLayersByName(feature["layer"])[0]
    feature_request = QgsFeatureRequest().setFilterExpression(f'"change_uuid" = \'{feature["change_uuid"]}\' ')
    osm_features = osm_layer.getFeatures(feature_request)

    for f in osm_features:

        # Update the feature in the OSM layer to mark it
        osm_layer.startEditing()
        f["approved"] = False
        osm_layer.updateFeature(f)
        
        # Mark the change as reviewed in the changes layer
        layer.startEditing()
        feature["reviewed"] = True  
        layer.updateFeature(feature)
        
        iface.messageBar().pushMessage("Info", "Update accepted", level=0)
    
else:
    iface.messageBar().pushMessage("Info", f"Unknown change type: {change_type}", level=0)
