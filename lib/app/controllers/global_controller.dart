import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/shared/index.dart';
import '../routes/app_routes.dart';
import 'index.dart';

class GlobalController extends GetxController {
  static GlobalController get to => Get.find<GlobalController>();

  static const int appointmentScheduleManagementPermission = 500;
  static const int viewOtherUsersSchedulePermission = 504;
  static const int globalConfigurationPermission = 25;
  static const int activityManagementPermission = 750;

  final Provider _provider = Provider();
  final Preferences _pref = Preferences();
  RxBool isAuthenticated = false.obs;
  final Rxn<UserDTO> authenticatedUser = Rxn<UserDTO>();
  final Rxn<EmployeeDTO> authenticatedEmployee = Rxn<EmployeeDTO>();
  final RxString selectedStoreName = ''.obs;
  final RxList<int> activePermissions = <int>[].obs;
  final Map<String, List<EnumEntryDTO>> enumEntries = {};
  final RxList<UserDTO> users = <UserDTO>[].obs;
  RxMap<int, RxList<MessageDTO>> oldMessages = <int, RxList<MessageDTO>>{}.obs;
  RxMap<int, RxList<MessageDTO>> newMessages = <int, RxList<MessageDTO>>{}.obs;
  RxMap<int, RxList<MessageDTO>> messages = <int, RxList<MessageDTO>>{}.obs;
  final RxList<AlarmDTO> programmedAlarms = <AlarmDTO>[].obs;
  final RxMap<int, dynamic> programmedAlarmsMap = <int, dynamic>{}.obs;
  RxList<AlarmInstanceDTO> alarmInstances = <AlarmInstanceDTO>[].obs;

  final RxList<NeatCleanCalendarEvent> eventList =
      <NeatCleanCalendarEvent>[].obs;
  final Map<String, dynamic> calendarFilters = {};
  var pendingMessages = 0.obs;
  var pendingCalendar = 0.obs;
  var pendingAlarms = 0.obs;
  var pendingActivities = 0.obs;

  var isCalendarControllerLoaded = false;
  var isChatControllerLoaded = false;
  Timer? timerChats;
  Timer? timerAlarms;
  Timer? timerAppts;
  bool _handlingExpiredSession = false;
  bool _timersStoppedByConnection = false;

  bool hasPermission(int permission) {
    return activePermissions.contains(permission);
  }

  bool get canAccessAppointmentCalendar =>
      hasPermission(appointmentScheduleManagementPermission);

  bool get canViewOtherUsersAppointments =>
      hasPermission(viewOtherUsersSchedulePermission);

  bool get canAccessAlarms => hasPermission(globalConfigurationPermission);

  bool get canAccessActivities => hasPermission(activityManagementPermission);

  List<int> getEnumEntryIdsByName(String enumKey, List<String> names) {
    return enumEntries[enumKey]
            ?.where((entry) => names.contains(entry.name))
            .map((entry) => entry.id)
            .toList() ??
        [];
  }

  Future<void> loadEnumEntries() async {
    final resp = await _provider.getEnumEntries();
    if (_handleConnectionError(resp)) {
      throw Exception(resp['message']);
    }
    if (await _handleExpiredResponse(resp)) {
      throw Exception(resp['message']);
    }
    if (resp['ok'] != true) {
      throw Exception(resp['message']);
    }

    enumEntries
      ..clear()
      ..addAll(resp['data'] as Map<String, List<EnumEntryDTO>>);
  }

  Future<bool> handleResponseError(Map<String, dynamic> response) async {
    if (_handleConnectionError(response)) {
      return true;
    }
    return _handleExpiredResponse(response);
  }

  void markSessionActive() {
    _handlingExpiredSession = false;
    _timersStoppedByConnection = false;
  }

  bool _handleConnectionError(Map<String, dynamic> response) {
    if (response['connectionError'] != true) {
      return false;
    }

    if (!_timersStoppedByConnection) {
      _timersStoppedByConnection = true;
      stopTimer();
      Get.snackbar(
        'Erro de conexão',
        'As atualizações automáticas foram interrompidas.',
      );
    }
    return true;
  }

  Future<bool> _handleExpiredResponse(Map<String, dynamic> response) async {
    if (response['sessionExpired'] != true) {
      return false;
    }

    if (!_handlingExpiredSession) {
      _handlingExpiredSession = true;
      stopTimer();
      await _pref.clear();
      Get.offAllNamed(Routes.login);
      await Future<void>.delayed(Get.defaultTransitionDuration);
      await clearSession();
      Get.snackbar(
        'Sessão terminada',
        'A sua sessão foi encerrada noutro dispositivo.',
      );
    }
    return true;
  }

  Future<void> initControllers() async {
    await loadEnumEntries();
    Get.put(HomeController());
    Get.put(ChatController());
    if (canAccessAlarms) {
      Get.put(AlarmController());
      startAlarmTimer();
    }
    if (canAccessAppointmentCalendar) {
      if (Get.isRegistered<CalendarController>()) {
        await Get.delete<CalendarController>(force: true);
      }
      Get.put(CalendarController(), permanent: true);
      await CalendarController.to.loadFilterOptions(
        showErrors: false,
        onLoading: (message) => EasyLoading.show(status: message),
      );
    }
    if (canAccessActivities) {
      Get.put(ActivitiesController());
    }

    EasyLoading.show(status: 'Carregando agenda, mensagens e alarmes...');
    await Future.wait([
      startChatTimer(),
      if (canAccessAlarms) getProgrammedAlarms(),
      if (canAccessAppointmentCalendar) startApptsTimer(),
    ]);
  }

  Future<void> startChatTimer() async {
    await Future.wait([getMessages(onlyUnread: false), getMessages()]);
    if (authenticatedUser.value == null || _timersStoppedByConnection) {
      return;
    }
    timerChats = Timer.periodic(const Duration(seconds: 5), (time) {
      getMessages();
    });
  }

  void startAlarmTimer() async {
    if (!canAccessAlarms) {
      programmedAlarms.clear();
      programmedAlarmsMap.clear();
      alarmInstances.clear();
      pendingAlarms.value = 0;
      return;
    }
    timerAlarms = Timer.periodic(Duration(minutes: 5), (time) {
      getActiveInstances();
    });
  }

  Future<void> startApptsTimer() async {
    if (!canAccessAppointmentCalendar) {
      eventList.clear();
      pendingCalendar.value = 0;
      return;
    }
    await getAppts();
    timerAppts = Timer.periodic(Duration(minutes: 10), (time) {
      if (Get.isRegistered<CalendarController>()) {
        CalendarController.to.refreshAppointments();
      }
    });
  }

  void stopTimer() {
    timerChats?.cancel();
    timerAlarms?.cancel();
    timerAppts?.cancel();
  }

  Future<void> clearSession({bool clearPreferences = false}) async {
    stopTimer();
    authenticatedUser.value = null;
    authenticatedEmployee.value = null;
    selectedStoreName.value = '';
    activePermissions.clear();
    enumEntries.clear();
    calendarFilters.clear();
    users.clear();
    oldMessages.clear();
    newMessages.clear();
    messages.clear();
    programmedAlarms.clear();
    programmedAlarmsMap.clear();
    alarmInstances.clear();
    eventList.clear();
    pendingMessages.value = 0;
    pendingCalendar.value = 0;
    pendingAlarms.value = 0;
    pendingActivities.value = 0;
    isCalendarControllerLoaded = false;
    isChatControllerLoaded = false;
    isAuthenticated.value = false;

    if (Get.isRegistered<HomeController>()) {
      await Get.delete<HomeController>(force: true);
    }
    if (Get.isRegistered<ChatController>()) {
      await Get.delete<ChatController>(force: true);
    }
    if (Get.isRegistered<AlarmController>()) {
      await Get.delete<AlarmController>(force: true);
    }
    if (Get.isRegistered<CalendarController>()) {
      await Get.delete<CalendarController>(force: true);
    }
    if (Get.isRegistered<ActivitiesController>()) {
      await Get.delete<ActivitiesController>(force: true);
    }
    if (clearPreferences) {
      await _pref.clear();
    }
  }

  void logout() async {
    try {
      EasyLoading.show();
      Map<String, dynamic> resp = await _provider.logout();
      if (resp['ok']) {
        EasyLoading.dismiss();
        stopTimer();
        await _pref.clear();
        Get.offAllNamed(Routes.login);
        await Future<void>.delayed(Get.defaultTransitionDuration);
        await clearSession();
      } else {
        Get.snackbar('Error', resp['message']);
      }
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      Get.snackbar('Error', '$error');
    }
  }

  Future<void> getMessages({
    DateTime? startDate,
    DateTime? endDate,
    bool onlyUnread = true,
    bool forceReload = false,
  }) async {
    final data = {
      "StartDate": startDate?.toUtc().toIso8601String(),
      "EndDate": endDate?.toUtc().toIso8601String(),
      "UserID": onlyUnread ? 0 : authenticatedUser.value!.id,
      "OnlyUnread": onlyUnread,
    };

    Map<String, dynamic> resp = await _provider.getMessages(data);

    if (_handleConnectionError(resp)) {
      return;
    }
    if (await _handleExpiredResponse(resp)) {
      return;
    }

    if (resp['ok']) {
      var auxMessages = resp['data'] as List<MessageDTO>;

      // actualizar contador pending
      if (onlyUnread) {
        pendingMessages.value = auxMessages.length <= 99
            ? auxMessages.length
            : 99;
      }

      // Insertar/actualizar incrementalmente
      for (var message in auxMessages) {
        final key = message.destinationUserID == authenticatedUser.value!.id
            ? message.creationUserID
            : message.destinationUserID;

        // asegurar existencia de la lista en old/new
        final targetMap = onlyUnread ? newMessages : oldMessages;
        final existing = targetMap.putIfAbsent(key, () => <MessageDTO>[].obs);

        // si ya existe, actualizar (por ejemplo cambiar status o texto)
        final idx = existing.indexWhere((m) => m.id == message.id);
        if (idx != -1) {
          existing[idx] = message;
        } else {
          existing.add(message);
        }

        // fusionar con lista principal de mensajes sin reemplazarla
        final mainList = messages.putIfAbsent(key, () => <MessageDTO>[].obs);

        for (var newMsg in existing) {
          final mIdx = mainList.indexWhere((m) => m.id == newMsg.id);
          if (mIdx != -1) {
            // mantener el estado anterior
            mainList[mIdx] = MessageDTO(
              id: newMsg.id,
              messageText: newMsg.messageText,
              creationDate: newMsg.creationDate,
              creationUserID: newMsg.creationUserID,
              destinationUserID: newMsg.destinationUserID,
              attachments: newMsg.attachments,
              status: mainList[mIdx].status,
            );
          } else {
            mainList.add(newMsg);
          }
        }

        // ordenar por fecha
        mainList.sort((a, b) => a.creationDate.compareTo(b.creationDate));

        // refresca solo esta RxList
        mainList.refresh();
      }
    } else {
      Get.snackbar('Error', resp['message'] ?? 'Erro não identificado');
    }
  }

  bool mergedListEquals(List<MessageDTO> a, List<MessageDTO> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].status != b[i].status) return false;
    }
    return true;
  }

  Future<void> getActiveInstances() async {
    if (!canAccessAlarms) {
      alarmInstances.clear();
      pendingAlarms.value = 0;
      return;
    }
    final data = {
      'withAlarmInstancesToNotify': true,
      'withAllAlarmInstances': false,
      'updateLastNotificationDate': false,
      'alarmIDToUpdateLastNotificationDate': -1,
    };
    Map<String, dynamic> resp = await _provider.getActiveInstances(data);
    if (_handleConnectionError(resp)) {
      return;
    }
    if (await _handleExpiredResponse(resp)) {
      return;
    }
    if (resp['ok']) {
      // 🔹 Limpia todas las listas de instancias antes de volver a llenarlas
      programmedAlarmsMap.forEach((key, value) {
        (value['instances'] as List).clear();
        value['length'] = 0;
      });

      // 🔹 Asigna las nuevas instancias
      alarmInstances.value = resp['data'] as List<AlarmInstanceDTO>;

      // 🔹 Vuelve a llenar las instancias agrupadas
      for (var instance in alarmInstances) {
        final alarm = programmedAlarmsMap[instance.alarmId];
        if (alarm != null) {
          (alarm['instances'] as List).add(instance);
        }
      }

      // 🔹 Recalcula los conteos
      pendingAlarms.value = 0;
      programmedAlarmsMap.forEach((key, value) {
        value['length'] = (value['instances'] as List).length;
        if (value['length'] > 0) pendingAlarms.value++;
      });
    } else {
      Get.snackbar('Error', resp['message']);
    }
  }

  Future<void> getProgrammedAlarms() async {
    if (!canAccessAlarms) {
      programmedAlarms.clear();
      programmedAlarmsMap.clear();
      alarmInstances.clear();
      pendingAlarms.value = 0;
      return;
    }
    try {
      Map<String, dynamic> resp = await _provider.getProgrammedAlarms();
      if (_handleConnectionError(resp)) {
        return;
      }
      if (await _handleExpiredResponse(resp)) {
        return;
      }
      if (resp['ok']) {
        programmedAlarms.value = resp['data'] as List<AlarmDTO>;
        programmedAlarmsMap.value = {
          for (var p in programmedAlarms)
            if (p.id != null) p.id!: {'alarm': p, 'instances': []},
        };
        await getActiveInstances();
      } else {
        Get.snackbar('Error', resp['message']);
      }
    } catch (error) {
      Get.snackbar('Error', '$error');
    }
  }

  Future<void> getAppts({DateTime? pStartDate, DateTime? pEndDate}) async {
    if (!canAccessAppointmentCalendar) {
      eventList.clear();
      pendingCalendar.value = 0;
      return;
    }
    final now = DateTime.now();
    final startDate =
        pStartDate?.toIso8601String() ??
        DateTime.utc(now.year, now.month, 1, 0, 0, 0).toIso8601String();
    final endDate =
        pEndDate?.toIso8601String() ??
        DateTime.utc(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();

    final data = {
      'TypeEnumList': getEnumEntryIdsByName('AppointmentTypeEnum', [
        'Appointment',
        'Emergency',
        'Urgency',
      ]),
      'EmployeeIDList': [authenticatedEmployee.value!.id],
      'RoomID': null,
      'StoreID': _pref.storeID,
      'ScheduleStartDate': startDate,
      'ScheduleEndDate': endDate,
      'OnlyNotCanceled': true,
      ...calendarFilters,
    };
    Map<String, dynamic> resp = await _provider.getAppts(data);
    if (_handleConnectionError(resp)) {
      return;
    }
    if (await _handleExpiredResponse(resp)) {
      return;
    }
    if (resp['ok']) {
      eventList.clear();
      final appts = resp['data'] as List<AppointmentDTO>;
      pendingCalendar.value = appts
          .where(
            (appt) =>
                appt.state?.id == 0 && appt.scheduleStartDate == DateTime.now(),
          )
          .length;

      for (var appt in appts) {
        var clientName = '';
        if (appt.clientName != null) {
          clientName = appt.clientName!.length < 30
              ? appt.clientName ?? ''
              : '${appt.clientName!.substring(0, 27)}...';
        }

        var services = '';
        if (appt.services != null && appt.services!.isNotEmpty) {
          services = appt.services!
              .map((s) => '${s.serviceCodeAndName},')
              .toString();
          services = services.length < 30
              ? services
              : '${services.substring(0, 27)}...';
        }

        eventList.add(
          NeatCleanCalendarEvent(
            clientName,
            description: services,
            startTime: appt.scheduleStartDate ?? DateTime.now(),
            endTime: appt.scheduleEndDate ?? DateTime.now(),
            color: appt.stateColorRGB != null
                ? Color(
                    int.parse(
                          appt.stateColorRGB!.replaceAll('#', ''),
                          radix: 16,
                        ) +
                        0xFF000000,
                  )
                : null,
          ),
        );
      }
    } else {
      Get.snackbar('Error', resp['message']);
    }
  }
}
