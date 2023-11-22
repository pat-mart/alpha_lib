import 'dart:math';

import '../alpha_lib.dart';

class DeepSky extends SkyObject {


  DeepSky({required super.latitude, required super.longitude, required super.raRad, required super.decRad, required super.time, super.utcOffset = 0, super.maxAz = -1, super.minAlt = -1, super.minAz = -1});


  /// Returns [alt, az] (radians)
  List<double>  get altAz {

    // tan Az = sin(hour angle) / (cos(ha)sin(lat) - tan(dec)cos(lat)
    // sin Alt = sin(lat)sin(dec) + cos(lat)cos(ha)

    var az = atan2(sin(gmtHourAngleRad), (cos(gmtHourAngleRad) * sin(latitude)) - (tan(decRad) * cos(latitude)));

    var alt = asin(sin(latitude) * sin(decRad) + cos(latitude) * cos(decRad) * cos(gmtHourAngleRad));

    return [alt, az];
  }
}