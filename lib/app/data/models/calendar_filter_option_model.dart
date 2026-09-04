class CalendarFilterOptionDTO {
  final int id;
  final String name;
  final int? parentID;
  final int? typeID;
  final int? roomID;
  final int? roomStoreID;
  final int? priceTableID;
  final bool isNotIdentifiedClient;
  final List<int> allowedSpecialtyIDs;

  const CalendarFilterOptionDTO({
    required this.id,
    required this.name,
    this.parentID,
    this.typeID,
    this.roomID,
    this.roomStoreID,
    this.priceTableID,
    this.isNotIdentifiedClient = false,
    this.allowedSpecialtyIDs = const [],
  });

  factory CalendarFilterOptionDTO.fromJson(Map<String, dynamic> json) {
    final store = json['Store'];
    final room = json['Room'];
    final type = json['Type'];
    return CalendarFilterOptionDTO(
      id: json['ID'] ?? 0,
      name:
          json['NameWithEntity'] ??
          json['Name'] ??
          json['ShortName'] ??
          json['NameAndType'] ??
          '',
      parentID: store is Map<String, dynamic> ? store['ID'] : null,
      typeID:
          _nullableInt(json['StoreTypeEnum']) ??
          (type is Map<String, dynamic> ? _nullableInt(type['ID']) : null),
      roomID: room is Map<String, dynamic> ? _nullableInt(room['ID']) : null,
      roomStoreID: room is Map<String, dynamic>
          ? _nestedInt(room['Store'], 'ID')
          : null,
      priceTableID: _nullableInt(json['PriceTableID']),
      isNotIdentifiedClient: json['IsNotIdentifiedClient'] == true,
      allowedSpecialtyIDs: _readAllowedSpecialtyIDs(
        json['AllowedAppointmentExecutionSpecialties'],
      ),
    );
  }
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  return value is int ? value : int.tryParse('$value');
}

int? _nestedInt(dynamic value, String key) {
  return value is Map<String, dynamic> ? _nullableInt(value[key]) : null;
}

List<int> _readAllowedSpecialtyIDs(dynamic value) {
  return (value as List?)
          ?.map((item) => item is Map<String, dynamic> ? item['ID'] : item)
          .map(_nullableInt)
          .whereType<int>()
          .toList() ??
      [];
}
