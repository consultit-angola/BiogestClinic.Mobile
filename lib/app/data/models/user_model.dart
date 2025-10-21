class UserInfoDTO {
  final int id;
  final String login;
  final String name;
  final String email;
  final String phone;
  final bool deleted;
  final int groupId;
  final List<int>? storeIds;
  final String shortName;
  final String groupName;

  UserInfoDTO({
    required this.id,
    required this.login,
    required this.name,
    required this.email,
    required this.phone,
    required this.deleted,
    required this.groupId,
    this.storeIds,
    required this.shortName,
    required this.groupName,
  });

  factory UserInfoDTO.fromJson(Map<String, dynamic> json) => UserInfoDTO(
    id: json['ID'] ?? 0,
    login: json['Login'] ?? '',
    name: json['Name'] ?? '',
    email: json['Email'] ?? '',
    phone: json['Phone'] ?? '',
    deleted: json['Deleted'] ?? false,
    groupId: json['GroupID'] ?? 0,
    storeIds: (json['StoreIDs'] as List?)?.map((e) => e as int).toList(),
    shortName: json['ShortName'] ?? '',
    groupName: json['GroupName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Login': login,
    'Name': name,
    'Email': email,
    'Phone': phone,
    'Deleted': deleted,
    'GroupID': groupId,
    'StoreIDs': storeIds,
    'ShortName': shortName,
    'GroupName': groupName,
  };
}
