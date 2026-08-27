import 'package:biogest_clinic_mobile/app/data/services/notification_socket_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the Angular chat identifier from socket metadata', () {
    final event = MessageReceivedByUserEvent.fromData({
      'type': 'send-message-to-user',
      'metadata': {'chatID': 42},
    });

    expect(event.chatID, 42);
  });

  test('accepts a string chat identifier from socket metadata', () {
    final event = MessageReceivedByUserEvent.fromData({
      'metadata': {'chatID': '7'},
    });

    expect(event.chatID, 7);
  });

  test('identifies an attachment message from socket metadata', () {
    final event = MessageReceivedByUserEvent.fromData({
      'metadata': {'chatID': 7, 'message': 'attachDocument'},
    });

    expect(event.message, 'attachDocument');
    expect(event.hasAttachment, isTrue);
  });

  test('does not identify a text message as an attachment', () {
    final event = MessageReceivedByUserEvent.fromData({
      'metadata': {'chatID': 7, 'message': 'Hello'},
    });

    expect(event.message, 'Hello');
    expect(event.hasAttachment, isFalse);
  });
}
