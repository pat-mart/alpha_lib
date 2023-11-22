import 'dart:math';

import 'package:alpha_lib/src/units.dart';

import '../alpha_lib.dart';

class DeepSky extends SkyObject {


  DeepSky({required super.latitude, required super.longitude, required super.raRad, required super.decRad, required super.time, super.utcOffset = 0, super.maxAz = -1, super.minAlt = -1, super.minAz = -1});


  /// Returns [alt, az] (radians)
  List<double>  get altAz {

    // tan Az = sin(hour angle) / (cos(ha)sin(lat) - tan(dec)cos(lat)
    // sin Alt = sin(lat)sin(dec) + cos(lat)cos(ha)

    final latRad = latitude.toRadians(Units.degrees);

    final az = atan2(sin(localHourAngleRad), (cos(localHourAngleRad) * sin(latRad)) - (tan(decRad) * cos(latRad)));

    final alt = asin(sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(localHourAngleRad));

    return [alt, az];
  }
}