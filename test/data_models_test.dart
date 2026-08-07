import 'dart:convert';

import 'package:biogest_clinic_mobile/app/data/models/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageDTO', () {
    final json = <String, dynamic>{
      'ID': 7,
      'MessageText': 'Bom dia',
      'CreationDate': '2026-08-06T08:30:00.000Z',
      'CreationUserID': 10,
      'DestinationUserID': 20,
      'Attachments': [
        {'Name': 'resultado.pdf', 'Data': 'cGRm'},
      ],
    };

    test('reads the API contract including attachments', () {
      final message = MessageDTO.fromJson(json);

      expect(message.id, 7);
      expect(message.creationDate, DateTime.utc(2026, 8, 6, 8, 30));
      expect(message.attachments.single.name, 'resultado.pdf');
      expect(message.status, MessageStatus.sent);
    });

    test('round-trips through JSON', () {
      final message = MessageDTO.fromJson(json);
      final decoded = MessageDTO.listFromJson(jsonEncode([message.toJson()]));

      expect(decoded.single.id, message.id);
      expect(decoded.single.messageText, message.messageText);
      expect(decoded.single.creationDate, message.creationDate);
      expect(decoded.single.attachments.single.name, 'resultado.pdf');
    });

    test('uses safe defaults for optional values', () {
      final message = MessageDTO.fromJson({
        'CreationDate': '2026-08-06T08:30:00Z',
      });

      expect(message.id, 0);
      expect(message.messageText, isEmpty);
      expect(message.attachments, isEmpty);
    });
  });

  group('AppointmentDTO', () {
    final json = <String, dynamic>{
      'ID': 42,
      'ClientName': 'Maria',
      'ScheduleStartDate': '2026-08-06T09:00:00.000Z',
      'ScheduleEndDate': '2026-08-06T09:30:00.000Z',
      'State': {'ID': 3, 'Name': 'Scheduled'},
      'Services': [
        {'ID': 8, 'ServiceCodeAndName': 'CONS - Consulta'},
      ],
      'DiagnosticCodes': <Map<String, dynamic>>[],
      'IsEmergency': false,
    };

    test('reads dates, state and nested services', () {
      final appointment = AppointmentDTO.fromJson(json);

      expect(appointment.id, 42);
      expect(appointment.clientName, 'Maria');
      expect(appointment.scheduleStartDate, DateTime.utc(2026, 8, 6, 9));
      expect(appointment.state?.name, 'Scheduled');
      expect(appointment.services?.single.id, 8);
    });

    test('round-trips the fields used by calendar and home', () {
      final appointment = AppointmentDTO.fromJson(json);
      final serialized = jsonDecode(jsonEncode(appointment.toJson()));
      final copy = AppointmentDTO.fromJson(serialized as Map<String, dynamic>);

      expect(copy.id, appointment.id);
      expect(copy.scheduleStartDate, appointment.scheduleStartDate);
      expect(copy.state?.id, appointment.state?.id);
      expect(copy.services?.single.serviceCodeAndName, 'CONS - Consulta');
    });

    test('accepts an incomplete payload', () {
      final appointment = AppointmentDTO.fromJson({'ID': 1});

      expect(appointment.scheduleStartDate, isNull);
      expect(appointment.diagnosticCodes, isEmpty);
      expect(appointment.services, isNull);
    });
  });

  group('Catalog models', () {
    test('CalendarFilterOptionDTO selects the available display field', () {
      expect(
        CalendarFilterOptionDTO.fromJson({'ID': 1, 'Name': 'Principal'}).name,
        'Principal',
      );
      expect(
        CalendarFilterOptionDTO.fromJson({'ID': 2, 'ShortName': 'Dra.'}).name,
        'Dra.',
      );
      expect(
        CalendarFilterOptionDTO.fromJson({
          'ID': 3,
          'NameAndType': 'Sala 1 - Consulta',
          'Store': {'ID': 9},
        }).parentID,
        9,
      );
    });

    test('UserDTO preserves StoreIDs', () {
      final user = UserDTO.fromJson({
        'ID': 4,
        'Login': 'maria',
        'StoreIDs': [2, 5],
      });

      expect(user.storeIds, [2, 5]);
      expect(user.toJson()['StoreIDs'], [2, 5]);
    });

    test('StoreDTO parses a list and nested extended data', () {
      final stores = StoreDTO.fromJsonList(
        jsonEncode([
          {
            'ID': 1,
            'Name': 'Luanda',
            'NextDoctorRoundDateTime': '2026-08-06T10:00:00Z',
            'ExtendedData': {
              'Address': 'Maianga',
              'ConsumptionStockIDs': [3, 4],
            },
          },
        ]),
      );

      expect(stores.single.name, 'Luanda');
      expect(stores.single.extendedData.address, 'Maianga');
      expect(stores.single.extendedData.consumptionStockIDs, [3, 4]);
    });
  });

  group('EmployeeAbsenceDTO', () {
    test('reads the live EmployeeAbsence contract', () {
      final activity = EmployeeAbsenceDTO.fromJson({
        'ID': 15,
        'Employee': {'ID': 8, 'Name': 'Ana', 'ShortName': 'Dra. Ana'},
        'Type': {
          'ID': 3,
          'Name': 'Formação',
          'Code': 12,
          'Description': 'Curso de actualização',
          'Deleted': false,
        },
        'StartDate': '2026-08-07T08:00:00Z',
        'EndDate': '2026-08-07T12:00:00Z',
        'PeriodicAbsenceID': 4,
        'Guid': 'activity-guid',
      });

      expect(activity.id, 15);
      expect(activity.employee?.name, 'Ana');
      expect(activity.type?.name, 'Formação');
      expect(activity.type?.description, 'Curso de actualização');
      expect(activity.startDate, DateTime.utc(2026, 8, 7, 8));
      expect(activity.endDate, DateTime.utc(2026, 8, 7, 12));
      expect(activity.periodicAbsenceID, 4);
      expect(activity.guid, 'activity-guid');
    });
  });

  group('Alarm models', () {
    test('AlarmDTO keeps scheduling and notification flags', () {
      final alarm = AlarmDTO.fromJson({
        'ID': 5,
        'Name': 'Stock mínimo',
        'Monday': true,
        'SendByEmail': true,
        'Arguments': [1, 'stock'],
        'AlarmUserIDs': [7, 8],
      });

      expect(alarm.arguments, ['1', 'stock']);
      expect(alarm.alarmUserIds, [7, 8]);
      expect(alarm.toJson()['SendByEmail'], isTrue);
    });

    test('AlarmInstanceDTO round-trips nested state and user', () {
      final instance = AlarmInstanceDTO.fromJson({
        'ID': 12,
        'AlarmID': 5,
        'EntityStringID': 'FAT-2026-1',
        'State': {'ID': 2, 'Name': 'Active'},
        'LastActionUser': {'ID': 3, 'Name': 'Ana'},
        'UserToNotifyIDs': [3],
      });
      final copy = AlarmInstanceDTO.fromJson(instance.toJson());

      expect(copy.state?.name, 'Active');
      expect(copy.lastActionUser?.name, 'Ana');
      expect(copy.userToNotifyIds, [3]);
    });
  });
}
