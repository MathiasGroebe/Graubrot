from qgis.core import QgsProject, QgsRectangle, QgsCoordinateTransform
from qgis.gui import QgsMapCanvas
from qgis.utils import iface

# Get the active layer and map canvas
project = QgsProject.instance()
layer = project.mapLayer("[% @layer_id %]")
canvas = iface.mapCanvas()

# Get selected features
feature = layer.getFeature(int("[% feature_id(@feature)%]"))

if not feature:
    iface.messageBar().pushMessage("Info", "Feautre not found", level=0)
else:
    # Calculate bounding box and transform to project CRS
    transform = QgsCoordinateTransform(layer.crs(), project.crs(), project)
    bbox = feature.geometry().boundingBox()
    bbox = transform.transform(bbox)
    
    # Add buffer to bounding box (10% padding)
    bbox.scale(1.5)
    
    # Set canvas extent to zoom to features
    canvas.setExtent(bbox)
    canvas.refresh()
    
    # Flash the feature to highlight it
    canvas.flashFeatureIds(layer, [feature.id()])