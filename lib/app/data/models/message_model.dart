import 'dart:convert';
import 'index.dart';

enum MessageStatus { sending, sent, read, failed }

class MessageDTO {
  final int id;
  final String messageText;
  final DateTime creationDate;
  final int creationUserID;
  final int destinationUserID;
  final List<AttachmentDTO> attachments;
  MessageStatus status;

  MessageDTO({
    required this.id,
    required this.messageText,
    required this.creationDate,
    required this.creationUserID,
    required this.destinationUserID,
    required this.attachments,
    this.status = MessageStatus.sent,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageDTO &&
        other.id == id &&
        other.messageText == messageText &&
        other.creationDate == creationDate &&
        other.creationUserID == creationUserID &&
        other.destinationUserID == destinationUserID &&
        other.attachments == attachments;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      messageText.hashCode ^
      creationDate.hashCode ^
      creationUserID.hashCode ^
      destinationUserID.hashCode ^
      attachments.hashCode;

  factory MessageDTO.fromJson(Map<String, dynamic> json) {
    return MessageDTO(
      id: json['ID'] ?? 0,
      messageText: json['MessageText'] ?? '',
      creationDate: DateTime.parse(json['CreationDate']),
      creationUserID: json['CreationUserID'] ?? 0,
      destinationUserID: json['DestinationUserID'] ?? 0,
      attachments:
          (json['Attachments'] as List<dynamic>?)
              ?.map((a) => AttachmentDTO.fromJson(a))
              .toList() ??
          [],
      status: MessageStatus.sent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'MessageText': messageText,
      'CreationDate': creationDate.toIso8601String(),
      'CreationUserID': creationUserID,
      'DestinationUserID': destinationUserID,
      'Attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  static List<MessageDTO> listFromJson(String str) {
    final jsonData = jsonDecode(str);
    return List<MessageDTO>.from(jsonData.map((x) => MessageDTO.fromJson(x)));
  }
}
