import 'package:get/get.dart';

import '../controllers/index.dart';

class AppointmentCreateBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentCreateController>(
      () => AppointmentCreateController(),
    );
  }
}
