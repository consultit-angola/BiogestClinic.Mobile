import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import '../data/services/notification_socket_service.dart';
import '../data/services/push_notification_service.dart';
import '../data/shared/index.dart';
import '../routes/app_routes.dart';
import '../ui/utils/app_toast.dart';
import 'index.dart';

class GlobalController extends GetxController {
  static GlobalController get to => Get.find<GlobalController>();

  static const int appointmentScheduleManagementPermission = 500;
  static const int appointmentScheduleCreatePermission = 501;
  static const int viewOtherUsersSchedulePermission = 504;
  static const int globalConfigurationPermission = 25;
  static const int dashboardViewPermission = 39;
  static const int clientManagementPermission = 351;
  static const int activityManagementPermission = 750;

  final Provider _provider = Provider();
  final Preferences _pref = Preferences();
  final NotificationSocketService _notificationSocketService =
      NotificationSocketService();
  final PushNotificationService _pushNotificationService =
      PushNotificationService.instance;
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
  var pendingConversations = 0.obs;
  var pendingCalendar = 0.obs;
  var pendingAlarms = 0.obs;
  var pendingActivities = 0.obs;
  final pageRefreshing = false.obs;

  var isCalendarControllerLoaded = false;
  var isChatControllerLoaded = false;
  Timer? timerAlarms;
  Timer? timerAppts;
  bool _handlingExpiredSession = false;
  bool _timersStoppedByConnection = false;
  bool _loadingSocketMessages = false;
  bool _socketMessageRefreshPending = false;
  final Set<int> _pendingAttachmentChatIDs = <int>{};
  StreamSubscription<String>? _pushTokenSubscription;
  StreamSubscription<PushNotificationTap>? _pushNotificationTapSubscription;
  int _pageRefreshCount = 0;

  bool hasPermission(int permission) {
    return activePermissions.contains(permission);
  }

  bool get canAccessAppointmentCalendar =>
      hasPermission(appointmentScheduleManagementPermission);

  bool get canCreateAppointment =>
      hasPermission(appointmentScheduleCreatePermission);

  bool get canViewOtherUsersAppointments =>
      hasPermission(viewOtherUsersSchedulePermission);

  bool get canAccessAlarms => hasPermission(globalConfigurationPermission);

  bool get canAccessDashboard => hasPermission(dashboardViewPermission);

  bool get canAccessActivities => hasPermission(activityManagementPermission);

  bool get canAccessClientManagement =>
      hasPermission(clientManagementPermission);

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
      AppToast.show(
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
      await clearSession(clearPreferences: true);
      Get.offAllNamed(Routes.login);
      AppToast.show(
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
      startNotificationSocket(),
      if (canAccessAlarms) getProgrammedAlarms(),
      if (canAccessAppointmentCalendar) startApptsTimer(),
    ]);
  }

  Future<void> refreshPage(String route) async {
    if (!isAuthenticated.value) return;

    switch (route) {
      case Routes.home:
        if (Get.isRegistered<HomeController>()) {
          await _runPageRefresh(HomeController.to.loadToday);
        }
        break;
      case Routes.calendar:
        if (Get.isRegistered<CalendarController>()) {
          await _runPageRefresh(CalendarController.to.refreshAppointments);
        }
        break;
      case Routes.activities:
        if (Get.isRegistered<ActivitiesController>()) {
          await _runPageRefresh(ActivitiesController.to.loadActivities);
        }
        break;
      case Routes.chat:
        if (Get.isRegistered<ChatController>()) {
          await _runPageRefresh(
            () => Future.wait([
              ChatController.to.getUsers(forceReload: true, showLoading: false),
              getMessages(onlyUnread: false),
              getMessages(),
            ]),
          );
        }
        break;
      case Routes.chatDetails:
        await _runPageRefresh(
          () => Future.wait([getMessages(onlyUnread: false), getMessages()]),
        );
        break;
      case Routes.alarm:
        if (Get.isRegistered<AlarmController>()) {
          await _runPageRefresh(getProgrammedAlarms);
        }
        break;
      case Routes.user:
        if (Get.isRegistered<UserController>()) {
          await _runPageRefresh(UserController.to.loadStores);
        }
        break;
      case Routes.dashboard:
        if (Get.isRegistered<DashboardController>()) {
          final controller = Get.find<DashboardController>();
          await _runPageRefresh(
            () => Future.wait([
              controller.load(controller.period.value),
              controller.loadClientStatistics(),
              controller.loadRealTimeStatistics(),
            ]),
          );
        }
        break;
    }
  }

  Future<void> _runPageRefresh(Future<void> Function() refresh) async {
    _pageRefreshCount++;
    pageRefreshing.value = true;
    try {
      await refresh();
    } finally {
      _pageRefreshCount--;
      pageRefreshing.value = _pageRefreshCount > 0;
    }
  }

  Future<void> startNotificationSocket() async {
    final user = authenticatedUser.value;
    if (user == null) return;

    await _preparePushNotifications();

    _notificationSocketService.onMessageReceivedByUser(
      _handleSocketMessageReceived,
    );
    _notificationSocketService.connect(
      onConnected: _registerPushDevice,
      onReconnected: () async {
        await _registerPushDevice();
        await getMessages();
      },
    );
    _notificationSocketService.joinChannel(
      '${ApiConfig.socketProjectKey}|${user.id}',
    );
    await Future.wait([getMessages(onlyUnread: false), getMessages()]);
  }

  Future<void> _preparePushNotifications() async {
    await _pushTokenSubscription?.cancel();
    _pushTokenSubscription = _pushNotificationService.tokenRefresh.listen((
      token,
    ) {
      _pref.tokenFCM = token;
      unawaited(_registerPushDevice(token: token));
    });
    await _pushNotificationTapSubscription?.cancel();
    _pushNotificationTapSubscription = _pushNotificationService.notificationTaps
        .listen((tap) {
          unawaited(openPushNotificationConversation(tap));
        });

    final token = await _pushNotificationService.requestPermissionAndGetToken();
    if (token != null && token.isNotEmpty) {
      _pref.tokenFCM = token;
    }
  }

  Future<void> openInitialPushNotificationConversation() async {
    final tap = _pushNotificationService.consumeInitialNotificationTap();
    if (tap == null) return;

    await openPushNotificationConversation(tap);
  }

  Future<void> openPushNotificationConversation(PushNotificationTap tap) async {
    if (!isAuthenticated.value) return;

    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }

    final chatController = ChatController.to;
    final notificationUserID = tap.conversationUserID;
    await Future.wait([
      chatController.getUsers(forceReload: true, showLoading: false),
      if (notificationUserID != null && notificationUserID > 0)
        getMessages(onlyUnread: false, userID: notificationUserID),
      getMessages(),
    ]);

    final conversationUserID = _resolvePushNotificationConversationUserID(tap);
    if (conversationUserID == null || conversationUserID <= 0) {
      Get.toNamed(Routes.chat);
      return;
    }

    await getMessages(onlyUnread: false, userID: conversationUserID);

    final user =
        users.firstWhereOrNull((user) => user.id == conversationUserID) ??
        UserDTO(
          id: conversationUserID,
          login: '',
          name: '',
          email: '',
          phone: '',
          deleted: false,
          groupId: 0,
          shortName: '',
          groupName: '',
        );

    chatController.destinationUser.value = user;
    chatController.markConversationAsRead();
    Get.toNamed(Routes.chatDetails, arguments: {'userID': conversationUserID});
  }

  int? _resolvePushNotificationConversationUserID(PushNotificationTap tap) {
    final candidateIDs = [tap.senderID, tap.chatID].whereType<int>().toList();

    for (final candidateID in candidateIDs) {
      if (candidateID > 0) {
        return candidateID;
      }
    }

    final currentUserID = authenticatedUser.value?.id;
    final messageID = tap.messageID;
    if (currentUserID != null && messageID != null) {
      for (final messagesList in messages.values) {
        final message = messagesList.firstWhereOrNull(
          (message) => message.id == messageID,
        );
        if (message == null) continue;

        return message.destinationUserID == currentUserID
            ? message.creationUserID
            : message.destinationUserID;
      }
    }

    if (pendingConversations.value == 1 && newMessages.length == 1) {
      return newMessages.keys.first;
    }

    return null;
  }

  Future<void> _registerPushDevice({String? token}) async {
    final user = authenticatedUser.value;
    final deviceToken = token ?? _pref.tokenFCM;
    if (user == null || deviceToken.isEmpty) return;

    await _notificationSocketService.registerDeviceToken(
      channel: '${ApiConfig.socketProjectKey}|${user.id}',
      token: deviceToken,
    );
  }

  Future<void> _handleSocketMessageReceived(
    MessageReceivedByUserEvent event,
  ) async {
    if (authenticatedUser.value == null) return;

    final chatID = event.chatID;
    if (event.hasAttachment && chatID != null) {
      _pendingAttachmentChatIDs.add(chatID);
    }
    _socketMessageRefreshPending = true;

    if (_loadingSocketMessages) {
      return;
    }

    _loadingSocketMessages = true;
    try {
      do {
        _socketMessageRefreshPending = false;
        final attachmentChatIDs = Set<int>.from(_pendingAttachmentChatIDs);
        _pendingAttachmentChatIDs.clear();

        await getMessages();

        for (final attachmentChatID in attachmentChatIDs) {
          await getMessages(onlyUnread: false, userID: attachmentChatID);
        }
      } while (_socketMessageRefreshPending && authenticatedUser.value != null);
    } finally {
      _loadingSocketMessages = false;
    }
  }

  void notifyChatMessageSent({
    required MessageDTO message,
    required String senderName,
    required List<String> attachmentsMimeTypes,
  }) {
    final senderID = authenticatedUser.value?.id;
    if (senderID == null) return;

    _notificationSocketService.sendMessageToUser(
      senderID: senderID,
      senderName: senderName,
      message: message.messageText,
      creationDate: message.creationDate,
      attachmentsMimeTypes: attachmentsMimeTypes,
      recipientID: message.destinationUserID,
    );
  }

  void notifyChatRead(int senderID) {
    final user = authenticatedUser.value;
    if (user == null) return;

    unawaited(
      Future.wait([
        _notificationSocketService.markSenderAsRead(
          channel: '${ApiConfig.socketProjectKey}|${user.id}',
          senderID: senderID,
        ),
        _pushNotificationService.cancelSenderNotification(senderID),
      ]),
    );
  }

  Future<void> disconnectNotificationSocket({
    bool unregisterDevice = false,
  }) async {
    final deviceToken = _pref.tokenFCM;
    if (unregisterDevice && deviceToken.isNotEmpty) {
      await _notificationSocketService.unregisterDeviceToken(deviceToken);
    }
    if (unregisterDevice) {
      await _pushNotificationService.cancelAllNotifications();
    }
    await _pushTokenSubscription?.cancel();
    _pushTokenSubscription = null;
    await _pushNotificationTapSubscription?.cancel();
    _pushNotificationTapSubscription = null;
    _notificationSocketService.disconnect();
    _pendingAttachmentChatIDs.clear();
    _socketMessageRefreshPending = false;
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
    timerAlarms?.cancel();
    timerAppts?.cancel();
    timerAlarms = null;
    timerAppts = null;
  }

  Future<void> clearSession({bool clearPreferences = false}) async {
    stopTimer();
    await disconnectNotificationSocket(unregisterDevice: true);
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
    pendingConversations.value = 0;
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
        await clearSession(clearPreferences: true);
        Get.offAllNamed(Routes.login);
      } else {
        AppToast.show('Error', resp['message']);
      }
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      AppToast.show('Error', '$error');
    }
  }

  Future<void> getMessages({
    DateTime? startDate,
    DateTime? endDate,
    bool onlyUnread = true,
    int? userID,
    bool forceReload = false,
  }) async {
    final data = {
      "StartDate": startDate?.toUtc().toIso8601String(),
      "EndDate": endDate?.toUtc().toIso8601String(),
      "UserID": onlyUnread ? 0 : userID ?? authenticatedUser.value!.id,
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
      final currentUserID = authenticatedUser.value!.id;
      final activeConversationUserID = _activeConversationUserID;
      final visibleUnreadMessages = onlyUnread
          ? auxMessages
                .where(
                  (message) => isMessageFromActiveConversation(
                    message,
                    currentUserID,
                    activeConversationUserID,
                  ),
                )
                .toList()
          : <MessageDTO>[];

      // Update the pending message counter
      if (onlyUnread) {
        if (visibleUnreadMessages.isNotEmpty &&
            activeConversationUserID != null) {
          for (final message in visibleUnreadMessages) {
            message.status = MessageStatus.read;
            if (message.id > 0) {
              unawaited(_provider.setMessageMarkAsRead(messageID: message.id));
            }
          }
          newMessages.remove(activeConversationUserID);
          newMessages.refresh();
          notifyChatRead(activeConversationUserID);
        }

        final pendingUnreadMessages = unreadMessagesOutsideActiveConversation(
          auxMessages,
          currentUserID,
          activeConversationUserID: activeConversationUserID,
        );
        pendingMessages.value = pendingUnreadMessages.length <= 99
            ? pendingUnreadMessages.length
            : 99;

        final senderIDs = pendingUnreadMessages
            .where((message) => message.destinationUserID == currentUserID)
            .map((message) => message.creationUserID)
            .toSet();
        pendingConversations.value = senderIDs.length;
        unawaited(
          Future.wait([
            _notificationSocketService.syncPendingSenders(
              channel: '${ApiConfig.socketProjectKey}|$currentUserID',
              senderIDs: senderIDs,
            ),
            _pushNotificationService.syncActiveSenderNotifications(senderIDs),
          ]),
        );
      }

      // Insert or update incrementally
      for (var message in auxMessages) {
        final key = message.destinationUserID == authenticatedUser.value!.id
            ? message.creationUserID
            : message.destinationUserID;
        final isVisibleUnreadMessage =
            onlyUnread &&
            isMessageFromActiveConversation(
              message,
              currentUserID,
              activeConversationUserID,
            );

        // Ensure the list exists in the old/new map
        final targetMap = onlyUnread && !isVisibleUnreadMessage
            ? newMessages
            : oldMessages;
        final existing = targetMap.putIfAbsent(key, () => <MessageDTO>[].obs);

        // Update an existing message when its status or text changes
        final idx = existing.indexWhere((m) => m.id == message.id);
        if (idx != -1) {
          existing[idx] = message;
        } else {
          existing.add(message);
        }

        // Merge into the main message list without replacing it
        final mainList = messages.putIfAbsent(key, () => <MessageDTO>[].obs);

        for (var newMsg in existing) {
          final mIdx = mainList.indexWhere((m) => m.id == newMsg.id);
          if (mIdx != -1) {
            // Preserve the previous status
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

        // Sort by date
        mainList.sort((a, b) => a.creationDate.compareTo(b.creationDate));

        // Refresh only this RxList
        mainList.refresh();
      }
    } else {
      AppToast.show('Error', resp['message'] ?? 'Erro não identificado');
    }
  }

  bool mergedListEquals(List<MessageDTO> a, List<MessageDTO> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].status != b[i].status) return false;
    }
    return true;
  }

  List<MessageDTO> unreadMessagesOutsideActiveConversation(
    List<MessageDTO> unreadMessages,
    int currentUserID, {
    int? activeConversationUserID,
  }) {
    return unreadMessages
        .where(
          (message) => !isMessageFromActiveConversation(
            message,
            currentUserID,
            activeConversationUserID ?? _activeConversationUserID,
          ),
        )
        .toList();
  }

  bool isMessageFromActiveConversation(
    MessageDTO message,
    int currentUserID,
    int? activeConversationUserID,
  ) {
    return activeConversationUserID != null &&
        message.destinationUserID == currentUserID &&
        message.creationUserID == activeConversationUserID;
  }

  int? get _activeConversationUserID {
    if (Get.currentRoute != Routes.chatDetails ||
        !Get.isRegistered<ChatController>()) {
      return null;
    }

    return ChatController.to.destinationUser.value?.id;
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
      // 🔹 Clear all instance lists before repopulating them
      programmedAlarmsMap.forEach((key, value) {
        (value['instances'] as List).clear();
        value['length'] = 0;
      });

      // 🔹 Assign the new instances
      alarmInstances.value = resp['data'] as List<AlarmInstanceDTO>;

      // 🔹 Repopulate the grouped instances
      for (var instance in alarmInstances) {
        final alarm = programmedAlarmsMap[instance.alarmId];
        if (alarm != null) {
          (alarm['instances'] as List).add(instance);
        }
      }

      // 🔹 Recalculate the counts
      pendingAlarms.value = 0;
      programmedAlarmsMap.forEach((key, value) {
        value['length'] = (value['instances'] as List).length;
        if (value['length'] > 0) pendingAlarms.value++;
      });
    } else {
      AppToast.show('Error', resp['message']);
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
        AppToast.show('Error', resp['message']);
      }
    } catch (error) {
      AppToast.show('Error', '$error');
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
      AppToast.show('Error', resp['message']);
    }
  }
}
