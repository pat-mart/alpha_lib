import 'package:alpha_lib/alpha_lib.dart';

import 'package:sweph/sweph.dart';

class Heliocentric extends SkyObject{

  HeavenlyBody object;

  Heliocentric(double latitude, double longitude, DateTime time, this.object) : super.helio(latitude: latitude, longitude: longitude, time: time);

  Future<void> init() async {
    await Future(Sweph.init(epheAssets: ["packages/sweph/assets/ephe/sepl_18.se1", "packages/sweph/assets/ephe/semo_18.se1"])).timeout(Duration(seconds: 10));
  }
}