import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:get/get.dart';

import 'index.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.find<CalendarController>();
  final globalController = GlobalController.to;
  final ValueChanged<bool>? onExpandStateChanged = null;
  final ValueChanged? onRangeSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventLongPressed = null;

  // @override
  // void onInit() {
  //   super.onInit();

  //   // if (!globalController.isCalendarControllerLoaded) {
  //   //   getAppts();
  //   //   globalController.isCalendarControllerLoaded = true;
  //   // }
  // }

  void onMonthChanged(DateTime month) {
    final startDate = DateTime.utc(month.year, month.month, 1, 0, 0, 0);
    final endDate = DateTime.utc(month.year, month.month + 1, 0, 23, 59, 59);
    globalController.getAppts(pStartDate: startDate, pEndDate: endDate);
  }
}
