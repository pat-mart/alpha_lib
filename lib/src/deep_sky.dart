import 'dart:math';

import '../alpha_lib.dart';

class DeepSky extends SkyObject {

  bool neverSets = false;
  bool neverRises = false;

  /// See [SkyObject] for constructor parameter information
  DeepSky({required super.latitude, required super.longitude, required super.raRad, required super.decRad, required super.time, super.utcOffset = 0, super.maxAz = -1, super.minAlt = -1, super.minAz = -1});

  /// Returns [alt, az] (radians)
  List<double>  get altAz {

    final hourAngle = gmtMeanSiderealHour(time.hour).toRadians(Units.hours) + longitude.toRadians(Units.degrees) - raRad;

    final latRad = latitude.toRadians(Units.degrees);

    final alt = asin(sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(hourAngle));

    var az = atan2(sin(hourAngle), (cos(hourAngle) * sin(latRad)) - (tan(decRad) * cos(latRad)));

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

    if(localRiseSetTimes.normalizedRadianTimes.contains(-1)){
      return [-1, -1];
    }

    List<double> hours = [99999, 99999];

    final month = DateTime.timestamp().month;

    final year = DateTime.timestamp().year;

    final day = DateTime.timestamp().day;

    var startHour = 0;

    var end = 360;

    var normalizedRiseSet = localRiseSetTimes.normalizedRadianTimes;

    if(normalizedRiseSet != [0, 0]){
      startHour = normalizedRiseSet[0].toHours(Units.radians).floor();
      var endHour = normalizedRiseSet[1].toHours(Units.radians).floor();

      end = (endHour - startHour).abs() * 15;
    }

    time = DateTime.utc(year, month, day, startHour);

    for(int i = 0; i < end; i++){

      time = time.add(Duration(minutes: 4));

      if(altAz[1].toDegrees(Units.radians) > minAz && altAz[1].toDegrees(Units.radians) < (maxAz == -1 ? 360 : maxAz)
          && altAz[0].toDegrees(Units.radians) > (minAlt == -1 ? 0 : minAlt)){

        if(hours[0] == 99999){
          hours[0] = time.hour + (time.minute / 60) + (time.second / 3600);
        }

        else {
          hours[1] = time.hour + (time.minute / 60) + (time.second / 3600);
        }
      }
    }

    if(hours.contains(99999)){
      return [-1, -1];
    }

    hours[0] = hours[0].toRadians(Units.hours);
    hours[1] = hours[1].toRadians(Units.hours);

    return hours;
  }

  /// Returns the local hours an object is observable, meaning it is in a sufficiently dark sky.
  /// [[-1, -1]] if the object is never visible and [[0, 0]] if it is always observable.
  List<double> get hoursVisible {

    if(sunriseSunset(104)[0].isNaN || sunriseSunset().contains(0.0)){
      return [-1, -1];
    }
    final morningTwi = sunriseSunset(104)[0];
    final evenTwi = sunriseSunset(104)[1];

    final objRise = localRiseSetTimes[0];
    final objSet = localRiseSetTimes[1];

    if(localRiseSetTimes[0] == 0 && localRiseSetTimes[1] == 0 && !sunriseSunset(104).contains(-1.0)){
      return sunriseSunset(104);
    }

    if(morningTwi == -1 && evenTwi == -1){
      if(localRiseSetTimes[0] == 0 && localRiseSetTimes[1] == 0){
        return [0, 0];
      }
      return localRiseSetTimes;
    }

    // FIXME the returned array on one of these sometimes has to be switched
    if (morningTwi <= objRise && objRise <= objSet && objSet <= evenTwi) {
      return [-1, -1];
    }

    else if(objSet <= objRise && objRise <= morningTwi) { // Not sure if this is possible
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
    else if(objRise <= evenTwi && objSet >= morningTwi && objSet >= evenTwi){
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

    // From Astronomical Algorithms (1991) by Jean Meeus
    var m0 = (raRad.toDegrees(Units.radians) - longitude - gmtMeanSiderealHour(0).toDegrees(Units.hours)) / 360;

    if(m0 < 0){
      m0 += 1;
    }
    else if(m0 > 1){
      m0 -= 1;
    }

    var peakHour = (m0 * 24).toRadians(Units.hours);

    if(peakHour >= 24.0.toRadians(Units.hours)){
      peakHour -= 24.0.toRadians(Units.hours);
    }
    else if(peakHour <= 0){
      peakHour += 24.0.toRadians(Units.hours);
    }

    int peakHourRounded = peakHour.toHours(Units.radians).floor();

    double peakMinute = ((peakHour.toHours(Units.radians) - peakHourRounded) * 60);
    int peakMinuteRounded = peakMinute.floor();

    int peakSecondRounded = ((peakMinute - peakMinuteRounded) * 60).floor();

    DateTime newTime = DateTime.utc(time.year, time.month, time.day, peakHourRounded, peakMinuteRounded, peakSecondRounded);

    final temp = time;

    time = newTime;

    final coords = altAz;

    time = temp;

    if(coords[0] < 0){
      return {'az': -1, 'alt': -1, 'time': 0};
    }

    peakHour += utcOffset.toRadians(Units.hours);

    if (peakHour < 0){
      peakHour += 24.0.toRadians(Units.hours);
    }
    else if(peakHour > 24){
      peakHour -= 24.0.toRadians(Units.hours);
    }

    return {'az': coords[1], 'alt': coords[0], 'time': peakHour};
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

  @Deprecated('use hoursSuggested instead; same method but better matches naming convention')
  List<double> get suggestedHours {
    return hoursSuggested;
  }

  /// Like a combination of [hoursVisible] and [timesWithinFilters], indicates the local hours which an object is both observable and the within filters. If no such times exist, [[-1, -1]] is returned
  List<double> get hoursSuggested {

    if(timesWithinFilters[0] == -1 || hoursVisible[0] == -1){
      return [-1.0, -1.0];
    }

    if(hoursVisible == [0, 0]){
      return timesWithinFilters.normalizedRadianTimes;
    }

    final visTimes = hoursVisible.normalizedRadianTimes;
    final filterTimes = timesWithinFilters.normalizedRadianTimes;

    double start = -1;
    double end = -1;

    if(visTimes[0] > visTimes[1]){ // Easiest to visualize these using a number line and paper

      if(filterTimes[0] > visTimes[0] && filterTimes[1] > filterTimes[0]){
        return filterTimes;
      }

      if(filterTimes[0] > filterTimes[1]){
        start = [filterTimes[0], visTimes[0]].reduce(max);
        end = [filterTimes[1], visTimes[1]].reduce(min);

        return [start, end];
      }

      if(filterTimes[0] > visTimes[1]) {
        if(filterTimes[1] < visTimes[0]){
          return [-1, -1];
        }
        return [visTimes[0], filterTimes[1]];
      }

      if(filterTimes[1] < visTimes[0]){
        return filterTimes;
      }

      return [filterTimes[0], visTimes[1]];
    }

    if(filterTimes[0] < filterTimes[1]){
      if(filterTimes[0] > visTimes[1]){
        return [-1, -1];
      }
      start = [filterTimes[0], visTimes[0]].reduce(max);
      end = [filterTimes[1], visTimes[1]].reduce(min);

      return [start, end];
    }

    if(filterTimes[0] > visTimes[1]){
      if(filterTimes[1] < visTimes[0]){
        return [-1, -1];
      }
      return [visTimes[0], filterTimes[1]];
    }

    if(filterTimes[0] > visTimes[0]){
      return [filterTimes[0], visTimes[1]];
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