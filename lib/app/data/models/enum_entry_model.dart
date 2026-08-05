class EnumEntryDTO {
  final int id;
  final String name;

  const EnumEntryDTO({required this.id, required this.name});

  factory EnumEntryDTO.fromJson(Map<String, dynamic> json) {
    return EnumEntryDTO(id: json['ID'] as int, name: json['Name'] as String);
  }
}
