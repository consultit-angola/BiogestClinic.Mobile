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

  final Provider _provider = Provider();
  final Preferences _pref = Preferences();
  RxBool isAuthenticated = false.obs;
  final Rxn<UserDTO> authenticatedUser = Rxn<UserDTO>();
  final Rxn<EmployeeDTO> authenticatedEmployee = Rxn<EmployeeDTO>();
  final RxList<UserDTO> users = <UserDTO>[].obs;
  RxMap<int, List<MessageDTO>> oldMessages = <int, List<MessageDTO>>{}.obs;
  RxMap<int, List<MessageDTO>> newMessages = <int, List<MessageDTO>>{}.obs;
  RxMap<int, List<MessageDTO>> messages = <int, List<MessageDTO>>{}.obs;
  final RxList<NeatCleanCalendarEvent> eventList =
      <NeatCleanCalendarEvent>[].obs;
  var pendingMessages = 0.obs;
  var pendingCalendar = 0.obs;
  var pendingAlarms = 0.obs;
  var pendingActivities = 0.obs;

  var isCalendarControllerLoaded = false;
  var isChatControllerLoaded = false;
  Timer? timer;

  void initControllers() {
    Get.put(HomeController());
    Get.put(ChatController());
    Get.put(AlarmController());
    Get.put(CalendarController());
    Get.put(ActivitiesController());

    getMessages(onlyUnread: false);
    getMessages();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 5), (time) {
      getMessages();
      getAppts();
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void logout() async {
    try {
      EasyLoading.show();
      Map<String, dynamic> resp = await _provider.logout();
      if (resp['ok']) {
        authenticatedUser.value = null;
        isAuthenticated.value = false;
        EasyLoading.dismiss();
        Preferences().clear();
        stopTimer();
        Get.offAllNamed(Routes.login);
      } else {
        Get.snackbar('Error', resp['message']);
      }
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      Get.snackbar('Error', '$error');
    }
  }

  void getMessages({
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

    if (resp['ok']) {
      (onlyUnread ? newMessages : oldMessages).clear();
      var auxMessages = resp['data'] as List<MessageDTO>;

      // Insertar/actualizar incrementalmente
      for (var message in auxMessages) {
        final key = message.destinationUserID == authenticatedUser.value!.id
            ? message.creationUserID
            : message.destinationUserID;

        // asegurar existencia de la lista
        final existing = (onlyUnread ? newMessages : oldMessages).putIfAbsent(
          key,
          () => <MessageDTO>[],
        );

        // si ya existe, actualizar (por ejemplo cambiar status o texto)
        final idx = existing.indexWhere((m) => m == message);
        if (idx != -1) {
          existing[idx] = message;
        } else {
          existing.add(message);
        }

        // Si el mensaje fue recibido por el usuario actual y viene como no leído,
        // marcar como leído (opcional: hacer batch en vez de uno por uno)
        if (!onlyUnread) {
          final isForMe =
              message.destinationUserID == authenticatedUser.value!.id;
          // Suponiendo que MessageDTO tenga un campo 'isRead' o similar — adapta:
          if (isForMe && (message.status != MessageStatus.read)) {
            // actualizamos la propiedad local para que muestre palomita doble
            message.status = MessageStatus.read;
            // Llamamos a la API para marcarlo como leído si corresponde
            // (si tu API tiene endpoint para eso, lo llamamos; si no, omítelo)
            // setMarkAsRead(message.id);
          }
        }
      }

      // refrescar observables
      (onlyUnread ? newMessages : oldMessages).refresh();

      // actualizar contador pending
      if (onlyUnread) {
        final allNew = auxMessages.length;
        pendingMessages.value = allNew <= 99 ? allNew : 99;
      }

      // actualizar mensajes
      (onlyUnread ? newMessages : oldMessages).forEach((key, newList) {
        final existingList = messages[key] ?? [];
        var different = [];

        // Filtra los mensajes que aún no existen por ID
        different.addAll(
          newList.where(
            (itemA) => !existingList.any((itemB) => itemB.id == itemA.id),
          ),
        );

        if (different.isNotEmpty) {
          messages[key] = [...existingList, ...different];
        }
      });

      // ordenar cada conversación por fecha ascendente (antiguos -> nuevos)
      for (var key in messages.keys) {
        messages[key]!.sort((a, b) => a.creationDate.compareTo(b.creationDate));
      }
    } else {
      Get.snackbar('Error', resp['message']);
    }
  }

  Future<void> getAppts() async {
    final data = {
      // TypeEnumList: 0 - NotDefined, 1 - Appointment, 2 - Internment, 3 - Surgery, 4 - Emergency, 5 - Urgency
      'TypeEnumList': [1, 4, 5],
      'EmployeeIDList': [authenticatedEmployee.value!.id],
      'RoomID': null,
      'StoreID': _pref.storeID,
      'ScheduleStartDate': DateTime(2025, 10, 1).toUtc().toIso8601String(),
      'ScheduleEndDate': DateTime(2025, 10, 31).toUtc().toIso8601String(),
      'OnlyNotCanceled': null,
    };
    Map<String, dynamic> resp = await _provider.getAppts(data);
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
