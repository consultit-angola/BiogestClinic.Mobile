class SpecialtyDTO {
  final int id;
  final String name;
  final int enumValue;
  final int code;
  final String description;
  final bool deleted;

  SpecialtyDTO({
    required this.id,
    required this.name,
    required this.enumValue,
    required this.code,
    required this.description,
    required this.deleted,
  });

  factory SpecialtyDTO.fromJson(Map<String, dynamic> json) => SpecialtyDTO(
    id: json['ID'] ?? 0,
    name: json['Name'] ?? '',
    enumValue: json['Enum'] ?? 0,
    code: json['Code'] ?? 0,
    description: json['Description'] ?? '',
    deleted: json['Deleted'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Enum': enumValue,
    'Code': code,
    'Description': description,
    'Deleted': deleted,
  };
}
