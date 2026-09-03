import 'package:get/get.dart';

import '../controllers/index.dart';

class ClientManagementBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientManagementController>(() => ClientManagementController());
  }
}
