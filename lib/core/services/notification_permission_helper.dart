// lib/core/services/notification_permission_helper.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../logger.dart';

class NotificationPermissionHelper {
  static Future<bool> checkAndRequestPermissions(BuildContext context) async {
    if (!Platform.isAndroid) {
      return true;
    }

    final notificationStatus = await Permission.notification.status;
    logger.i('📱 Notification permission: $notificationStatus');

    if (!notificationStatus.isGranted) {
      final granted = await Permission.notification.request();
      if (!granted.isGranted) {
        if (context.mounted) {
          _showPermissionDialog(
            context,
            'Notification Permission Required',
            'Please enable notifications to receive daily reminders.',
            Permission.notification,
          );
        }
        return false;
      }
    }

    if (Platform.isAndroid) {
      try {
        final scheduleStatus = await Permission.scheduleExactAlarm.status;
        logger.i('⏰ Schedule exact alarm permission: $scheduleStatus');

        if (!scheduleStatus.isGranted) {
          if (context.mounted) {
            final shouldRequest = await _showExactAlarmDialog(context);
            if (shouldRequest) {
              await Permission.scheduleExactAlarm.request();

              // Sprawdź ponownie
              final newStatus = await Permission.scheduleExactAlarm.status;
              if (!newStatus.isGranted) {
                if (context.mounted) {
                  _showManualInstructionsDialog(context);
                }
                return false;
              }
            } else {
              return false;
            }
          }
        }
      } catch (e) {
        logger.e('❌ Error checking exact alarm permission: $e');
      }
    }

    return true;
  }

  static Future<bool> _showExactAlarmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.alarm, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text('Exact Alarm Permission')),
              ],
            ),
            content: const Text(
              'GoodLoop needs permission to schedule exact alarms for daily reminders.\n\n'
              'This ensures you receive notifications at the exact time you choose.\n\n'
              'Tap "Allow" on the next screen.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Dialog z instrukcjami manualnymi
  static Future<void> _showManualInstructionsDialog(
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Manual Setup Required'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enable "Alarms & reminders" permission manually:\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStep('1', 'Open Phone Settings'),
              _buildStep('2', 'Go to Apps → GoodLoop'),
              _buildStep('3', 'Tap Permissions'),
              _buildStep('4', 'Enable "Alarms & reminders"'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is required for daily reminders to work',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I understand'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  static Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    Permission permission,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Future<bool> hasAllPermissions() async {
    if (!Platform.isAndroid) return true;

    final notification = await Permission.notification.isGranted;
    final exactAlarm = await Permission.scheduleExactAlarm.isGranted;

    logger.i('📱 Notification: $notification, Exact Alarm: $exactAlarm');
    return notification && exactAlarm;
  }

  static Future<String> getPermissionsStatus() async {
    if (!Platform.isAndroid) return 'iOS - Automatic';

    final notification = await Permission.notification.status;
    final exactAlarm = await Permission.scheduleExactAlarm.status;

    return 'Notifications: ${notification.name}\n'
        'Exact Alarms: ${exactAlarm.name}';
  }
}
