import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/providers/notification_service.dart';

class NotificationDebugSection extends ConsumerWidget {
  const NotificationDebugSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      leading: const Icon(Icons.bug_report, color: Colors.orange),
      title: const Text('Debug Notifications'),
      subtitle: const Text('Test and check scheduled notifications'),
      children: [
        ListTile(
          leading: const Icon(Icons.send, color: Colors.blue),
          title: const Text('Test Instant Notification'),
          subtitle: const Text('Send a test notification now'),
          onTap: () => _testInstantNotification(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.schedule, color: Colors.green),
          title: const Text('View Scheduled Notifications'),
          subtitle: const Text('Check pending notifications'),
          onTap: () => _showScheduledNotifications(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.task, color: Colors.purple),
          title: const Text('Test Task Notification'),
          onTap: () => _testTaskNotification(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.emoji_events, color: Colors.amber),
          title: const Text('Test Achievement Notification'),
          onTap: () => _testAchievementNotification(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.local_fire_department, color: Colors.red),
          title: const Text('Test Streak Notification'),
          onTap: () => _testStreakNotification(context, ref),
        ),
      ],
    );
  }

  Future<void> _testInstantNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final service = ref.read(notificationServiceProvider);
    await service.notifyNewTask('Complete 10 pushups!');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📱 Test notification sent!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testTaskNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final service = ref.read(notificationServiceProvider);
    await service.notifyNewTask('Help someone carry their groceries');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎯 Task notification sent!')),
      );
    }
  }

  Future<void> _testAchievementNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final service = ref.read(notificationServiceProvider);
    await service
        .notifyAchievementUnlocked('First Steps - Complete your first task');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🏆 Achievement notification sent!')),
      );
    }
  }

  Future<void> _testStreakNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final service = ref.read(notificationServiceProvider);
    await service.notifyStreakMilestone(7);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔥 Streak notification sent!')),
      );
    }
  }

  Future<void> _showScheduledNotifications(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final service = ref.read(notificationServiceProvider);
    final pending = await service.getPendingNotifications();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scheduled Notifications'),
        content: pending.isEmpty
            ? const Text('No scheduled notifications')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  itemBuilder: (context, index) {
                    final notification = pending[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${notification.id}'),
                      ),
                      title: Text(notification.title ?? 'No title'),
                      subtitle: Text(notification.body ?? 'No body'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
