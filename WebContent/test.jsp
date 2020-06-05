<%@ page language="java" contentType="text/html; charset=UTF-8"
	import="java.util.*,member.*" 
    pageEncoding="UTF-8"
    isELIgnored="false" %>
<%
  request.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>Display a map</title>
<meta name="viewport" content="initial-scale=1,maximum-scale=1,user-scalable=no" />
<script src="https://api.mapbox.com/mapbox-gl-js/v1.6.1/mapbox-gl.js"></script>
<link href="https://api.mapbox.com/mapbox-gl-js/v1.6.1/mapbox-gl.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/@turf/turf@5/turf.min.js"></script>
<style>
	body { margin: 0; padding: 0; }
	#map { position: absolute; top: 0; bottom: 0; width: 100%; };
</style>
</head>
<body>
<script src="https://api.mapbox.com/mapbox-gl-js/plugins/mapbox-gl-directions/v4.0.2/mapbox-gl-directions.js"></script>
<link
rel="stylesheet"
href="https://api.mapbox.com/mapbox-gl-js/plugins/mapbox-gl-directions/v4.0.2/mapbox-gl-directions.css"
type="text/css"
/>
<div id="map"></div>
<script>
	mapboxgl.accessToken = 'pk.eyJ1IjoiYWthMjM0NCIsImEiOiJjazUxeGtjN2ExMXh5M29wZ3NpOWhqbjE2In0.q5q-58QCxrAmfu8wNmQgyg';
var map = new mapboxgl.Map({
container: 'map', // container id
style: 'mapbox://styles/mapbox/streets-v11', // stylesheet location
center: [126.986, 37.541], // starting position [lng, lat]
zoom: 9 // starting zoom
});
map.on('load', function() {
map.addSource('shelter',{
'type': 'geojson',
'data': 'http://localhost:8080/geoserver/test1/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=test1:shel_seoul&maxFeatures=3000&outputFormat=application/json'
})
map.addSource('ways',{
'type': 'geojson',
'data': 'http://localhost:8080/geoserver/test1/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=test1:ways&outputFormat=application/json'
})
map.addSource('node',{
'type': 'geojson',
'data': 'http://localhost:8080/geoserver/test1/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=test1:ways_vertices_pgr&outputFormat=application/json'
})
map.addLayer(
{
'id': 'points',
'type': 'symbol',
'source': 'shelter',
'layout': {
// get the icon name from the source's "icon" property
// concatenate the name to get an icon from the style's sprite sheet
// get the title name from the source's "title" property
"icon-image": "marker-15",
"icon-size": 3
}} 
);

map.addLayer(
{
'id': 'nodes',
'type': 'symbol',
'source': 'node',
'layout': {
// get the icon name from the source's "icon" property
// concatenate the name to get an icon from the style's sprite sheet
// get the title name from the source's "title" property
}} 
);

map.addLayer(
{
'id': 'egde',
'type': 'line',
'source': 'ways',
'layout': {
    'line-join': 'round',
'line-cap': 'round'
// get the icon name from the source's "icon" property
// concatenate the name to get an icon from the style's sprite sheet
// get the title name from the source's "title" property
},
'paint': {
'line-color': '#ed6498',
'line-width': 2,
'line-opacity': 0
}} 
);



var marker = new mapboxgl.Marker()
  .setLngLat([126.986, 37.541])
  .addTo(map);

var popup = new mapboxgl.Popup({
    closeButton: false,
closeOnClick: false
});

map.addSource('nearest-shelter', {
  type: 'geojson',
  data: {
    type: 'FeatureCollection',
    features: [
    ]
  }
});


// create a function to make a directions request
function getRoute(start, end) {
  // make a directions request using cycling profile
  // an arbitrary start will always be the same
  // only the end or destination will change
  var url = 'https://api.mapbox.com/directions/v5/mapbox/walking/' + start[0] + ',' + start[1] + ';' + end[0] + ',' + end[1] + '?steps=true&geometries=geojson&access_token=' + mapboxgl.accessToken;

  // make an XHR request https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest
  var req = new XMLHttpRequest();
  req.responseType = 'json';
  req.open('GET', url, true);
  req.onload = function() {
    var data = req.response.routes[0];
    var route = data.geometry.coordinates;
    var geojson = {
      type: 'Feature',
      properties: {},
      geometry: {
        type: 'LineString',
        coordinates: route
      }
    };
    // if the route already exists on the map, reset it using setData
    if (map.getSource('route')) {
      map.getSource('route').setData(geojson);
    } else { // otherwise, make a new request
      map.addLayer({
        id: 'route',
        type: 'line',
        source: {
          type: 'geojson',
          data: {
            type: 'Feature',
            properties: {},
            geometry: {
              type: 'LineString',
              coordinates: geojson
            }
          }
        },
        layout: {
          'line-join': 'round',
          'line-cap': 'round'
        },
        paint: {
          'line-color': '#3887be',
          'line-width': 5,
          'line-opacity': 0.75
        }
      });
    }
    // add turn instructions here at the end
  };
  req.send();
}

map.on('load', function() {
  // make an initial directions request that
  // starts and ends at the same location
  getRoute(start, end);

  // Add starting point to the map
  map.addLayer({
    id: 'point',
    type: 'circle',
    source: {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: [{
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'Point',
            coordinates: start
          }
        }
        ]
      }
    },
    paint: {
      'circle-radius': 10,
      'circle-color': '#3887be'
    }
  });
  // this is where the code from the next step will go
});

map.on('click', function(e) {
      marker.setLngLat(e.lngLat);
      var targetPoint = turf.point([e.lngLat.lng, e.lngLat.lat]);
      var shelFeatures = [];
      var shelter =  map.querySourceFeatures('shelter', {
      sourceLayer: 'points'});
      for(var i = 0; i < shelter.length ; i++){
          var cood = shelter[i].geometry.coordinates.slice();
          shelFeatures.push(turf.point([cood[0], cood[1]]));
      }
      var points = turf.featureCollection(shelFeatures);
      var nearestShelter = turf.nearestPoint(targetPoint, points);
      if(nearestShelter == null){
          console.log("error! null");
      }
      if (nearestShelter !== null) {
    // Update the 'nearest-library' data source to include
    // the nearest library
    var marker_cood = turf.getCoord(targetPoint);
    var shelter_cood = turf.getCoord(nearestShelter);
    map.getSource('nearest-shelter').setData({
      type: 'FeatureCollection',
      features: [
      nearestShelter
      ]
    });
    map.addLayer({
      id: 'nearest-shelter',
      type: 'circle',
      source: 'nearest-shelter',
      paint: {
        'circle-radius': 20,
        'circle-color': '#486DE0'
      }
    }, 'points');

  }
  //getRoute(turf.getCoord(targetPoint), turf.getCoord(nearestShelter));
});



map.on('mouseenter', 'points', function(e) {
map.getCanvas().style.cursor = 'pointer';
var coordinates = e.features[0].geometry.coordinates.slice();
var shel_name = e.features[0].properties.ì§ì§í´;
var shel_address = e.features[0].properties.ìì¬ì§;
var shel_cap = e.features[0].properties.ìì©ê°;
var shel_maxcap = e.features[0].properties.ìµëì;
var shel_con = e.features[0].properties.ê´ë¦¬ê¸°;
var shel_call = e.features[0].properties.ê´ë¦¬_1;

var shel_info = 'ì´ë¦ : ' + shel_name + "<br>" +
                'ì£¼ì : ' + shel_address+ "<br>" +
                'ì ì ìì©ì¸ì : ' + shel_cap + "ëª <br>" +
                'ìµëìì©ì¸ì : ' + shel_maxcap + "ëª <br>" +
                'ê´ë¦¬ê¸°ê´ : ' + shel_con + "<br>" +
                'ì íë²í¸ : ' + shel_call + "<br>";

while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
}


popup
.setLngLat(coordinates)
.setHTML(shel_info)
.addTo(map);
});

map.on('mouseleave', 'points', function() {
map.getCanvas().style.cursor = '';
popup.remove();
});

});


</script>
 
</body>
</html>