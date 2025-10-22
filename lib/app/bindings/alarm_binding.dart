import 'package:get/get.dart';
import '../controllers/index.dart';

class AlarmBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlarmController>(() => AlarmController());
  }
}
