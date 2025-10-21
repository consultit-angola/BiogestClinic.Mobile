import 'package:get/get.dart';

class CustomMenuController extends GetxController {
  static CustomMenuController get to => Get.find<CustomMenuController>();

  var selectedPosItem = 0.obs;

  void selectItem(int index) {
    selectedPosItem.value = index;
  }
}
