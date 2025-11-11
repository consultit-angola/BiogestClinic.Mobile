class AlarmDTO {
  final int? id;
  final String? name;
  final String? startDate;
  final int? interval;
  final String? lastTestDate;
  final String? lastNotificationDate;
  final int? argumentType; // ['0', '1', '2', '3']
  final List<String>? arguments;
  final String? argumentsString;
  final bool? useNoticeTimeForExecution;
  final bool? detectedOnlyByService;
  final int? frequencyType; // ['1', '2', '3', '4']
  final String? userNoticeTime;
  final bool? monday;
  final bool? tuesday;
  final bool? wednesday;
  final bool? thursday;
  final bool? friday;
  final bool? saturday;
  final bool? sunday;
  final int? dayOfMonth;
  final int? hourlyInterval;
  final bool? immediateNotice;
  final bool? repeat;
  final int? repeatInterval;
  final int? postponeLimit;
  final bool? canBePostponed;
  final bool? canBeCanceled;
  final bool? canBeSentToWorkstation;
  final bool? canBeSentByEmail;
  final bool? canBeSentBySMS;
  final bool? sendToWorkstation;
  final bool? sendByEmail;
  final bool? sendBySMS;
  final List<int>? alarmUserIds;

  AlarmDTO({
    this.id,
    this.name,
    this.startDate,
    this.interval,
    this.lastTestDate,
    this.lastNotificationDate,
    this.argumentType,
    this.arguments,
    this.argumentsString,
    this.useNoticeTimeForExecution,
    this.detectedOnlyByService,
    this.frequencyType,
    this.userNoticeTime,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.dayOfMonth,
    this.hourlyInterval,
    this.immediateNotice,
    this.repeat,
    this.repeatInterval,
    this.postponeLimit,
    this.canBePostponed,
    this.canBeCanceled,
    this.canBeSentToWorkstation,
    this.canBeSentByEmail,
    this.canBeSentBySMS,
    this.sendToWorkstation,
    this.sendByEmail,
    this.sendBySMS,
    this.alarmUserIds,
  });

  factory AlarmDTO.fromJson(Map<String, dynamic> json) {
    return AlarmDTO(
      id: json['ID'] as int?,
      name: json['Name'] as String?,
      startDate: json['StartDate'] as String?,
      interval: json['Interval'] as int?,
      lastTestDate: json['LastTestDate'] as String?,
      lastNotificationDate: json['LastNotificationDate'] as String?,
      argumentType: json['ArgumentType'] as int?,
      arguments: (json['Arguments'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      argumentsString: json['ArgumentsString'] as String?,
      useNoticeTimeForExecution: json['UseNoticeTimeForExecution'] as bool?,
      detectedOnlyByService: json['DetectedOnlyByService'] as bool?,
      frequencyType: json['FrequencyType'] as int?,
      userNoticeTime: json['UserNoticeTime'] as String?,
      monday: json['Monday'] as bool?,
      tuesday: json['Tuesday'] as bool?,
      wednesday: json['Wednesday'] as bool?,
      thursday: json['Thursday'] as bool?,
      friday: json['Friday'] as bool?,
      saturday: json['Saturday'] as bool?,
      sunday: json['Sunday'] as bool?,
      dayOfMonth: json['DayOfMonth'] as int?,
      hourlyInterval: json['HourlyInterval'] as int?,
      immediateNotice: json['ImmediateNotice'] as bool?,
      repeat: json['Repeat'] as bool?,
      repeatInterval: json['RepeatInterval'] as int?,
      postponeLimit: json['PostponeLimit'] as int?,
      canBePostponed: json['CanBePostponed'] as bool?,
      canBeCanceled: json['CanBeCanceled'] as bool?,
      canBeSentToWorkstation: json['CanBeSentToWorkstation'] as bool?,
      canBeSentByEmail: json['CanBeSentByEmail'] as bool?,
      canBeSentBySMS: json['CanBeSentBySMS'] as bool?,
      sendToWorkstation: json['SendToWorkstation'] as bool?,
      sendByEmail: json['SendByEmail'] as bool?,
      sendBySMS: json['SendBySMS'] as bool?,
      alarmUserIds: (json['AlarmUserIDs'] as List?)
          ?.map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
      'StartDate': startDate,
      'Interval': interval,
      'LastTestDate': lastTestDate,
      'LastNotificationDate': lastNotificationDate,
      'ArgumentType': argumentType,
      'Arguments': arguments,
      'ArgumentsString': argumentsString,
      'UseNoticeTimeForExecution': useNoticeTimeForExecution,
      'DetectedOnlyByService': detectedOnlyByService,
      'FrequencyType': frequencyType,
      'UserNoticeTime': userNoticeTime,
      'Monday': monday,
      'Tuesday': tuesday,
      'Wednesday': wednesday,
      'Thursday': thursday,
      'Friday': friday,
      'Saturday': saturday,
      'Sunday': sunday,
      'DayOfMonth': dayOfMonth,
      'HourlyInterval': hourlyInterval,
      'ImmediateNotice': immediateNotice,
      'Repeat': repeat,
      'RepeatInterval': repeatInterval,
      'PostponeLimit': postponeLimit,
      'CanBePostponed': canBePostponed,
      'CanBeCanceled': canBeCanceled,
      'CanBeSentToWorkstation': canBeSentToWorkstation,
      'CanBeSentByEmail': canBeSentByEmail,
      'CanBeSentBySMS': canBeSentBySMS,
      'SendToWorkstation': sendToWorkstation,
      'SendByEmail': sendByEmail,
      'SendBySMS': sendBySMS,
      'AlarmUserIDs': alarmUserIds,
    };
  }
}
