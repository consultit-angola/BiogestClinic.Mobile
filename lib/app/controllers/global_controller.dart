import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/shared/index.dart';
import '../routes/app_routes.dart';

class GlobalController extends GetxController {
  static GlobalController get to => Get.find<GlobalController>();

  RxBool isAuthenticated = false.obs;
  final Rxn<UserInfoDTO> user = Rxn<UserInfoDTO>();
  final Provider _provider = Provider();

  // @override
  // void onInit() {
  //   super.onInit();

  // }

  void logout() async {
    try {
      EasyLoading.show();
      Map<String, dynamic> resp = await _provider.logout();
      if (resp['ok']) {
        user.value = null;
        isAuthenticated.value = false;
        EasyLoading.dismiss();
        Preferences().clear();
        Get.offAllNamed(Routes.login);
      } else {
        Get.snackbar('Error', resp['message']);
      }
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      Get.snackbar('Error', '$error');
    }
  }
}
