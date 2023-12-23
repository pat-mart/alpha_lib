import 'dart:math';

import 'package:alpha_lib/src/deep_sky.dart';

class Example {
  DeepSky vega = DeepSky(latitude: 40.5, longitude: -72.1, raRad: 4.832, decRad: 0.67718, time: DateTime.timestamp(), utcOffset: -5, minAz: 200, maxAz: 300);

  Example () {
    print(vega.altAz); // Get the altitude and azimuth of Vega, at the current time, at coordinates (40.5, -72.1)
    print(vega.peakInfo); // Gets the azimuth, altitude, and time of Vega's peak / transit
    print(vega.sunriseSunset(104)); // Gets the times which at which the Sun is above/below 104° zenith angle
  }
}
