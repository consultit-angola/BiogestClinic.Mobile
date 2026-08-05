import 'package:get/get.dart';
import '../controllers/index.dart';

class ChatBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatController>()) {
      Get.lazyPut<ChatController>(() => ChatController());
    }
  }
}
