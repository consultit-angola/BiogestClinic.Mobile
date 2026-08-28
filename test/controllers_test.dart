import 'package:biogest_clinic_mobile/app/controllers/alarm_controller.dart';
import 'package:biogest_clinic_mobile/app/controllers/dashboard_controller.dart';
import 'package:biogest_clinic_mobile/app/controllers/global_controller.dart';
import 'package:biogest_clinic_mobile/app/controllers/home_controller.dart';
import 'package:biogest_clinic_mobile/app/data/models/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late GlobalController globalController;

  setUp(() {
    Get.testMode = true;
    globalController = Get.put(GlobalController());
    globalController.enumEntries.addAll({
      'AppointmentStateEnum': const [
        EnumEntryDTO(id: 1, name: 'Scheduled'),
        EnumEntryDTO(id: 2, name: 'BeingPerformed'),
        EnumEntryDTO(id: 3, name: 'Canceled'),
        EnumEntryDTO(id: 4, name: 'AllFinished'),
      ],
      'AppointmentPriorityEnum': const [
        EnumEntryDTO(id: 10, name: 'Immediate'),
      ],
    });
  });

  tearDown(() {
    Get.reset();
  });

  group('GlobalController', () {
    test('maps permissions to feature access', () {
      globalController.activePermissions.assignAll([
        GlobalController.appointmentScheduleManagementPermission,
        GlobalController.dashboardViewPermission,
      ]);

      expect(globalController.canAccessAppointmentCalendar, isTrue);
      expect(globalController.canAccessDashboard, isTrue);
      expect(globalController.canAccessAlarms, isFalse);
    });

    test('resolves enum IDs in the requested order from the catalog', () {
      expect(
        globalController.getEnumEntryIdsByName('AppointmentStateEnum', [
          'BeingPerformed',
          'Canceled',
        ]),
        [2, 3],
      );
      expect(
        globalController.getEnumEntryIdsByName('Missing', ['Any']),
        isEmpty,
      );
    });

    test('compares merged message lists by ID and delivery status', () {
      final first = _message(1, 'Olá');
      final same = _message(1, 'Olá');
      final changedText = _message(1, 'Alterada');
      final changedStatus = _message(1, 'Olá')..status = MessageStatus.read;

      expect(globalController.mergedListEquals([first], [same]), isTrue);
      expect(globalController.mergedListEquals([first], [changedText]), isTrue);
      expect(
        globalController.mergedListEquals([first], [changedStatus]),
        isFalse,
      );
      expect(globalController.mergedListEquals([first], []), isFalse);
    });

    test('ignores unread messages from the active conversation', () {
      final activeMessage = _message(1, 'Aberta');
      final otherMessage = _message(2, 'Outra', creationUserID: 3);

      final pendingMessages = globalController
          .unreadMessagesOutsideActiveConversation(
            [activeMessage, otherMessage],
            2,
            activeConversationUserID: 1,
          );

      expect(pendingMessages, [otherMessage]);
      expect(
        globalController.isMessageFromActiveConversation(activeMessage, 2, 1),
        isTrue,
      );
    });
  });

  group('HomeController', () {
    test('counts appointments using enum names', () {
      final controller = HomeController();
      controller.todayAppointments.assignAll([
        _appointment(1, stateID: 1),
        _appointment(2, stateID: 2),
        _appointment(3, stateID: 2),
      ]);

      expect(controller.countStates(['BeingPerformed']), 2);
      expect(controller.countStates(['Scheduled', 'BeingPerformed']), 3);
    });

    test(
      'upcomingAppointments includes future and in-progress appointments',
      () {
        final controller = HomeController();
        final now = DateTime.now();
        controller.todayAppointments.assignAll([
          _appointment(1, stateID: 1, date: now.add(const Duration(hours: 1))),
          _appointment(
            2,
            stateID: 2,
            date: now.subtract(const Duration(hours: 1)),
          ),
          _appointment(3, stateID: 3, date: now.add(const Duration(hours: 2))),
          _appointment(4, stateID: 4, date: now.add(const Duration(hours: 3))),
          _appointment(
            5,
            stateID: 1,
            date: now.subtract(const Duration(hours: 2)),
          ),
        ]);

        expect(controller.upcomingAppointments.map((item) => item.id), [1, 2]);
      },
    );

    test('upcomingAppointments returns at most four entries', () {
      final controller = HomeController();
      controller.todayAppointments.assignAll(
        List.generate(
          6,
          (index) => _appointment(
            index,
            stateID: 1,
            date: DateTime.now().add(Duration(hours: index + 1)),
          ),
        ),
      );

      expect(controller.upcomingAppointments, hasLength(4));
    });
  });

  group('DashboardController', () {
    test('reads nested data and uses zero for absent values', () {
      final controller = DashboardController();
      controller.data.assignAll({
        'Summary': {'Total': 12.0},
        'Rows': {
          'Items': [
            {'ID': 1},
          ],
        },
      });

      expect(controller.nestedInt('Summary', 'Total'), 12);
      expect(controller.nestedInt('Summary', 'Missing'), 0);
      expect(controller.items('Rows'), hasLength(1));
      expect(controller.items('Missing'), isEmpty);
    });

    test('finds state and priority totals through enum IDs', () {
      final controller = DashboardController();
      controller.data['DashboardAppointmentByState'] = {
        'Items': [
          {'ID': 2, 'ApptCount': 6},
        ],
      };
      controller.realTimeData['DashboardAppointmentByPriority'] = {
        'Items': [
          {'Id': 10, 'PriorityCount': 3},
        ],
      };

      expect(controller.appointmentStateCount('BeingPerformed'), 6);
      expect(controller.appointmentStateCount('Unknown'), 0);
      expect(controller.priorityCount('Immediate'), 3);
    });

    test('toggles chart series visibility independently', () {
      final controller = DashboardController();

      expect(
        controller.isChartSeriesVisible('appointments', 'scheduled'),
        isTrue,
      );
      controller.toggleChartSeries('appointments', 'scheduled');
      expect(
        controller.isChartSeriesVisible('appointments', 'scheduled'),
        isFalse,
      );
      expect(
        controller.isChartSeriesVisible('appointments', 'canceled'),
        isTrue,
      );
      controller.toggleChartSeries('appointments', 'scheduled');
      expect(
        controller.isChartSeriesVisible('appointments', 'scheduled'),
        isTrue,
      );
    });
  });

  group('AlarmController', () {
    test('toggles expanded alarms', () {
      final controller = AlarmController();

      controller.toggleExpanded(9);
      expect(controller.isExpanded(9), isTrue);
      controller.toggleExpanded(9);
      expect(controller.isExpanded(9), isFalse);
    });

    test('filters instances by entity identifier and alarm name', () {
      final controller = AlarmController();
      final stock = AlarmInstanceDTO(alarmId: 5, entityStringId: 'STK-001');
      final invoice = AlarmInstanceDTO(alarmId: 6, entityStringId: 'FAT-002');
      globalController.alarmInstances.assignAll([stock, invoice]);
      globalController.programmedAlarmsMap.assignAll({
        5: {'alarm': AlarmDTO(id: 5, name: 'Stock mínimo')},
        6: {'alarm': AlarmDTO(id: 6, name: 'Fatura vencida')},
      });

      controller.searchQuery.value = 'stk';
      expect(controller.filteredInstances, [stock]);
      controller.searchQuery.value = 'fatura';
      expect(controller.filteredInstances, [invoice]);
    });

    test('uses the selected alarm instance list', () {
      final controller = AlarmController();
      final selected = AlarmInstanceDTO(alarmId: 5, entityStringId: 'A');
      globalController.programmedAlarmsMap[5] = {
        'alarm': AlarmDTO(id: 5, name: 'Alarme'),
        'instances': <AlarmInstanceDTO>[selected],
      };
      controller.filterAlarmID.value = 5;

      expect(controller.filteredInstances, [selected]);
    });
  });
}

MessageDTO _message(
  int id,
  String text, {
  int creationUserID = 1,
  int destinationUserID = 2,
}) {
  return MessageDTO(
    id: id,
    messageText: text,
    creationDate: DateTime.utc(2026, 8, 6),
    creationUserID: creationUserID,
    destinationUserID: destinationUserID,
    attachments: const [],
  );
}

AppointmentDTO _appointment(int id, {required int stateID, DateTime? date}) {
  return AppointmentDTO(
    id: id,
    state: StateDTO(id: stateID),
    scheduleStartDate: date,
  );
}
