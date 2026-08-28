import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  bool get isEnabled => _isEnabled;

  Stream<String> get tokenRefresh => _isEnabled
      ? FirebaseMessaging.instance.onTokenRefresh
      : const Stream<String>.empty();

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
