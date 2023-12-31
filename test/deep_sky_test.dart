import 'dart:math';

import 'package:alpha_lib/alpha_lib.dart';
import 'package:test/test.dart';

void main() {
  group('Tests for DeepSky class', () {

    DeepSky vega = DeepSky(latitude: 40.5, longitude: -73.1, raRad: 4.832, decRad: 0.67718, time: DateTime.timestamp(), utcOffset: 0, minAz: 200, maxAz: 300);

    DeepSky altair = DeepSky(latitude: 40.5, longitude: -73.1, raRad: 4.98, decRad: 0.1559, time: DateTime.timestamp(), utcOffset: 0, minAz: 100, maxAz: 350, minAlt: 40);

    DeepSky vegaCircumpolar = DeepSky(latitude: -88.5, longitude: -73.1, raRad: 4.832, decRad: 0.67718, time: DateTime.timestamp(), utcOffset: -5, minAz: 200, maxAz: 300);
    DeepSky altairCircumpolar = DeepSky(latitude: 88.5, longitude: -73.1, raRad: 4.98, decRad: 0.1559, time: DateTime.timestamp(), utcOffset: -5, minAz: 100, maxAz: 350, minAlt: 40);

    DeepSky polaris = DeepSky(latitude: 40.5, longitude: -73.1, raRad: 0.79, decRad: pi/2, time: DateTime.timestamp(), utcOffset: 0);

    setUp((){});

    test('Circumpolar sunrise/set test', () {
      expect(altairCircumpolar.sunriseSunset()[0] == -1, true);

      expect(vegaCircumpolar.sunriseSunset()[0] == 0, true);
    });

    test('Hunting unexpected errors', () {
      altairCircumpolar.suggestedHours;
      vegaCircumpolar.suggestedHours;

      altairCircumpolar.sunriseSunset();
      vegaCircumpolar.sunriseSunset();

      altairCircumpolar.sunriseSunset(104);
      vegaCircumpolar.sunriseSunset(104);

      altairCircumpolar.altAz;
      vegaCircumpolar.altAz;
    });

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
