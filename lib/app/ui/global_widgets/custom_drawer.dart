import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/index.dart';
import '../../data/shared/index.dart';
import '../../routes/index.dart';
import '../index.dart';

Widget customDrawer() {
  final globalController = GlobalController.to;
  final menuController = Get.put(CustomMenuController());

  void navigate(String route, int index) {
    Get.back();
    menuController.selectItem(index);
    Get.toNamed(route);
  }

  return Drawer(
    backgroundColor: CustomColors.surfaceColor,
    child: SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            color: CustomColors.primaryDarkerColor,
            child: Obx(() {
              final user = globalController.authenticatedUser.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/images/logo.svg', height: 48),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Biogest Clinic',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ApiConfig.activeApiName,
                    style: const TextStyle(color: Color(0xff9EDDD7)),
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: ListView(
              primary: false,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _drawerItem(
                  Icons.home_outlined,
                  'Início',
                  () => navigate(Routes.home, 0),
                ),
                if (globalController.canAccessAppointmentCalendar)
                  _drawerItem(
                    Icons.calendar_month_outlined,
                    'Agenda',
                    () => navigate(Routes.calendar, 1),
                  ),
                if (globalController.canAccessActivities)
                  _drawerItem(
                    Icons.groups_outlined,
                    'Actividades',
                    () => navigate(Routes.activities, 2),
                  ),
                if (globalController.canAccessDashboard)
                  _drawerItem(
                    Icons.dashboard_outlined,
                    'Dashboard',
                    () => navigate(Routes.dashboard, 3),
                  ),
                _drawerItem(
                  Icons.chat_bubble_outline,
                  'Chat',
                  () => navigate(Routes.chat, 4),
                ),
                if (globalController.canAccessAlarms)
                  _drawerItem(
                    Icons.notifications_none,
                    'Alarmes',
                    () => navigate(Routes.alarm, 4),
                  ),
                _drawerItem(
                  Icons.person_outline,
                  'Utilizador',
                  () => navigate(Routes.user, -1),
                ),
                const Divider(height: 28),
                _drawerItem(
                  Icons.delete_sweep_outlined,
                  'Limpar cache',
                  () async {
                    Get.back();
                    await Preferences().clear();
                    Preferences().skipSplash = false;
                    Get.offAllNamed(Routes.splash);
                  },
                ),
                if (globalController.authenticatedUser.value?.id == 1)
                  _drawerItem(
                    Icons.cloud_sync_outlined,
                    'Alterar API',
                    () => navigate(Routes.apiSettings, -1),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _drawerItem(Icons.logout_rounded, 'Sair', () {
            Get.back();
            globalController.logout();
          }, color: CustomColors.tertiaryColor),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Widget _drawerItem(
  IconData icon,
  String label,
  VoidCallback onTap, {
  Color? color,
}) {
  return ListTile(
    leading: Icon(icon, color: color ?? CustomColors.primaryDarkerColor),
    title: Text(
      label,
      style: TextStyle(
        color: color ?? CustomColors.textColor,
        fontWeight: FontWeight.w600,
      ),
    ),
    onTap: onTap,
  );
}
