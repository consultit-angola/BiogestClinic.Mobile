import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';
import 'broadcast_dialog.dart';
import 'new_conversation_dialog.dart';

enum _ChatCreationAction { newConversation, broadcast }

enum _ChatGeneralAction { markAllAsRead }

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (chatController) => Scaffold(
        backgroundColor: CustomColors.backgroundColor,
        drawer: customDrawer(),
        body: Column(
          children: [
            customAppbar(),
            search(context, chatController),
            Obx(() {
              final messagesMap = chatController.globalController.messages;
              return lastMessages(chatController, messagesMap);
            }),
          ],
        ),
        bottomNavigationBar: customMenu(alignBottom: false),
      ),
    );
  }

  Widget lastMessages(
    ChatController chatController,
    RxMap<int, RxList<MessageDTO>> messagesMap,
  ) {
    var lastMessages = <Widget>[];
    final query = chatController.conversationSearchQuery.value.toLowerCase();

    for (final entry in messagesMap.entries) {
      final user = chatController.globalController.users.firstWhereOrNull(
        (u) => u.id == entry.key,
      );
      final chatMessages = entry.value;
      if (chatMessages.isEmpty) continue;

      var pendingMessages = chatMessages
          .where(
            (m) =>
                m.status == MessageStatus.sent &&
                m.destinationUserID ==
                    chatController.globalController.authenticatedUser.value?.id,
          )
          .length;

      if (user != null) {
        final lastMessage = chatMessages.last;
        final lastMessageText = _getLastMessageText(lastMessage);
        final matchesSearch =
            query.isEmpty ||
            user.name.toLowerCase().contains(query) ||
            lastMessageText.toLowerCase().contains(query);
        if (!matchesSearch) continue;

        lastMessages.add(
          contact(
            chatController: chatController,
            user: user,
            lastMessage: lastMessageText,
            time: DateFormat('HH:mm').format(lastMessage.creationDate),
            pendingMessages: pendingMessages,
          ),
        );
      }
    }

    return Expanded(
      child: ListView(
        primary: false,
        padding: EdgeInsets.zero,
        children: lastMessages,
      ),
    );
  }

  String _getLastMessageText(MessageDTO message) {
    if (message.messageText == 'attachDocument' &&
        message.attachments.isNotEmpty) {
      return message.attachments.last.name;
    }

    return message.messageText;
  }

  Widget contact({
    required ChatController chatController,
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
        '${user.name} ${user.id == chatController.globalController.authenticatedUser.value?.id ? '(Eu)' : ''}',
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
        chatController.openConversation(user, markAsRead: true);
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

  Widget search(BuildContext context, ChatController chatController) {
    return Padding(
      padding: EdgeInsets.all(Get.width * 0.05),
      child: Row(
        children: [
          Expanded(
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
              child: Obx(
                () => TextField(
                  controller: chatController.searchController,
                  focusNode: chatController.searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar conversas',
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    fillColor: CustomColors.witheColor,
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        chatController.conversationSearchQuery.value.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.close),
                            onPressed: chatController.clearConversationSearch,
                          ),
                  ),
                  onChanged: (value) =>
                      chatController.conversationSearchQuery.value = value
                          .trim(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<_ChatCreationAction>(
            tooltip: 'Criar mensagem',
            icon: const Icon(Icons.chat, color: CustomColors.secondaryColor),
            onSelected: (action) =>
                _handleCreationAction(context, chatController, action),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ChatCreationAction.newConversation,
                child: Row(
                  children: [
                    Icon(Icons.group),
                    SizedBox(width: 12),
                    Text('Nova conversa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _ChatCreationAction.broadcast,
                child: Row(
                  children: [
                    Icon(Icons.groups),
                    SizedBox(width: 12),
                    Text('Nova mensagem de difusão'),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<_ChatGeneralAction>(
            tooltip: 'Mais opções',
            icon: const Icon(
              Icons.more_vert,
              color: CustomColors.secondaryColor,
            ),
            onSelected: (action) {
              if (action == _ChatGeneralAction.markAllAsRead) {
                chatController.markAllConversationsAsRead();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ChatGeneralAction.markAllAsRead,
                child: Text('Marcar todas como lidas'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreationAction(
    BuildContext context,
    ChatController chatController,
    _ChatCreationAction action,
  ) async {
    chatController.searchFocusNode.unfocus();
    if (chatController.globalController.users.isEmpty) {
      await chatController.getUsers();
    }
    if (!context.mounted) return;

    if (chatController.globalController.users.isEmpty) {
      AppToast.show('Informação', 'Não existem utilizadores disponíveis.');
      return;
    }

    if (action == _ChatCreationAction.newConversation) {
      final user = await _showNewConversationDialog(chatController);
      if (user != null && context.mounted) {
        _openConversation(chatController, user);
      }
      return;
    }

    final request = await _showBroadcastDialog(chatController);
    if (request != null) {
      await chatController.sendBroadcastMessage(
        users: request.users,
        text: request.message,
      );
    }
  }

  Future<UserDTO?> _showNewConversationDialog(
    ChatController chatController,
  ) async {
    final users = [...chatController.globalController.users]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final tag = 'new-conversation-${DateTime.now().microsecondsSinceEpoch}';
    Get.put(NewConversationDialogController(users: users), tag: tag);

    try {
      return await Get.dialog<UserDTO>(NewConversationDialog(tag: tag));
    } finally {
      if (Get.isRegistered<NewConversationDialogController>(tag: tag)) {
        await Get.delete<NewConversationDialogController>(tag: tag);
      }
    }
  }

  Future<BroadcastRequest?> _showBroadcastDialog(
    ChatController chatController,
  ) async {
    final users = [...chatController.globalController.users]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final tag = 'broadcast-${DateTime.now().microsecondsSinceEpoch}';
    Get.put(BroadcastDialogController(users: users), tag: tag);

    try {
      return await Get.dialog<BroadcastRequest>(BroadcastDialog(tag: tag));
    } finally {
      if (Get.isRegistered<BroadcastDialogController>(tag: tag)) {
        await Get.delete<BroadcastDialogController>(tag: tag);
      }
    }
  }

  void _openConversation(ChatController chatController, UserDTO user) {
    chatController.openConversation(user);
  }
}
