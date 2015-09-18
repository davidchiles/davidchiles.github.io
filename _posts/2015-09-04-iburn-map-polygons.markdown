---
layout: post
title:  "Making the iBurn Map: Polygons"
date:   2015-09-18 3:00:00
tags: iburn map js
---

This is the second part of in a series on how the data was created for the 2015 iBurn map. I would suggest you read making the [streets]({% post_url 2015-08-29-iburn-map-streets %}) first.

### Plazas

The simplest polygon are the plazas. There are two pieces of information needed to create a plaza, the center and the diameter of the plaza. The diameter of the plazas is published in Burning Man's [Golden Spike](http://innovate.burningman.org/dataset/2015-golden-spike-location/) information. Then in the `layout.json` file we capture the the distance from The Man, either a street or in feet, and the time angle. From this we can derive the center point. Using the same function from [creating streets]({% post_url 2015-08-29-iburn-map-streets %}) we can create a circle around the center.

![Black Rock City Plazas]({{ site.url }}/assets/bm_plazas.png)

#### Center Camp Plaza

The Center Camp Plaza is a little trickier because the Café is right in the middle. Looking at previous years satellite imagery and other pdf maps I was able to estimate that the the Café structure has a 110' radius. So it's easy with [geoJSON](http://geojson.org/geojson-spec.html#polygon) to describe a polygon with 'holes' so we just add the Café polygon as a hole to the larger Center Camp Plaza.

![Center Camp Plaza]({{ site.url }}/assets/bm_center_camp_plaza.png)

### Portals

I was really excited to add portals to our map this year because it really helps to orient yourself out on the desert. I wanted to get the portals as accurate as possible so I looked at past satellite imagery to try to understand their dimensions. From the imagery they seemed pretty consistent starting at a particular street intersection and expanding towards The Man, terminating at either Esplanade or Rod's Road for the Center Camp Portal. I estimated the angle to be about 20 or 30 degrees depending on the portal.

To create the portal first I create an angle starting at the intersection with edges a 1/2 mile opening up towards The Man. Then I took Esplanade (for 6:00 portal Rod's Road) street and 'cut' the angle's edges. To cut cut the angle I used the [jsts difference](http://bjornharrtell.github.io/jsts/doc/api/symbols/jsts.geom.Geometry.html#difference) function. Then you have a portal!

![Black Rock City Portals]({{ site.url}}/assets/bm_portals.png)

The problem is that 9:00, 3:00 and 6:00 portals overlap their plaza. I decided that the plaza was the more defining feature at that point so I cut those portals again with the plaza so there wasn't any overlap for the renderer.

![Portal plaza overlap]({{ site.url}}/assets/bm_plaza_portal_overlap.png)
![Portal plaza overlap fixed]({{ site.url}}/assets/bm_plaza_portal_overlap_fixed.png)

### Results

![Black Rock City Polygons]({{ site.url}}/assets/bm_polygons.png)
