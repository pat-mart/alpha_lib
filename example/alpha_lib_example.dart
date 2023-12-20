import 'dart:math';

import 'package:alpha_lib/src/deep_sky.dart';

class Example {
  DeepSky vega = DeepSky(latitude: 40.5, longitude: -72.1, raRad: 4.832, decRad: 0.67718, time: DateTime.timestamp(), utcOffset: -5, minAz: 200, maxAz: 300);

  DeepSky altair = DeepSky(latitude: 40.5, longitude: -72.1, raRad: 4.98, decRad: 0.1559, time: DateTime.timestamp(), utcOffset: -5, minAz: 100, maxAz: 350, minAlt: 40);

  DeepSky polaris = DeepSky(latitude: 40.5, longitude: -72.1, raRad: 0.79, decRad: pi/2, time: DateTime.timestamp(), utcOffset: -5);

  Example () {
    print(vega.altAz);
  }
}
