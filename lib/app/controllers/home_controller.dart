import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/shared/preferences.dart';
import 'index.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();
  final globalController = GlobalController.to;
  final Provider _provider = Provider();
  final Preferences _preferences = Preferences();
  final RxList<AppointmentDTO> todayAppointments = <AppointmentDTO>[].obs;
  final RxBool loading = false.obs;

  Future<void> loadToday() async {
    if (!globalController.canAccessAppointmentCalendar ||
        globalController.authenticatedEmployee.value == null) {
      return;
    }
    loading.value = true;
    final now = DateTime.now();
    final response = await _provider.getAppts({
      'TypeEnumList': globalController.getEnumEntryIdsByName(
        'AppointmentTypeEnum',
        ['Appointment', 'Emergency', 'Urgency'],
      ),
      'EmployeeIDList': [globalController.authenticatedEmployee.value!.id],
      'RoomID': null,
      'StoreID': _preferences.storeID,
      'ScheduleStartDate': DateTime(
        now.year,
        now.month,
        now.day,
      ).toUtc().toIso8601String(),
      'ScheduleEndDate': DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      ).toUtc().toIso8601String(),
      'OnlyNotCanceled': false,
    });
    if (await globalController.handleResponseError(response)) {
      loading.value = false;
      return;
    }
    if (response['ok'] == true) {
      todayAppointments.assignAll(response['data'] as List<AppointmentDTO>);
      if (globalController.selectedStoreName.value.trim().isEmpty) {
        globalController.selectedStoreName.value = todayAppointments
            .map((appointment) => appointment.storeName?.trim() ?? '')
            .firstWhere((name) => name.isNotEmpty, orElse: () => '');
      }
      todayAppointments.sort(
        (a, b) => (a.scheduleStartDate ?? DateTime(2100)).compareTo(
          b.scheduleStartDate ?? DateTime(2100),
        ),
      );
    }
    loading.value = false;
  }

  int countStates(List<String> names) {
    final ids = globalController.getEnumEntryIdsByName(
      'AppointmentStateEnum',
      names,
    );
    return todayAppointments
        .where((appointment) => ids.contains(appointment.state?.id))
        .length;
  }

  List<AppointmentDTO> get upcomingAppointments {
    final now = DateTime.now();
    final inProgress = globalController.getEnumEntryIdsByName(
      'AppointmentStateEnum',
      ['BeingPerformed'],
    );
    final excluded = globalController.getEnumEntryIdsByName(
      'AppointmentStateEnum',
      [
        'Canceled',
        'DeScheduled',
        'DidNotAttend',
        'AllFinished',
        'ServicesFinished',
      ],
    );
    return todayAppointments
        .where(
          (appointment) =>
              ((appointment.scheduleStartDate?.isAfter(now) ?? false) ||
                  inProgress.contains(appointment.state?.id)) &&
              !excluded.contains(appointment.state?.id),
        )
        .take(4)
        .toList();
  }
}
