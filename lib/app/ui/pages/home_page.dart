import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../index.dart';
import '../../routes/index.dart';
import '../../controllers/index.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              customAppbar(showSettings: true),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: Get.height * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 3,
                        child: SvgPicture.asset(
                          'assets/images/dra.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Flexible(flex: 4, child: menu()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menu() {
    return Container(
      width: 1.15.sw,
      decoration: BoxDecoration(
        color: CustomColors.primaryLightColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(80.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 0.08.sw, vertical: 0.05.sh),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.maxWidth * 0.18;
          final fontSize = (constraints.maxWidth * 0.05).clamp(12, 20).sp;
          return Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: menuButton(
                        icon: Icons.chat,
                        label: 'Chat',
                        iconSize: iconSize,
                        fontSize: fontSize,
                        pendingNotifCount:
                            controller.globalController.pendingMessages.value,
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
                        iconSize: iconSize,
                        fontSize: fontSize,
                        pendingNotifCount:
                            controller.globalController.pendingCalendar.value,
                        onTap: () {
                          CustomMenuController.to.selectItem(2);
                          Get.toNamed(Routes.calendar);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.03.sh),
                Row(
                  children: [
                    Expanded(
                      child: menuButton(
                        icon: Icons.notifications_active,
                        label: 'Alarm',
                        iconSize: iconSize,
                        fontSize: fontSize,
                        pendingNotifCount:
                            controller.globalController.pendingAlarms.value,
                        onTap: () {
                          CustomMenuController.to.selectItem(3);
                          Get.toNamed(Routes.alarm);
                        },
                      ),
                    ),
                    Expanded(
                      child: menuButton(
                        icon: Icons.groups,
                        label: 'Actividades',
                        iconSize: iconSize,
                        fontSize: fontSize,
                        pendingNotifCount:
                            controller.globalController.pendingActivities.value,
                        onTap: () {
                          CustomMenuController.to.selectItem(4);
                          Get.toNamed(Routes.activities);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget menuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int pendingNotifCount,
    double? iconSize,
    double? fontSize,
  }) {
    final double size = iconSize ?? 50.sp;
    final double badgeSize = size * 0.5; // Ajusta el tamaño de la burbuja

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: size, color: Colors.white),
                  if (pendingNotifCount > 0)
                    Transform.translate(
                      offset: Offset(size * 0.6, -size * 0.2),
                      child: Container(
                        height: badgeSize,
                        width: badgeSize,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            pendingNotifCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeSize * 0.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize ?? 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
