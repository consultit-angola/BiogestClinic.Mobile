import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
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
  final RxList<UserDTO> users = <UserDTO>[].obs;
  RxMap<int, List<MessageDTO>> messages = <int, List<MessageDTO>>{}.obs;
  final RxList<NeatCleanCalendarEvent> eventList =
      <NeatCleanCalendarEvent>[].obs;
  var pendingMessages = 0.obs;
  var pendingCalendar = 0.obs;
  var pendingAlarms = 0.obs;
  var pendingActivities = 0.obs;

  var isCalendarControllerLoaded = false;
  var isChatControllerLoaded = false;

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
