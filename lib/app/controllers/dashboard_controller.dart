import 'package:get/get.dart';

import '../data/providers/provider.dart';
import 'index.dart';

class DashboardController extends GetxController {
  final Provider _provider = Provider();
  final globalController = GlobalController.to;
  final data = <String, dynamic>{}.obs;
  final loading = false.obs;
  final period = 'today'.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load([String selectedPeriod = 'today']) async {
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
    final end = selectedPeriod == 'today'
        ? DateTime(now.year, now.month, now.day, 23, 59, 59)
        : now;
    loading.value = true;
    final response = await _provider.getDashboardFullStatistics(
      startDate: start,
      endDate: end,
    );
    if (await globalController.handleResponseError(response)) {
      loading.value = false;
      return;
    }
    if (response['ok'] == true) {
      data.assignAll(response['data'] as Map<String, dynamic>);
    }
    loading.value = false;
  }

  List<Map<String, dynamic>> items(String key) =>
      (((data[key] as Map?)?['Items'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();
  int nestedInt(String group, String key) =>
      (((data[group] as Map?)?[key] as num?) ?? 0).toInt();
}
