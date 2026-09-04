import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/shared/preferences.dart';
import '../ui/utils/app_toast.dart';
import 'index.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.find<CalendarController>();
  final globalController = GlobalController.to;
  final Provider _provider = Provider();
  final Preferences _preferences = Preferences();
  final ValueChanged<bool>? onExpandStateChanged = null;
  final ValueChanged? onRangeSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventSelected = null;
  final ValueChanged<NeatCleanCalendarEvent>? onEventLongPressed = null;

  List<CalendarFilterOptionDTO> employees = [];
  List<CalendarFilterOptionDTO> stores = [];
  List<CalendarFilterOptionDTO> rooms = [];
  List<CalendarFilterOptionDTO> appointmentStates = [];
  List<CalendarFilterOptionDTO> medicalSpecialties = [];
  List<CalendarFilterOptionDTO> clients = [];

  Set<int> selectedEmployeeIDs = {};
  Set<int> selectedStateIDs = {};
  Set<int> selectedClientIDs = {};
  int? selectedStoreID;
  int? selectedRoomID;
  int? selectedMedicalSpecialtyID;
  bool showCanceled = false;
  bool filterOptionsLoaded = false;
  final RxBool isMonthLoading = false.obs;
  final Set<String> _loadingFilters = {};
  String? _lastEmployeeSearch;
  String? _lastClientSearch;
  DateTime? _rangeStartDate;
  DateTime? _rangeEndDate;

  bool get loadingFilterOptions => _loadingFilters.isNotEmpty;
  bool get loadingEmployees => _loadingFilters.contains('employees');
  bool get loadingStores => _loadingFilters.contains('stores');
  bool get loadingRooms => _loadingFilters.contains('rooms');
  bool get loadingStates => _loadingFilters.contains('states');
  bool get loadingMedicalSpecialties =>
      _loadingFilters.contains('medicalSpecialties');
  bool get loadingClients => _loadingFilters.contains('clients');

  bool get canViewOtherUsersAppointments =>
      globalController.canViewOtherUsersAppointments;

  @override
  void onInit() {
    super.onInit();
    final employee = globalController.authenticatedEmployee.value;
    if (employee != null) {
      selectedEmployeeIDs = {employee.id};
      employees = [
        CalendarFilterOptionDTO(
          id: employee.id,
          name: employee.name.isNotEmpty ? employee.name : employee.shortName,
          roomID: employee.room.id > 0 ? employee.room.id : null,
          roomStoreID: employee.room.store.id > 0
              ? employee.room.store.id
              : null,
          allowedSpecialtyIDs: employee.allowedAppointmentExecutionSpecialties
              .map((specialty) => specialty.id)
              .where((id) => id > 0)
              .toList(),
        ),
      ];
    }
    final storedStoreID = _preferences.storeID;
    selectedStoreID = storedStoreID > 0 ? storedStoreID : null;
  }

  Future<bool> loadFilterOptions({
    bool showErrors = true,
    ValueChanged<String>? onLoading,
  }) async {
    if (filterOptionsLoaded) {
      return true;
    }

    final results = <bool>[];
    onLoading?.call('Carregando locais...');
    results.add(await reloadStores(showError: showErrors));
    onLoading?.call('Carregando salas...');
    results.add(await reloadRooms(showError: showErrors));
    onLoading?.call('Carregando estados...');
    results.add(await reloadStates(showError: showErrors));
    onLoading?.call('Carregando especialidades...');
    results.add(await reloadMedicalSpecialties(showError: showErrors));
    if (canViewOtherUsersAppointments) {
      onLoading?.call('Carregando medicos...');
      results.add(await reloadEmployees(showError: showErrors));
    }
    filterOptionsLoaded = results.every((loaded) => loaded);
    update();
    return filterOptionsLoaded;
  }

  Future<bool> searchEmployees(String name, {bool showError = true}) async {
    final search = name.trim();
    _lastEmployeeSearch = search;
    return _reloadOptions(
      key: 'employees',
      request: () => _provider.searchEmployees(name: search),
      onLoaded: (options) => employees = _mergeOptions(employees, options),
      showError: showError,
    );
  }

  Future<bool> reloadEmployees({bool showError = true}) async {
    return _reloadOptions(
      key: 'employees',
      request: () => _provider.searchEmployees(name: _lastEmployeeSearch),
      onLoaded: (options) => employees = _mergeOptions(employees, options),
      showError: showError,
    );
  }

  void clearEmployeeSearch() {
    _lastEmployeeSearch = null;
  }

  Future<bool> reloadStores({bool showError = true}) => _reloadOptions(
    key: 'stores',
    request: _provider.getCalendarStores,
    onLoaded: (options) => stores = options,
    showError: showError,
  );

  Future<bool> reloadRooms({bool showError = true}) => _reloadOptions(
    key: 'rooms',
    request: _provider.getRooms,
    onLoaded: (options) => rooms = options,
    showError: showError,
  );

  Future<bool> reloadStates({bool showError = true}) => _reloadOptions(
    key: 'states',
    request: _provider.getAppointmentStates,
    onLoaded: (options) => appointmentStates = options,
    showError: showError,
  );

  Future<bool> reloadMedicalSpecialties({bool showError = true}) =>
      _reloadOptions(
        key: 'medicalSpecialties',
        request: _provider.getMedicalSpecialties,
        onLoaded: (options) => medicalSpecialties = options,
        showError: showError,
      );

  Future<bool> searchClients(String name, {bool showError = true}) async {
    final search = name.trim();
    if (search.length < 3) return false;
    _lastClientSearch = search;
    return _reloadOptions(
      key: 'clients',
      request: () => _provider.searchClients(name: search),
      onLoaded: (options) => clients = _mergeOptions(clients, options),
      showError: showError,
    );
  }

  Future<bool> reloadClients({bool showError = true}) async {
    final search = _lastClientSearch;
    if (search == null) {
      AppToast.show('Pesquisa', 'Introduza pelo menos 3 letras do cliente.');
      return false;
    }
    return searchClients(search, showError: showError);
  }

  Future<bool> _reloadOptions({
    required String key,
    required Future<Map<String, dynamic>> Function() request,
    required ValueChanged<List<CalendarFilterOptionDTO>> onLoaded,
    required bool showError,
  }) async {
    _loadingFilters.add(key);
    update();
    try {
      final response = await request();
      if (response['ok'] == true) {
        onLoaded(_optionsFrom(response));
        return true;
      }
      if (await globalController.handleResponseError(response)) {
        return false;
      }
      if (showError) {
        AppToast.show('Erro', response['message']?.toString() ?? '');
      }
      return false;
    } finally {
      _loadingFilters.remove(key);
      update();
    }
  }

  List<CalendarFilterOptionDTO> _optionsFrom(Map<String, dynamic> response) {
    final options = response['data'] as List<CalendarFilterOptionDTO>;
    options.sort((first, second) => first.name.compareTo(second.name));
    return options;
  }

  List<CalendarFilterOptionDTO> _mergeOptions(
    List<CalendarFilterOptionDTO> current,
    List<CalendarFilterOptionDTO> loaded,
  ) {
    final optionsByID = {
      for (final option in current) option.id: option,
      for (final option in loaded) option.id: option,
    };
    final options = optionsByID.values.toList();
    options.sort((first, second) => first.name.compareTo(second.name));
    return options;
  }

  List<CalendarFilterOptionDTO> roomsForStore(int? storeID) {
    if (storeID == null) {
      return rooms;
    }
    return rooms.where((room) => room.parentID == storeID).toList();
  }

  Future<void> applyFilters({
    required Set<int> employeeIDs,
    required int? storeID,
    required int? roomID,
    required Set<int> stateIDs,
    required int? medicalSpecialtyID,
    required Set<int> clientIDs,
    required bool showCanceledValue,
  }) async {
    final authenticatedEmployeeID =
        globalController.authenticatedEmployee.value?.id;
    final allowedEmployeeIDs = canViewOtherUsersAppointments
        ? employeeIDs
        : authenticatedEmployeeID == null
        ? <int>{}
        : {authenticatedEmployeeID};

    selectedEmployeeIDs = allowedEmployeeIDs;
    selectedStoreID = storeID;
    selectedRoomID = roomID;
    selectedStateIDs = stateIDs;
    selectedMedicalSpecialtyID = medicalSpecialtyID;
    selectedClientIDs = clientIDs;
    showCanceled = showCanceledValue;

    globalController.calendarFilters
      ..clear()
      ..addAll({
        'EmployeeIDList': allowedEmployeeIDs.isEmpty
            ? null
            : allowedEmployeeIDs.toList(),
        'StoreID': storeID,
        'RoomID': roomID,
        'States': stateIDs.isEmpty ? null : stateIDs.toList(),
        'MedicalSpecialtyID': medicalSpecialtyID,
        'ClientIDList': clientIDs.isEmpty ? null : clientIDs.toList(),
        'OnlyNotCanceled': !showCanceledValue,
      });

    update();
    await globalController.getAppts(
      pStartDate: _rangeStartDate,
      pEndDate: _rangeEndDate,
    );
  }

  void onMonthChanged(DateTime month) {
    _rangeStartDate = DateTime.utc(month.year, month.month, 1, 0, 0, 0);
    _rangeEndDate = DateTime.utc(month.year, month.month + 1, 0, 23, 59, 59);
    refreshAppointments(showMonthLoading: true);
  }

  Future<void> refreshAppointments({bool showMonthLoading = false}) async {
    if (showMonthLoading) {
      isMonthLoading.value = true;
    }
    try {
      await globalController.getAppts(
        pStartDate: _rangeStartDate,
        pEndDate: _rangeEndDate,
      );
    } finally {
      if (showMonthLoading) {
        isMonthLoading.value = false;
      }
    }
  }
}
