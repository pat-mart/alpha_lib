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
      return this / 15;
    }
    if(from == Units.radians){
      return this * (12 / pi);
    }
    return this;
  }
}

extension Times on List<double> {
  List<double> get normalizedRadianTimes {
    if(contains(-1)){
      return [-1, -1];
    }
    for(int i = 0; i < length; i++){
      if(this[i] > 24.0.toRadians(Units.hours)){
        this[i] -= (24.0.toRadians(Units.hours));
      }
      if(this[i] < 0){
        this[i] += 24.0.toRadians(Units.hours);
      }
    }
    return this;
  }
}
