import 'dart:math';

import 'package:alpha_lib/src/units.dart';

import '../alpha_lib.dart';

class DeepSky extends SkyObject {

  bool neverSets = false;
  bool neverRises = false;

  DeepSky({required super.latitude, required super.longitude, required super.raRad, required super.decRad, required super.time, super.utcOffset = 0, super.maxAz = -1, super.minAlt = -1, super.minAz = -1});

  /// Returns [alt, az] (radians)
  List<double>  get altAz {

    // tan Az = sin(hour angle) / (cos(ha)sin(lat) - tan(dec)cos(lat)
    // sin Alt = sin(lat)sin(dec) + cos(lat)cos(ha)

    final latRad = latitude.toRadians(Units.degrees);

    var az = atan2(sin(localHourAngleRad), (cos(localHourAngleRad) * sin(latRad)) - (tan(decRad) * cos(latRad)));

    final alt = asin(sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(localHourAngleRad));

    if (az < 0) az = pi + az;

    return [alt, az];
  }

  /// Returns times within filters in radians or [-1, -1] if never within all filters
  List<double> get withinFilters {

  }

  /// Returns [rise, set] in radians, [-1, -1] if object never rises, [0, 0] if object never sets
  List<double> get utcRiseSetTimes {

    //Checks if obj is always above horizon
    if((decRad - latitude.toRadians(Units.degrees)).abs() > (pi/2)){
      neverRises = true;
      neverSets = true;
      return [-1, -1];
    }

    else if((decRad + latitude.toRadians(Units.degrees)).abs() > (pi/2)){
      neverRises = true;
      neverSets = true;
      return [0, 0];
    }

    // ra - arccos(-tan(dec)tan(latitude))
    final riseTimeRad = raRad - acos(-tan(decRad) * tan(latitude.toRadians(Units.degrees)));

    // ra + arccos(-tan(dec)tan(latitude))
    final setTimeRad = -riseTimeRad + (2 * raRad);

    return [riseTimeRad + utcOffset.toRadians(Units.hours), setTimeRad + utcOffset.toRadians(Units.hours)];
  }

  /// Returns [rise, set] in radians, [-1, -1] if object never rises, [0, 0] if object never sets
  List<double> get localRiseSetTimes {

    if(utcRiseSetTimes[0] != 0 && utcRiseSetTimes[0] != -1){
      return [utcRiseSetTimes[0] + utcOffset.toRadians(Units.hours), utcRiseSetTimes[1] + utcOffset.toRadians(Units.hours)];
    }

    return utcRiseSetTimes;
  }

}