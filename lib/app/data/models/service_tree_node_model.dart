import 'service_option_model.dart';

class ServiceTreeNodeDTO {
  final String key;
  final String label;
  final int level;
  final bool isGroup;
  final ServiceOptionDTO? service;

  const ServiceTreeNodeDTO({
    required this.key,
    required this.label,
    required this.level,
    required this.isGroup,
    this.service,
  });
}

List<ServiceTreeNodeDTO> buildServiceTreeNodes(
  List<ServiceOptionDTO> services,
) {
  final groupedServices = <String, List<ServiceOptionDTO>>{};
  final groupLabels = <String, String>{};

  for (final service in services) {
    final groupKey = service.groupID?.toString() ?? 'without-group';
    groupedServices.putIfAbsent(groupKey, () => []).add(service);
    groupLabels[groupKey] = service.groupName.isNotEmpty
        ? service.groupName
        : 'Sem grupo';
  }

  final sortedGroupKeys = groupedServices.keys.toList()
    ..sort((a, b) => groupLabels[a]!.compareTo(groupLabels[b]!));
  final nodes = <ServiceTreeNodeDTO>[];

  for (final groupKey in sortedGroupKeys) {
    nodes.add(
      ServiceTreeNodeDTO(
        key: 'group-$groupKey',
        label: groupLabels[groupKey]!,
        level: 0,
        isGroup: true,
      ),
    );

    final children = groupedServices[groupKey]!
      ..sort((a, b) => a.name.compareTo(b.name));
    for (final service in children) {
      nodes.add(
        ServiceTreeNodeDTO(
          key: 'service-${service.id}',
          label: service.name,
          level: 1,
          isGroup: false,
          service: service,
        ),
      );
    }
  }

  return nodes;
}
