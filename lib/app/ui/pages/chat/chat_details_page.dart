import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/index.dart';
import '../../../data/models/index.dart';
import '../../index.dart';

class ChatDetailsPage extends GetView<ChatController> {
  const ChatDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ejecutar después del primer frame (solo una vez)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markConversationAsRead();
    });

    return Scaffold(
      drawer: customDrawer(),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Contenido principal
          Column(children: [customAppbar(), buttonBack(), _buildChatArea()]),
        ],
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

  /// 🔹 Área del chat con lista de mensajes y campo de entrada
  Widget _buildChatArea() {
    return Expanded(
      child: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: Obx(() {
              final messages = controller.sortList();
              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = messages.length - 1 - index;
                  final msg = messages[reversedIndex];
                  final prevMsg = reversedIndex > 0
                      ? messages[reversedIndex - 1]
                      : null;

                  final isDifferentDay =
                      prevMsg == null ||
                      !isSameDay(msg.creationDate, prevMsg.creationDate);

                  return Column(
                    children: [
                      if (isDifferentDay) _buildDateLabel(msg.creationDate),
                      _buildChatBubble(msg),
                    ],
                  );
                },
              );
            }),
          ),

          // Campo de entrada
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// 🔹 Burbujas de chat (enviadas y recibidas)
  Widget _buildChatBubble(MessageDTO msg) {
    final isMine =
        msg.creationUserID ==
            controller.globalController.authenticatedUser.value?.id ||
        msg.creationUserID == 0;

    final bubbleColor = isMine
        ? CustomColors.secondaryColor
        : CustomColors.primaryLightColor;

    return Row(
      mainAxisAlignment: isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            constraints: BoxConstraints(maxWidth: Get.width * 0.7),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMine ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMine ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.messageText != 'attachDocument') _buildMessageText(msg),
                if (msg.attachments.isNotEmpty) ...[
                  if (msg.messageText != 'attachDocument')
                    const SizedBox(height: 8),
                  ...msg.attachments.map(_buildAttachment),
                ],
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildMessageState(msg, isMine),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachment(AttachmentDTO attachment) {
    final imageBytes = _imageBytes(attachment);

    return InkWell(
      onTap: () => imageBytes == null
          ? controller.openAttachment(attachment)
          : _showImagePreview(attachment, imageBytes),
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.insert_drive_file,
                    size: 54,
                    color: CustomColors.secondaryColor,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Uint8List? _imageBytes(AttachmentDTO attachment) {
    final extension = attachment.name.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'}.contains(extension)) {
      return null;
    }

    try {
      return base64Decode(attachment.data);
    } catch (_) {
      return null;
    }
  }

  void _showImagePreview(AttachmentDTO attachment, Uint8List bytes) {
    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: InteractiveViewer(child: Image.memory(bytes))),
            TextButton.icon(
              onPressed: () => controller.openAttachment(attachment),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir ficheiro'),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Texto del mensaje
  Widget _buildMessageText(MessageDTO msg) {
    return Text(
      msg.messageText,
      style: const TextStyle(
        color: CustomColors.witheColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 🔹 Estado y hora del mensaje
  Widget _buildMessageState(MessageDTO msg, bool isMine) {
    IconData? icon;
    Color? color;

    if (isMine) {
      switch (msg.status) {
        case MessageStatus.sending:
          icon = Icons.access_time;
          color = CustomColors.witheColor;
          break;
        case MessageStatus.sent:
          icon = Icons.check;
          color = CustomColors.witheColor;
          break;
        case MessageStatus.read:
          icon = Icons.done_all;
          color = CustomColors.witheColor;
          break;
        default:
          icon = Icons.error;
          color = CustomColors.tertiaryColor;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('HH:mm').format(msg.creationDate),
          style: TextStyle(
            fontSize: 10,
            color: CustomColors.witheColor.withValues(alpha: 0.9),
          ),
        ),
        if (isMine && icon != null) ...[
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: color),
        ],
      ],
    );
  }

  /// 🔹 Etiqueta de día
  Widget _buildDateLabel(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formatDayLabel(date),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Campo de entrada del mensaje
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.attachFiles,
            child: const Icon(
              Icons.attach_file_rounded,
              color: CustomColors.secondaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.inputController,
              decoration: InputDecoration(
                hintText: 'Escrever uma mensagem...',
                filled: true,
                fillColor: CustomColors.witheColor,
                contentPadding: const EdgeInsets.symmetric(
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: controller.sendMessage,
            child: SvgPicture.asset(
              'assets/images/icon_send.svg',
              width: Get.width * 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
