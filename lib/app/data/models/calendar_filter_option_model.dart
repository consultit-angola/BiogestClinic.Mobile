class CalendarFilterOptionDTO {
  final int id;
  final String name;
  final int? parentID;

  const CalendarFilterOptionDTO({
    required this.id,
    required this.name,
    this.parentID,
  });

  factory CalendarFilterOptionDTO.fromJson(Map<String, dynamic> json) {
    final store = json['Store'];
    return CalendarFilterOptionDTO(
      id: json['ID'] ?? 0,
      name: json['Name'] ?? json['ShortName'] ?? json['NameAndType'] ?? '',
      parentID: store is Map<String, dynamic> ? store['ID'] : null,
    );
  }
}
