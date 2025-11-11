// import 'package:get/get.dart';

// import 'index.dart';

// class AlarmController extends GetxController {
//   static AlarmController get to => Get.find<AlarmController>();

//   final globalController = GlobalController.to;
//   RxBool expanded = false.obs;
//   RxInt filterAlarmID = (-1).obs;
// }
import 'package:get/get.dart';
import '../data/models/index.dart';
import 'index.dart';

class AlarmController extends GetxController {
  static AlarmController get to => Get.find<AlarmController>();

  final globalController = GlobalController.to;
  RxSet<int> expandedAlarms = <int>{}.obs;
  RxInt filterAlarmID = (-1).obs;
  RxString searchQuery = ''.obs;

  void toggleExpanded(int alarmId) {
    if (expandedAlarms.contains(alarmId)) {
      expandedAlarms.remove(alarmId);
    } else {
      expandedAlarms.add(alarmId);
    }
  }

  bool isExpanded(int alarmId) => expandedAlarms.contains(alarmId);

  List<AlarmInstanceDTO> get filteredInstances {
    final allInstances = filterAlarmID.value != -1
        ? (globalController.programmedAlarmsMap[filterAlarmID
                          .value]?['instances']
                      as List?)
                  ?.cast<AlarmInstanceDTO>() ??
              []
        : globalController.alarmInstances;

    if (searchQuery.value.isEmpty) return allInstances;

    final query = searchQuery.value.toLowerCase();
    return allInstances.where((a) {
      final name =
          globalController.programmedAlarmsMap[a.alarmId]?['alarm']?.name
              ?.toLowerCase() ??
          '';
      final id = a.entityStringId?.toLowerCase() ?? '';
      return name.contains(query) || id.contains(query);
    }).toList();
  }
}
