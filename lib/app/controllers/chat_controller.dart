import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

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
  final attachments = <AttachmentDTO>[].obs;

  // ────────────────────────────────
  // Users
  // ────────────────────────────────
  Future<void> getUsers({
    bool forceReload = false,
    bool showLoading = true,
  }) async {
    if (globalController.users.isNotEmpty && !forceReload) return;

    try {
      globalController.users.clear();
      if (showLoading) EasyLoading.show();
      final resp = await _provider.getUsers();

      if (resp['ok']) {
        globalController.users.value = resp['data'] as List<UserDTO>;
      } else {
        Get.snackbar('Error', resp['message']);
      }
    } catch (error) {
      Get.snackbar('Error', '$error');
    } finally {
      if (showLoading) EasyLoading.dismiss();
    }
  }

  // ────────────────────────────────
  // Messages
  // ────────────────────────────────
  Future<bool?> sendMessage() async {
    final text = inputController.text.trim();
    final selectedAttachments = List<AttachmentDTO>.from(attachments);
    if (text.isEmpty && selectedAttachments.isEmpty) return null;

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();

    final message = MessageDTO(
      id: tempId,
      messageText: text.isEmpty ? 'attachDocument' : text,
      creationDate: now,
      creationUserID: 0,
      destinationUserID: destinationUser.value!.id,
      attachments: selectedAttachments,
      status: MessageStatus.sending,
    );

    final key = message.destinationUserID;
    globalController.messages.putIfAbsent(key, () => <MessageDTO>[].obs);
    globalController.messages[key]!.add(message);
    globalController.messages.refresh();
    scrollToBottom();

    inputController.clear();

    try {
      final resp = await _provider.sendMessage(message: message);
      if (resp['ok']) {
        final sent = resp['data'] as MessageDTO..status = MessageStatus.sent;

        _replaceTempMessage(key, tempId, sent);
        attachments.clear();
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

  Future<void> attachFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;

      final selected = <AttachmentDTO>[];
      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) continue;

        selected.add(
          AttachmentDTO(id: 0, name: file.name, data: base64Encode(bytes)),
        );
      }

      if (selected.isEmpty) {
        Get.snackbar('Erro', 'Não foi possível ler os ficheiros selecionados.');
        return;
      }

      attachments.assignAll(selected);
      await sendMessage();
    } catch (error) {
      Get.snackbar('Erro', 'Não foi possível anexar o ficheiro: $error');
    }
  }

  Future<void> openAttachment(AttachmentDTO attachment) async {
    try {
      final bytes = base64Decode(attachment.data);
      final tempDirectory = await getTemporaryDirectory();
      final safeName = attachment.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final file = File(
        '${tempDirectory.path}${Platform.pathSeparator}$safeName',
      );
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        Get.snackbar('Erro', result.message);
      }
    } catch (error) {
      Get.snackbar('Erro', 'Não foi possível abrir o ficheiro: $error');
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

  // ────────────────────────────────
  // Scroll
  // ────────────────────────────────

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
}
