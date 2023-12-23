import 'dart:math';

enum Units {
  degrees,
  hours,
  radians
}

extension Conversion on double {

  double toRadians(Units from) {
    if (from == Units.degrees) {
      return this * (pi / 180);
    }
    if (from == Units.hours) {
      return this * 15 * (pi / 180);
    }
    return this;
  }

  double toDegrees(Units from) {
    if (from == Units.radians) {
      return this * (180 / pi);
    }
    if (from == Units.hours) {
      return this * 15;
    }
    return this;
  }

  double toHours(Units from){
    if (from == Units.degrees){
      return this * 15;
    }
    if(from == Units.radians){
      return this * (12 / pi);
    }
    return this;
  }
}
