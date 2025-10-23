import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/shared/index.dart';
import 'index.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.find<CalendarController>();
  final Provider _provider = Provider();
  final globalController = GlobalController.to;
  final Preferences _pref = Preferences();
  final ValueChanged<DateTime>? onDateSelected = null;
  final ValueChanged<DateTime>? onMonthChanged = null;
  final ValueChanged<bool>? onExpandStateChanged = null;
  final ValueChanged? onRangeSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventLongPressed = null;

  @override
  void onInit() {
    super.onInit();

    if (!globalController.isCalendarControllerLoaded) {
      getAppts();
      globalController.isCalendarControllerLoaded = true;
    }
  }

  Future<void> getAppts() async {
    EasyLoading.show();
    final data = {
      // TypeEnumList: 0 - NotDefined, 1 - Appointment, 2 - Internment, 3 - Surgery, 4 - Emergency, 5 - Urgency
      'TypeEnumList': [1],
      'EmployeeIDList': [globalController.authenticatedUser.value!.id],
      'RoomID': null,
      'StoreID': _pref.storeID,
      'ScheduleStartDate': DateTime(2025, 10, 1).toUtc().toIso8601String(),
      'ScheduleEndDate': DateTime(2025, 10, 31).toUtc().toIso8601String(),
      'OnlyNotCanceled': null,
    };
    Map<String, dynamic> resp = await _provider.getAppts(data);
    if (resp['ok']) {
      globalController.eventList.clear();
      final appts = resp['data'] as List<AppointmentDTO>;
      globalController.pendingCalendar.value = appts
          .where(
            (appt) =>
                appt.state?.id == 0 && appt.scheduleStartDate == DateTime.now(),
          )
          .length;

      for (var appt in appts) {
        var clientName = '';
        if (appt.clientName != null) {
          clientName = appt.clientName!.length < 30
              ? appt.clientName ?? ''
              : '${appt.clientName!.substring(0, 27)}...';
        }

        var services = '';
        if (appt.services != null && appt.services!.isNotEmpty) {
          services = appt.services!
              .map((s) => '${s.serviceCodeAndName},')
              .toString();
          services = services.length < 30
              ? services
              : '${services.substring(0, 27)}...';
        }

        globalController.eventList.add(
          NeatCleanCalendarEvent(
            clientName,
            description: services,
            startTime: appt.scheduleStartDate ?? DateTime.now(),
            endTime: appt.scheduleEndDate ?? DateTime.now(),
            color: appt.stateColorRGB != null
                ? Color(
                    int.parse(
                          appt.stateColorRGB!.replaceAll('#', ''),
                          radix: 16,
                        ) +
                        0xFF000000,
                  )
                : null,
          ),
        );
      }
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      Get.snackbar('Error', resp['message']);
    }
  }
}
