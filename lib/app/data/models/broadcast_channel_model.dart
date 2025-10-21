class BroadcastChannelDTO {
  final int id;
  final String name;

  BroadcastChannelDTO({required this.id, required this.name});

  factory BroadcastChannelDTO.fromJson(Map<String, dynamic> json) =>
      BroadcastChannelDTO(id: json['ID'] ?? 0, name: json['Name'] ?? '');

  Map<String, dynamic> toJson() => {'ID': id, 'Name': name};
}
