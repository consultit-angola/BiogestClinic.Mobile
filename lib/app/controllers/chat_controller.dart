import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/models/index.dart';
import '../data/providers/provider.dart';
import 'index.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find<ChatController>();
  final Provider _provider = Provider();
  final globalController = GlobalController.to;
  final RxList<UserDTO> users = <UserDTO>[].obs;
  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  var inputController = TextEditingController();
  var scrollController = ScrollController();
  var destinationUser = Rxn<UserDTO>();
  var attachments = Rxn<List<AttachmentDTO>>();

  @override
  void onInit() {
    super.onInit();
    getUsers();
    getMessages();
  }

  void getUsers({bool forceReload = false}) async {
    if (users.isNotEmpty && !forceReload) return;

    try {
      users.clear();
      EasyLoading.show();
      Map<String, dynamic> resp = await _provider.getUsers();
      if (resp['ok']) {
        users.value = resp['data'] as List<UserDTO>;
        EasyLoading.dismiss();
      } else {
        Get.snackbar('Error', resp['message']);
      }
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      Get.snackbar('Error', '$error');
    }
  }

  void getMessages({silenceLoad = false}) async {
    try {
      globalController.messages.clear();
      if (!silenceLoad) {
        EasyLoading.show();
      }

      Map<String, dynamic> resp = await _provider.getMessages(
        userID: globalController.authenticatedUser.value!.id,
      );
      if (resp['ok']) {
        var auxMessages = resp['data'] as List<MessageDTO>;
        for (var message in auxMessages) {
          if (globalController.messages.containsKey(
            message.destinationUserID,
          )) {
            globalController.messages[message.destinationUserID]!.add(message);
            globalController.messages.refresh();
          } else {
            globalController.messages[message.destinationUserID] = [message];
          }
        }
        globalController.pendingMessages.value = auxMessages.length <= 99
            ? auxMessages.length
            : 99;
        EasyLoading.dismiss();
      } else {
        if (!silenceLoad) {
          Get.snackbar('Error', resp['message']);
        }
      }
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      if (!silenceLoad) {
        Get.snackbar('Error', '$error');
      }
    }
  }

  Future<bool?> sendMessage() async {
    try {
      final text = inputController.text.trim();
      if (text.isEmpty) return null;

      var message = MessageDTO(
        id: 0,
        messageText: text,
        creationDate: DateTime.now(),
        creationUserID: globalController.authenticatedUser.value!.id,
        destinationUserID: destinationUser.value!.id,
        attachments: attachments.value ?? [],
      );

      EasyLoading.show();
      Map<String, dynamic> resp = await _provider.sendMessage(message: message);
      if (resp['ok']) {
        message = resp['data'];

        if (globalController.messages.containsKey(message.destinationUserID)) {
          globalController.messages[message.destinationUserID]!.add(message);
          globalController.messages.refresh();
        } else {
          globalController.messages[message.destinationUserID] = [message];
        }

        getMessages(silenceLoad: true);
        inputController.clear();

        if (scrollController.hasClients) {
          scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
        EasyLoading.dismiss();
        return true;
      } else {
        Get.snackbar('Error', resp['message']);
        EasyLoading.dismiss();
        return false;
      }
    } catch (error) {
      EasyLoading.dismiss();
      Get.snackbar('Error', '$error');
      return false;
    }
  }

  List<MessageDTO> sortList() {
    final messagesList = [
      ...?globalController.messages[destinationUser.value!.id],
    ];
    messagesList.sort((a, b) => a.creationDate.compareTo(b.creationDate));

    // for (var m in messagesList) {
    //   setMarkAsRead(m.id);
    // }

    return messagesList;
  }

  String formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  void setMarkAsRead(int messageID) async {
    try {
      EasyLoading.show();
      Map<String, dynamic> resp = await _provider.setMarkAsRead(
        messageID: messageID,
      );
      if (!resp['ok']) {
        Get.snackbar('Error', resp['message']);
      }
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      Get.snackbar('Error', '$error');
    }
  }
}
