import 'index.dart';

class AlarmInstanceDTO {
  final int? id;
  final String? date;
  final AlarmInstanceStateDTO? state;
  final int? entityId;
  final String? entityStringId;
  final UserDTO? lastActionUser;
  final String? lastActionDate;
  final String? lastUserNotificationDate;
  final String? lastUserNotificationRepeatDate;
  final String? postponeDate;
  final String? text;
  final int? alarmId;
  final bool? isNotification;
  final bool? isNotificationRepeat;
  final List<int>? userToNotifyIds;

  AlarmInstanceDTO({
    this.id,
    this.date,
    this.state,
    this.entityId,
    this.entityStringId,
    this.lastActionUser,
    this.lastActionDate,
    this.lastUserNotificationDate,
    this.lastUserNotificationRepeatDate,
    this.postponeDate,
    this.text,
    this.alarmId,
    this.isNotification,
    this.isNotificationRepeat,
    this.userToNotifyIds,
  });

  factory AlarmInstanceDTO.fromJson(Map<String, dynamic> json) {
    return AlarmInstanceDTO(
      id: json['ID'] as int?,
      date: json['Date'] as String?,
      state: json['State'] != null
          ? AlarmInstanceStateDTO.fromJson(json['State'])
          : null,
      entityId: json['EntityID'] as int?,
      entityStringId: json['EntityStringID'] as String?,
      lastActionUser: json['LastActionUser'] != null
          ? UserDTO.fromJson(json['LastActionUser'])
          : null,
      lastActionDate: json['LastActionDate'] as String?,
      lastUserNotificationDate: json['LastUserNotificationDate'] as String?,
      lastUserNotificationRepeatDate:
          json['LastUserNotificationRepeatDate'] as String?,
      postponeDate: json['PostponeDate'] as String?,
      text: json['Text'] as String?,
      alarmId: json['AlarmID'] as int?,
      isNotification: json['IsNotification'] as bool?,
      isNotificationRepeat: json['IsNotificationRepeat'] as bool?,
      userToNotifyIds: (json['UserToNotifyIDs'] as List?)
          ?.map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Date': date,
      'State': state?.toJson(),
      'EntityID': entityId,
      'EntityStringID': entityStringId,
      'LastActionUser': lastActionUser?.toJson(),
      'LastActionDate': lastActionDate,
      'LastUserNotificationDate': lastUserNotificationDate,
      'LastUserNotificationRepeatDate': lastUserNotificationRepeatDate,
      'PostponeDate': postponeDate,
      'Text': text,
      'AlarmID': alarmId,
      'IsNotification': isNotification,
      'IsNotificationRepeat': isNotificationRepeat,
      'UserToNotifyIDs': userToNotifyIds,
    };
  }
}
