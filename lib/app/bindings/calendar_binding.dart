import 'package:get/get.dart';
import '../controllers/index.dart';

class CalendarBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CalendarController>()) {
      Get.lazyPut<CalendarController>(() => CalendarController());
    }
  }
}
