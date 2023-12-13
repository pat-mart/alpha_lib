import 'dart:math';

import 'package:alpha_lib/src/deep_sky.dart';
import 'package:alpha_lib/src/helio.dart';
import 'package:alpha_lib/src/units.dart';


/// This class contains some useful methods and attributes shared by its child classes [DeepSky] and [Helio].
/// The calculation methods in this class use formulas provided by the [United States Navy Astronomical Applications Department.](https://aa.usno.navy.mil)
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
  /// [time] of observation in UTC
  SkyObject({required this.latitude, required this.longitude, required this.raRad, required this.decRad, this.minAz = -1,
      this.maxAz = -1, this.minAlt = -1, this.utcOffset = 0, required this.time});

  /// GMT hour angle (UTC sidereal time - right ascension) in radians
  double gmtHourAngleRad([hoursSinceMidnight = 0.0]) {
    return (gmtMeanSiderealHour(hoursSinceMidnight) * 0.2618) - raRad;
  }

  /// The mean sidereal time represented as hours (in [double] form). For the local sidereal time, subtract or add a UTC offset or use [localSiderealHours]
  double gmtMeanSiderealHour([hoursSinceMidnight = 0.0]) {
    final julianDay = julianDayUtc(true) - 2451545;

    final hoursElapsed = hoursSinceMidnight == 0 ? time.toUtc().hour : hoursSinceMidnight;

    final numCenturies = julianDay / 36525;

    final gmstHours = (6.697375 + (0.065709824279 * julianDay) + (1.0027379 * hoursElapsed) + (0.0854103 * numCenturies)) % 24;

    return gmstHours;
  }

  /// Gets the local time (hour) from a sidereal hour
  double localTimeFromSidereal(double sidereal){

    var localHour = time.hour + (time.minute / 60) + (time.second / 3600);

    if(localHour > 24){
      localHour -= 24;
    }
    else if(localHour < 0){
      localHour += 24;
    }

    print(localSiderealHour(localHour));

    final localTime = localHour + utcOffset + (sidereal - (localSiderealHour(localHour)) / 1.0027379);

    print(localTime);

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

  /// Returns the Julian calendar day of [this.time] in UTC, or the Julian day of
  double julianDayUtc([bool midnightBefore = false]) {
    var year = time.year;

    var month = time.month;

    var day = time.day;

    var gmtH = time.hour;

    if (midnightBefore) {
      DateTime dt = time.toUtc();

      final hour = dt.hour;

      final minute = dt.minute;

      final second = dt.second;

      final millis = dt.millisecond;

      final micros = dt.microsecond;

      dt.subtract(Duration(
          hours: hour,
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

  List<double> get toTimes {
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

extension Radians on double {

  double toRadians(Units from){

    if(from == Units.degrees){
      return this * (pi / 180);
    }
    if (from == Units.hours){
      return this * 15 * (pi / 180);
    }
    return this;
  }

  double toDegrees(Units from){

    if(from == Units.radians){
      return this * (180 / pi);
    }
    if(from == Units.hours){
      return this * 15;
    }
    return this;
  }
}
