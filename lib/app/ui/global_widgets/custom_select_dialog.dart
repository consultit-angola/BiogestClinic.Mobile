import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/calendar_filter_option_model.dart';

Future<int?> showCustomSingleSelectDialog({
  required BuildContext context,
  required String title,
  required List<CalendarFilterOptionDTO> options,
  required int? selectedID,
  bool searchable = true,
  Future<List<CalendarFilterOptionDTO>> Function(String)? onRemoteSearch,
}) async {
  var search = '';
  var availableOptions = [...options];
  var searching = false;
  var searchVersion = 0;
  Timer? searchDebounce;
  final result = await showDialog<int>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final isRemoteSearch = onRemoteSearch != null;
        final visibleOptions = isRemoteSearch && search.trim().length >= 3
            ? availableOptions
            : availableOptions
                .where(
                  (option) => option.name.toLowerCase().contains(
                        search.toLowerCase(),
                      ),
                )
                .toList();
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: Column(
              children: [
                if (searchable) ...[
                  TextField(
                    autofocus: true,
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
                ],
                Expanded(
                  child: isRemoteSearch && search.trim().length < 3
                      ? const Center(
                          child: Text('Introduza pelo menos 3 letras'),
                        )
                      : !searching && visibleOptions.isEmpty
                          ? const Center(child: Text('Nenhum resultado'))
                          : ListView(
                              primary: false,
                              children: [
                                ...visibleOptions.map(
                                  (option) => ListTile(
                                    leading: Icon(
                                      option.id == selectedID
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                    ),
                                    title: Text(option.name),
                                    onTap: () =>
                                        Navigator.pop(dialogContext, option.id),
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
  searchDebounce?.cancel();
  return result;
}

Future<Set<int>?> showCustomMultiSelectDialog({
  required BuildContext context,
  required String title,
  required List<CalendarFilterOptionDTO> options,
  required Set<int> selectedIDs,
  Future<List<CalendarFilterOptionDTO>> Function(String)? onRemoteSearch,
  int remoteSearchMinLength = 3,
  Widget Function(
    BuildContext context,
    List<CalendarFilterOptionDTO> options,
    Set<int> selected,
    void Function(int id, bool selected) onSelectionChanged,
  )? optionsBuilder,
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
        final visibleOptions =
            isRemoteSearch && search.trim().length >= remoteSearchMinLength
                ? availableOptions
                : availableOptions
                    .where(
                      (option) => option.name.toLowerCase().contains(
                            search.toLowerCase(),
                          ),
                    )
                    .toList();
        void changeSelection(int id, bool checked) {
          setDialogState(() {
            if (checked) {
              selected.add(id);
            } else {
              selected.remove(id);
            }
          });
        }

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
                        ? remoteSearchMinLength == 0
                            ? 'Pesquisar'
                            : 'Introduza pelo menos 3 letras'
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
                      if (isRemoteSearch &&
                          value.trim().length < remoteSearchMinLength) {
                        searching = false;
                      }
                    });
                    if (!isRemoteSearch ||
                        value.trim().length < remoteSearchMinLength) {
                      return;
                    }

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
                  child: isRemoteSearch &&
                          search.trim().length < remoteSearchMinLength
                      ? Center(
                          child: Text(
                            'Introduza pelo menos $remoteSearchMinLength letras',
                          ),
                        )
                      : !searching && visibleOptions.isEmpty
                          ? const Center(child: Text('Nenhum resultado'))
                          : optionsBuilder != null
                              ? optionsBuilder(
                                  context,
                                  visibleOptions,
                                  selected,
                                  changeSelection,
                                )
                              : ListView.builder(
                                  primary: false,
                                  itemCount: visibleOptions.length,
                                  itemBuilder: (context, index) {
                                    final option = visibleOptions[index];
                                    return CheckboxListTile(
                                      value: selected.contains(option.id),
                                      title: Text(option.name),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      onChanged: (checked) => changeSelection(
                                          option.id, checked == true),
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
