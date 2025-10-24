import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import 'index.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find<ChatController>();

  final _provider = Provider();
  final globalController = GlobalController.to;

  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  final destinationUser = Rxn<UserDTO>();
  final attachments = Rxn<List<AttachmentDTO>>();

  @override
  void onInit() {
    super.onInit();
    if (!globalController.isChatControllerLoaded) {
      getUsers();
      globalController.isChatControllerLoaded = true;
    }
  }

  // @override
  // void onReady() {
  //   super.onReady();
  //   _markConversationAsRead();
  // }

  // ────────────────────────────────
  // USUARIOS
  // ────────────────────────────────
  Future<void> getUsers({bool forceReload = false}) async {
    if (globalController.users.isNotEmpty && !forceReload) return;

    try {
      globalController.users.clear();
      EasyLoading.show();
      final resp = await _provider.getUsers();

      if (resp['ok']) {
        globalController.users.value = resp['data'] as List<UserDTO>;
      } else {
        Get.snackbar('Error', resp['message']);
      }
    } catch (error) {
      Get.snackbar('Error', '$error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // ────────────────────────────────
  // MENSAJES
  // ────────────────────────────────
  Future<bool?> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty) return null;

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();

    final message = MessageDTO(
      id: tempId,
      messageText: text,
      creationDate: now,
      creationUserID: 0,
      destinationUserID: destinationUser.value!.id,
      attachments: attachments.value ?? [],
      status: MessageStatus.sending,
    );

    final key = message.destinationUserID;
    globalController.messages.putIfAbsent(key, () => []);
    globalController.messages[key]!.add(message);
    globalController.messages.refresh();
    scrollToBottom();

    inputController.clear();

    try {
      final resp = await _provider.sendMessage(message: message);
      if (resp['ok']) {
        final sent = resp['data'] as MessageDTO..status = MessageStatus.sent;

        _replaceTempMessage(key, tempId, sent);
        scrollToBottom();
        return true;
      } else {
        _setMessageStatus(key, tempId, MessageStatus.failed);
        return false;
      }
    } catch (error) {
      _setMessageStatus(key, tempId, MessageStatus.failed);
      return false;
    }
  }

  void _replaceTempMessage(int key, int tempId, MessageDTO sent) {
    final msgs = globalController.messages[key]!;
    final index = msgs.indexWhere((m) => m.id == tempId);
    if (index != -1) {
      msgs[index] = sent;
    } else {
      msgs.add(sent);
    }
    globalController.messages.refresh();
  }

  void _setMessageStatus(int key, int messageId, MessageStatus status) {
    if (!globalController.messages.containsKey(key)) return;
    final msgs = globalController.messages[key]!;
    final index = msgs.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      msgs[index].status = status;
      globalController.messages.refresh();
    }
  }

  void markConversationAsRead() {
    EasyLoading.show();
    if (globalController.messages.isEmpty || destinationUser.value == null) {
      EasyLoading.dismiss();
      return;
    }

    final msgs = globalController.messages[destinationUser.value!.id];
    if (msgs == null) {
      EasyLoading.dismiss();
      return;
    }

    for (final m in msgs) {
      if (m.destinationUserID == globalController.authenticatedUser.value!.id) {
        setMessageMarkAsRead(m.id);
        m.status = MessageStatus.read;
      }
    }
    globalController.messages.refresh();

    EasyLoading.dismiss();
    return;
  }

  List<MessageDTO> sortList() {
    final list = [...?globalController.messages[destinationUser.value?.id]];
    list.sort((a, b) => a.creationDate.compareTo(b.creationDate));
    return list;
  }

  // ────────────────────────────────
  // UTILIDADES DE FECHA / SCROLL
  // ────────────────────────────────
  String formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void scrollToBottom({int durationMs = 250}) {
    if (!scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.easeOut,
        );
      } catch (_) {
        try {
          scrollController.jumpTo(0);
        } catch (_) {}
      }
    });
  }

  // ────────────────────────────────
  // MARCAR LEÍDO
  // ────────────────────────────────
  Future<void> setMessageMarkAsRead(int messageID) async {
    try {
      final resp = await _provider.setMessageMarkAsRead(messageID: messageID);
      if (!resp['ok']) {
        Get.snackbar('Error', resp['message']);
      }
    } catch (error) {
      Get.snackbar('Error', '$error');
    } finally {}
  }
}
