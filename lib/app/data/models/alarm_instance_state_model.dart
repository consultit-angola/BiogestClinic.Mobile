class AlarmInstanceStateDTO {
  final int? id;
  final String? name;

  AlarmInstanceStateDTO({this.id, this.name});

  factory AlarmInstanceStateDTO.fromJson(Map<String, dynamic> json) {
    return AlarmInstanceStateDTO(
      id: json['ID'] as int?,
      name: json['Name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'ID': id, 'Name': name};
  }
}
