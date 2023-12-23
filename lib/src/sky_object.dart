import 'dart:math';

import 'package:alpha_lib/src/deep_sky.dart';
import 'package:alpha_lib/src/units.dart';

/// This class contains some useful methods and attributes shared by its child class [DeepSky].
/// There was originally going to be another child class dealing with heliocentric objects, but the ephemeris package I was planning to use is not suitable for production yet.
/// Most of the methods in this class use formulas provided by the [United States Navy Astronomical Applications Department](https://aa.usno.navy.mil).
abstract class SkyObject {
  double latitude = 0;

  double longitude = 0;

  double raRad = 0;

  double decRad = 0;

  double minAz = -1;

  double maxAz = -1;

  double minAlt = -1;

  double utcOffset = 0;

  DateTime time = DateTime.timestamp();

  /// [latitude] of observer in degrees <br>
  /// [longitude] of observer in degrees  <br>
  /// [raRad] right ascension of the object in radians <br>
  /// [decRad] declination of the object in radians <br>
  /// [minAz] minimum azimuth filter in degrees, -1 by default <br>
  /// [maxAz] maximum azimuth filter in degrees, -1 by default <br>
  /// [minAlt] minimum altitude filter in degrees, -1 by default <br>
  /// [time] of observation in UTC.
  /// The altitude and azimuth filters can be used to indicate the times an object is within a certain azimuth range or above a certain altitude.
  SkyObject({required this.latitude, required this.longitude, required this.raRad, required this.decRad, this.minAz = -1,
      this.maxAz = -1, this.minAlt = -1, this.utcOffset = 0, required this.time});

  SkyObject.helio({required this.latitude, required this.longitude, this.minAz = -1,
    this.maxAz = -1, this.minAlt = -1, this.utcOffset = 0, required this.time});

  /// GMT hour angle (UTC sidereal time - right ascension) of object in radians
  double gmtHourAngleRad([hoursSinceMidnight = 0.0]) {
    return (gmtMeanSiderealHour(hoursSinceMidnight) * 0.2618) - raRad;
  }

  /// The Equation of Time returns the difference between apparent and mean solar time in minutes
  double get eot {
    final dayOfYear = time.difference(DateTime(time.year, 1, 1)).inDays.toDouble().round();

    final D = 6.24004077 + 0.01720197 * (365.25 * (time.year - 2000) + dayOfYear);

    return -7.659 * sin(D) + 9.863 * sin(2 * D + 3.592);
  }

  /// Returns the local sunrise and sunset times in radians
  /// Returns [[0.0, 0.0]] if the Sun never sets and [[-1, -1]] if the sun never rises
  /// For local sunrise and sunset times, convert to hours and add [utcOffset]
  /// [zenithAngle] is 89.33° by default. Use 104° to find sunrise/sunset astronomical twilight, or a different angle depending on your needs.
  List<double> sunriseSunset([double zenithAngle = 89.33])  {

    int dayOfYear = time.difference(DateTime(time.year, 1, 1).toUtc()).inDays.toDouble().round();

    final solarDecl = -23.45.toRadians(Units.degrees) * cos((360/365 * (dayOfYear + 10)).toRadians(Units.degrees));

    final circumpolarTest = (cos(pi/2) - (sin(solarDecl) * sin(latitude.toRadians(Units.degrees)))) / (cos(solarDecl) * cos(latitude.toRadians(Units.degrees)));

    if(circumpolarTest < -1){
      return [0.0, 0.0];
    }
    else if(circumpolarTest > 1){
      return [-1, -1];
    }

    // ha = +- arccos ( (cos(zenith angle) / cos(lat)cos(decl)) -  tan(lat)tan(decl)
    final sunriseHa = acos(
        (
            cos(89.133.toRadians(Units.degrees)) /
                ( cos(latitude.toRadians(Units.degrees)) * cos(solarDecl) )
        ) - (tan(latitude.toRadians(Units.degrees) * tan(solarDecl))) );

    final sunsetHa = -sunriseHa;

    final sunriseTime = (720 - 4 * (longitude + sunriseHa.toDegrees(Units.radians)) - eot + (utcOffset * 60)) / 60;

    final sunsetTime = (720 - 4 * (longitude + sunsetHa.toDegrees(Units.radians)) - eot + (utcOffset * 60)) / 60;

    return [sunriseTime.toRadians(Units.hours), sunsetTime.toRadians(Units.hours)];
  }

  /// The mean sidereal time represented in hours. For the local sidereal time, add [utcOffset] or use [localSiderealHours]
  double gmtMeanSiderealHour([hoursSinceMidnight = 0.0]) {
    final julianDayUtc = julianDay(true) - 2451545;

    final hoursElapsed = hoursSinceMidnight == 0 ? time.toUtc().hour : hoursSinceMidnight;

    final numCenturies = julianDayUtc / 36525;

    final gmstHours = (6.697375 + (0.065709824279 * julianDayUtc) + (1.0027379 * hoursElapsed) + (0.0854103 * numCenturies)) % 24;

    return gmstHours;
  }

  /// Gets the local time (hour) from the local sidereal time at the same location
  double localTimeFromSidereal(double sidereal){

    var localHour = time.hour + (time.minute / 60) + (time.second / 3600);

    if(localHour > 24){
      localHour -= 24;
    }
    else if(localHour < 0){
      localHour += 24;
    }

    final localTime = localHour + utcOffset + (sidereal - (localSiderealHour(localHour)) / 1.0027379);

    return localTime;
  }


  double localSiderealHour([hoursSinceMidnight = 0.0]) {
    if(gmtMeanSiderealHour(hoursSinceMidnight) + utcOffset < 0){
      return (gmtMeanSiderealHour(hoursSinceMidnight) + utcOffset) + 24;
    }
    return gmtMeanSiderealHour(hoursSinceMidnight) + utcOffset;
  }

  /// Local hour angle (local sidereal time - right ascension) in radians
  double localHourAngleRad([hoursSinceMidnight = 0.0]) {
    return localSiderealHour(hoursSinceMidnight).toRadians(Units.hours) - raRad;
  }

  /// Returns the Julian calendar day of [this.time] in UTC
  double julianDay([bool midnightBefore = false, bool local = false]) {
    var year = time.year;

    var month = time.month;

    var day = time.day;

    var gmtH = time.hour + (local ? utcOffset : 0);

    if (midnightBefore) {
      DateTime dt = time.toUtc();

      final double hour = dt.hour + (local ? utcOffset : 0);

      final minute = dt.minute + ((hour - hour.floor()) * 60).floor();

      final second = dt.second;

      final millis = dt.millisecond;

      final micros = dt.microsecond;

      dt.subtract(Duration(
          hours: hour.floor(),
          minutes: minute,
          seconds: second,
          milliseconds: millis,
          microseconds: micros));

      year = dt.year;

      month = dt.month;

      day = dt.day;

      gmtH = dt.hour;
    }

    final julianDay = (367 * year) - ((7 * (year + (month + 9) / 12)) / 4) + (275 * month / 9) + day + 1721013.5 + gmtH / 24;

    return julianDay;
  }
}

extension Times on List<double> {

  List<double> get correctTimes {
    if(length > 0){
      for(int i = 0; i < length; i++){
        if(this[i] > 24){
          this[i] -= 24;
        }
        else if(this[i] < 0){
          this[i] += 24;
        }
      }
    }
    return this;
  }
}
