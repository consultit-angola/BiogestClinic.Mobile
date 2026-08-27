import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../shared/api_config.dart';

class MessageReceivedByUserEvent {
  static const String attachmentMessage = 'attachDocument';

  const MessageReceivedByUserEvent({this.chatID, this.message});

  final int? chatID;
  final String? message;

  bool get hasAttachment => message == attachmentMessage;

  factory MessageReceivedByUserEvent.fromData(dynamic data) {
    final event = data is Map ? data : const <dynamic, dynamic>{};
    final metadataValue = event['metadata'];
    final metadata = metadataValue is Map
        ? metadataValue
        : const <dynamic, dynamic>{};
    final chatIDValue = metadata['chatID'];

    return MessageReceivedByUserEvent(
      chatID: chatIDValue is int
          ? chatIDValue
          : int.tryParse(chatIDValue?.toString() ?? ''),
      message: metadata['message']?.toString(),
    );
  }
}

class NotificationSocketService {
  io.Socket? _socket;
  final Set<String> _channels = {};
  bool _hasConnected = false;
  FutureOr<void> Function(MessageReceivedByUserEvent event)?
  _onMessageReceivedByUser;

  void connect({required FutureOr<void> Function() onReconnected}) {
    disconnect();
    final serverSecret = dotenv.env['SOCKET_SERVER_SECRET']?.trim() ?? '';
    if (serverSecret.isEmpty) {
      throw StateError(
        'A variável SOCKET_SERVER_SECRET não está configurada no ficheiro .env.',
      );
    }

    final socket = io.io(
      ApiConfig.socketServerUrl,
      io.OptionBuilder()
          .setPath('/socket.io')
          .setAuth({'token': serverSecret})
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      for (final channel in _channels) {
        socket.emit('join-channel', channel);
      }

      if (_hasConnected) {
        onReconnected();
      }
      _hasConnected = true;
    });

    socket.on('message-received-by-user', (data) {
      _onMessageReceivedByUser?.call(MessageReceivedByUserEvent.fromData(data));
    });

    socket.connect();
  }

  void joinChannel(String channel) {
    if (channel.isEmpty) return;
    _channels.add(channel);
    if (_socket?.connected == true) {
      _socket?.emit('join-channel', channel);
    }
  }

  void leaveChannel(String channel) {
    _channels.remove(channel);
    if (_socket?.connected == true) {
      _socket?.emit('leave-channel', channel);
    }
  }

  void onMessageReceivedByUser(
    FutureOr<void> Function(MessageReceivedByUserEvent event) handler,
  ) {
    _onMessageReceivedByUser = handler;
  }

  void sendMessageToUser({
    required int senderID,
    required String senderName,
    required String message,
    required DateTime creationDate,
    required List<String> attachmentsMimeTypes,
    required int recipientID,
  }) {
    final socket = _socket;
    if (socket == null) return;

    socket.emit('push-event', {
      'channels': ['${ApiConfig.socketProjectKey}|$recipientID'],
      'type': 'send-message-to-user',
      'metadata': {
        'sender': {'ID': senderID, 'Name': senderName},
        'message': message,
        'chatID': senderID,
        'creationDate': creationDate.toIso8601String(),
        'attachmentsMimeTypes': attachmentsMimeTypes,
      },
    });
  }

  void disconnect() {
    final socket = _socket;
    if (socket?.connected == true) {
      for (final channel in _channels) {
        socket?.emit('leave-channel', channel);
      }
    }
    socket?.dispose();
    _socket = null;
    _channels.clear();
    _hasConnected = false;
  }
}
