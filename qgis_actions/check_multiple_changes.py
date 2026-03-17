from qgis.core import QgsFeatureRequest, QgsProject
from qgis.utils import iface

project = QgsProject.instance()
layer = project.mapLayer("[% @layer_id %]")
feature = layer.getFeature(int("[% feature_id(@feature)%]"))

# Check if there are other unreviewed changes for the same feature (identified by osm_id and layer) before accepting/rejecting the change
check_features = QgsFeatureRequest().setFilterExpression(f'"reviewed" IS NULL AND "layer" = \'{feature["layer"]}\' AND "osm_id" = {feature["osm_id"]}')
features = layer.getFeatures(check_features)
feature_count = len(list(features))

if feature_count > 1:
    iface.messageBar().pushMessage("Warning", 
    f"There are {feature_count} unreviewed changes for this feature. Please review them before accepting/rejecting the change.", level=1)
elif feature_count == 1:
    iface.messageBar().pushMessage("Info", "This change can be accepted/rejected.", level=0)
else:
    iface.messageBar().pushMessage("Info", "No other unreviewed changes found for this feature.", level=0)