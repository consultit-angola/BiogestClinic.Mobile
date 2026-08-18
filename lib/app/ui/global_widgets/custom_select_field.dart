import 'package:flutter/material.dart';

import '../../data/models/calendar_filter_option_model.dart';
import 'custom_select_dialog.dart';

class CustomSingleSelectField extends StatelessWidget {
  final String label;
  final List<CalendarFilterOptionDTO> options;
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool loading;
  final Future<void> Function() onRefresh;
  final bool searchable;
  final String? emptyOptionText;

  const CustomSingleSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.loading,
    required this.onRefresh,
    this.searchable = false,
    this.emptyOptionText,
  });

  @override
  Widget build(BuildContext context) {
    final selected = options.where((option) => option.id == value).firstOrNull;
    final emptyText = emptyOptionText ?? 'Todos os ${label.toLowerCase()}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final result = await showCustomSingleSelectDialog(
                  context: context,
                  title: label,
                  options: options,
                  selectedID: value,
                  searchable: searchable,
                );
                if (result != null) {
                  onChanged(result);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  suffixIcon: _suffixIcon(onClear: () => onChanged(null)),
                ),
                child: Text(
                  selected?.name ?? emptyText,
                  style: selected == null
                      ? Theme.of(context).inputDecorationTheme.hintStyle
                      : null,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          CustomRefreshButton(loading: loading, onRefresh: onRefresh),
        ],
      ),
    );
  }

  Widget _suffixIcon({VoidCallback? onClear}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_drop_down),
        _clearIcon(onClear: onClear),
      ],
    );
  }

  Widget _clearIcon({VoidCallback? onClear}) {
    return IconButton(
      tooltip: 'Limpar selecao',
      onPressed: onClear,
      icon: const Icon(Icons.clear),
    );
  }
}

class CustomMultiSelectField extends StatelessWidget {
  final String label;
  final List<CalendarFilterOptionDTO> options;
  final Set<int> selectedIDs;
  final ValueChanged<Set<int>> onChanged;
  final bool loading;
  final Future<void> Function() onRefresh;
  final Future<List<CalendarFilterOptionDTO>> Function(String)? onRemoteSearch;
  final VoidCallback? onClear;
  final String? emptyOptionText;

  const CustomMultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedIDs,
    required this.onChanged,
    required this.loading,
    required this.onRefresh,
    this.onRemoteSearch,
    this.onClear,
    this.emptyOptionText,
  });

  @override
  Widget build(BuildContext context) {
    final selectedNames = options
        .where((option) => selectedIDs.contains(option.id))
        .map((option) => option.name)
        .join(', ');
    final selectedText = selectedNames.isNotEmpty
        ? selectedNames
        : selectedIDs.isEmpty
        ? (emptyOptionText ?? 'Todos os ${label.toLowerCase()}')
        : '${selectedIDs.length} selecionado(s)';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final result = await showCustomMultiSelectDialog(
                  context: context,
                  title: label,
                  options: options,
                  selectedIDs: selectedIDs,
                  onRemoteSearch: onRemoteSearch,
                );
                if (result != null) onChanged(result);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_drop_down),
                      IconButton(
                        tooltip: 'Limpar selecao',
                        onPressed: onClear ?? () => onChanged({}),
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ),
                ),
                child: Text(
                  selectedText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          CustomRefreshButton(loading: loading, onRefresh: onRefresh),
        ],
      ),
    );
  }
}

class CustomRefreshButton extends StatelessWidget {
  final bool loading;
  final Future<void> Function() onRefresh;

  const CustomRefreshButton({
    super.key,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Recarregar opções',
      onPressed: loading ? null : onRefresh,
      icon: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
    );
  }
}
