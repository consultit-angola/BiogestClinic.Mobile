import 'dart:async';

import 'package:get/get.dart';

import '../data/providers/provider.dart';
import 'index.dart';

class DashboardController extends GetxController {
  final Provider _provider = Provider();
  final globalController = GlobalController.to;
  final data = <String, dynamic>{}.obs;
  final clientData = <String, dynamic>{}.obs;
  final realTimeData = <String, dynamic>{}.obs;
  final hiddenChartSeries = <String>{}.obs;
  final loading = false.obs;
  final period = 'month'.obs;
  Timer? realTimeTimer;

  @override
  void onReady() {
    super.onReady();
    realTimeTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => loadRealTimeStatistics(showError: false),
    );
  }

  @override
  void onClose() {
    realTimeTimer?.cancel();
    super.onClose();
  }

  Future<void> load([String selectedPeriod = 'month']) async {
    period.value = selectedPeriod;
    final now = DateTime.now();
    late DateTime start;
    if (selectedPeriod == 'week') {
      start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
    } else if (selectedPeriod == 'month') {
      start = DateTime(now.year, now.month, 1);
    } else {
      start = DateTime(now.year, now.month, now.day);
    }
    late DateTime end;
    if (selectedPeriod == 'week') {
      end = start.add(const Duration(days: 7));
    } else if (selectedPeriod == 'month') {
      end = DateTime(now.year, now.month + 1, 1);
    } else {
      end = start.add(const Duration(days: 1));
    }
    loading.value = true;
    final response = await _provider.getDashboardFullStatistics(
      startDate: start,
      endDate: end,
    );
    if (await globalController.handleResponseError(response)) {
      loading.value = false;
      return;
    }
    if (response['ok'] != true) {
      loading.value = false;
      Get.snackbar('Erro', 'Não foi possível carregar os dados do dashboard.');
      return;
    }
    data.assignAll(response['data'] as Map<String, dynamic>);
    loading.value = false;
  }

  Future<void> loadClientStatistics() async {
    final response = await _provider.getDashboardClientStatistics(
      DateTime.now().year,
    );
    if (await globalController.handleResponseError(response)) return;
    if (response['ok'] == true) {
      clientData.assignAll(response['data'] as Map<String, dynamic>);
    }
  }

  Future<void> loadRealTimeStatistics({bool showError = true}) async {
    final response = await _provider.getDashboardRealTimeStatistics();
    if (await globalController.handleResponseError(response)) return;
    if (response['ok'] == true) {
      realTimeData.assignAll(response['data'] as Map<String, dynamic>);
    } else if (showError) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar a monitorização de urgência.',
      );
    }
  }

  List<Map<String, dynamic>> items(String key) =>
      (((data[key] as Map?)?['Items'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();
  int nestedInt(String group, String key) =>
      (((data[group] as Map?)?[key] as num?) ?? 0).toInt();

  List<Map<String, dynamic>> clientItems(String key) =>
      (((clientData[key] as Map?)?['Items'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> realTimeItems(String key) =>
      (((realTimeData[key] as Map?)?['Items'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

  int realTimeValue(String key) =>
      (((realTimeData[key] as Map?)?['Value'] as num?) ?? 0).toInt();

  int appointmentStateCount(String stateName) {
    final ids = globalController.getEnumEntryIdsByName('AppointmentStateEnum', [
      stateName,
    ]);
    if (ids.isEmpty) return 0;
    final item = items(
      'DashboardAppointmentByState',
    ).firstWhereOrNull((entry) => entry['ID'] == ids.first);
    return ((item?['ApptCount'] as num?) ?? 0).toInt();
  }

  int priorityCount(String priorityName) {
    final ids = globalController.getEnumEntryIdsByName(
      'AppointmentPriorityEnum',
      [priorityName],
    );
    if (ids.isEmpty) return 0;
    final item = realTimeItems(
      'DashboardAppointmentByPriority',
    ).firstWhereOrNull((entry) => entry['Id'] == ids.first);
    return ((item?['PriorityCount'] as num?) ?? 0).toInt();
  }

  bool isChartSeriesVisible(String chart, String series) {
    return !hiddenChartSeries.contains('$chart:$series');
  }

  void toggleChartSeries(String chart, String series) {
    final key = '$chart:$series';
    if (hiddenChartSeries.contains(key)) {
      hiddenChartSeries.remove(key);
    } else {
      hiddenChartSeries.add(key);
    }
  }
}
