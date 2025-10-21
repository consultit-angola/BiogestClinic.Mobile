class StockDTO {
  final int id;
  final String name;
  final bool deleted;
  final String deletedAsString;
  final int code;
  final String description;

  StockDTO({
    required this.id,
    required this.name,
    required this.deleted,
    required this.deletedAsString,
    required this.code,
    required this.description,
  });

  factory StockDTO.fromJson(Map<String, dynamic> json) => StockDTO(
    id: json['ID'] ?? 0,
    name: json['Name'] ?? '',
    deleted: json['Deleted'] ?? false,
    deletedAsString: json['DeletedAsString'] ?? '',
    code: json['Code'] ?? 0,
    description: json['Description'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Deleted': deleted,
    'DeletedAsString': deletedAsString,
    'Code': code,
    'Description': description,
  };
}
