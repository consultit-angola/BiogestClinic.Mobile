import 'package:flutter/material.dart';

import '../../data/models/calendar_filter_option_model.dart';
import '../../data/models/service_option_model.dart';

class ServiceTreeMultiSelect extends StatefulWidget {
  final List<CalendarFilterOptionDTO> options;
  final Set<int> selectedIDs;
  final Future<List<ServiceOptionDTO>> Function(int groupID)
  onLoadGroupServices;
  final Future<List<ServiceOptionDTO>> Function(int groupID)
  onLoadMoreGroupServices;
  final bool Function(int groupID) hasMoreGroupServices;
  final void Function(int id, bool selected) onSelectionChanged;
  final String searchTerm;

  const ServiceTreeMultiSelect({
    super.key,
    required this.options,
    required this.selectedIDs,
    required this.onLoadGroupServices,
    required this.onLoadMoreGroupServices,
    required this.hasMoreGroupServices,
    required this.onSelectionChanged,
    this.searchTerm = '',
  });

  @override
  State<ServiceTreeMultiSelect> createState() => _ServiceTreeMultiSelectState();
}

class _ServiceTreeMultiSelectState extends State<ServiceTreeMultiSelect> {
  final Set<int> _expandedGroupIDs = {};
  final Set<int> _loadingGroupIDs = {};
  final Set<int> _loadedGroupIDs = {};
  final Map<int, List<ServiceOptionDTO>> _servicesByGroupID = {};

  @override
  void initState() {
    super.initState();
    _resetOptions();
  }

  @override
  void didUpdateWidget(covariant ServiceTreeMultiSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    final searchChanged = oldWidget.searchTerm != widget.searchTerm;
    final searchResultsChanged =
        widget.searchTerm.trim().isNotEmpty &&
        !_haveSameOptionIDs(oldWidget.options, widget.options);
    if (searchChanged || searchResultsChanged) {
      _resetOptions();
      return;
    }
    _syncOptions(widget.options);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupOptions();
    final servicesWithoutGroups = _serviceOptions()
        .where((service) => service.groupID == null)
        .toList();

    if (groups.isEmpty && servicesWithoutGroups.isEmpty) {
      return const Center(child: Text('Nenhum resultado'));
    }

    return ListView(
      primary: false,
      children: [
        ...groups.map((group) => _groupTile(context, group)),
        ...servicesWithoutGroups.map((service) => _serviceTile(service)),
      ],
    );
  }

  Widget _groupTile(BuildContext context, ServiceGroupOptionDTO group) {
    final services = _servicesByGroupID[group.id] ?? [];
    final groupMarkerID = -group.id;
    final loaded = _loadedGroupIDs.contains(group.id);
    final expanded = _expandedGroupIDs.contains(group.id);
    final loading = _loadingGroupIDs.contains(group.id);
    final selected = _groupSelectionValue(groupMarkerID, services);
    final hasMore = widget.hasMoreGroupServices(group.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          dense: true,
          tristate: true,
          value: selected,
          title: Text(
            group.name,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
          secondary: IconButton(
            tooltip: expanded ? 'Contrair' : 'Expandir',
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onPressed: loading ? null : () => _toggleGroup(group.id),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) => _changeGroupSelection(
            groupMarkerID: groupMarkerID,
            services: services,
            selected: checked == true,
          ),
        ),
        if (expanded && loaded)
          ...services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(left: 28),
              child: _serviceTile(service),
            ),
          ),
        if (expanded && loaded && hasMore)
          Padding(
            padding: const EdgeInsets.only(left: 56, right: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: loading ? null : () => _loadMoreGroup(group.id),
                icon: const Icon(Icons.expand_more),
                label: const Text('Carregar mais'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _serviceTile(ServiceOptionDTO service) {
    return CheckboxListTile(
      dense: true,
      value: widget.selectedIDs.contains(service.id),
      title: Text(service.name, overflow: TextOverflow.ellipsis),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) =>
          _changeServiceSelection(service: service, selected: checked == true),
    );
  }

  bool? _groupSelectionValue(
    int groupMarkerID,
    List<ServiceOptionDTO> services,
  ) {
    if (widget.selectedIDs.contains(groupMarkerID)) return true;
    if (services.isEmpty) return false;

    final selectedCount = services
        .where((service) => widget.selectedIDs.contains(service.id))
        .length;
    if (selectedCount == 0) return false;
    if (selectedCount == services.length) return true;
    return null;
  }

  void _changeGroupSelection({
    required int groupMarkerID,
    required List<ServiceOptionDTO> services,
    required bool selected,
  }) {
    widget.onSelectionChanged(groupMarkerID, selected);
    for (final service in services) {
      widget.onSelectionChanged(service.id, selected);
    }
  }

  void _changeServiceSelection({
    required ServiceOptionDTO service,
    required bool selected,
  }) {
    final groupID = service.groupID;
    if (groupID != null) {
      widget.onSelectionChanged(-groupID, false);
    }
    widget.onSelectionChanged(service.id, selected);
  }

  Future<void> _toggleGroup(int groupID) async {
    if (_expandedGroupIDs.contains(groupID)) {
      setState(() => _expandedGroupIDs.remove(groupID));
      return;
    }

    setState(() => _expandedGroupIDs.add(groupID));
    if (_loadedGroupIDs.contains(groupID)) return;

    setState(() => _loadingGroupIDs.add(groupID));
    final services = await widget.onLoadGroupServices(groupID);
    if (!mounted) return;
    setState(() {
      _servicesByGroupID[groupID] = services;
      _loadedGroupIDs.add(groupID);
      _loadingGroupIDs.remove(groupID);
    });

    if (widget.selectedIDs.contains(-groupID)) {
      for (final service in services) {
        widget.onSelectionChanged(service.id, true);
      }
    }
  }

  Future<void> _loadMoreGroup(int groupID) async {
    setState(() => _loadingGroupIDs.add(groupID));
    final services = await widget.onLoadMoreGroupServices(groupID);
    if (!mounted) return;
    setState(() {
      _servicesByGroupID[groupID] = services;
      _loadedGroupIDs.add(groupID);
      _loadingGroupIDs.remove(groupID);
    });

    if (widget.selectedIDs.contains(-groupID)) {
      for (final service in services) {
        widget.onSelectionChanged(service.id, true);
      }
    }
  }

  List<ServiceGroupOptionDTO> _groupOptions() {
    final groups = widget.options
        .whereType<ServiceGroupCalendarFilterOptionDTO>()
        .map((option) => option.group)
        .toList();
    final serviceGroups = _serviceOptions()
        .where(
          (service) => service.groupID != null && service.groupName.isNotEmpty,
        )
        .map(
          (service) => ServiceGroupOptionDTO(
            id: service.groupID!,
            name: service.groupName,
          ),
        );
    final groupsByID = <int, ServiceGroupOptionDTO>{};

    for (final group in [...groups, ...serviceGroups]) {
      groupsByID[group.id] = group;
    }

    return groupsByID.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  List<ServiceOptionDTO> _serviceOptions() {
    return widget.options
        .whereType<ServiceCalendarFilterOptionDTO>()
        .map((option) => option.service)
        .toList();
  }

  void _syncOptions(List<CalendarFilterOptionDTO> options) {
    for (final option in options.whereType<ServiceCalendarFilterOptionDTO>()) {
      final groupID = option.service.groupID;
      if (groupID == null) continue;
      final services = _servicesByGroupID.putIfAbsent(groupID, () => []);
      if (!services.any((service) => service.id == option.service.id)) {
        services.add(option.service);
        services.sort((a, b) => a.name.compareTo(b.name));
      }
    }
  }

  void _resetOptions() {
    _expandedGroupIDs.clear();
    _loadingGroupIDs.clear();
    _loadedGroupIDs.clear();
    _servicesByGroupID.clear();
    _syncOptions(widget.options);

    if (widget.searchTerm.trim().isEmpty) return;
    _expandedGroupIDs.addAll(_servicesByGroupID.keys);
    _loadedGroupIDs.addAll(_servicesByGroupID.keys);
  }

  bool _haveSameOptionIDs(
    List<CalendarFilterOptionDTO> previous,
    List<CalendarFilterOptionDTO> current,
  ) {
    if (previous.length != current.length) return false;
    final previousIDs = previous.map((option) => option.id).toSet();
    final currentIDs = current.map((option) => option.id).toSet();
    return previousIDs.length == currentIDs.length &&
        previousIDs.containsAll(currentIDs);
  }
}
