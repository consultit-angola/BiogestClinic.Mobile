import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:get/get.dart';

import 'index.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.find<CalendarController>();
  final globalController = GlobalController.to;
  final ValueChanged<DateTime>? onDateSelected = null;
  final ValueChanged<DateTime>? onMonthChanged = null;
  final ValueChanged<bool>? onExpandStateChanged = null;
  final ValueChanged? onRangeSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventLongPressed = null;

  // @override
  // void onInit() {
  //   super.onInit();

  //   if (!globalController.isCalendarControllerLoaded) {
  //     getAppts();
  //     globalController.isCalendarControllerLoaded = true;
  //   }
  // }
}
