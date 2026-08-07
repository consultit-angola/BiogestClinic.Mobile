import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/calendar_filter_option_model.dart';

Future<int?> showCustomSingleSelectDialog({
  required BuildContext context,
  required String title,
  required List<CalendarFilterOptionDTO> options,
  required int? selectedID,
  String? emptyOptionText,
}) {
  var search = '';
  return showDialog<int>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final visibleOptions = options
            .where(
              (option) =>
                  option.name.toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setDialogState(() => search = value),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    primary: false,
                    children: [
                      ListTile(
                        leading: Icon(
                          selectedID == null
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(
                          emptyOptionText ?? 'Todos os ${title.toLowerCase()}',
                        ),
                        onTap: () => Navigator.pop(dialogContext, 0),
                      ),
                      ...visibleOptions.map(
                        (option) => ListTile(
                          leading: Icon(
                            option.id == selectedID
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                          ),
                          title: Text(option.name),
                          onTap: () => Navigator.pop(dialogContext, option.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    ),
  );
}

Future<Set<int>?> showCustomMultiSelectDialog({
  required BuildContext context,
  required String title,
  required List<CalendarFilterOptionDTO> options,
  required Set<int> selectedIDs,
  Future<List<CalendarFilterOptionDTO>> Function(String)? onRemoteSearch,
}) async {
  var selected = {...selectedIDs};
  var search = '';
  var availableOptions = [...options];
  var searching = false;
  var searchVersion = 0;
  Timer? searchDebounce;
  final result = await showDialog<Set<int>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final isRemoteSearch = onRemoteSearch != null;
        final visibleOptions = availableOptions
            .where(
              (option) =>
                  option.name.toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: isRemoteSearch
                        ? 'Introduza pelo menos 3 letras'
                        : 'Pesquisar',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    searchDebounce?.cancel();
                    final currentVersion = ++searchVersion;
                    setDialogState(() {
                      search = value;
                      if (isRemoteSearch && value.trim().length < 3) {
                        searching = false;
                      }
                    });
                    if (!isRemoteSearch || value.trim().length < 3) return;

                    searchDebounce = Timer(
                      const Duration(milliseconds: 400),
                      () async {
                        if (!dialogContext.mounted) return;
                        setDialogState(() => searching = true);
                        final loadedOptions = await onRemoteSearch(
                          value.trim(),
                        );
                        if (!dialogContext.mounted ||
                            currentVersion != searchVersion) {
                          return;
                        }
                        setDialogState(() {
                          availableOptions = loadedOptions;
                          searching = false;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: isRemoteSearch && search.trim().length < 3
                      ? const Center(
                          child: Text('Introduza pelo menos 3 letras'),
                        )
                      : !searching && visibleOptions.isEmpty
                      ? const Center(child: Text('Nenhum resultado'))
                      : ListView.builder(
                          primary: false,
                          itemCount: visibleOptions.length,
                          itemBuilder: (context, index) {
                            final option = visibleOptions[index];
                            return CheckboxListTile(
                              value: selected.contains(option.id),
                              title: Text(option.name),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (checked) => setDialogState(() {
                                if (checked == true) {
                                  selected.add(option.id);
                                } else {
                                  selected.remove(option.id);
                                }
                              }),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => setDialogState(() => selected.clear()),
              child: const Text('Limpar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, selected),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    ),
  );
  searchDebounce?.cancel();
  return result;
}
