class EmployeeAbsenceDTO {
  final int id;
  final EmployeeAbsenceEmployeeDTO? employee;
  final EmployeeAbsenceTypeDTO? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? periodicAbsenceID;
  final String guid;

  const EmployeeAbsenceDTO({
    required this.id,
    this.employee,
    this.type,
    this.startDate,
    this.endDate,
    this.periodicAbsenceID,
    required this.guid,
  });

  factory EmployeeAbsenceDTO.fromJson(Map<String, dynamic> json) {
    final employee = json['Employee'];
    final type = json['Type'];
    return EmployeeAbsenceDTO(
      id: json['ID'] ?? 0,
      employee: employee is Map<String, dynamic>
          ? EmployeeAbsenceEmployeeDTO.fromJson(employee)
          : null,
      type: type is Map<String, dynamic>
          ? EmployeeAbsenceTypeDTO.fromJson(type)
          : null,
      startDate: DateTime.tryParse(json['StartDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['EndDate']?.toString() ?? ''),
      periodicAbsenceID: json['PeriodicAbsenceID'],
      guid: json['Guid']?.toString() ?? '',
    );
  }
}

class EmployeeAbsenceEmployeeDTO {
  final int id;
  final String name;
  final String shortName;

  const EmployeeAbsenceEmployeeDTO({
    required this.id,
    required this.name,
    required this.shortName,
  });

  factory EmployeeAbsenceEmployeeDTO.fromJson(Map<String, dynamic> json) =>
      EmployeeAbsenceEmployeeDTO(
        id: json['ID'] ?? 0,
        name: json['Name']?.toString() ?? '',
        shortName: json['ShortName']?.toString() ?? '',
      );
}

class EmployeeAbsenceTypeDTO {
  final int id;
  final String name;
  final int code;
  final String description;
  final bool deleted;

  const EmployeeAbsenceTypeDTO({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.deleted,
  });

  factory EmployeeAbsenceTypeDTO.fromJson(Map<String, dynamic> json) =>
      EmployeeAbsenceTypeDTO(
        id: json['ID'] ?? 0,
        name: json['Name']?.toString() ?? '',
        code: json['Code'] ?? 0,
        description: json['Description']?.toString() ?? '',
        deleted: json['Deleted'] ?? false,
      );
}
