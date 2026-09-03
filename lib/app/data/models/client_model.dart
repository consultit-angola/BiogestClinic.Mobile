class ClientDTO {
  final int id;
  final String stringID;
  final String name;
  final String nameWithEntity;
  final String phoneNumber;
  final String fiscalNumber;
  final String entityAsString;
  final String priceTableName;
  final String clientIdentificationDocument;
  final String email;
  final String currentAgeAsString;
  final int? gender;
  final bool isDeleted;

  ClientDTO({
    required this.id,
    required this.stringID,
    required this.name,
    required this.nameWithEntity,
    required this.phoneNumber,
    required this.fiscalNumber,
    required this.entityAsString,
    required this.priceTableName,
    required this.clientIdentificationDocument,
    required this.email,
    required this.currentAgeAsString,
    this.gender,
    required this.isDeleted,
  });

  factory ClientDTO.fromJson(Map<String, dynamic> json) {
    final id = json['ID'] ?? json['ClientID'] ?? 0;
    return ClientDTO(
      id: id is int ? id : int.tryParse('$id') ?? 0,
      stringID: _string(json['StringID'] ?? json['ID'] ?? json['ClientID']),
      name: _string(json['Name'] ?? json['ClientName']),
      nameWithEntity: _string(json['NameWithEntity'] ?? json['Name']),
      phoneNumber: _string(json['PhoneNumber'] ?? json['ClientPhoneNumber']),
      fiscalNumber: _string(json['FiscalNumber']),
      entityAsString: _string(json['EntityAsString']),
      priceTableName: _string(json['PriceTableName']),
      clientIdentificationDocument: _string(
        json['ClientIdentificationDocument'],
      ),
      email: _string(json['Email']),
      currentAgeAsString: _string(json['CurrentAgeAsString']),
      gender: json['Gender'] is int
          ? json['Gender'] as int
          : int.tryParse(_string(json['Gender'])),
      isDeleted: json['IsDeleted'] == true,
    );
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';
}
