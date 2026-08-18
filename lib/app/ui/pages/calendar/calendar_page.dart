import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

import '../../../controllers/index.dart';
import '../../index.dart';

class CalendarPage extends GetView<CalendarController> {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
      builder: (calendarController) => Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        drawer: customDrawer(),
        body: Column(
          children: [
            customAppbar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => RefreshIndicator(
                  onRefresh: () => calendarController.refreshAppointments(),
                  child: ListView(
                    primary: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: constraints.maxHeight,
                        child: Column(
                          children: [
                            calendarFilters(calendarController, context),
                            Expanded(child: Obx(calendar)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: customMenu(alignBottom: false),
      ),
    );
  }

  Widget calendarFilters(
    CalendarController calendarController,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            tooltip: 'Filtros',
            icon: calendarController.loadingFilterOptions
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomColors.primaryDarkerColor,
                    ),
                  )
                : Icon(
                    Icons.filter_list,
                    color: CustomColors.primaryDarkerColor,
                  ),
            onPressed: calendarController.loadingFilterOptions
                ? null
                : () => _openFilters(context),
          ),
        ),
      ),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final navigator = Navigator.of(context);

    var employeeIDs = {...controller.selectedEmployeeIDs};
    var storeID = controller.selectedStoreID;
    var roomID = controller.selectedRoomID;
    var stateIDs = {...controller.selectedStateIDs};
    var medicalSpecialtyID = controller.selectedMedicalSpecialtyID;
    var clientIDs = {...controller.selectedClientIDs};
    var showCanceled = controller.showCanceled;

    await showModalBottomSheet<void>(
      context: navigator.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final availableRooms = controller.roomsForStore(storeID);
          return Container(
            height: MediaQuery.sizeOf(context).height * 0.82,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Filtros do calendário',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      primary: false,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (controller.canViewOtherUsersAppointments)
                          CustomMultiSelectField(
                            label: 'Médicos',
                            options: controller.employees,
                            selectedIDs: employeeIDs,
                            loading: controller.loadingEmployees,
                            onClear: () {
                              controller.clearEmployeeSearch();
                              setModalState(() => employeeIDs = {});
                            },
                            onRefresh: () async {
                              final reload = controller.reloadEmployees();
                              setModalState(() {});
                              final loaded = await reload;
                              if (!context.mounted) return;
                              if (!loaded) {
                                setModalState(() {});
                                return;
                              }
                              setModalState(() {
                                final availableIDs = controller.employees
                                    .map((option) => option.id)
                                    .toSet();
                                employeeIDs = employeeIDs.intersection(
                                  availableIDs,
                                );
                              });
                            },
                            onChanged: (value) =>
                                setModalState(() => employeeIDs = value),
                          ),
                        CustomSingleSelectField(
                          label: 'Local',
                          options: controller.stores,
                          value: storeID,
                          loading: controller.loadingStores,
                          onRefresh: () async {
                            final reload = controller.reloadStores();
                            setModalState(() {});
                            final loaded = await reload;
                            if (!context.mounted) return;
                            if (!loaded) {
                              setModalState(() {});
                              return;
                            }
                            setModalState(() {
                              if (!controller.stores.any(
                                (option) => option.id == storeID,
                              )) {
                                storeID = null;
                                roomID = null;
                              }
                            });
                          },
                          onChanged: (value) => setModalState(() {
                            storeID = value;
                            if (!controller
                                .roomsForStore(storeID)
                                .any((room) => room.id == roomID)) {
                              roomID = null;
                            }
                          }),
                        ),
                        CustomSingleSelectField(
                          label: 'Sala',
                          options: availableRooms,
                          value: roomID,
                          loading: controller.loadingRooms,
                          searchable: true,
                          emptyOptionText: 'Todas as salas',
                          onRefresh: () async {
                            final reload = controller.reloadRooms();
                            setModalState(() {});
                            final loaded = await reload;
                            if (!context.mounted) return;
                            if (!loaded) {
                              setModalState(() {});
                              return;
                            }
                            setModalState(() {
                              if (!controller
                                  .roomsForStore(storeID)
                                  .any((option) => option.id == roomID)) {
                                roomID = null;
                              }
                            });
                          },
                          onChanged: (value) =>
                              setModalState(() => roomID = value),
                        ),
                        CustomMultiSelectField(
                          label: 'Estados',
                          options: controller.appointmentStates,
                          selectedIDs: stateIDs,
                          loading: controller.loadingStates,
                          onRefresh: () async {
                            final reload = controller.reloadStates();
                            setModalState(() {});
                            final loaded = await reload;
                            if (!context.mounted) return;
                            if (!loaded) {
                              setModalState(() {});
                              return;
                            }
                            setModalState(() {
                              final availableIDs = controller.appointmentStates
                                  .map((option) => option.id)
                                  .toSet();
                              stateIDs = stateIDs.intersection(availableIDs);
                            });
                          },
                          onChanged: (value) =>
                              setModalState(() => stateIDs = value),
                        ),
                        CustomSingleSelectField(
                          label: 'Especialidade',
                          options: controller.medicalSpecialties,
                          value: medicalSpecialtyID,
                          loading: controller.loadingMedicalSpecialties,
                          searchable: true,
                          emptyOptionText: 'Todas as especialidades',
                          onRefresh: () async {
                            final reload = controller
                                .reloadMedicalSpecialties();
                            setModalState(() {});
                            final loaded = await reload;
                            if (!context.mounted) return;
                            if (!loaded) {
                              setModalState(() {});
                              return;
                            }
                            setModalState(() {
                              if (!controller.medicalSpecialties.any(
                                (option) => option.id == medicalSpecialtyID,
                              )) {
                                medicalSpecialtyID = null;
                              }
                            });
                          },
                          onChanged: (value) =>
                              setModalState(() => medicalSpecialtyID = value),
                        ),
                        CustomMultiSelectField(
                          label: 'Clientes',
                          options: controller.clients,
                          selectedIDs: clientIDs,
                          loading: controller.loadingClients,
                          onRemoteSearch: (name) async {
                            await controller.searchClients(name);
                            return controller.clients;
                          },
                          onRefresh: () async {
                            final reload = controller.reloadClients();
                            setModalState(() {});
                            final loaded = await reload;
                            if (!context.mounted) return;
                            if (!loaded) {
                              setModalState(() {});
                              return;
                            }
                            setModalState(() {
                              final availableIDs = controller.clients
                                  .map((option) => option.id)
                                  .toSet();
                              clientIDs = clientIDs.intersection(availableIDs);
                            });
                          },
                          onChanged: (value) =>
                              setModalState(() => clientIDs = value),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Mostrar cancelados(as)'),
                          value: showCanceled,
                          activeThumbColor: CustomColors.primaryColor,
                          onChanged: (value) =>
                              setModalState(() => showCanceled = value),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => setModalState(() {
                            employeeIDs = {};
                            storeID = null;
                            roomID = null;
                            stateIDs = {};
                            medicalSpecialtyID = null;
                            clientIDs = {};
                            showCanceled = false;
                          }),
                          child: const Text('Limpar'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              await controller.applyFilters(
                                employeeIDs: employeeIDs,
                                storeID: storeID,
                                roomID: roomID,
                                stateIDs: stateIDs,
                                medicalSpecialtyID: medicalSpecialtyID,
                                clientIDs: clientIDs,
                                showCanceledValue: showCanceled,
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Aplicar filtros'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget calendar() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.03),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CustomColors.borderColor),
            ),
            child: Calendar(
              topRowIconColor: CustomColors.primaryDarkerColor,
              bottomBarColor: CustomColors.primaryLightColor,
              startOnMonday: true,
              weekDays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
              eventsList: controller.globalController.eventList.toList(),
              isExpandable: true,
              eventDoneColor: CustomColors.secondaryColor,
              selectedColor: CustomColors.tertiaryColor,
              selectedTodayColor: Colors.red,
              todayColor: CustomColors.primaryColor,
              eventColor: null,
              locale: 'pt_PT',
              todayButtonText: 'Hoje',
              allDayEventText: 'O dia todo',
              multiDayEndText: 'Fim',
              isExpanded: true,
              expandableDateFormat: 'EEEE, dd. MMMM yyyy',
              datePickerType: DatePickerType.date,
              onPrintLog: (_) {},
              dayOfWeekStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
              onMonthChanged: controller.onMonthChanged,
            ),
          ),
        ),
        if (controller.isMonthLoading.value)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.white70,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }
}
