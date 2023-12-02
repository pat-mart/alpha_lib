import 'dart:math';

import 'package:alpha_lib/src/deep_sky.dart';
import 'package:test/test.dart';

void main() {
  group('Tests for DeepSky class', () {

    DeepSky vega = DeepSky(latitude: 41.2, longitude: -73.1, raRad: 4.723355466, decRad: 0.67718, time: DateTime.timestamp(), utcOffset: -5);

    DeepSky altair = DeepSky(latitude: 41.2, longitude: -73.1, raRad: 4.98, decRad: 0.1559, time: DateTime.timestamp(), utcOffset: -5);

    DeepSky polaris = DeepSky(latitude: 41.2, longitude: -73.1, raRad: 0.79, decRad: pi/2, time: DateTime.timestamp(), utcOffset: -5);

    setUp(() {});

    test('Azimuth test', () {
      expect(altair.altAz[1] >= 0, true);

      expect(altair.altAz[1] <= 360, true);

      expect(vega.altAz[1] >= 0, true);

      expect(vega.altAz[1] <= 360, true);
    });

    test('Altitude test', () {
      expect(altair.altAz[0] > 0, true);

      expect(vega.altAz[0] > 0, true);
    });

    test('Rise set test', () {
      expect(altair.localRiseSetTimes[0] > 0, true);

      expect(altair.localRiseSetTimes[0] > 0, true);

      expect(polaris.localRiseSetTimes[0] == 0, true);
    });
  });
}
