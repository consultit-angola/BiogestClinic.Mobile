import 'package:get/get.dart';
// import 'package:flutter/material.dart';

import 'index.dart';
// import '../routes/index.dart';

class CustomMenuController extends GetxController {
  static CustomMenuController get to => Get.find<CustomMenuController>();
  final globalController = GlobalController.to;

  var selectedPosItem = 0.obs;

  void selectItem(int index) {
    selectedPosItem.value = index;
  }

  // void openMoreMenu() {
  //   Get.bottomSheet(
  //     SafeArea(
  //       child: Container(
  //         padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Container(
  //               width: 42,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: Colors.black12,
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             ListTile(
  //               leading: const Icon(Icons.chat_bubble_outline),
  //               title: const Text('Chat'),
  //               onTap: () {
  //                 Get.back();
  //                 Get.toNamed(Routes.chat);
  //               },
  //             ),
  //             if (globalController.canAccessAlarms)
  //               ListTile(
  //                 leading: const Icon(Icons.notifications_none),
  //                 title: const Text('Alarmes'),
  //                 onTap: () {
  //                   Get.back();
  //                   Get.toNamed(Routes.alarm);
  //                 },
  //               ),
  //             ListTile(
  //               leading: const Icon(Icons.person_outline),
  //               title: const Text('Utilizador'),
  //               onTap: () {
  //                 Get.back();
  //                 Get.toNamed(Routes.user);
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
