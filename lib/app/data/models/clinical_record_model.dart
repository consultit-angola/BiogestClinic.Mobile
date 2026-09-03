class DigitalDocumentDTO {
  final int id;
  final String name;
  final String creationDateAsString;
  final String typeName;
  final int? dataTypeID;

  DigitalDocumentDTO({
    required this.id,
    required this.name,
    required this.creationDateAsString,
    required this.typeName,
    this.dataTypeID,
  });

  factory DigitalDocumentDTO.fromJson(Map<String, dynamic> json) {
    return DigitalDocumentDTO(
      id: _int(json['ID']),
      name: _string(json['Name']),
      creationDateAsString: _string(
        json['CreationDateAsString'] ?? json['CreationDate'],
      ),
      typeName: _string((json['Type'] as Map?)?['Name']),
      dataTypeID: _nullableInt(json['DataTypeID'] ?? json['DataTypeEnum']),
    );
  }
}

class ClientMedicalDocumentDTO {
  final int id;
  final String creationDateAsString;
  final String typeName;
  final int? typeEnum;
  final int? dataTypeID;

  ClientMedicalDocumentDTO({
    required this.id,
    required this.creationDateAsString,
    required this.typeName,
    this.typeEnum,
    this.dataTypeID,
  });

  factory ClientMedicalDocumentDTO.fromJson(Map<String, dynamic> json) {
    return ClientMedicalDocumentDTO(
      id: _int(json['ID']),
      creationDateAsString: _string(
        json['CreationDateAsString'] ?? json['CreationDate'],
      ),
      typeName: _string((json['Type'] as Map?)?['Name']),
      typeEnum: _nullableInt(
        json['TypeEnum'] ?? (json['Type'] as Map?)?['Enum'],
      ),
      dataTypeID: _nullableInt(json['DataTypeID'] ?? json['DataTypeEnum']),
    );
  }
}

class AppointmentServiceDTO {
  final int id;
  final String dateAsString;
  final String tableName;
  final String serviceCodeAndName;
  final String doctor;
  final String observations;
  final String quantity;
  final String billed;
  final String storeName;
  final String roomName;

  AppointmentServiceDTO({
    required this.id,
    required this.dateAsString,
    required this.tableName,
    required this.serviceCodeAndName,
    required this.doctor,
    required this.observations,
    required this.quantity,
    required this.billed,
    required this.storeName,
    required this.roomName,
  });

  factory AppointmentServiceDTO.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceDTO(
      id: _int(json['ID']),
      dateAsString: _string(json['DateAsString'] ?? json['Date']),
      tableName: _string(json['ServiceGroupCodeAndName']),
      serviceCodeAndName: _string(json['ServiceCodeAndName']),
      doctor: _string(json['EmployeeName'] ?? json['doctor']),
      observations: _string(json['Observations']),
      quantity: _string(json['Quantity']),
      billed: json['IsBilled'] == true ? 'Sim' : 'Não',
      storeName: _string(json['StoreName']),
      roomName: _string(json['RoomName']),
    );
  }
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  return value is int ? value : int.tryParse('$value');
}

String _string(dynamic value) => value?.toString().trim() ?? '';
