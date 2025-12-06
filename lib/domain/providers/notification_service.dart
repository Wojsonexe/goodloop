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
  static const String _prefEnabledKey = 'daily_reminder_enabled';

  static const int _dailyReminderId = 0;
  static const int _taskNotificationId = 1;
  static const int _achievementNotificationId = 2;
  static const int _streakNotificationId = 3;

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      logger.i("✅ Timezone set to: $timeZoneName");

      // 🐛 DEBUG: Log current time
      final now = tz.TZDateTime.now(tz.local);
      logger.i("🕐 Current local time: $now");
    } catch (e) {
      logger.e("❌ Timezone error: $e. Using Europe/Warsaw as fallback");
      tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
    }
  }

  Future<void> initialize() async {
    logger.i('📱 Initializing notification service...');

    await _requestPermissions();
    await _initializeLocalNotifications();
    await _configureFCM();
    await _restoreDailyReminder();

    logger.i('✅ Notification service initialized');
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission();
        logger.i('📱 Android notification permission: $granted');

        // 🐛 DEBUG: Request exact alarm permission
        final exactAlarmGranted =
            await androidImplementation.requestExactAlarmsPermission();
        logger.i('⏰ Exact alarm permission: $exactAlarmGranted');
      }
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    logger.i('📱 FCM permission: ${settings.authorizationStatus}');
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

    logger.i('✅ Local notifications initialized');
  }

  Future<void> _configureFCM() async {
    String? token = await _messaging.getToken();
    if (token != null) {
      logger.i('📱 FCM Token: ${token.substring(0, 20)}...');
      await _saveTokenToFirestore(token);
    }

    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String platformName = Platform.isAndroid ? 'android' : 'ios';

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
    if (context == null) return;

    final type = data['type'] as String?;
    logger.i('📱 Navigating to: type=$type');

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
      default:
        Navigator.pushNamed(context, '/home');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
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
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ✅ NAPRAWIONA FUNKCJA z pełnym debugowaniem
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String? customMessage,
  }) async {
    logger.i('📱 ========================================');
    logger.i('📱 SCHEDULING DAILY REMINDER');
    logger.i('📱 Time: $hour:${minute.toString().padLeft(2, '0')}');
    logger.i('📱 ========================================');

    try {
      // 1. Anuluj poprzednie
      await _localNotifications.cancel(_dailyReminderId);
      logger.i('✅ Previous notification cancelled');

      // 2. Zapisz ustawienia
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefHourKey, hour);
      await prefs.setInt(_prefMinuteKey, minute);
      await prefs.setBool(_prefEnabledKey, true);
      logger.i('✅ Settings saved to SharedPreferences');

      // 3. Oblicz następne wystąpienie
      final scheduledDate = _nextInstanceOfTime(hour, minute);

      // 🐛 DEBUG: Sprawdź obliczony czas
      final now = tz.TZDateTime.now(tz.local);
      final difference = scheduledDate.difference(now);
      logger.i('🕐 Current time: $now');
      logger.i('🕐 Scheduled time: $scheduledDate');
      logger.i(
          '⏰ Time until notification: ${difference.inHours}h ${difference.inMinutes % 60}m');

      // 4. Zaplanuj powiadomienie
      await _localNotifications.zonedSchedule(
        _dailyReminderId,
        '🎯 Time for a good deed!',
        customMessage ?? 'Check your daily tasks in GoodLoop',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Daily task reminders',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF6200EE),
            enableVibration: true,
            playSound: true,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      logger.i('✅ Daily reminder scheduled successfully');

      // 5. Verify scheduled notification
      await _verifyScheduledNotification();
    } catch (e, stack) {
      logger.e('❌ Error scheduling reminder: $e', stackTrace: stack);
      rethrow;
    }
  }

  // 🐛 DEBUG: Weryfikacja zaplanowanego powiadomienia
  Future<void> _verifyScheduledNotification() async {
    try {
      final pending = await _localNotifications.pendingNotificationRequests();
      logger.i('📋 Pending notifications: ${pending.length}');

      for (var notification in pending) {
        logger.i('  - ID: ${notification.id}');
        logger.i('    Title: ${notification.title}');
        logger.i('    Body: ${notification.body}');
      }

      if (pending.isEmpty) {
        logger.e('⚠️ WARNING: No pending notifications found!');
      }
    } catch (e) {
      logger.e('❌ Error verifying notifications: $e');
    }
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
      0,
      0,
    );

    // Jeśli ta godzina już minęła dzisiaj, zaplanuj na jutro
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      logger.i('⏭️ Time already passed today, scheduling for tomorrow');
    }

    return scheduledDate;
  }

  Future<void> _restoreDailyReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_prefEnabledKey) ?? false;

      if (!enabled) {
        logger.i('⚠️ Daily reminder not enabled, skipping restore');
        return;
      }

      final hour = prefs.getInt(_prefHourKey);
      final minute = prefs.getInt(_prefMinuteKey);

      if (hour != null && minute != null) {
        logger.i('🔄 Restoring daily reminder: $hour:$minute');
        await scheduleDailyReminder(hour: hour, minute: minute);
      }
    } catch (e) {
      logger.e('❌ Error restoring reminder: $e');
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      await _localNotifications.cancel(_dailyReminderId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefHourKey);
      await prefs.remove(_prefMinuteKey);
      await prefs.setBool(_prefEnabledKey, false);

      logger.i('❌ Daily reminder cancelled');
    } catch (e) {
      logger.e('❌ Error cancelling reminder: $e');
    }
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

  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefEnabledKey) ?? false;
  }

  Future<void> notifyNewTask(String taskTitle) async {
    await _showLocalNotification(
      id: _taskNotificationId,
      title: '🎯 New task available!',
      body: taskTitle,
      payload: _encodePayload({'type': 'task'}),
    );
  }

  Future<void> notifyAchievementUnlocked(String achievementName) async {
    await _showLocalNotification(
      id: _achievementNotificationId,
      title: '🏆 Achievement Unlocked!',
      body: 'You unlocked: $achievementName',
      payload: _encodePayload({'type': 'achievement'}),
    );
  }

  Future<void> notifyStreakMilestone(int days) async {
    await _showLocalNotification(
      id: _streakNotificationId,
      title: '🔥 Amazing Streak!',
      body: 'You\'ve completed tasks for $days days in a row!',
      payload: _encodePayload({'type': 'task'}),
    );
  }

  Future<void> notifyFriendRequest(String friendName) async {
    await _showLocalNotification(
      title: '👥 New Friend Request!',
      body: '$friendName wants to be your friend',
      payload: _encodePayload({'type': 'friend_request'}),
    );
  }

  String _encodePayload(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      logger.e('❌ Error encoding payload: $e');
      return '{}';
    }
  }

  Map<String, dynamic> _decodePayload(String payload) {
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (e) {
      logger.e('❌ Error decoding payload: $e');
      return {};
    }
  }

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
    logger.i('📱 All notifications cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  Future<void> logScheduledNotifications() async {
    final pending = await getPendingNotifications();
    logger.i('📋 ========================================');
    logger.i('📋 SCHEDULED NOTIFICATIONS: ${pending.length}');
    logger.i('📋 ========================================');
    for (var notification in pending) {
      logger.i('  ID: ${notification.id}');
      logger.i('  Title: ${notification.title}');
      logger.i('  Body: ${notification.body}');
      logger.i('  ---');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  logger.i('📱 Background message: ${message.notification?.title}');
}
