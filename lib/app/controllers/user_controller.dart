import 'package:get/get.dart';

import 'index.dart';

class UserController extends GetxController {
  static UserController get to => Get.find<UserController>();
  final globalController = GlobalController.to;
}
