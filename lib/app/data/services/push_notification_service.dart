import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationTap {
  const PushNotificationTap({this.chatID, this.senderID, this.messageID});

  final int? chatID;
  final int? senderID;
  final int? messageID;

  int? get conversationUserID => chatID ?? senderID;

  factory PushNotificationTap.fromRemoteMessage(RemoteMessage message) {
    return PushNotificationTap.fromData(message.data);
  }

  factory PushNotificationTap.fromData(Map<String, dynamic> data) {
    final metadata = _readMap(data['metadata']);

    int? readInt(String key) {
      final value = data[key] ?? metadata[key];
      return value is int ? value : int.tryParse(value?.toString() ?? '');
    }

    int? readNestedSenderID() {
      final sender = _readMap(data['sender']);
      final metadataSender = _readMap(metadata['sender']);
      final senderData = sender.isNotEmpty ? sender : metadataSender;
      if (senderData.isEmpty) return null;

      final value = senderData['ID'] ?? senderData['id'];
      return value is int ? value : int.tryParse(value?.toString() ?? '');
    }

    return PushNotificationTap(
      chatID: readInt('chatID') ?? readInt('ChatID'),
      senderID:
          readInt('senderID') ?? readInt('SenderID') ?? readNestedSenderID(),
      messageID: readInt('messageID') ?? readInt('MessageID'),
    );
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is! String || value.trim().isEmpty) return {};

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}

    return {};
  }
}

class FirebaseEnvironmentOptions {
  static FirebaseOptions? fromEnvironment() {
    final apiKey = dotenv.env['FIREBASE_API_KEY']?.trim() ?? '';
    final appID = dotenv.env['FIREBASE_APP_ID']?.trim() ?? '';
    final messagingSenderID =
        dotenv.env['FIREBASE_MESSAGING_SENDER_ID']?.trim() ?? '';
    final projectID = dotenv.env['FIREBASE_PROJECT_ID']?.trim() ?? '';

    if ([
      apiKey,
      appID,
      messagingSenderID,
      projectID,
    ].any((value) => value.isEmpty)) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appID,
      messagingSenderId: messagingSenderID,
      projectId: projectID,
    );
  }
}

@pragma('vm:entry-point')
Future<void> pushNotificationBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!dotenv.isInitialized) {
    await dotenv.load(fileName: '.env');
  }

  if (Firebase.apps.isEmpty) {
    await PushNotificationService.initializeFirebaseApp();
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String messageChannelID = 'messages';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isEnabled = false;
  bool _localNotificationsInitialized = false;
  PushNotificationTap? _initialTap;
  StreamSubscription<RemoteMessage>? _notificationTapSubscription;
  final StreamController<PushNotificationTap> _tapController =
      StreamController<PushNotificationTap>.broadcast();

  bool get isEnabled => _isEnabled;

  Stream<String> get tokenRefresh => _isEnabled
      ? FirebaseMessaging.instance.onTokenRefresh
      : const Stream<String>.empty();

  Stream<PushNotificationTap> get notificationTaps => _tapController.stream;

  static Future<void> initializeFirebaseApp() async {
    final options = FirebaseEnvironmentOptions.fromEnvironment();
    if (options == null) {
      await Firebase.initializeApp();
      return;
    }

    await Firebase.initializeApp(options: options);
  }

  Future<bool> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    await _initializeLocalNotifications();

    try {
      if (Firebase.apps.isEmpty) {
        await initializeFirebaseApp();
      }
      FirebaseMessaging.onBackgroundMessage(pushNotificationBackgroundHandler);
      _isEnabled = true;
      await _listenNotificationTaps();

      final token = await FirebaseMessaging.instance.getToken();
      log('FCM TOKEN: $token');

      return true;
    } catch (error) {
      debugPrint('Firebase Cloud Messaging initialization failed: $error');
      return false;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('launcher_icon'),
        ),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              messageChannelID,
              'Mensagens',
              description: 'Notificações de novas mensagens',
              importance: Importance.high,
              showBadge: true,
            ),
          );
      _localNotificationsInitialized = true;
    } catch (error) {
      debugPrint('Local notification initialization failed: $error');
    }
  }

  Future<String?> requestPermissionAndGetToken() async {
    if (!_isEnabled) return null;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!authorized) return null;
    return FirebaseMessaging.instance.getToken();
  }

  PushNotificationTap? consumeInitialNotificationTap() {
    final tap = _initialTap;
    _initialTap = null;
    return tap;
  }

  Future<void> _listenNotificationTaps() async {
    _initialTap = await FirebaseMessaging.instance.getInitialMessage().then(
      (message) => message == null
          ? null
          : PushNotificationTap.fromRemoteMessage(message),
    );

    await _notificationTapSubscription?.cancel();
    _notificationTapSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      _tapController.add(PushNotificationTap.fromRemoteMessage(message));
    });
  }

  Future<void> cancelSenderNotification(int senderID) async {
    if (!_localNotificationsInitialized) return;
    await _localNotifications.cancel(id: 0, tag: 'chat-$senderID');
  }

  Future<void> syncActiveSenderNotifications(Set<int> senderIDs) async {
    if (!_localNotificationsInitialized) return;

    final notifications = await _localNotifications.getActiveNotifications();
    for (final notification in notifications) {
      final tag = notification.tag;
      if (tag == null || !tag.startsWith('chat-')) continue;

      final senderID = int.tryParse(tag.substring('chat-'.length));
      if (senderID == null || senderIDs.contains(senderID)) continue;

      await _localNotifications.cancel(id: notification.id ?? 0, tag: tag);
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_localNotificationsInitialized) return;
    await _localNotifications.cancelAll();
  }
}
