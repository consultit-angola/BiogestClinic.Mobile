import 'dart:async';
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
import '../routes/index.dart';
import '../ui/utils/app_toast.dart';
import 'index.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find<ChatController>();

  final _provider = Provider();
  final globalController = GlobalController.to;

  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  final conversationSearchQuery = ''.obs;
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  final destinationUser = Rxn<UserDTO>();
  final attachments = <AttachmentDTO>[].obs;
  int? _loadingConversationUserID;

  void clearConversationSearch() {
    searchController.clear();
    conversationSearchQuery.value = '';
  }

  Future<void> openPendingConversationOrChat() async {
    if (globalController.pendingConversations.value != 1) {
      _openChatList();
      return;
    }

    var user = _singlePendingConversationUser();
    if (user == null) {
      await getUsers();
      user = _singlePendingConversationUser();
    }

    if (user == null) {
      _openChatList();
      return;
    }

    openConversation(user, markAsRead: true);
  }

  void _openChatList() {
    if (Get.currentRoute != Routes.chat) {
      Get.toNamed(Routes.chat);
    }
  }

  void openConversation(UserDTO user, {bool markAsRead = false}) {
    destinationUser.value = user;
    searchFocusNode.unfocus();
    if (markAsRead) {
      markConversationAsRead();
    }
    Get.toNamed(Routes.chatDetails, arguments: {'userID': user.id});
  }

  Future<void> openConversationByID(
    int userID, {
    bool markAsRead = false,
  }) async {
    if (userID <= 0) return;
    if (_loadingConversationUserID == userID) return;

    _loadingConversationUserID = userID;
    try {
      var user = globalController.users.firstWhereOrNull(
        (user) => user.id == userID,
      );
      if (user == null) {
        await getUsers(forceReload: true, showLoading: false);
        user = globalController.users.firstWhereOrNull(
          (user) => user.id == userID,
        );
      }

      user ??= UserDTO(
        id: userID,
        login: '',
        name: '',
        email: '',
        phone: '',
        deleted: false,
        groupId: 0,
        shortName: '',
        groupName: '',
      );

      destinationUser.value = user;
      await globalController.getMessages(onlyUnread: false, userID: userID);
      if (markAsRead) {
        markConversationAsRead();
      }
    } finally {
      _loadingConversationUserID = null;
    }
  }

  Future<void> loadRouteConversationIfNeeded(int userID) async {
    if (destinationUser.value?.id == userID) return;
    await openConversationByID(userID, markAsRead: true);
  }

  UserDTO? _singlePendingConversationUser() {
    final currentUserID = globalController.authenticatedUser.value?.id;
    if (currentUserID == null) return null;

    final senderIDs = globalController.newMessages.entries
        .where(
          (entry) => entry.value.any(
            (message) =>
                message.destinationUserID == currentUserID &&
                message.status != MessageStatus.read,
          ),
        )
        .map((entry) => entry.key)
        .toList();
    if (senderIDs.length != 1) return null;

    return globalController.users.firstWhereOrNull(
      (user) => user.id == senderIDs.single,
    );
  }

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
        AppToast.show('Error', resp['message']);
      }
    } catch (error) {
      AppToast.show('Error', '$error');
    } finally {
      if (showLoading) EasyLoading.dismiss();
    }
  }

  // ────────────────────────────────
  // Messages
  // ────────────────────────────────
  Future<bool?> sendMessage() async {
    final user = destinationUser.value;
    final text = inputController.text.trim();
    final selectedAttachments = List<AttachmentDTO>.from(attachments);
    if (user == null || (text.isEmpty && selectedAttachments.isEmpty)) {
      return null;
    }

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();

    final message = MessageDTO(
      id: tempId,
      messageText: text.isEmpty ? 'attachDocument' : text,
      creationDate: now,
      creationUserID: 0,
      destinationUserID: user.id,
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
        globalController.notifyChatMessageSent(
          message: sent,
          senderName: globalController.authenticatedUser.value?.name ?? '',
          attachmentsMimeTypes: selectedAttachments
              .map((attachment) => _getAttachmentMimeType(attachment.name))
              .toList(),
        );
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

  Future<void> sendBroadcastMessage({
    required List<UserDTO> users,
    required String text,
  }) async {
    final messageText = text.trim();
    if (users.isEmpty || messageText.isEmpty) return;

    EasyLoading.show();
    try {
      final now = DateTime.now();
      final results = await Future.wait(
        users.map((user) async {
          final message = MessageDTO(
            id: 0,
            messageText: messageText,
            creationDate: now,
            creationUserID: 0,
            destinationUserID: user.id,
            attachments: const [],
          );
          final resp = await _provider.sendMessage(message: message);
          if (resp['ok'] != true) return false;

          final sent = resp['data'] as MessageDTO..status = MessageStatus.sent;
          _addSentMessage(user.id, sent);
          globalController.notifyChatMessageSent(
            message: sent,
            senderName: globalController.authenticatedUser.value?.name ?? '',
            attachmentsMimeTypes: const [],
          );
          return true;
        }),
      );

      final sentCount = results.where((sent) => sent).length;
      if (sentCount == users.length) {
        AppToast.show(
          'Sucesso',
          'Mensagem de difusão enviada para $sentCount utilizadores.',
        );
      } else if (sentCount > 0) {
        AppToast.show(
          'Atenção',
          'Mensagem enviada para $sentCount de ${users.length} utilizadores.',
        );
      } else {
        AppToast.show('Erro', 'Não foi possível enviar a mensagem de difusão.');
      }
    } catch (error) {
      AppToast.show('Erro', 'Não foi possível enviar a mensagem: $error');
    } finally {
      EasyLoading.dismiss();
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
        AppToast.show(
          'Erro',
          'Não foi possível ler os ficheiros selecionados.',
        );
        return;
      }

      attachments.assignAll(selected);
      await sendMessage();
    } catch (error) {
      AppToast.show('Erro', 'Não foi possível anexar o ficheiro: $error');
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
        AppToast.show('Erro', result.message);
      }
    } catch (error) {
      AppToast.show('Erro', 'Não foi possível abrir o ficheiro: $error');
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

  void _addSentMessage(int key, MessageDTO message) {
    final messages = globalController.messages.putIfAbsent(
      key,
      () => <MessageDTO>[].obs,
    );
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
    messages.sort((a, b) => a.creationDate.compareTo(b.creationDate));
    messages.refresh();
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

  String _getAttachmentMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    const mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
      'pdf': 'application/pdf',
      'txt': 'text/plain',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'zip': 'application/zip',
    };
    return mimeTypes[extension] ?? 'application/octet-stream';
  }

  void markConversationAsRead() {
    if (globalController.messages.isEmpty || destinationUser.value == null) {
      return;
    }

    final msgs = globalController.messages[destinationUser.value!.id];
    if (msgs == null) {
      return;
    }

    var markedMessages = 0;
    for (final m in msgs) {
      if (m.destinationUserID == globalController.authenticatedUser.value!.id &&
          m.status != MessageStatus.read) {
        unawaited(setMessageMarkAsRead(m.id));
        m.status = MessageStatus.read;
        markedMessages++;
      }
    }
    if (markedMessages == 0) {
      return;
    }

    globalController.newMessages.remove(destinationUser.value!.id);
    globalController.newMessages.refresh();
    globalController.pendingConversations.value =
        globalController.pendingConversations.value > 0
        ? globalController.pendingConversations.value - 1
        : 0;
    globalController.notifyChatRead(destinationUser.value!.id);
    final remainingMessages =
        globalController.pendingMessages.value - markedMessages;
    globalController.pendingMessages.value = remainingMessages < 0
        ? 0
        : remainingMessages;
    globalController.messages.refresh();
  }

  List<MessageDTO> sortList() {
    final userID = destinationUser.value?.id;
    if (userID == null) return [];

    final list = [...?globalController.messages[userID]];
    list.sort((a, b) => a.creationDate.compareTo(b.creationDate));
    return list;
  }

  Future<void> setMessageMarkAsRead(int messageID) async {
    try {
      final resp = await _provider.setMessageMarkAsRead(messageID: messageID);
      if (!resp['ok']) {
        AppToast.show('Error', resp['message']);
      }
    } catch (error) {
      AppToast.show('Error', '$error');
    } finally {}
  }

  Future<void> markAllConversationsAsRead() async {
    final currentUserID = globalController.authenticatedUser.value?.id;
    if (currentUserID == null) return;

    final unreadMessages = <int, int>{};
    for (final entry in globalController.newMessages.entries) {
      for (final message in entry.value) {
        if (message.id > 0 && message.destinationUserID == currentUserID) {
          unreadMessages[message.id] = entry.key;
        }
      }
    }

    if (unreadMessages.isEmpty) {
      globalController.pendingMessages.value = 0;
      AppToast.show('Informação', 'Não existem mensagens por ler.');
      return;
    }

    EasyLoading.show();
    try {
      final results = await Future.wait(
        unreadMessages.keys.map((messageID) async {
          final resp = await _provider.setMessageMarkAsRead(
            messageID: messageID,
          );
          return MapEntry(messageID, resp['ok'] == true);
        }),
      );
      final markedIDs = results
          .where((result) => result.value)
          .map((result) => result.key)
          .toSet();

      _setMessagesAsRead(globalController.messages, markedIDs);
      _setMessagesAsRead(globalController.oldMessages, markedIDs);

      final sendersToNotify = <int>[];
      for (final entry in globalController.newMessages.entries.toList()) {
        entry.value.removeWhere((message) => markedIDs.contains(message.id));
        if (entry.value.isEmpty) {
          globalController.newMessages.remove(entry.key);
          sendersToNotify.add(entry.key);
        } else {
          entry.value.refresh();
        }
      }

      globalController.newMessages.refresh();
      globalController.pendingConversations.value =
          globalController.newMessages.length;
      globalController.messages.refresh();
      globalController.pendingMessages.value = globalController
          .newMessages
          .values
          .fold(0, (count, messages) => count + messages.length)
          .clamp(0, 99);

      for (final senderID in sendersToNotify) {
        globalController.notifyChatRead(senderID);
      }

      if (markedIDs.length == unreadMessages.length) {
        AppToast.show(
          'Sucesso',
          'Todas as mensagens foram marcadas como lidas.',
        );
      } else if (markedIDs.isNotEmpty) {
        AppToast.show(
          'Atenção',
          '${markedIDs.length} de ${unreadMessages.length} mensagens foram marcadas como lidas.',
        );
      } else {
        AppToast.show(
          'Erro',
          'Não foi possível marcar as mensagens como lidas.',
        );
      }
    } catch (error) {
      AppToast.show('Erro', 'Não foi possível marcar as mensagens: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _setMessagesAsRead(
    RxMap<int, RxList<MessageDTO>> messagesMap,
    Set<int> messageIDs,
  ) {
    if (messageIDs.isEmpty) return;

    for (final messages in messagesMap.values) {
      for (final message in messages) {
        if (messageIDs.contains(message.id)) {
          message.status = MessageStatus.read;
        }
      }
      messages.refresh();
    }
    messagesMap.refresh();
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
