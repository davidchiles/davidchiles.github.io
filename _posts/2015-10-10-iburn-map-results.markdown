---
layout: post
title:  "Making the iBurn Map: Results"
date:   2015-10-10 17:56:00
tags:   iburn map js
map:    leaflet
map-height: 400
---

This is the final post in a series on making the data for iBurn 2015. So far we've created the [streets]({% post_url 2015-08-29-iburn-map-streets %}) and [polygons]({% post_url 2015-09-18-iburn-map-polygons %}). The last few pieces are making the 'outline' of the entire city and a few points of interest.

### Outline

The Golden Spike `csv` has the street widths so we are able to create polygons from the street lines using `buffer` from [jsts](https://github.com/bjornharrtell/jsts).

```js
sreets.features.map(function(item){
    var geo = reader.read(item).geometry;
    var width = defaultWidth;
    if (item.properties.width) {
      width = item.properties.width;
    }
    //Convert width in feet to radius in degrees
    radius = width / 2 / 364568.0;

    var buffer = geo.buffer(radius)
    buffer = parser.write(buffer);
    var newBuffer = {
      "type": "Feature",
      "properties": {}
    }
    newBuffer.geometry = buffer;
    if (outline) {
      outline = turf.union(outline,newBuffer);
    } else {
      outline = newBuffer;
    }
  });
```

Now that everything is a polygon, streets, plazas and portals, we combine all the polygons into one large polygon. Once we get to the rendering out to tiles this will make it look really nice instead of layering the plazas or portals above or below the streets. We still need the street lines for creating the labels during rendering.

### Points of Interest

I didn't spend much time this year improving our POI data set. I relied on [William's data](http://www.wkeller.net/BRC-GPS/) for the location of toilets. This data doesn't change much year to year so just moving them depending on how the city moves as a whole works for us. I did the same thing with the other POI, ice, first aid and ranger stations. The only major difference this year is the added first aid stations which were estimated based on this [map](http://survival.burningman.org/brc-infrastructure/city-layout/).

My plan for next year is to really improve the POI for the next year. Fingers crossed that [Playa Events](http://playaevents.burningman.org/) will even include latitude and longitude int their API.

### The Final Map

We used the same process as other years and created a bunch of png tiles and packaged them up into an mbtiles file using [Tilemill](https://www.mapbox.com/tilemill/). Next year we hope to use vector tiles as long as [MapboxGL](https://github.com/mapbox/mapbox-gl-native/) has [mbtiles support](https://github.com/mapbox/mapbox-gl-native/issues/584).

<div id="map"></div>
<script >
  var southWest = L.latLng(40.7413,-119.267),
    northEast = L.latLng(40.8365, -119.1465),
    bounds = L.latLngBounds(southWest, northEast);
  var map = L.map('map').setView([40.7864, -119.2065], 13).setMaxBounds(bounds);

  L.tileLayer('https://raw.githubusercontent.com/davidchiles/tiles/master/iburn-2015-tiles/{z}/{x}/{y}.png', {
        minZoom: 12,
  			maxZoom: 19
  		}).addTo(map);



</script>
