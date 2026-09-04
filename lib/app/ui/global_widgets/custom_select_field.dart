import 'package:flutter/material.dart';

import '../../data/models/calendar_filter_option_model.dart';
import 'custom_select_dialog.dart';

class CustomSingleSelectField extends StatelessWidget {
  final String label;
  final List<CalendarFilterOptionDTO> options;
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool loading;
  final Future<void> Function()? onRefresh;
  final bool searchable;
  final Future<List<CalendarFilterOptionDTO>> Function(String)? onRemoteSearch;
  final String? emptyOptionText;
  final bool? withEmptyOptionText;

  const CustomSingleSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.loading,
    required this.onRefresh,
    this.searchable = false,
    this.onRemoteSearch,
    this.emptyOptionText,
    this.withEmptyOptionText = true,
  });

  @override
  Widget build(BuildContext context) {
    final selected = options.where((option) => option.id == value).firstOrNull;
    final hasSelectedValue = selected != null;
    final showLabelInside = !hasSelectedValue && withEmptyOptionText != true;
    final emptyText = withEmptyOptionText == true
        ? emptyOptionText ?? 'Todos os ${label.toLowerCase()}'
        : label;

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
                  onRemoteSearch: onRemoteSearch,
                );
                if (result != null) {
                  onChanged(result);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: showLabelInside ? null : label,
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
          if (onRefresh != null)
            CustomRefreshButton(loading: loading, onRefresh: onRefresh!),
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
  final Future<void> Function()? onRefresh;
  final Future<List<CalendarFilterOptionDTO>> Function(String)? onRemoteSearch;
  final Future<List<CalendarFilterOptionDTO>> Function()? onBeforeOpen;
  final int remoteSearchMinLength;
  final Widget Function(
    BuildContext context,
    List<CalendarFilterOptionDTO> options,
    Set<int> selected,
    void Function(int id, bool selected) onSelectionChanged,
  )?
  optionsBuilder;
  final VoidCallback? onClear;
  final String? emptyOptionText;
  final String? selectedTextOverride;
  final bool? withEmptyOptionText;
  final bool enabled;
  final int maxLines;

  const CustomMultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedIDs,
    required this.onChanged,
    required this.loading,
    required this.onRefresh,
    this.onRemoteSearch,
    this.onBeforeOpen,
    this.remoteSearchMinLength = 3,
    this.optionsBuilder,
    this.onClear,
    this.emptyOptionText,
    this.selectedTextOverride,
    this.withEmptyOptionText = true,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final selectedNames = options
        .where((option) => selectedIDs.contains(option.id))
        .map((option) => option.name)
        .join(', ');
    final hasSelectedValue = selectedNames.isNotEmpty || selectedIDs.isNotEmpty;
    final showLabelInside = !hasSelectedValue && withEmptyOptionText != true;
    final emptyText = withEmptyOptionText == true
        ? emptyOptionText ?? 'Todos os ${label.toLowerCase()}'
        : label;
    final selectedText = selectedTextOverride?.isNotEmpty == true
        ? selectedTextOverride!
        : selectedNames.isNotEmpty
        ? selectedNames
        : selectedIDs.isEmpty
        ? emptyText
        : '${selectedIDs.length} selecionado(s)';
    Widget selectedTextWidget = Text(
      selectedText,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );

    if (maxLines > 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: selectedText,
          style: DefaultTextStyle.of(context).style,
        ),
        textDirection: Directionality.of(context),
      );
      final maxTextHeight = textPainter.preferredLineHeight * maxLines;
      textPainter.dispose();

      selectedTextWidget = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxTextHeight),
        child: Scrollbar(
          child: SingleChildScrollView(
            primary: false,
            child: Text(selectedText),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: enabled
                  ? () async {
                      var dialogOptions = options;
                      final loadedOptions = await onBeforeOpen?.call();
                      if (!context.mounted) return;
                      if (loadedOptions != null) {
                        dialogOptions = loadedOptions;
                      }
                      final result = await showCustomMultiSelectDialog(
                        context: context,
                        title: label,
                        options: dialogOptions,
                        selectedIDs: selectedIDs,
                        onRemoteSearch: onRemoteSearch,
                        remoteSearchMinLength: remoteSearchMinLength,
                        optionsBuilder: optionsBuilder,
                      );
                      if (result != null) onChanged(result);
                    }
                  : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: showLabelInside ? null : label,
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_drop_down),
                      IconButton(
                        tooltip: 'Limpar selecao',
                        onPressed: enabled
                            ? onClear ?? () => onChanged({})
                            : null,
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ),
                ),
                child: selectedTextWidget,
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (onRefresh != null)
            CustomRefreshButton(loading: loading, onRefresh: onRefresh!),
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
