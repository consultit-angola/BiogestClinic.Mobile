import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/index.dart';
import '../../routes/index.dart';
import '../index.dart';

Widget customMenu({bool alignBottom = true}) {
  final controller = Get.put(CustomMenuController());
  final menu = Obx(
    () => Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CustomColors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _item(controller, 0, Icons.home_sharp, 'Início', Routes.home),
            _item(
              controller,
              1,
              Icons.calendar_month_sharp,
              'Agenda',
              Routes.calendar,
              visible: controller.globalController.canAccessAppointmentCalendar,
            ),
            _item(
              controller,
              2,
              Icons.groups_sharp,
              'Actividades',
              Routes.activities,
              visible: controller.globalController.canAccessActivities,
            ),
            _item(
              controller,
              3,
              Icons.dashboard_sharp,
              'Dashboard',
              Routes.dashboard,
              visible: controller.globalController.canAccessDashboard,
            ),
            // Expanded(
            //   child: InkWell(
            //     onTap: controller.openMoreMenu,
            //     child: const _MenuContent(
            //       icon: Icons.more_horiz,
            //       label: 'Mais',
            //       selected: false,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    ),
  );
  if (!alignBottom) {
    return menu;
  }
  return Align(alignment: Alignment.bottomCenter, child: menu);
}

Widget _item(
  CustomMenuController controller,
  int index,
  IconData icon,
  String label,
  String route, {
  bool visible = true,
}) {
  if (!visible) return const SizedBox.shrink();
  return Expanded(
    child: InkWell(
      onTap: () {
        controller.selectItem(index);
        Get.offNamed(route);
      },
      child: _MenuContent(
        icon: icon,
        label: label,
        selected: controller.selectedPosItem.value == index,
      ),
    ),
  );
}

class _MenuContent extends StatelessWidget {
  const _MenuContent({
    required this.icon,
    required this.label,
    required this.selected,
  });
  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? CustomColors.primaryColor : CustomColors.textColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 3),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
