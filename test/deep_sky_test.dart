import 'dart:math';

import 'package:alpha_lib/alpha_lib.dart';
import 'package:test/test.dart';

void main() {
  group('Tests for DeepSky class', () {

    DeepSky vega = DeepSky(latitude: 40.8, longitude: -73.12, raRad: 4.832, decRad: 0.67718, time: DateTime.timestamp(), utcOffset: 0, maxAz: 300, minAlt: 20);
    DeepSky orion = DeepSky(latitude: -80.8, longitude: -73.12, raRad: 5.5.toRadians(Units.hours), decRad: -5.1.toRadians(Units.degrees), time: DateTime.timestamp(), utcOffset: -5, minAlt: 30);

    DeepSky altair = DeepSky(latitude: 40.5, longitude: -73.1, raRad: (19.916.toRadians(Units.hours)), decRad: 0.1559, time: DateTime.timestamp(), utcOffset: 0, minAz: 100, maxAz: 350, minAlt: 40);

    DeepSky vegaCircumpolar = DeepSky(latitude: -88.5, longitude: -73.1, raRad: 4.832, decRad: 0.67718, time: DateTime.timestamp(), utcOffset: -5, minAz: 200, maxAz: 300);
    DeepSky altairCircumpolar = DeepSky(latitude: 88.5, longitude: -73.1, raRad: 4.98, decRad: 0.1559, time: DateTime.timestamp(), utcOffset: -5, minAz: 100, maxAz: 350, minAlt: 40);

    DeepSky polaris = DeepSky(latitude: 40.5, longitude: -73.1, raRad: 0.79, decRad: pi/2, time: DateTime.timestamp(), utcOffset: 0);

    DeepSky scheatChile = DeepSky(latitude: -40.5, longitude: -73.5, raRad: (23.0167).toRadians(Units.hours), decRad: (28.21).toRadians(Units.degrees), time: DateTime.timestamp());

    setUp((){
      // print(vega.hoursVisible.normalizedRadianTimes[0].toHours(Units.radians));
      // print(vega.hoursVisible.normalizedRadianTimes[1].toHours(Units.radians));
      //
      // print(vega.timesWithinFilters.normalizedRadianTimes[0].toHours(Units.radians));
      // print(vega.timesWithinFilters.normalizedRadianTimes[1].toHours(Units.radians));
      //

      print(orion.peakInfo['time']!.toHours(Units.radians));
      print(polaris.peakInfo['time']!.toHours(Units.radians));
      //
      // print(scheatChile.peakInfo['time']!.toHours(Units.radians));
    });

    test('Circumpolar sunrise/set test', () {
      expect(altairCircumpolar.sunriseSunset()[0] == -1, true);

      expect(vegaCircumpolar.sunriseSunset()[0] == 0, true);
    });

    test('Hunting unexpected errors', () {
      altairCircumpolar.hoursSuggested;
      vegaCircumpolar.hoursSuggested;

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
