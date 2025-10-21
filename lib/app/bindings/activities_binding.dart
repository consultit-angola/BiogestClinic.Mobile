import 'package:get/get.dart';
import '../controllers/index.dart';

class ActivitiesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivitiesController>(() => ActivitiesController());
  }
}
