import 'package:get/get.dart';

import '../controllers/index.dart';

class ClinicalRecordAppointmentDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClinicalRecordAppointmentDetailController>(
      () => ClinicalRecordAppointmentDetailController(),
    );
  }
}
