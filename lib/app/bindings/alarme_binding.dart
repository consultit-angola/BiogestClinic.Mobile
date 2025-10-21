import 'package:get/get.dart';
import '../controllers/index.dart';

class AlarmeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlarmeController>(() => AlarmeController());
  }
}
