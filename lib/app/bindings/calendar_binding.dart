import 'package:get/get.dart';
import '../controllers/index.dart';

class CalendarBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarController>(() => CalendarController());
  }
}
