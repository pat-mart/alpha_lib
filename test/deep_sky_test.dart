import 'dart:math';

import 'package:alpha_lib/alpha_lib.dart';
import 'package:alpha_lib/src/deep_sky.dart';
import 'package:alpha_lib/src/units.dart';
import 'package:test/test.dart';

void main() {
  group('Tests for DeepSky class', () {

    DeepSky vega = DeepSky(latitude: 40.8, longitude: -73.1, raRad: 4.832, decRad: 0.67718, time: DateTime.timestamp(), utcOffset: -5, minAz: 200, maxAz: 300);

    DeepSky altair = DeepSky(latitude: 40.8, longitude: -73.1, raRad: 4.98, decRad: 0.1559, time: DateTime.timestamp(), utcOffset: -5, minAz: 250, maxAz: 350);

    DeepSky polaris = DeepSky(latitude: 40.8, longitude: -73.1, raRad: 0.79, decRad: pi/2, time: DateTime.timestamp(), utcOffset: -5);

    setUp(() {
      print(vega.peakInfo);
    });

    test('Azimuth test', () {
      expect(altair.altAz[1] >= 0, true);

      expect(altair.altAz[1] <= 360, true);

      expect(vega.altAz[1] >= 0, true);

      expect(vega.altAz[1] <= 360, true);
    });

    test('Altitude test', () {
      expect(altair.altAz[0] > 0, false);

      expect(vega.altAz[0] > 0, true);
    });

    test('Rise set test', () {
      expect(altair.localRiseSetTimes[0] > 0, true);

      expect(altair.localRiseSetTimes[0] > 0, true);

      expect(polaris.localRiseSetTimes[0] == 0, true);
    });
  });
}
