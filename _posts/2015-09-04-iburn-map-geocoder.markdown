---
layout: post
title:  "Making the iBurn Map: Geocoder"
date:   2015-10-10 18:40:00
tags: iburn map js
---

Creating a reverse and forward geocoder was the most experimental feature this year. One of the goals of the geocoder was to be able to run them on the device without an internet connection. We also wanted to run it both on Android and iOS. Since all the past work was done with javascript it seemed logical to stick with javascript. But because I wanted to run on both platforms it made it so I couldn't use things like [spatialite](http://www.gaia-gis.it/gaia-sins/) without a lot of effort and learning C++. There are definitely more efficient ways to make local geocoder so any hints on how to make it better are welcome.

### Forward Geocoder

The main purpose for the forward geocoder was taking the playa address provided by [Playa Events](http://playaevents.burningman.org/) and turning those into latitude and longitude coordinates. There are two address types for the playa. The easiest and most accurate is time and distance i.e. `4:25 & 800'`. The second are street intersections i.e. `7:30 & Arcade`. This type is a lot less accurate because it only gives you the nearest intersection not the actual location of the camp.

The first step for the geocoder is to prepare the data. I take the streets geoJSON file and other polygon features and load them into a large features array. Once there's a request to reverse geocoded it's put through some regex to figure out which type of address it is. If it's a time and distance then I figure out the angle of the time and use [turf-destination](https://github.com/Turfjs/turf-destination) to get the lat long. If it's a street intersection. I find the best match using [levenshtein](https://github.com/gf3/Levenshtein) to a feature and once I have the best two matched features I find their intersection with each other using [turf-intersect](https://github.com/Turfjs/turf-intersect).

#### Improvements

I noticed that streets on the ends like 2:00 and 10:00 don't always intersect. This year I just tried using radial streets off by + or - 1/20 of a degree. I could instead ensure that the streets share points to guarantee a result when checking if they intersect.

This year we didn't handle plaza addresses. This is the case where the plaza has an internal clock to locate camps along the outer edge.

### Reverse Geocoder

We got a feature request from a Ranger telling us that it would be helpful to know where they were on the playa not latitude and longitude but something they could say over the radio and have another Ranger understand. I first categorized a few different places you could be.

- Center Camp Plaza
- Café
- The city streets area
- Inner Playa
- Outer Playa
- Outside Black Rock City


![Reverse geocoding polygons]({{ site.url }}/assets/bm_2015_reverse_polygons.png)

For the Center Camp Plaza or Café I just returned the name of the feature. In the future I should probably do this for all plazas and portals. The city streets area first detected the nearest non-time street. This was done in a pretty naive way by sorting a large array of all the features. If the closest match was part of Center Camp then we calculated the time based on the Center Camp Center but for all others we calculated the time based on the Man. So results would look like `8:26 & Arcade`. For Inner and Outer Playa I used time and distance as the address. This was easy to calculate as all was needed was to convert the angle to the man then convert that to clock coordinates and then find the distance between the man and the point.

### Geocoder on device

#### Preparation

To get the geocoder ready for use on the device I used browserify to package up all the js necessary.

```bash
browserify index.js > bundle.js
```
We also did some [uglifyify](https://github.com/hughsk/uglifyify) to get it a bit smaller.


#### iOS

We created a small [wrapper class](https://github.com/Burning-Man-Earth/iBurn-iOS/blob/master/iBurn/BRCGeocoder.h) around [JavaScriptCore](https://developer.apple.com/library/mac/documentation/Carbon/Reference/WebKit_JavaScriptCore_Ref/). Apple makes it really easy to pass between Objective-C and JS. Loading the JS:

```obj-c
NSString *path = [[NSBundle mainBundle] pathForResource:@"bundle" ofType:@"js"];

NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
string = [NSString stringWithFormat:@"var window = this; %@",string];

strongSelf.context = [[JSContext alloc] init];

[strongSelf.context evaluateScript:string];
[strongSelf.context evaluateScript:@"var reverseGeocoder = prepare()"];
```

Then to execute a query:

```obj-c
- (NSString*) executeReverseLookup:(CLLocationCoordinate2D)location {
    NSString *command = [NSString stringWithFormat:@"reverseGeocode(reverseGeocoder, %f, %f)", location.latitude, location.longitude];
    JSValue *result = [self.context evaluateScript:command];
    NSString *locationString = [result toString];
    return locationString;
}
```

#### Android

I wasn't part of implementing the android but if you're used to look at Java take a look [here](https://github.com/Burning-Man-Earth/iBurn-Android/blob/de112f52c27878f1555f676d7f86891667b639c2/iBurn/src/main/java/com/gaiagps/iburn/fragment/GoogleMapFragment.java#L342) where it's setup. We were able to execute ths javascript in an off screen web view.
