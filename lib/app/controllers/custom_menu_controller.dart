import 'package:get/get.dart';

import 'index.dart';

class CustomMenuController extends GetxController {
  static CustomMenuController get to => Get.find<CustomMenuController>();
  final globalController = GlobalController.to;

  var selectedPosItem = 0.obs;

  void selectItem(int index) {
    selectedPosItem.value = index;
  }
}
