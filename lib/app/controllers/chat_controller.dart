import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/index.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find<ChatController>();

  var messages = <Message>[].obs;
  var inputController = TextEditingController();
  var scrollController = ScrollController();
  var user = UserInfoDTO(
    id: 1,
    login: 'ryu',
    name: 'Ryu',
    email: 'ryu@gmail.com',
    phone: '123456',
    deleted: false,
    groupId: 2,
    shortName: 'Ryu',
    groupName: 'Users',
  ).obs;

  void sendMessage() {
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    messages.insert(
      0,
      Message(
        text: text,
        isSentByMe: messages.length % 2 == 0,
        time: TimeOfDay.now().format(Get.context!),
      ),
    );

    inputController.clear();

    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }
}
