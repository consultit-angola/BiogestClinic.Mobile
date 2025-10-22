import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';

class ChatDetailsPage extends GetView<ChatController> {
  const ChatDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (chatController) => Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/background.png',
              width: Get.width,
              height: Get.height,
              fit: BoxFit.fill,
            ),

            Obx(
              () => Stack(
                children: [
                  Column(children: [customAppbar(), buttonBack(), chatArea()]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  buttonBack() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BackButton(
            color: Colors.black,
            onPressed: () {
              Get.back();
            },
          ),
          SizedBox(
            width: Get.width * 0.7,
            child: Text(
              controller.destinationUser.value?.name ?? '',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget chatArea() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: ListView(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(8),
                children: buildChatList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: CustomColors.secondaryColor,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.inputController,
                    decoration: InputDecoration(
                      hintText: 'Escrever uma mensagem...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: controller.sendMessage,
                  child: SvgPicture.asset(
                    'assets/images/icon_send.svg',
                    width: Get.width * 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildChatList() {
    final widgets = <Widget>[];
    final messages = controller.sortList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.scrollToBottom();
    });

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final prevMsg = i > 0 ? messages[i - 1] : null;

      final isDifferentDay =
          prevMsg == null ||
          msg.creationDate.day != prevMsg.creationDate.day ||
          msg.creationDate.month != prevMsg.creationDate.month ||
          msg.creationDate.year != prevMsg.creationDate.year;

      if (isDifferentDay) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.formatDayLabel(msg.creationDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      widgets.add(chatBubble(msg));
    }

    return widgets;
  }

  Widget chatBubble(MessageDTO msg) {
    return Row(
      mainAxisAlignment:
          msg.creationUserID ==
              controller.globalController.authenticatedUser.value?.id
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          constraints: BoxConstraints(maxWidth: Get.width * 0.7),
          decoration: BoxDecoration(
            color:
                msg.creationUserID ==
                    controller.globalController.authenticatedUser.value?.id
                ? CustomColors.secondaryColor
                : CustomColors.primaryLightColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft:
                  msg.creationUserID ==
                      controller.globalController.authenticatedUser.value?.id
                  ? Radius.circular(16)
                  : Radius.zero,
              bottomRight:
                  msg.creationUserID ==
                      controller.globalController.authenticatedUser.value?.id
                  ? Radius.zero
                  : Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.messageText,
                style: TextStyle(
                  color:
                      msg.creationUserID ==
                          controller
                              .globalController
                              .authenticatedUser
                              .value
                              ?.id
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              SizedBox(height: 2),
              Text(
                DateFormat('HH:mm').format(msg.creationDate),
                style: TextStyle(fontSize: 10, color: Colors.grey[200]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
