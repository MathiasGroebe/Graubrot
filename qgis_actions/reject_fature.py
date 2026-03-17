from qgis.core import QgsProject, QgsFeatureRequest
from qgis.utils import iface

# Get the layer and feature
project = QgsProject.instance()
layer = project.mapLayer("[% @layer_id %]")
feature = layer.getFeature(int("[% feature_id(@feature)%]"))
change_type = feature["action"]

if change_type == "A": # New object
    
    # Find the corresponding feature in the OSM layer using the osm_id and version attributes
    osm_layer = project.mapLayersByName(feature["layer"])[0]
    feature_request = QgsFeatureRequest().setFilterExpression(f'"change_uuid" = \'{feature["change_uuid"]}\' ')
    osm_features = osm_layer.getFeatures(feature_request)

    for f in osm_features:

        if f["approved"] == None: # Only update if the feature is not already marked as approved/rejected
            # Update the feature in the OSM layer to mark it
            osm_layer.startEditing()
            f["approved"] = False
            osm_layer.updateFeature(f)
            
            # Mark the change as reviewed in the changes layer
            layer.startEditing()
            feature["reviewed"] = True  
            layer.updateFeature(feature)
            
            iface.messageBar().pushMessage("Info", f"New feature marked as rejected", level=0)
        
elif change_type == "M": # Modified object: set new object in his layer as reviewed "false"
    
    # Find the corresponding feature in the OSM layer using the osm_id and version attributes
    osm_layer = project.mapLayersByName(feature["layer"])[0]
    feature_request = QgsFeatureRequest().setFilterExpression(f'"change_uuid" = \'{feature["change_uuid"]}\' ')
    osm_features = osm_layer.getFeatures(feature_request)

    for f in osm_features:
        
        if f["approved"] == None: # Only update if the feature is not already marked as approved/rejected
            # Update the feature in the OSM layer to mark it
            osm_layer.startEditing()
            f["approved"] = False
            osm_layer.updateFeature(f)
            
            # Mark the change as reviewed in the changes layer
            layer.startEditing()
            feature["reviewed"] = True  
            layer.updateFeature(feature)
            
            iface.messageBar().pushMessage("Info", f"New feature marked as rejected", level=0)
     
elif change_type == "D": # Deleted object
    
    layer.startEditing()
    feature["reviewed"] = True
    layer.updateFeature(feature)
    
    iface.messageBar().pushMessage("Info", "Update rejected", level=0)
    
else:
    iface.messageBar().pushMessage("Info", f"Unknown change type: {change_type}", level=0)

