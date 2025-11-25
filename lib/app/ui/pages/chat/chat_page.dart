import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../../routes/index.dart';
import '../../index.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (chatController) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CustomColors.witheColor,
                    CustomColors.secondaryColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            Stack(
              children: [
                Column(
                  children: [
                    customAppbar(),
                    search(),
                    Obx(() {
                      final messagesMap = controller.globalController.messages;
                      return lastMessages(messagesMap);
                    }),
                  ],
                ),
                customMenu(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget lastMessages(RxMap<int, RxList<MessageDTO>> messagesMap) {
    var lastMessages = <Widget>[];

    for (final entry in messagesMap.entries) {
      final user = controller.globalController.users.firstWhereOrNull(
        (u) => u.id == entry.key,
      );
      final chatMessages = entry.value;
      if (chatMessages.isEmpty) continue;

      var pendingMessages = chatMessages
          .where(
            (m) =>
                m.status == MessageStatus.sent &&
                m.destinationUserID ==
                    controller.globalController.authenticatedUser.value?.id,
          )
          .length;

      if (user != null) {
        final lastMessage = chatMessages.last;
        lastMessages.add(
          contact(
            user: user,
            lastMessage: lastMessage.messageText,
            time: DateFormat('HH:mm').format(lastMessage.creationDate),
            pendingMessages: pendingMessages,
          ),
        );
      }
    }

    return Expanded(
      child: ListView(padding: EdgeInsets.zero, children: lastMessages),
    );
  }

  Widget contact({
    required UserDTO user,
    String? lastMessage,
    String? time,
    bool showTime = true,
    int? pendingMessages,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: Get.width * 0.066,
        backgroundColor: Colors.black12,
        child: CircleAvatar(
          radius: Get.width * 0.06,
          backgroundColor: CustomColors.secondaryColor,
          child: Icon(
            Icons.person_rounded,
            size: Get.width * 0.1,
            color: CustomColors.witheColor,
          ),
        ),
      ),
      title: Text(
        '${user.name} ${user.id == controller.globalController.authenticatedUser.value?.id ? '(Eu)' : ''}',
      ),
      subtitle: lastMessage != null
          ? Padding(
              padding: const EdgeInsets.only(left: 3.0),
              child: Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            )
          : null,
      onTap: () {
        controller.destinationUser.value = user;
        controller.searchFocusNode.unfocus();
        controller.searchController.clear();
        Get.toNamed(Routes.chatDetails);
      },
      trailing: showTime
          ? Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  pendingMessages == 0 || pendingMessages == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Container(
                            width: Get.width * 0.07,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
                              ),
                              color: CustomColors.secondaryColor,
                            ),
                            child: Text(
                              pendingMessages.toString(),
                              style: TextStyle(color: CustomColors.witheColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                  Text(time ?? TimeOfDay.now().format(Get.context!)),
                ],
              ),
            )
          : null,
    );
  }

  Widget search() {
    return Padding(
      padding: EdgeInsets.all(Get.width * 0.05),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.witheColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SearchField<UserDTO>(
          controller: controller.searchController,
          focusNode: controller.searchFocusNode,
          maxSuggestionsInViewPort: 5,
          itemHeight: 60,
          suggestionsDecoration: SuggestionDecoration(
            color: CustomColors.witheColor,
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            elevation: 8,
          ),
          searchInputDecoration: SearchInputDecoration(
            hintText: 'Pesquisar contatos',
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            fillColor: CustomColors.witheColor,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: GestureDetector(
              // onTapDown: (){},
              child: Icon(Icons.group_add_sharp, size: Get.width * 0.08),
            ),
          ),
          suggestions: controller.globalController.users
              .map(
                (user) => SearchFieldListItem<UserDTO>(
                  user.name,
                  child: contact(user: user, showTime: false),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
