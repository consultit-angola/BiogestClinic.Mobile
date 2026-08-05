import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/global_controller.dart';
import 'app_routes.dart';

class CalendarPermissionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!GlobalController.to.canAccessAppointmentCalendar) {
      return const RouteSettings(name: Routes.home);
    }
    return null;
  }
}
