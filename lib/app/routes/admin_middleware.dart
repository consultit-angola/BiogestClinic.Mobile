import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/global_controller.dart';
import 'app_routes.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (GlobalController.to.authenticatedUser.value?.id != 1) {
      return const RouteSettings(name: Routes.home);
    }
    return null;
  }
}
