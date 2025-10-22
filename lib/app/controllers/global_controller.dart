import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/shared/index.dart';
import '../routes/app_routes.dart';
import 'index.dart';

class GlobalController extends GetxController {
  static GlobalController get to => Get.find<GlobalController>();

  final Provider _provider = Provider();
  RxBool isAuthenticated = false.obs;
  final Rxn<UserDTO> authenticatedUser = Rxn<UserDTO>();
  RxMap<int, List<MessageDTO>> messages = <int, List<MessageDTO>>{}.obs;
  var pendingMessages = 0.obs;
  var pendingCalendar = 0.obs;
  var pendingAlarms = 0.obs;
  var pendingActivities = 0.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  void initControllers() {
    Get.put(HomeController());
    Get.put(ChatController());
    Get.put(AlarmController());
    Get.put(CalendarController());
    Get.put(ActivitiesController());
  }

  void getMessages({silenceLoad = false}) async {
    try {
      messages.clear();
      if (!silenceLoad) {
        EasyLoading.show();
      }

      Map<String, dynamic> resp = await _provider.getMessages(
        userID: authenticatedUser.value!.id,
      );
      if (resp['ok']) {
        var auxMessages = resp['data'] as List<MessageDTO>;
        for (var message in auxMessages) {
          if (messages.containsKey(message.destinationUserID)) {
            messages[message.destinationUserID]!.add(message);
            messages.refresh();
          } else {
            messages[message.destinationUserID] = [message];
          }
        }
        pendingMessages.value = auxMessages.length <= 99
            ? auxMessages.length
            : 99;
        EasyLoading.dismiss();
      } else {
        if (!silenceLoad) {
          Get.snackbar('Error', resp['message']);
        }
      }
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      if (!silenceLoad) {
        Get.snackbar('Error', '$error');
      }
    }
  }

  void logout() async {
    try {
      EasyLoading.show();
      Map<String, dynamic> resp = await _provider.logout();
      if (resp['ok']) {
        authenticatedUser.value = null;
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
