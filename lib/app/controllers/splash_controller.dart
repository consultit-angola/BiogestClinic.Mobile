import 'package:get/get.dart';

import '../data/shared/index.dart';

class SplashController extends GetxController {
  static SplashController get to => Get.find<SplashController>();

  Preferences preferences = Preferences();
}
