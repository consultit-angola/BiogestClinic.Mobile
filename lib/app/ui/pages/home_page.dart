import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../controllers/index.dart';
import '../../routes/index.dart';
import '../index.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Image.asset(
              'assets/images/background.png',
              width: Get.width,
              height: Get.height,
              fit: BoxFit.fill,
            ),
            Stack(
              children: [
                Column(children: [customAppbar(showSettings: true), doctors()]),
                menu(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget doctors() {
    return SvgPicture.asset(
      'assets/images/dra.svg',
      width: Get.width * 0.5,
      height: Get.height * 0.5,
    );
  }

  Widget menu() {
    return Positioned(
      bottom: 0,
      left: -Get.width * 0.06,
      child: Container(
        height: Get.height * 0.35,
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
        padding: EdgeInsets.all(Get.width * 0.1),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: menuButton(
                      icon: Icons.chat,
                      label: 'Chat',
                      pendingNotifCount: 1,
                      onTap: () {
                        CustomMenuController.to.selectItem(1);
                        Get.toNamed(Routes.chat);
                      },
                    ),
                  ),
                  Expanded(
                    child: menuButton(
                      icon: Icons.calendar_month,
                      label: 'Calendário',
                      pendingNotifCount: 5,
                      onTap: () {
                        CustomMenuController.to.selectItem(2);
                        Get.toNamed(Routes.calendar);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: menuButton(
                      icon: Icons.notifications_active,
                      label: 'Alarme',
                      pendingNotifCount: 3,
                      onTap: () {
                        CustomMenuController.to.selectItem(3);
                        Get.toNamed(Routes.alarme);
                      },
                    ),
                  ),
                  Expanded(
                    child: menuButton(
                      icon: Icons.groups,
                      label: 'Actividades',
                      pendingNotifCount: null,
                      onTap: () {
                        CustomMenuController.to.selectItem(4);
                        Get.toNamed(Routes.activities);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuButton({
    required IconData icon,
    required String label,
    required int? pendingNotifCount,
    required Null Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Icon(icon, size: 50, color: CustomColors.witheColor),
              pendingNotifCount != null
                  ? Positioned(
                      right: 0,
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
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomColors.primaryDarkerColor,
            ),
          ),
        ],
      ),
    );
  }
}
