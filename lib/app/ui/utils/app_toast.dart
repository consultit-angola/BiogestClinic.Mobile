import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_colors.dart';

class AppToast {
  const AppToast._();

  static SnackbarController show(String title, String message) {
    return Get.snackbar(
      title,
      message,
      backgroundColor: CustomColors.secundaryDarkerColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}
