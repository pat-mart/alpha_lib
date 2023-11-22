import 'package:alpha_lib/alpha_lib.dart';
import 'package:alpha_lib/src/deep_sky.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {


    setUp(() {

    });

    test('Alt Az deep sky test', () {

      DeepSky andromeda = DeepSky(latitude: 40.8, longitude: -73.1, raRad: 0.0127991, decRad: 0.7226487, time: DateTime.timestamp());

      print(andromeda.gmtMeanSiderealHours);

      expect(andromeda.altAz[1] > 0, true);
    });
  });
}
