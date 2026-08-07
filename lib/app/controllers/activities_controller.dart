import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../ui/utils/custom_colors.dart';
import 'global_controller.dart';

class ActivitiesController extends GetxController {
  static ActivitiesController get to => Get.find<ActivitiesController>();

  final GlobalController globalController = GlobalController.to;
  final Provider _provider = Provider();
  final RxList<NeatCleanCalendarEvent> eventList =
      <NeatCleanCalendarEvent>[].obs;
  final RxBool isLoading = false.obs;

  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;
  String? _selectedMonth;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    onMonthChanged(DateTime(now.year, now.month));
  }

  void onMonthChanged(DateTime month) {
    final selectedMonth = '${month.year}-${month.month}';
    if (_selectedMonth == selectedMonth) {
      return;
    }
    _selectedMonth = selectedMonth;
    _rangeStartDate = DateTime.utc(month.year, month.month, 1);
    _rangeEndDate = DateTime.utc(month.year, month.month + 1, 0, 23, 59, 59);
    loadActivities(showMonthLoading: true);
  }

  Future<void> loadActivities({bool showMonthLoading = false}) async {
    final employeeID = globalController.authenticatedEmployee.value?.id;
    if (employeeID == null || employeeID <= 0) {
      eventList.clear();
      return;
    }

    if (showMonthLoading) {
      isLoading.value = true;
    }
    try {
      final response = await _provider.getEmployeeAbsences({
        'EmployeeIDs': [employeeID],
        'StartDate': _rangeStartDate?.toIso8601String(),
        'EndDate': _rangeEndDate?.toIso8601String(),
      });
      if (response['ok'] == true) {
        final activities = response['data'] as List<EmployeeAbsenceDTO>;
        eventList.assignAll(
          activities
              .where(
                (activity) =>
                    activity.startDate != null && activity.endDate != null,
              )
              .map(_toCalendarEvent),
        );
        return;
      }
      if (await globalController.handleResponseError(response)) {
        return;
      }
      Get.snackbar(
        'Erro',
        response['message']?.toString() ??
            'Não foi possível carregar as actividades.',
      );
    } finally {
      if (showMonthLoading) {
        isLoading.value = false;
      }
    }
  }

  NeatCleanCalendarEvent _toCalendarEvent(EmployeeAbsenceDTO activity) {
    final typeName = activity.type?.name.trim() ?? '';
    final typeDescription = activity.type?.description.trim() ?? '';
    final employeeName = activity.employee?.name.trim().isNotEmpty == true
        ? activity.employee!.name.trim()
        : activity.employee?.shortName.trim() ?? '';
    final description = [
      if (typeDescription.isNotEmpty) typeDescription,
      if (employeeName.isNotEmpty) employeeName,
    ].join(' • ');

    return NeatCleanCalendarEvent(
      typeName.isNotEmpty ? typeName : 'Actividade',
      description: description,
      startTime: activity.startDate!,
      endTime: activity.endDate!,
      color: CustomColors.primaryDarkerColor,
      isMultiDay: !_isSameDay(activity.startDate!, activity.endDate!),
      id: activity.id > 0 ? activity.id.toString() : activity.guid,
      metadata: {'activity': activity},
    );
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
