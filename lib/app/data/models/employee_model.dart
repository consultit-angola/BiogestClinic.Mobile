import 'index.dart';

class EmployeeDTO {
  final int id;
  final String name;
  final String shortName;
  final GroupDTO group;
  final String category;
  final bool deleted;
  final String deletedAsString;
  final int userId;
  final String userAsString;
  final String fiscalNumber;
  final String socialSecurityNumber;
  final List<String> fixedPhoneNumbers;
  final List<String> cellPhoneNumbers;
  final List<String> emails;
  final AddressDTO address;
  final String color;
  final int gender;
  final CivilStateDTO? civilState;
  final String dateOfBirth;
  final int identificationCardType;
  final String identificationCardNumber;
  final String identificationCardPlaceOfIssue;
  final String identificationCardDateOfIssue;
  final TypeDTO type;
  final int contractTypeEnum;
  final ContractTypeDTO contractType;
  final String contractStartDate;
  final String contractEndDate;
  final RoomDTO room;
  final List<int> appointmentExecutionSpecialties;
  final List<int> appointmentVisualizationSpecialties;
  final List<SpecialtyDTO> allowedAppointmentExecutionSpecialties;

  EmployeeDTO({
    required this.id,
    required this.name,
    required this.shortName,
    required this.group,
    required this.category,
    required this.deleted,
    required this.deletedAsString,
    required this.userId,
    required this.userAsString,
    required this.fiscalNumber,
    required this.socialSecurityNumber,
    required this.fixedPhoneNumbers,
    required this.cellPhoneNumbers,
    required this.emails,
    required this.address,
    required this.color,
    required this.gender,
    this.civilState,
    required this.dateOfBirth,
    required this.identificationCardType,
    required this.identificationCardNumber,
    required this.identificationCardPlaceOfIssue,
    required this.identificationCardDateOfIssue,
    required this.type,
    required this.contractTypeEnum,
    required this.contractType,
    required this.contractStartDate,
    required this.contractEndDate,
    required this.room,
    required this.appointmentExecutionSpecialties,
    required this.appointmentVisualizationSpecialties,
    required this.allowedAppointmentExecutionSpecialties,
  });

  factory EmployeeDTO.fromJson(Map<String, dynamic> json) => EmployeeDTO(
    id: json['ID'] ?? 0,
    name: json['Name'] ?? '',
    shortName: json['ShortName'] ?? '',
    group: GroupDTO.fromJson(json['Group'] ?? {}),
    category: json['Category'] ?? '',
    deleted: json['Deleted'] ?? false,
    deletedAsString: json['DeletedAsString'] ?? '',
    userId: json['UserID'] ?? 0,
    userAsString: json['UserAsString'] ?? '',
    fiscalNumber: json['FiscalNumber'] ?? '',
    socialSecurityNumber: json['SocialSecurityNumber'] ?? '',
    fixedPhoneNumbers:
        (json['FixedPhoneNumbers'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    cellPhoneNumbers:
        (json['CellPhoneNumbers'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    emails: (json['Emails'] as List?)?.map((e) => e.toString()).toList() ?? [],
    address: AddressDTO.fromJson(json['Address'] ?? {}),
    color: json['Color'] ?? '',
    gender: json['Gender'] ?? 0,
    civilState: CivilStateDTO.fromJson(json['CivilState'] ?? {}),
    dateOfBirth: json['DateOfBirth'] ?? '',
    identificationCardType: json['IdentificationCardType'] ?? 0,
    identificationCardNumber: json['IdentificationCardNumber'] ?? '',
    identificationCardPlaceOfIssue:
        json['IdentificationCardPlaceOfIssue'] ?? '',
    identificationCardDateOfIssue: json['IdentificationCardDateOfIssue'] ?? '',
    type: TypeDTO.fromJson(json['Type'] ?? {}),
    contractTypeEnum: json['ContractTypeEnum'] ?? 0,
    contractType: ContractTypeDTO.fromJson(json['ContractType'] ?? {}),
    contractStartDate: json['ContractStartDate'] ?? '',
    contractEndDate: json['ContractEndDate'] ?? '',
    room: RoomDTO.fromJson(json['Room'] ?? {}),
    appointmentExecutionSpecialties:
        (json['AppointmentExecutionSpecalties'] as List?)
            ?.map((e) => e as int)
            .toList() ??
        [],
    appointmentVisualizationSpecialties:
        (json['AppointmentVisualizationSpecalties'] as List?)
            ?.map((e) => e as int)
            .toList() ??
        [],
    allowedAppointmentExecutionSpecialties:
        (json['AllowedAppointmentExecutionSpecialties'] as List?)
            ?.map((e) => SpecialtyDTO.fromJson(e))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'ShortName': shortName,
    'Group': group.toJson(),
    'Category': category,
    'Deleted': deleted,
    'DeletedAsString': deletedAsString,
    'UserID': userId,
    'UserAsString': userAsString,
    'FiscalNumber': fiscalNumber,
    'SocialSecurityNumber': socialSecurityNumber,
    'FixedPhoneNumbers': fixedPhoneNumbers,
    'CellPhoneNumbers': cellPhoneNumbers,
    'Emails': emails,
    'Address': address.toJson(),
    'Color': color,
    'Gender': gender,
    'CivilState': civilState,
    'DateOfBirth': dateOfBirth,
    'IdentificationCardType': identificationCardType,
    'IdentificationCardNumber': identificationCardNumber,
    'IdentificationCardPlaceOfIssue': identificationCardPlaceOfIssue,
    'IdentificationCardDateOfIssue': identificationCardDateOfIssue,
    'Type': type.toJson(),
    'ContractTypeEnum': contractTypeEnum,
    'ContractType': contractType.toJson(),
    'ContractStartDate': contractStartDate,
    'ContractEndDate': contractEndDate,
    'Room': room.toJson(),
    'AppointmentExecutionSpecalties': appointmentExecutionSpecialties,
    'AppointmentVisualizationSpecalties': appointmentVisualizationSpecialties,
    'AllowedAppointmentExecutionSpecialties':
        allowedAppointmentExecutionSpecialties.map((e) => e.toJson()).toList(),
  };
}

class GroupDTO {
  final int id;
  final String name;
  final int code;
  final String description;
  final bool deleted;

  GroupDTO({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.deleted,
  });

  factory GroupDTO.fromJson(Map<String, dynamic> json) => GroupDTO(
    id: json['ID'] ?? 0,
    name: json['Name'] ?? '',
    code: json['Code'] ?? 0,
    description: json['Description'] ?? '',
    deleted: json['Deleted'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Code': code,
    'Description': description,
    'Deleted': deleted,
  };
}

class TypeDTO extends GroupDTO {
  TypeDTO({
    required super.id,
    required super.name,
    required super.code,
    required super.description,
    required super.deleted,
  });

  factory TypeDTO.fromJson(Map<String, dynamic> json) => TypeDTO(
    id: json['ID'] ?? 0,
    name: json['Name'] ?? '',
    code: json['Code'] ?? 0,
    description: json['Description'] ?? '',
    deleted: json['Deleted'] ?? false,
  );
}

class ContractTypeDTO extends GroupDTO {
  ContractTypeDTO({
    required super.id,
    required super.name,
    required super.code,
    required super.description,
    required super.deleted,
  });

  factory ContractTypeDTO.fromJson(Map<String, dynamic> json) =>
      ContractTypeDTO(
        id: json['ID'] ?? 0,
        name: json['Name'] ?? '',
        code: json['Code'] ?? 0,
        description: json['Description'] ?? '',
        deleted: json['Deleted'] ?? false,
      );
}

class CivilStateDTO {
  final int id;
  final String name;
  final int code;
  final String description;
  final bool deleted;

  CivilStateDTO({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.deleted,
  });

  factory CivilStateDTO.fromJson(Map<String, dynamic> json) => CivilStateDTO(
    id: json['ID'] ?? 0,
    name: json['Name'] ?? '',
    code: json['Code'] ?? 0,
    description: json['Description'] ?? '',
    deleted: json['Deleted'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Code': code,
    'Description': description,
    'Deleted': deleted,
  };
}
