import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:get/get.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.find<CalendarController>();

  final ValueChanged<DateTime>? onDateSelected = null;
  final ValueChanged<DateTime>? onMonthChanged = null;
  final ValueChanged<bool>? onExpandStateChanged = null;
  final ValueChanged? onRangeSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventLongPressed = null;

  final List<NeatCleanCalendarEvent> eventList = [
    NeatCleanCalendarEvent(
      'MultiDay Event A',
      startTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        10,
        0,
      ),
      endTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day + 2,
        12,
        0,
      ),
      color: Colors.orange,
      isMultiDay: true,
    ),
    NeatCleanCalendarEvent(
      'Allday Event B',
      startTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day - 2,
        14,
        30,
      ),
      endTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day + 2,
        17,
        0,
      ),
      color: Colors.pink,
      isAllDay: true,
    ),
    NeatCleanCalendarEvent(
      'Normal Event D',
      startTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        14,
        30,
      ),
      endTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        17,
        0,
      ),
      color: Colors.indigo,
    ),
  ];
}
