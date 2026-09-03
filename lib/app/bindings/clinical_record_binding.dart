import 'package:get/get.dart';

import '../controllers/index.dart';

class ClinicalRecordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClinicalRecordController>(() => ClinicalRecordController());
  }
}
