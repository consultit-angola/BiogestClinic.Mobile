class ServicesDTO {
  final int id;
  final String serviceCodeAndName;

  ServicesDTO({required this.id, required this.serviceCodeAndName});

  factory ServicesDTO.fromJson(Map<String, dynamic> json) => ServicesDTO(
    id: json['ID'] ?? 0,
    serviceCodeAndName: json['ServiceCodeAndName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'ServiceCodeAndName': serviceCodeAndName,
  };
}
