import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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

            Stack(
              children: [
                Column(children: [customAppbar(), buttonBack(), chatArea()]),
              ],
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
          Text(
            controller.user.value.name,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
            child: Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                child: ListView.builder(
                  reverse: true,
                  controller: controller.scrollController,
                  padding: EdgeInsets.all(8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    return chatBubble(msg);
                  },
                ),
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

  Widget chatBubble(Message msg) {
    return Row(
      mainAxisAlignment: msg.isSentByMe
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          constraints: BoxConstraints(maxWidth: Get.width * 0.7),
          decoration: BoxDecoration(
            color: msg.isSentByMe
                ? CustomColors.secondaryColor
                : CustomColors.primaryLightColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: msg.isSentByMe ? Radius.circular(16) : Radius.zero,
              bottomRight: msg.isSentByMe ? Radius.zero : Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.text,
                style: TextStyle(
                  color: msg.isSentByMe ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 2),
              Text(
                msg.time,
                style: TextStyle(fontSize: 10, color: Colors.grey[200]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
