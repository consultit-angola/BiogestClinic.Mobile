import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../ui/utils/app_toast.dart';
import 'calendar_controller.dart';
import 'global_controller.dart';

class AppointmentCreateController extends GetxController {
  static const int _servicePageSize = 10;
  static const int _serviceSearchPageSize = 100;

  static AppointmentCreateController get to =>
      Get.find<AppointmentCreateController>();

  final globalController = GlobalController.to;
  final Provider _provider = Provider();
  final searchController = TextEditingController();
  final observationsController = TextEditingController();

  int? clientID;
  int? employeeID;
  int? medicalSpecialtyID;
  int? storeID;
  int? roomID;
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 8, minute: 15);
  bool saving = false;
  bool loadingServices = false;
  String _serviceSearch = '';
  int _serviceSearchVersion = 0;
  final Set<int> _loadedServiceGroupIDs = {};
  final Map<int, int> _serviceGroupPageSizes = {};
  final Map<int, int> _serviceGroupTotalCounts = {};
  final Map<int, ServiceOptionDTO> _knownServiceOptions = {};
  final List<ServiceGroupOptionDTO> serviceGroups = [];
  final List<ServiceOptionDTO> serviceOptions = [];
  final List<AppointmentServiceDTO> selectedServices = [];

  CalendarController get calendarController => CalendarController.to;

  List<CalendarFilterOptionDTO> get clients => calendarController.clients;
  List<CalendarFilterOptionDTO> get employees => calendarController.employees;
  List<CalendarFilterOptionDTO> get medicalSpecialties {
    final employee = selectedEmployee;
    if (employee == null) return calendarController.medicalSpecialties;
    final allowedIDs = employee.allowedSpecialtyIDs.toSet();
    if (allowedIDs.isEmpty) return [];
    return calendarController.medicalSpecialties
        .where((specialty) => allowedIDs.contains(specialty.id))
        .toList();
  }

  List<CalendarFilterOptionDTO> get stores {
    final ambulatoryIDs = _ambulatoryStoreTypeIDs;
    if (ambulatoryIDs.isEmpty) return calendarController.stores;
    return calendarController.stores
        .where((store) => ambulatoryIDs.contains(store.typeID))
        .toList();
  }

  List<CalendarFilterOptionDTO> get rooms {
    final ambulatoryIDs = _ambulatoryRoomTypeIDs;
    return calendarController
        .roomsForStore(storeID)
        .where(
          (room) =>
              ambulatoryIDs.isEmpty || ambulatoryIDs.contains(room.typeID),
        )
        .toList();
  }

  bool get loadingClients => calendarController.loadingClients;
  bool get loadingEmployees => calendarController.loadingEmployees;
  bool get loadingMedicalSpecialties =>
      calendarController.loadingMedicalSpecialties;
  bool get loadingStores => calendarController.loadingStores;
  bool get loadingRooms => calendarController.loadingRooms;

  int? get _appointmentTypeID => globalController.getEnumEntryIdsByName(
    'AppointmentTypeEnum',
    ['Appointment'],
  ).firstOrNull;

  int? get _scheduledStateID => globalController.getEnumEntryIdsByName(
    'AppointmentStateEnum',
    ['Scheduled'],
  ).firstOrNull;

  int? get _appointmentServiceSourceOtherID => globalController
      .getEnumEntryIdsByName('AppointmentServiceSourceEnum', ['Other'])
      .firstOrNull;

  List<int> get _ambulatoryStoreTypeIDs =>
      globalController.getEnumEntryIdsByName('StoreTypeEnum', ['Ambulatory']);

  List<int> get _ambulatoryRoomTypeIDs =>
      globalController.getEnumEntryIdsByName('RoomTypeEnum', ['Ambulatory']);

  CalendarFilterOptionDTO? get selectedClient =>
      clients.firstWhereOrNull((option) => option.id == clientID);

  CalendarFilterOptionDTO? get selectedEmployee =>
      employees.firstWhereOrNull((option) => option.id == employeeID);

  bool get canEditServices {
    if (selectedServices.isNotEmpty) return true;
    final client = selectedClient;
    return client != null &&
        !client.isNotIdentifiedClient &&
        employeeID != null &&
        roomID != null;
  }

  String get selectedServicesText => selectedServices
      .where((service) => service.raw['Deleted'] != true)
      .map((service) => service.serviceCodeAndName)
      .where((name) => name.isNotEmpty)
      .join('\n');

  Set<int> get selectedServiceIDs => selectedServices
      .map((service) => service.serviceID)
      .whereType<int>()
      .toSet();

  String get serviceSearch => _serviceSearch;

  List<CalendarFilterOptionDTO> get serviceFilterOptions {
    if (_serviceSearch.isNotEmpty) {
      final visibleCountByGroupID = <int, int>{};
      return serviceOptions
          .where((service) {
            final groupID = service.groupID;
            if (groupID == null) return true;

            final visibleCount = visibleCountByGroupID[groupID] ?? 0;
            final pageSize =
                _serviceGroupPageSizes[groupID] ?? _servicePageSize;
            if (visibleCount >= pageSize) return false;

            visibleCountByGroupID[groupID] = visibleCount + 1;
            return true;
          })
          .map((service) => ServiceCalendarFilterOptionDTO(service))
          .toList();
    }

    return [
      ...serviceGroups.map(
        (group) => ServiceGroupCalendarFilterOptionDTO(group),
      ),
      ...serviceOptions.map(
        (service) => ServiceCalendarFilterOptionDTO(service),
      ),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    clientID = calendarController.selectedClientIDs.length == 1
        ? calendarController.selectedClientIDs.first
        : null;
    employeeID = calendarController.selectedEmployeeIDs.length == 1
        ? calendarController.selectedEmployeeIDs.first
        : globalController.authenticatedEmployee.value?.id;
    medicalSpecialtyID = calendarController.selectedMedicalSpecialtyID;
    storeID = calendarController.selectedStoreID;
    roomID = calendarController.selectedRoomID;
    _syncMedicalSpecialtyWithEmployee();
    _syncRoomWithStore();
    _syncRoomWithEmployee();
  }

  @override
  void onClose() {
    searchController.dispose();
    observationsController.dispose();
    super.onClose();
  }

  Future<void> searchClients(String name) async {
    await calendarController.searchClients(name);
    update();
  }

  Future<void> reloadClients() async {
    await calendarController.reloadClients();
    update();
  }

  Future<void> reloadEmployees() async {
    await calendarController.reloadEmployees();
    update();
  }

  Future<void> reloadMedicalSpecialties() async {
    await calendarController.reloadMedicalSpecialties();
    update();
  }

  Future<void> reloadStores() async {
    await calendarController.reloadStores();
    update();
  }

  Future<void> reloadRooms() async {
    await calendarController.reloadRooms();
    update();
  }

  void selectClient(int? value) {
    clientID = value;
    _clearServicesIfSelectionIsIncomplete();
    update();
  }

  void selectEmployee(int? value) {
    employeeID = value;
    _syncMedicalSpecialtyWithEmployee();
    _syncRoomWithEmployee();
    _clearServicesIfSelectionIsIncomplete();
    update();
  }

  void selectMedicalSpecialty(int? value) {
    medicalSpecialtyID =
        medicalSpecialties.any((specialty) => specialty.id == value)
        ? value
        : null;
    update();
  }

  void selectStore(int? value) {
    storeID = value;
    _syncRoomWithStore();
    _syncRoomWithEmployee();
    _clearServicesIfSelectionIsIncomplete();
    update();
  }

  void selectRoom(int? value) {
    roomID = value;
    _clearServicesIfSelectionIsIncomplete();
    update();
  }

  Future<List<CalendarFilterOptionDTO>> searchServices(String search) async {
    if (!canEditServices) return serviceFilterOptions;
    final searchTerm = search.trim();
    final requestVersion = ++_serviceSearchVersion;
    _serviceSearch = searchTerm;
    _resetServicePagination();
    loadingServices = true;
    update();
    try {
      if (searchTerm.isEmpty) {
        final response = await _provider.searchAppointmentServiceGroups();
        if (requestVersion != _serviceSearchVersion) {
          return serviceFilterOptions;
        }
        if (await globalController.handleResponseError(response)) {
          return serviceFilterOptions;
        }
        serviceGroups
          ..clear()
          ..addAll(response['data'] as List<ServiceGroupOptionDTO>);
        serviceOptions.clear();
        await _loadSelectedServiceGroups();
        return serviceFilterOptions;
      }

      final services = await _loadAllMatchingServices(
        searchTerm,
        requestVersion,
      );
      if (services == null || requestVersion != _serviceSearchVersion) {
        return serviceFilterOptions;
      }
      serviceOptions
        ..clear()
        ..addAll(services);
      _storeServiceOptions(serviceOptions);
      for (final service in serviceOptions) {
        final groupID = service.groupID;
        if (groupID == null) continue;
        _serviceGroupTotalCounts[groupID] =
            (_serviceGroupTotalCounts[groupID] ?? 0) + 1;
      }
      return serviceFilterOptions;
    } finally {
      if (requestVersion == _serviceSearchVersion) {
        loadingServices = false;
        update();
      }
    }
  }

  Future<List<ServiceOptionDTO>> loadGroupServices(int groupID) async {
    if (!canEditServices) return [];
    if (_serviceSearch.isNotEmpty) {
      _loadedServiceGroupIDs.add(groupID);
      return _visibleSearchServicesForGroup(groupID);
    }
    if (_loadedServiceGroupIDs.contains(groupID)) {
      return serviceOptions
          .where((service) => service.groupID == groupID)
          .toList();
    }

    final requestVersion = _serviceSearchVersion;
    final response = await _provider.searchAppointmentServiceOptions(
      search: '',
      groupIDs: [groupID],
      pageSize: _serviceGroupPageSizes[groupID] ?? _servicePageSize,
    );
    if (requestVersion != _serviceSearchVersion || _serviceSearch.isNotEmpty) {
      return _serviceSearch.isEmpty
          ? <ServiceOptionDTO>[]
          : _visibleSearchServicesForGroup(groupID);
    }
    if (await globalController.handleResponseError(response)) return [];
    final services = response['data'] as List<ServiceOptionDTO>;
    _serviceGroupPageSizes[groupID] =
        response['pageSize'] as int? ?? _servicePageSize;
    _serviceGroupTotalCounts[groupID] =
        response['totalCount'] as int? ?? services.length;
    _storeServiceOptions(services);
    final currentIDs = serviceOptions.map((service) => service.id).toSet();
    serviceOptions.addAll(
      services.where((service) => !currentIDs.contains(service.id)),
    );
    _loadedServiceGroupIDs.add(groupID);
    update();
    return serviceOptions
        .where((service) => service.groupID == groupID)
        .toList();
  }

  Future<List<ServiceOptionDTO>> loadMoreGroupServices(int groupID) async {
    if (_serviceSearch.isNotEmpty) {
      _serviceGroupPageSizes[groupID] =
          (_serviceGroupPageSizes[groupID] ?? _servicePageSize) +
          _servicePageSize;
      return _visibleSearchServicesForGroup(groupID);
    }

    _loadedServiceGroupIDs.remove(groupID);
    _serviceGroupPageSizes[groupID] =
        (_serviceGroupPageSizes[groupID] ?? _servicePageSize) +
        _servicePageSize;
    return loadGroupServices(groupID);
  }

  bool hasMoreGroupServices(int groupID) {
    final totalCount = _serviceGroupTotalCounts[groupID];
    if (totalCount == null) return false;
    if (_serviceSearch.isNotEmpty) {
      final visibleCount = _serviceGroupPageSizes[groupID] ?? _servicePageSize;
      return visibleCount < totalCount;
    }
    final loadedCount = serviceOptions
        .where((service) => service.groupID == groupID)
        .length;
    return loadedCount < totalCount;
  }

  Future<List<ServiceOptionDTO>?> _loadAllMatchingServices(
    String searchTerm,
    int requestVersion,
  ) async {
    final servicesByID = <int, ServiceOptionDTO>{};
    var pageNumber = 1;
    var totalCount = 0;
    var pageSize = _serviceSearchPageSize;

    do {
      final response = await _provider.searchAppointmentServiceOptions(
        search: searchTerm,
        pageNumber: pageNumber,
        pageSize: _serviceSearchPageSize,
      );
      if (requestVersion != _serviceSearchVersion) return null;
      if (await globalController.handleResponseError(response)) return null;

      final pageServices = response['data'] as List<ServiceOptionDTO>;
      for (final service in pageServices) {
        servicesByID[service.id] = service;
      }

      pageSize = response['pageSize'] as int? ?? _serviceSearchPageSize;
      totalCount = response['totalCount'] as int? ?? servicesByID.length;
      if (pageServices.isEmpty || pageSize <= 0) break;
      pageNumber++;
    } while ((pageNumber - 1) * pageSize < totalCount);

    return servicesByID.values.toList();
  }

  List<ServiceOptionDTO> _visibleSearchServicesForGroup(int groupID) {
    final pageSize = _serviceGroupPageSizes[groupID] ?? _servicePageSize;
    return serviceOptions
        .where((service) => service.groupID == groupID)
        .take(pageSize)
        .toList();
  }

  void _resetServicePagination() {
    _loadedServiceGroupIDs.clear();
    _serviceGroupPageSizes.clear();
    _serviceGroupTotalCounts.clear();
  }

  Future<void> _loadSelectedServiceGroups() async {
    final selectedGroups = serviceOptions
        .where((service) => selectedServiceIDs.contains(service.id))
        .followedBy(
          selectedServiceIDs
              .map((serviceID) => _knownServiceOptions[serviceID])
              .whereType<ServiceOptionDTO>(),
        )
        .map((service) => service.groupID)
        .whereType<int>()
        .toSet();

    for (final groupID in selectedGroups) {
      await loadGroupServices(groupID);
    }
  }

  void _storeServiceOptions(List<ServiceOptionDTO> services) {
    for (final service in services) {
      _knownServiceOptions[service.id] = service;
    }
  }

  Future<void> updateSelectedServices(Set<int> serviceIDs) async {
    final selectedGroupIDs = serviceIDs.where((id) => id < 0).map((id) => -id);
    final selectedLeafIDs = serviceIDs.where((id) => id > 0).toSet();

    for (final groupID in selectedGroupIDs) {
      final groupServices = await loadGroupServices(groupID);
      selectedLeafIDs.addAll(groupServices.map((service) => service.id));
    }

    final currentIDs = selectedServiceIDs;
    final removedIDs = currentIDs.difference(selectedLeafIDs);
    final addedIDs = selectedLeafIDs.difference(currentIDs);

    if (removedIDs.isNotEmpty) {
      selectedServices.removeWhere(
        (service) => removedIDs.contains(service.serviceID),
      );
      update();
    }

    for (final serviceID in addedIDs) {
      final service = serviceOptions.firstWhereOrNull(
        (option) => option.id == serviceID,
      );
      if (service != null) {
        await addService(service);
      }
    }
  }

  Future<void> addService(ServiceOptionDTO service) async {
    if (selectedServiceIDs.contains(service.id)) return;
    final typeID = _appointmentTypeID;
    if (!canEditServices ||
        clientID == null ||
        employeeID == null ||
        roomID == null ||
        typeID == null) {
      AppToast.show(
        'Serviços',
        'Selecione cliente, médico e sala antes de adicionar serviços.',
      );
      return;
    }

    loadingServices = true;
    update();
    try {
      final response = await _provider.createAppointmentService(
        serviceID: service.id,
        clientID: clientID!,
        appointmentType: typeID,
        employeeID: employeeID!,
        roomID: roomID!,
        priceTableID: selectedClient?.priceTableID,
      );
      if (await globalController.handleResponseError(response)) return;

      final createdServices = (response['data'] as List<AppointmentServiceDTO>)
          .map(
            (item) => AppointmentServiceDTO.fromJson({
              ...item.toJson(),
              'AppointmentID': null,
              'Source': _appointmentServiceSourceOtherID,
            }),
          )
          .toList();
      selectedServices.addAll(createdServices);
    } finally {
      loadingServices = false;
      update();
    }
  }

  void removeService(AppointmentServiceDTO service) {
    selectedServices.remove(service);
    update();
  }

  void selectDate(DateTime value) {
    selectedDate = value;
    update();
  }

  void selectStartTime(TimeOfDay value) {
    startTime = value;
    endTime = _addMinutes(value, 15);
    update();
  }

  void selectEndTime(TimeOfDay value) {
    endTime = value;
    update();
  }

  Future<bool> save() async {
    final client = clients.firstWhereOrNull((option) => option.id == clientID);
    if (client == null ||
        employeeID == null ||
        medicalSpecialtyID == null ||
        storeID == null ||
        roomID == null) {
      AppToast.show('Formulário', 'Preencha os campos obrigatórios.');
      return false;
    }

    final scheduleStart = _combineDateAndTime(selectedDate, startTime);
    final scheduleEnd = _combineDateAndTime(selectedDate, endTime);
    if (!scheduleEnd.isAfter(scheduleStart)) {
      AppToast.show(
        'Formulário',
        'A hora de fim deve ser posterior ao início.',
      );
      return false;
    }

    final typeID = _appointmentTypeID;
    final stateID = _scheduledStateID;
    if (typeID == null || stateID == null) {
      AppToast.show('Erro', 'Dados de marcação indisponíveis.');
      return false;
    }

    saving = true;
    update();
    try {
      final appointment = AppointmentDTO(
        id: 0,
        clientID: client.id,
        clientName: client.name,
        employeeID: employeeID,
        roomID: roomID,
        storeID: storeID,
        observations: observationsController.text.trim(),
        scheduleStartDate: scheduleStart,
        scheduleEndDate: scheduleEnd,
        state: StateDTO(id: stateID, name: 'Scheduled'),
        medicalSpecialty: SpecialtyDTO(
          id: medicalSpecialtyID!,
          name: '',
          enumValue: 0,
          code: 0,
          description: '',
          deleted: false,
        ),
        type: TypeDTO(
          id: typeID,
          name: 'Appointment',
          code: 0,
          description: '',
          deleted: false,
        ),
        services: selectedServices,
      );

      final validationBody = appointment.toJson()..remove('ID');
      final validation = await _provider.validateAppointmentSchedule(
        validationBody,
      );
      if (await globalController.handleResponseError(validation)) return false;
      if (validation['ok'] != true) {
        AppToast.show('Erro', validation['message']?.toString() ?? '');
        return false;
      }

      final warning = validation['data']?.toString() ?? '';
      if (warning.trim().isNotEmpty) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Confirmar marcação'),
            content: Text(warning),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
        if (confirmed != true) return false;
      }

      final response = await _provider.createAppointment(appointment);
      if (await globalController.handleResponseError(response)) return false;
      if (response['ok'] != true) {
        AppToast.show('Erro', response['message']?.toString() ?? '');
        return false;
      }

      AppToast.show('Sucesso', 'Marcação criada com sucesso.');
      await calendarController.refreshAppointments();
      return true;
    } finally {
      saving = false;
      update();
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final date = DateTime(
      0,
      1,
      1,
      time.hour,
      time.minute,
    ).add(Duration(minutes: minutes));
    return TimeOfDay(hour: date.hour, minute: date.minute);
  }

  void _clearServicesIfSelectionIsIncomplete() {
    if (canEditServices) return;
    selectedServices.clear();
  }

  void _syncMedicalSpecialtyWithEmployee() {
    if (medicalSpecialtyID == null) return;
    if (medicalSpecialties.any(
      (specialty) => specialty.id == medicalSpecialtyID,
    )) {
      return;
    }
    medicalSpecialtyID = null;
  }

  void _syncRoomWithStore() {
    if (!rooms.any((room) => room.id == roomID)) {
      roomID = null;
    }
  }

  void _syncRoomWithEmployee() {
    final employee = selectedEmployee;
    if (employee?.roomID == null || employee?.roomStoreID == null) return;
    if (employee!.roomStoreID == storeID &&
        rooms.any((room) => room.id == employee.roomID)) {
      roomID = employee.roomID;
    }
  }
}
