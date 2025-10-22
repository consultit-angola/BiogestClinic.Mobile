class AttachmentDTO {
  final int id;
  final String name;
  final String data;

  AttachmentDTO({required this.id, required this.name, required this.data});

  factory AttachmentDTO.fromJson(Map<String, dynamic> json) {
    return AttachmentDTO(
      id: json['ID'] ?? 0,
      name: json['Name'] ?? '',
      data: json['Data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ID': id, 'Name': name, 'Data': data};
  }
}
