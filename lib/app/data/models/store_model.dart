import 'dart:convert';

class StoreDTO {
  final int id;
  final String name;
  final String stringID;
  final String companyInfo;
  final int billingClientID;
  final ExtendedDataDTO extendedData;
  final int storeTypeEnum;
  final int code;
  final String description;
  final bool deleted;
  final DateTime nextDoctorRoundDateTime;

  StoreDTO({
    required this.id,
    required this.name,
    required this.stringID,
    required this.companyInfo,
    required this.billingClientID,
    required this.extendedData,
    required this.storeTypeEnum,
    required this.code,
    required this.description,
    required this.deleted,
    required this.nextDoctorRoundDateTime,
  });

  factory StoreDTO.fromJson(Map<String, dynamic> json) => StoreDTO(
    id: json["ID"] ?? 0,
    name: json["Name"] ?? "",
    stringID: json["StringID"] ?? "",
    companyInfo: json["CompanyInfo"] ?? "",
    billingClientID: json["BillingClientID"] ?? 0,
    extendedData: ExtendedDataDTO.fromJson(json["ExtendedData"] ?? {}),
    storeTypeEnum: json["StoreTypeEnum"] ?? 0,
    code: json["Code"] ?? 0,
    description: json["Description"] ?? "",
    deleted: json["Deleted"] ?? false,
    nextDoctorRoundDateTime:
        DateTime.tryParse(json["NextDoctorRoundDateTime"] ?? "") ??
        DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "Name": name,
    "StringID": stringID,
    "CompanyInfo": companyInfo,
    "BillingClientID": billingClientID,
    "ExtendedData": extendedData.toJson(),
    "StoreTypeEnum": storeTypeEnum,
    "Code": code,
    "Description": description,
    "Deleted": deleted,
    "NextDoctorRoundDateTime": nextDoctorRoundDateTime.toIso8601String(),
  };

  static List<StoreDTO> fromJsonList(String jsonString) {
    final data = json.decode(jsonString);
    return List<StoreDTO>.from(data.map((x) => StoreDTO.fromJson(x)));
  }
}

class StoreExtendedDataDTO {
  final String address;
  final String location;
  final String contacts;
  final List<int> consumptionStockIDs;
  final String doctorsRoundTime;

  StoreExtendedDataDTO({
    required this.address,
    required this.location,
    required this.contacts,
    required this.consumptionStockIDs,
    required this.doctorsRoundTime,
  });

  factory StoreExtendedDataDTO.fromJson(Map<String, dynamic> json) =>
      StoreExtendedDataDTO(
        address: json['Address'] ?? '',
        location: json['Location'] ?? '',
        contacts: json['Contacts'] ?? '',
        consumptionStockIDs: List<int>.from(json['ConsumptionStockIDs'] ?? []),
        doctorsRoundTime: json['DoctorsRoundTime'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'Address': address,
    'Location': location,
    'Contacts': contacts,
    'ConsumptionStockIDs': consumptionStockIDs,
    'DoctorsRoundTime': doctorsRoundTime,
  };
}

class ExtendedDataDTO {
  final String address;
  final String location;
  final String contacts;
  final List<int> consumptionStockIDs;
  final String doctorsRoundTime;

  ExtendedDataDTO({
    required this.address,
    required this.location,
    required this.contacts,
    required this.consumptionStockIDs,
    required this.doctorsRoundTime,
  });

  factory ExtendedDataDTO.fromJson(Map<String, dynamic> json) =>
      ExtendedDataDTO(
        address: json["Address"] ?? "",
        location: json["Location"] ?? "",
        contacts: json["Contacts"] ?? "",
        consumptionStockIDs:
            (json["ConsumptionStockIDs"] as List?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        doctorsRoundTime: json["DoctorsRoundTime"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "Address": address,
    "Location": location,
    "Contacts": contacts,
    "ConsumptionStockIDs": consumptionStockIDs,
    "DoctorsRoundTime": doctorsRoundTime,
  };
}
