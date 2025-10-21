import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/shared/index.dart';
import '../routes/app_routes.dart';

class GlobalController extends GetxController {
  static GlobalController get to => Get.find<GlobalController>();

  RxBool isAuthenticated = false.obs;
  final Rxn<UserInfoDTO> user = Rxn<UserInfoDTO>();

  // @override
  // void onInit() {
  //   super.onInit();

  // }

  void signOut() async {
    Preferences().clear();
    Get.offAllNamed(Routes.home);
  }
}
