import 'dart:convert';

import 'index.dart';

class AppointmentDTO {
  final int id;
  final UserDTO? creationUser;
  final DateTime? creationDate;
  final int? clientID;
  final String? clientName;
  final String? clientPhoneNumber;
  final StateDTO? state;
  final bool? patientWaiting;
  final DateTime? patientWaitingDate;
  final DateTime? startDate;
  final DateTime? scheduleStartDate;
  final DateTime? scheduleEndDate;
  final int? employeeID;
  final String? employeeName;
  final int? roomID;
  final String? roomName;
  final String? storeName;
  final String? observations;
  final int? clientNotificationSentCount;
  final List<ServicesDTO>? services;
  final List<DiagnosticCodeDTO>? diagnosticCodes;
  final SpecialtyDTO? medicalSpecialty;
  final TypeDTO? type;
  final String? summary;
  final int? servicesCount;
  final int? billedServicesCount;
  final int? unbilledServicesCount;
  final String? stateColorRGB;
  final String? title;
  final String? toolTipText;
  final bool? isEmergency;

  AppointmentDTO({
    required this.id,
    this.creationUser,
    this.creationDate,
    this.clientID,
    this.clientName,
    this.clientPhoneNumber,
    this.state,
    this.patientWaiting,
    this.patientWaitingDate,
    this.startDate,
    this.scheduleStartDate,
    this.scheduleEndDate,
    this.employeeID,
    this.employeeName,
    this.roomID,
    this.roomName,
    this.storeName,
    this.observations,
    this.clientNotificationSentCount,
    this.services,
    this.diagnosticCodes,
    this.medicalSpecialty,
    this.type,
    this.summary,
    this.servicesCount,
    this.billedServicesCount,
    this.unbilledServicesCount,
    this.stateColorRGB,
    this.title,
    this.toolTipText,
    this.isEmergency,
  });

  factory AppointmentDTO.fromJson(Map<String, dynamic> json) {
    return AppointmentDTO(
      id: json['ID'] ?? 0,
      creationUser: json['CreationUser'] != null
          ? UserDTO.fromJson(json['CreationUser'])
          : null,
      creationDate: json['CreationDate'] != null
          ? DateTime.tryParse(json['CreationDate'])
          : null,
      clientID: json['ClientID'],
      clientName: json['ClientName'],
      clientPhoneNumber: json['ClientPhoneNumber'],
      state: json['State'] != null ? StateDTO.fromJson(json['State']) : null,
      patientWaiting: json['PatientWaiting'],
      patientWaitingDate: json['PatientWaitingDate'] != null
          ? DateTime.tryParse(json['PatientWaitingDate'])
          : null,
      startDate: json['StartDate'] != null
          ? DateTime.tryParse(json['StartDate'])
          : null,
      scheduleStartDate: json['ScheduleStartDate'] != null
          ? DateTime.tryParse(json['ScheduleStartDate'])
          : null,
      scheduleEndDate: json['ScheduleEndDate'] != null
          ? DateTime.tryParse(json['ScheduleEndDate'])
          : null,
      employeeID: json['EmployeeID'],
      employeeName: json['EmployeeName'],
      roomID: json['RoomID'],
      roomName: json['RoomName'],
      storeName: json['StoreName'],
      observations: json['Observations'],
      clientNotificationSentCount: json['ClientNotificationSentCount'],
      services: json['Services'] != null
          ? List<ServicesDTO>.from(
              json['Services'].map((x) => ServicesDTO.fromJson(x)),
            )
          : null,
      diagnosticCodes: json['DiagnosticCodes'] != null
          ? (json['DiagnosticCodes'] as List)
                .map((e) => DiagnosticCodeDTO.fromJson(e))
                .toList()
          : [],
      medicalSpecialty: json['MedicalSpecialty'] != null
          ? SpecialtyDTO.fromJson(json['MedicalSpecialty'])
          : null,
      type: json['Type'] != null ? TypeDTO.fromJson(json['Type']) : null,
      summary: json['Summary'],
      servicesCount: json['ServicesCount'],
      billedServicesCount: json['BilledServicesCount'],
      unbilledServicesCount: json['UnbilledServicesCount'],
      stateColorRGB: json['StateColorRGB'],
      title: json['Title'],
      toolTipText: json['ToolTipText'],
      isEmergency: json['IsEmergency'],
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': id,
    'CreationUser': creationUser?.toJson(),
    'CreationDate': creationDate?.toIso8601String(),
    'ClientID': clientID,
    'ClientName': clientName,
    'ClientPhoneNumber': clientPhoneNumber,
    'State': state?.toJson(),
    'PatientWaiting': patientWaiting,
    'PatientWaitingDate': patientWaitingDate?.toIso8601String(),
    'StartDate': startDate?.toIso8601String(),
    'ScheduleStartDate': scheduleStartDate?.toIso8601String(),
    'ScheduleEndDate': scheduleEndDate?.toIso8601String(),
    'EmployeeID': employeeID,
    'EmployeeName': employeeName,
    'RoomID': roomID,
    'RoomName': roomName,
    'StoreName': storeName,
    'Observations': observations,
    'ClientNotificationSentCount': clientNotificationSentCount,
    'Services': services,
    'DiagnosticCodes': diagnosticCodes?.map((e) => e.toJson()).toList(),
    'MedicalSpecialty': medicalSpecialty?.toJson(),
    'Type': type?.toJson(),
    'Summary': summary,
    'ServicesCount': servicesCount,
    'BilledServicesCount': billedServicesCount,
    'UnbilledServicesCount': unbilledServicesCount,
    'StateColorRGB': stateColorRGB,
    'Title': title,
    'ToolTipText': toolTipText,
    'IsEmergency': isEmergency,
  };

  static List<AppointmentDTO> listFromJson(String str) {
    final jsonData = jsonDecode(str);
    return List<AppointmentDTO>.from(
      jsonData.map((x) => AppointmentDTO.fromJson(x)),
    );
  }
}

class StateDTO {
  final int? id;
  final String? name;
  final int? code;
  final String? description;
  final bool? deleted;

  StateDTO({this.id, this.name, this.code, this.description, this.deleted});

  factory StateDTO.fromJson(Map<String, dynamic> json) {
    return StateDTO(
      id: json['ID'],
      name: json['Name'],
      code: json['Code'],
      description: json['Description'],
      deleted: json['Deleted'],
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Code': code,
    'Description': description,
    'Deleted': deleted,
  };
}

class DiagnosticCodeDTO {
  final int? id;
  final String? name;
  final GroupDTO? group;
  final String? code;
  final String? codeAndName;
  final DateTime? creationDate;
  final String? creationDateAsString;

  DiagnosticCodeDTO({
    this.id,
    this.name,
    this.group,
    this.code,
    this.codeAndName,
    this.creationDate,
    this.creationDateAsString,
  });

  factory DiagnosticCodeDTO.fromJson(Map<String, dynamic> json) {
    return DiagnosticCodeDTO(
      id: json['ID'],
      name: json['Name'],
      group: json['Group'] != null ? GroupDTO.fromJson(json['Group']) : null,
      code: json['Code'],
      codeAndName: json['CodeAndName'],
      creationDate: json['CreationDate'] != null
          ? DateTime.tryParse(json['CreationDate'])
          : null,
      creationDateAsString: json['CreationDateAsString'],
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Group': group?.toJson(),
    'Code': code,
    'CodeAndName': codeAndName,
    'CreationDate': creationDate?.toIso8601String(),
    'CreationDateAsString': creationDateAsString,
  };
}
