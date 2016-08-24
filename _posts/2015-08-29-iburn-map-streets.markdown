---
layout: post
title:  "Making the iBurn Map: Streets"
date:   2015-08-29 16:13:28
tags: iburn map js
---

I worked with [Andrew Johnstone](http://architecturalartsguild.com/about/), [Savannah Henderson](http://www.savannahhenderson.com), [David Brodsky](https://github.com/onlyinamerica) and [Chris Ballinger](http://chrisballinger.info) making the [iBurn](http://www.iburnapp.com/) app for [Android](https://github.com/Burning-Man-Earth/iBurn-Android) and [iOS](https://github.com/Burning-Man-Earth/iBurn-iOS). One of my favorite features in iBurn is the map when you first launch the app. This year I took on rewriting and rethinking how we create the geo data. I'm going to try and document how I made the different components of the map.

### Components of the map
- Streets
- Plazas & Portals
- Points of Interest (toilets, ranger stations, etc.)

#### Streets
Everything we do starts with the [Golden Spike](http://innovate.burningman.org/dataset/2015-golden-spike-location/) which fortunately is published fairly far ahead of time. There's tons of useful information in the `csv` but for streets we need the distance each circular street is from the man and the names for this year.

```objective_c
MARCR,2940,"Man to ""A"" Road Center Radius"
...
ARN,Arcade,"""A"" Road Name"
```

This format was not the best to work with directly so I took what I needed and added some other data to a JSON file I called [`layout.json`](https://github.com/Burning-Man-Earth/iBurn-Data/blob/master/data/2015/geo/layout.json). The purpose of the layout file is to contain all the data necessary to create the city layout. So to make the map for 2014 or any other year just update the layout file.

#### Circle & Time Streets
The format is a a bit strange but here's a sample for the circular streets.

```js
"cStreets":[
    ...,
    {
      "distance":2940,
      "segments":[["2:00","10:00"]],
      "ref":"a",
      "name": "Arcade"
    },
    {
      "distance":3180,
      "segments":[["2:00","5:30"],["6:30","10:00"]],
      "ref":"b",
      "name": "Ballyhoo"
    },
    ...
]
```

One of the biggest benefits of the JSON format is I can capture the fact that not all streets start at 2:00 and go to 10:00. So it's easy for B and F streets to be created correctly. We'll handle Center camp separately.

The time streets are the same each year. So I used past PDF maps and past satellite images to figure out their configuration. Because there's so much repetition with the time streets I changed the format a bit.

```js
"tStreets":[
    ...
    {
      "refs":[
        "2:00",
        "2:30",
        "3:30",
        "4:00",
        "4:30",
        "5:00",
        "7:00",
        "7:30",
        "8:00",
        "8:30",
        "9:30",
        "10:00"],
      "segments":[["esplanade","l"]]
    },
    ...
]
```
Now once everything is in the layout file there are only a few scripts need to make the geoJSON files that will be used to make the map. I used [Turf.js](http://turfjs.org/) for all the geo calculations. Turf worked really well in our case and made it so I didn't have to do any geo math... ever.  

In order to create the arc or circular streets I just dropped a point every 5 degrees going from the start of a segment to the end.

```js
var currentPoint = turf.destination(center,distance,currentBearing,units);
points.push(currentPoint.geometry.coordinates);
```

Then just collect all the points into a `MultiLineString` with the correct properties from the layout file.

The time streets are done in a similar way. Using Turf and [`turf.destination`](https://github.com/Turfjs/turf-destination) to calculate the correct start and end points. There are a few functions in [`util.js`](https://github.com/Burning-Man-Earth/iBurn-Data/blob/master/scripts/2015/layout.js) that help to convert from Playa time to degrees (with a bit of math).

![Burning Man streets]({{ site.url }}/assets/bm_streets.png)

#### Center Camp
The trickiest part is creating Center Camp and cutting out the other streets that would ordinarily cut through Center Camp. There are a few components of center camp.

- Rod's Road
- A Road
- Center Camp Plaza
- Route 66
- 6:00

Rod's Road is the easiest. Once we find the center of Center Camp we just use the same arc function to create a full circle around that point. And the same goes for the Center Camp Plaza Road which is just half way between the edge of the Café and the outer edge of the Center Camp Plaza.

The A road which goes into Center camp is a actually a straight road not an arc from Rod's Road to the Center Camp Plaza Road. So we calculate where A Road and Rod's Road intersect, create a line from there to the center of Center Camp and then 'cut' that line with the Center Camp Plaza Road. We also cut 6:00 with the Center Camp Plaza Road. All the Cutting was using [jsts](https://github.com/bjornharrtell/jsts) difference method.

Once we have the two A Road segments through center camp we find the bearing of each and create arcs for Route 66, a service road between Rod's Road and Center Camp Plaza. And then for the segment of Route 66 on the man side we cut that with the 6:00 portal.

![Center Camp streets]({{ site.url }}/assets/bm_center_camp.png)

Finally I cut the other arc and time roads with Rod's road and combine them into a single geoJSON file. All the code for creating the streets can be found [here](https://github.com/Burning-Man-Earth/iBurn-Data/tree/master/scripts/2015). Or by just running:

```bash
node layout.js -f ../../data/2015/geo/layout.json -t streets
```
#### Result
![Black Rock City All Streets]({{ site.url }}/assets/bm_all_streets.png)
