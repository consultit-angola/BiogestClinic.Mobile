import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/index.dart';
import '../../routes/index.dart';
import '../index.dart';

Widget customMenu() {
  final menuController = Get.put(CustomMenuController());

  return Positioned(
    bottom: 0,
    left: -Get.width * 0.06,
    child: Obx(
      () => Container(
        height: Get.height * 0.08,
        width: Get.width * 1.15,
        decoration: BoxDecoration(
          color: CustomColors.primaryLightColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(80)),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
        child: Row(
          children: [
            Expanded(
              child: menuButton(
                icon: Icons.home,
                pendingNotifCount: 0,
                pos: 0,
                isSelected: menuController.selectedPosItem.value == 0,
                onTap: () {
                  menuController.selectItem(0);
                  Get.toNamed(Routes.home);
                },
              ),
            ),
            Expanded(
              child: menuButton(
                icon: Icons.chat,
                pendingNotifCount:
                    menuController.globalController.pendingMessages.value,
                pos: 0,
                isSelected: menuController.selectedPosItem.value == 1,
                onTap: () {
                  menuController.selectItem(1);
                  Get.toNamed(Routes.chat);
                },
              ),
            ),
            Expanded(
              child: menuButton(
                icon: Icons.calendar_month,
                pendingNotifCount:
                    menuController.globalController.pendingCalendar.value,
                pos: 1,
                isSelected: menuController.selectedPosItem.value == 2,
                onTap: () {
                  menuController.selectItem(2);
                  Get.toNamed(Routes.calendar);
                },
              ),
            ),
            Expanded(
              child: menuButton(
                icon: Icons.notifications_active,
                pendingNotifCount:
                    menuController.globalController.pendingAlarms.value,
                pos: 2,
                isSelected: menuController.selectedPosItem.value == 3,
                onTap: () {
                  menuController.selectItem(3);
                  Get.toNamed(Routes.alarm);
                },
              ),
            ),
            Expanded(
              child: menuButton(
                icon: Icons.groups,
                pendingNotifCount:
                    menuController.globalController.pendingActivities.value,
                pos: 3,
                isSelected: menuController.selectedPosItem.value == 4,
                onTap: () {
                  menuController.selectItem(4);
                  Get.toNamed(Routes.activities);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget menuButton({
  required IconData icon,
  required int pendingNotifCount,
  required int pos,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Center(
    child: GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            size: Get.width * 0.1,
            color: isSelected
                ? CustomColors.witheColor
                : CustomColors.primaryColor,
          ),
          if (pendingNotifCount != 0)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                height: Get.width * 0.05,
                width: Get.width * 0.05,
                decoration: BoxDecoration(
                  color: CustomColors.tertiaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    pendingNotifCount.toString(),
                    style: TextStyle(
                      color: CustomColors.witheColor,
                      fontWeight: FontWeight.bold,
                      fontSize: Get.width * 0.025,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
