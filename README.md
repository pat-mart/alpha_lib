<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A database-less package for performing astronomical calculations with any third-party database of deep-sky objects. 

## Features

alpha_lib can accurately calculate the altitude and azimuth of an object at any location or time. 

The local or Greenwich mean sideral time and Julian date can also be calculated.

Additionally, it can determine the rise and set times of an object, in addition to when (and where) an object will "peak" in the sky.

The current implementation of coordinate filtering is a little janky, but it can indicate the times an object is above a certain altitude or within a certain azimuth range.

## Usage

Use the ```DeepSky``` class to create a deep sky object. I hope to implement a class for heliocentric objects (that also extends ```SkyObject```) soon. 

All astronomical values will be returned as radians.

Time values are returned as hours, which can be appended to the day, month, and year of ```time``` for a specific date and time.

The constructor parameters ```minAz```, ```maxAz```, and ```minAlt``` are optional and used for coordinate filtering. 

```dart
import 'dart:math';
DeepSky andromeda = DeepSky(latitude: 40.5, longitude: -72.1, raRad: 0.01243, decRad: 0.7191, time: DateTime.timestamp(), utcOffset: -5, minAz: 200, maxAz: 300, minAlt: 40);
```

To get the object's altitude and azimuth at that time, use the ```altAz``` method. 

```dart
final altAz = andromeda.altAz;
print(altAz);

//[0.23092634227782138, 0.8105940619838048] -- the altitude, azimuth in radians 

// To convert altitude to degrees
print(altAz[0].toDegrees(Units.radians));

// 13.231104790912635 -- the Andromeda Galaxy is currently 13.2 degrees above the horizon
```

To get the local times when the object is within the ```minAz```, ```maxAz```, and ```minAlt``` filters, use the ```withinFilters``` method. 

```dart
print(withinFilters);
// [18.933333333333334, 22.866666666666667] -- the object is within azimuths 200° and 300° and 40° above the horizon from about 19:00 to about 23:00. 
// This is a useful feature for astronomers with obstructed views of the sky.
```

To get the hours an object will set, use the ```localRiseSetTimes``` or ```utcRiseSetTimes``` methods. 
If an object never sets, its rise and set times will be returned as ```[0, 0]```.
If an object never rises, its rise and and set times will be returned as ```[-1, -1]```.

To get information about an object's peak, use the ```peakInfo``` method. It returns a ```Map<String, double>``` with keys ```'alt', 'az', 'time'``` and their corresponding values.

## Additional information
 
Please file issues, suggestions, pull requests, etc. on the GitHub repository and I will try to respond to them. I am currently applying to colleges so I may be a little busy.
Most notably, the ```withinFilters``` method could probably use some improving. 
