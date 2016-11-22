---
title: Progress on OpenAddresses
layout: post
date:   2016-11-21 18:50:00
tags: open source address swift census us
---

[OpenAddresses](https://github.com/openaddresses/openaddresses/) contains a large repository of addresses, 282,064,595 in total. For a while I've checked the [growing list of included sources](http://results.openaddresses.io/). I want to take a look at just the [US sources](https://github.com/openaddresses/openaddresses/tree/master/sources/us) and ask how many people are covered by the current set of data?

This also gave me a chance to try building a [swift](https://swift.org/) command line tool with the [Swift Package Manager](https://swift.org/package-manager/). [OpenAddressesCensus](https://github.com/davidchiles/OpenAddressesCensus) is a simple tool that looks at a census csv file and the OpenAddresses repository and compares which counties have exact coverage, coverage from a state source or no coverage. If you're interested on how it works check out the [repository](https://github.com/davidchiles/OpenAddressesCensus). One big assumption the tool makes a state level source contains all addresses in that state. It's possible that a state source is incomplete and excludes some counties. I also manually marked the New York City counties as covered because they are so large and covered in a [city level source](https://github.com/openaddresses/openaddresses/blob/master/sources/us/ny/city_of_new_york.json).

### [Results](https://github.com/davidchiles/OpenAddressesCensus/blob/master/Results/Result.markdown)

The best I can do right now looking at county level data is find a lower bounds on the population covered. For example I noticed there are a lot of counties in New York that are not marked as covered because there is no geoid in the [New York State source](https://github.com/openaddresses/openaddresses/blob/master/sources/us/ny/statewide.json). Although it appears the New York State source does not cover all counties. There are also quite a few city level sources that OpenAddressesCensus doesn't handle yet. You can see [Detroit](https://github.com/openaddresses/openaddresses/blob/master/sources/us/mi/city_of_detroit.json), [Austin](https://github.com/openaddresses/openaddresses/blob/master/sources/us/tx/city_of_austin.json) are all big cities that aren't counted in my population numbers yet.

So with that all in mind here are the results:

| | Population | Population % |
| --- | --- | --- |
| Complete | 203106631 | 63.2% |
| State | 46750056 | 14.5% |
| None | 71562133 | 22.3% |

<br>

That puts the lower bounds at **77.7%** of the US population covered. That's a lot better than I expected.

The 10 biggest counties missing are below. Every one of them has an own issue or is mostly covered by a city in that county. You can see the full list of missing counties in the [OpenAddressesCensus results](https://github.com/davidchiles/OpenAddressesCensus/blob/master/Results/Result.markdown).

#### Missing Counties
1. Wayne County, Michigan (partial coverage in the [Detroit source](https://github.com/openaddresses/openaddresses/blob/master/sources/us/mi/city_of_detroit.json))
2. Suffolk County, New York ([#579](https://github.com/openaddresses/openaddresses/issues/579))
3. Nassau County, New York ([#1990](https://github.com/openaddresses/openaddresses/issues/1990))
4. Travis County, Texas (partial coverage in the [Austin source](https://github.com/openaddresses/openaddresses/blob/master/sources/us/tx/city_of_austin.json))
5. Gwinnett County, Georgia ([#2060](https://github.com/openaddresses/openaddresses/issues/2060))
6. Pierce County, Washington (Related [#1947](https://github.com/openaddresses/openaddresses/issues/1947))
7. Montgomery County, Pennsylvania ([#1982](https://github.com/openaddresses/openaddresses/issues/1982) & [#1979](https://github.com/openaddresses/openaddresses/issues/1979))
8. Oklahoma County, Oklahoma ([#192](https://github.com/openaddresses/openaddresses/issues/192))
9. Cobb County, Georgia ([#456](https://github.com/openaddresses/openaddresses/issues/456))
10. DeKalb County, Georgia ([#460](https://github.com/openaddresses/openaddresses/issues/460))

### Next Steps

I want to make this tool more accurate. Right now it's limited to county level population data. I could add city level population data and handle sources like the New York State that don't have a geoid but rather a geometry. In both cases the tool needs to support finding the union of geometries covered and then finding the population within that geometry. That way it doesn't double count overlapping sources from a city and a intersecting county. 