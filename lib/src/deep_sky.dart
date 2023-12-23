import 'dart:math';

import 'package:alpha_lib/src/units.dart';

import '../alpha_lib.dart';

class DeepSky extends SkyObject {

  bool neverSets = false;
  bool neverRises = false;

  /// See [SkyObject] for constructor parameter information
  DeepSky({required super.latitude, required super.longitude, required super.raRad, required super.decRad, required super.time, super.utcOffset = 0, super.maxAz = -1, super.minAlt = -1, super.minAz = -1});

  /// Returns [alt, az] (radians)
  List<double>  get altAz {

    final latRad = latitude.toRadians(Units.degrees);

    final alt = asin(sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(localHourAngleRad(time.hour)));

    var az = atan2(sin(localHourAngleRad(time.hour)), (cos(localHourAngleRad(time.hour)) * sin(latRad)) - (tan(decRad) * cos(latRad)));

    az -= pi;

    if(az < 0){
      az += (2 * pi);
    }

    return [alt, az];
  }

  /// Returns local times the object is within filters [(minAlt, minAz, maxAz)] in radians or [-1, -1] if never within all filters
  /// Reference point is the day of the plan starting
  List<double> get timesWithinFilters {

    // not sure if there is a way to solve for a specific azimuth as a function of hour angle so taking brute force approach
    // since brute forcing azimuth already, sort of? makes sense to determine altitude times as well
    // although there is a simple way to determine altitude times in constant time
    // improvement suggestions obviously appreciated

    List<double> hours = [25, -1];

    final month = DateTime.timestamp().month;

    final year = DateTime.timestamp().year;

    final day = DateTime.timestamp().day;

    time = DateTime(year, month, day).toUtc();

    for(int i = 0; i < 360; i++){

      time = time.add(Duration(minutes: 4));

      if(altAz[1].toDegrees(Units.radians) > minAz && altAz[1].toDegrees(Units.radians) < (maxAz == -1 ? 360 : maxAz)
          && altAz[0].toDegrees(Units.radians) > (minAlt == -1 ? 0 : minAlt)){

        if(hours[0] >= i/15){
          hours[0] = i/15;
        }

        if(hours[1] <= i/15){
          hours[1] = i/15;
        }
      }
    }

    if(hours[0] == 25){
      return [-1, -1];
    }

    hours[0] = hours[0].toRadians(Units.hours);
    hours[1] = hours[1].toRadians(Units.hours);

    return hours;
  }

  /// Returns the hours an object is observable, meaning it is in a sufficiently dark sky.
  List<double> get hoursVisible {

    if(sunriseSunset(104)[0].isNaN){
      return [-1, -1];
    }
    final morningTwi = sunriseSunset(104)[0];
    final evenTwi = sunriseSunset(104)[1];

    final objRise = localRiseSetTimes[0];
    final objSet = localRiseSetTimes[1];

    // Not going to explain the logic behind these
    // They should work and I don't believe any are extraneous
    // I also don't believe any cases are missing, but I could easily be wrong
    if (morningTwi <= objRise && objRise <= objSet && objSet <= evenTwi){
      return [-1, -1];
    }
    else if(objSet <= objRise && objRise <= morningTwi){ // I am not sure if this is possible.
      return [objRise, morningTwi, evenTwi, objSet];
    }
    else if(objRise <= morningTwi && objSet <= evenTwi){
      return [objRise, morningTwi];
    }
    else if(evenTwi >= objRise && objRise >= morningTwi && morningTwi >= objSet){
      return [evenTwi, objSet];
    }
    else if(objRise >= evenTwi && objSet <= morningTwi){
      return [objRise, objSet];
    }
    else if(objRise >= evenTwi && objSet >= morningTwi){
      return [objRise, morningTwi];
    }
    else if(objRise <= evenTwi && objSet >= morningTwi){
      return [evenTwi, morningTwi];
    }
    return [-1, -1];
  }

  /// Returns a map with keys 'az', 'alt', 'time' (all -1 if object never rises)
  /// Time is local and az, alt are in radians
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

    return {'az': coords[1], 'alt': coords[0], 'time': peakHour.toRadians(Units.hours)};
  }



  /// Returns [[rise, set]] in radians, [[-1, -1]] if object never rises, [[0, 0]] if object never sets
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


  /// Like a combination of [hoursVisible] and [timesWithinFilters], indicates the local hours which an object is observable and within filters
  List<double> get suggestedHours {
    if(timesWithinFilters[0] == -1 || hoursVisible[0] == -1){
      final start = [hoursVisible[0], timesWithinFilters[0]].reduce(min);
      final end = [hoursVisible[1], timesWithinFilters[1]].reduce(min);

      return [start, end];
    }
    return [-1, -1];
  }

  /// Returns [rise, set] in radians, [-1, -1] if object never rises, [0, 0] if object never sets
  List<double> get utcRiseSetTimes {

    if(localRiseSetTimes[0] != 0 && localRiseSetTimes[0] != -1){
      return [localRiseSetTimes[0] - utcOffset.toRadians(Units.hours), localRiseSetTimes[1] - utcOffset.toRadians(Units.hours)];
    }

    return localRiseSetTimes;
  }
}