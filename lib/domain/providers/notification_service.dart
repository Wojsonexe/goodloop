import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodloop/logger.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _prefHourKey = 'daily_reminder_hour';
  static const String _prefMinuteKey = 'daily_reminder_minute';

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final dynamic timeZoneResponse = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneResponse.toString();
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      logger.i("Ustawiono strefę czasową: $timeZoneName");
    } catch (e) {
      logger
          .e("Błąd ustawiania strefy '$timeZoneName': $e. Ustawiam domyślną.");
      tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
    }
  }

  Future<void> initialize() async {
    logger.i('📱 Initializing notification service...');

    await _requestPermissions();

    await _initializeLocalNotifications();

    await _configureFCM();

    logger.i('✅ Notification service initialized');
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    logger.i('📱 Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('✅ User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      logger.w('⚠️ User granted provisional permission');
    } else {
      logger.e('❌ User declined permission');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _configureFCM() async {
    String? token = await _messaging.getToken();
    if (token != null) {
      logger.i('📱 FCM Token: $token');
      await _saveTokenToFirestore(token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      logger.i('📱 New FCM Token: $newToken');
      _saveTokenToFirestore(newToken);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      logger.i('📱 App opened from terminated state via notification');
      _handleNotificationOpen(initialMessage);
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        logger.i('⚠️ No user logged in, skipping token save');
        return;
      }

      String platformName = 'unknown';
      try {
        if (Platform.isAndroid) {
          platformName = 'android';
        } else if (Platform.isIOS) {
          platformName = 'ios';
        }
      } catch (e) {
        // Fallback dla web/innych
        platformName = 'web/other';
      }

      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': platformName,
      }, SetOptions(merge: true));

      logger.i('✅ FCM Token saved to Firestore');
    } catch (e) {
      logger.e('❌ Error saving FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    logger.i('📱 Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'GoodLoop',
        body: message.notification!.body ?? '',
        payload: _encodePayload(message.data),
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    logger.i('📱 Notification tapped: ${response.payload}');

    if (response.payload == null) return;

    final data = _decodePayload(response.payload!);
    _navigateBasedOnPayload(data);
  }

  void _handleNotificationOpen(RemoteMessage message) {
    logger.i('📱 Notification opened app: ${message.data}');
    _navigateBasedOnPayload(message.data);
  }

  void _navigateBasedOnPayload(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      logger.w('⚠️ Navigator context not available');
      return;
    }

    final type = data['type'] as String?;
    final id = data['id'] as String?;

    logger.i('📱 Navigating to: type=$type, id=$id');

    switch (type) {
      case 'task':
        Navigator.pushNamed(context, '/home');
        break;

      case 'achievement':
        Navigator.pushNamed(context, '/achievements');
        break;

      case 'friend_request':
        Navigator.pushNamed(context, '/friends');
        break;

      case 'chat':
        Navigator.pushNamed(context, '/chat');
        break;

      case 'challenge':
        Navigator.pushNamed(context, '/daily-challenge');
        break;

      case 'feed':
        Navigator.pushNamed(context, '/feed');
        break;

      case 'reward':
        Navigator.pushNamed(context, '/rewards', arguments: {'userPoints': 0});
        break;

      default:
        Navigator.pushNamed(context, '/home');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'goodloop_channel',
      'GoodLoop Notifications',
      channelDescription: 'Notifications for GoodLoop app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF6200EE),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String? customMessage,
  }) async {
    logger.i('📱 Scheduling daily reminder for $hour:$minute');

    await _localNotifications.zonedSchedule(
      0,
      'Czas na dobry uczynek! 😊',
      customMessage ?? 'Sprawdź swoje dzisiejsze zadania w GoodLoop',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Przypomnienia o codziennych zadaniach',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHourKey, hour);
    await prefs.setInt(_prefMinuteKey, minute);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefHourKey);
    await prefs.remove(_prefMinuteKey);
  }

  Future<TimeOfDay?> getScheduledTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_prefHourKey);
    final minute = prefs.getInt(_prefMinuteKey);

    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  Future<void> notifyNewTask(String taskTitle) async {
    await _showLocalNotification(
      title: '🎯 Nowe zadanie!',
      body: taskTitle,
      payload: _encodePayload({'type': 'task'}),
    );
  }

  Future<void> notifyAchievementUnlocked(String achievementName) async {
    await _showLocalNotification(
      title: '🏆 Nowe osiągnięcie!',
      body: 'Odblokowałeś: $achievementName',
      payload: _encodePayload({'type': 'achievement'}),
    );
  }

  Future<void> notifyStreakMilestone(int days) async {
    await _showLocalNotification(
      title: '🔥 Niesamowita passa!',
      body: 'Wykonujesz zadania od $days dni z rzędu!',
      payload: _encodePayload({'type': 'task'}),
    );
  }

  Future<void> notifyFriendRequest(String friendName) async {
    await _showLocalNotification(
      title: '👥 Nowe zaproszenie!',
      body: '$friendName chce być Twoim znajomym',
      payload: _encodePayload({'type': 'friend_request'}),
    );
  }

  Future<void> notifyChatMessage(String senderName, String message) async {
    await _showLocalNotification(
      title: '💬 $senderName',
      body: message,
      payload: _encodePayload({'type': 'chat'}),
    );
  }

  Future<void> notifyDailyChallenge(String challengeTitle) async {
    await _showLocalNotification(
      title: '🎲 Nowe wyzwanie dnia!',
      body: challengeTitle,
      payload: _encodePayload({'type': 'challenge'}),
    );
  }

  String _encodePayload(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      logger.e('Błąd kodowania payloadu: $e');
      return '{}';
    }
  }

  Map<String, dynamic> _decodePayload(String payload) {
    final Map<String, dynamic> data = {};

    try {
      final parts = payload.split('&');
      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length == 2) {
          data[kv[0]] = kv[1];
        }
      }
    } catch (e) {
      logger.e('❌ Error decoding payload: $e');
    }

    return data;
  }

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
    logger.i('📱 All notifications cancelled');
  }

  Future<void> cancel(int id) async {
    await _localNotifications.cancel(id);
    logger.i('📱 Notification $id cancelled');
  }

  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (Theme.of(navigatorKey.currentContext!).platform ==
        TargetPlatform.android) {
      final notifications = await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications();
      return notifications ?? [];
    }
    return [];
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  logger.i('📱 Background message: ${message.notification?.title}');
}
