import 'dart:math';

import 'package:alpha_lib/src/units.dart';

import '../alpha_lib.dart';

class DeepSky extends SkyObject {

  bool neverSets = false;
  bool neverRises = false;

  DeepSky({required super.latitude, required super.longitude, required super.raRad, required super.decRad, required super.time, super.utcOffset = 0, super.maxAz = -1, super.minAlt = -1, super.minAz = -1});

  /// Returns [alt, az] (radians)
  List<double>  get altAz {

    final latRad = latitude.toRadians(Units.degrees);

    final alt = asin(sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(localHourAngleRad(time.hour)));

    var az = atan2(sin(localHourAngleRad(time.hour)), (cos(localHourAngleRad(time.hour)) * sin(latRad)) - (tan(decRad) * cos(latRad)) );

    az -= pi;

    if(az < 0){
      az += (2 * pi);
    }

    return [alt, az];
  }

  /// Returns local times within filters in radians or [-1, -1] if never within all filters
  /// Reference point is the day of the plan starting
  List<double> get withinFilters {

    // not sure if there is a way to solve for a specific azimuth as a function of hour angle so taking brute force approach
    // since brute forcing azimuth already, sort of? makes sense to do altitude as well
    // improvement suggestions obviously appreciated

    List<double> azHours = [25, -1];

    var tempTime = time;

    var month = DateTime.timestamp().month;

    var year = DateTime.timestamp().year;

    var day = DateTime.timestamp().day;

    time = DateTime(year, month, day).toUtc();

    for(int i = 0; i < 360; i++){

      time = time.add(Duration(minutes: 4));

      if(altAz[1].toDegrees(Units.radians) > minAz && altAz[1].toDegrees(Units.radians) < (maxAz == -1 ? 360 : maxAz)
          && altAz[0] > (minAlt == -1 ? 0 : minAlt)){

        if(azHours[0] >= i/15){
          azHours[0] = i/15;
        }

        if(azHours[1] <= i/15){
          azHours[1] = i/15;
        }
      }
    }

    time = tempTime;

    return azHours;
  }

  /// Returns a map with keys 'az', 'alt', 'time'
  Map<String, double> get peakInfo {
    if(localRiseSetTimes[0] == -1){
      return {'az': -1, 'alt': -1, 'time': -1};
    }

    double peakHour = raRad * 3.8197186342;

    peakHour = localTimeFromSidereal(peakHour);

    int peakHourRounded = peakHour.floor();

    double peakMinute = ((peakHour % peakHourRounded) * 60);
    int peakMinuteRounded = peakMinute.floor();

    int peakSecondRounded = ((peakMinute % peakMinuteRounded) * 60).floor();

    final utcHours = utcOffset.floor();
    final utcMinutes = (utcHours % utcOffset * 60).floor();

    //This undoes the localization of the peak hour function
    DateTime newTime = DateTime.utc(time.year, time.month, time.day, peakHourRounded, peakMinuteRounded, peakSecondRounded).subtract(Duration(hours: utcHours, minutes: utcMinutes));

    final temp = time;

    time = newTime;

    final coords = altAz;

    time = temp;

    if(coords[0] < -1){
      return {'az': -1, 'alt': -1, 'time': 0};
    }

    return {'az': coords[1], 'alt': coords[0], 'time': peakHour};
  }



  /// Returns [rise, set] in radians, [-1, -1] if object never rises, [0, 0] if object never sets
  List<double> get localRiseSetTimes {

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
  List<double> get utcRiseSetTimes {

    if(localRiseSetTimes[0] != 0 && localRiseSetTimes[0] != -1){
      return [localRiseSetTimes[0] - utcOffset.toRadians(Units.hours), localRiseSetTimes[1] - utcOffset.toRadians(Units.hours)];
    }

    return localRiseSetTimes;
  }

}