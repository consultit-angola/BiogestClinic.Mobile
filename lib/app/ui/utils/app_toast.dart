import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_colors.dart';

class AppToast {
  const AppToast._();

  static SnackbarController show(
    String title,
    String message, {
    Color backgroundColor = CustomColors.secundaryDarkerColor,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 5),
    bool isDismissible = true,
    DismissDirection dismissDirection = DismissDirection.horizontal,
  }) {
    return Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      isDismissible: isDismissible,
      dismissDirection: dismissDirection,
    );
  }
}
