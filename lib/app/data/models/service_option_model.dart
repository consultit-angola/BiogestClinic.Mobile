import 'calendar_filter_option_model.dart';

class ServiceOptionDTO {
  final int id;
  final String name;
  final int? groupID;
  final String groupName;

  const ServiceOptionDTO({
    required this.id,
    required this.name,
    this.groupID,
    this.groupName = '',
  });

  ServiceOptionDTO copyWith({
    int? id,
    String? name,
    int? groupID,
    String? groupName,
  }) {
    return ServiceOptionDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      groupID: groupID ?? this.groupID,
      groupName: groupName ?? this.groupName,
    );
  }

  factory ServiceOptionDTO.fromJson(Map<String, dynamic> json) {
    final group = json['Group'] is Map<String, dynamic>
        ? json['Group'] as Map<String, dynamic>
        : null;
    return ServiceOptionDTO(
      id: _int(json['ID']),
      name: _string(
        json['CodeAndName'] ??
            json['ServiceCodeAndName'] ??
            json['Name'] ??
            json['Description'],
      ),
      groupID: _nullableInt(group?['ID'] ?? json['GroupID']),
      groupName: _string(
        group?['CodeAndName'] ??
            group?['Name'] ??
            json['ServiceGroupCodeAndName'] ??
            json['GroupCodeAndName'] ??
            json['GroupName'],
      ),
    );
  }
}

class ServiceGroupOptionDTO {
  final int id;
  final String name;

  const ServiceGroupOptionDTO({required this.id, required this.name});

  factory ServiceGroupOptionDTO.fromJson(Map<String, dynamic> json) {
    return ServiceGroupOptionDTO(
      id: _int(json['ID']),
      name: _string(json['CodeAndName'] ?? json['Name']),
    );
  }
}

class ServiceCalendarFilterOptionDTO extends CalendarFilterOptionDTO {
  final ServiceOptionDTO service;

  ServiceCalendarFilterOptionDTO(this.service)
      : super(id: service.id, name: service.name);
}

class ServiceGroupCalendarFilterOptionDTO extends CalendarFilterOptionDTO {
  final ServiceGroupOptionDTO group;

  ServiceGroupCalendarFilterOptionDTO(this.group)
      : super(id: -group.id, name: group.name);
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse('$value');
}

String _string(dynamic value) => value?.toString().trim() ?? '';
