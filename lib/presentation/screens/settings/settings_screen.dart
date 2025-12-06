// lib/presentation/screens/settings/settings_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goodloop/core/constants/app_colors.dart';
import 'package:goodloop/core/database/migration_service.dart';
import 'package:goodloop/core/services/notification_permission_helper.dart';
import 'package:goodloop/domain/providers/auth_provider.dart';
import 'package:goodloop/domain/providers/theme_provider.dart';
import '../../../domain/providers/notification_service.dart';
import 'widgets/notification_debug_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay? _notificationTime;
  bool _isLoading = true;
  bool _isReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final service = ref.read(notificationServiceProvider);
    final time = await service.getScheduledTime();
    final enabled = await service.isDailyReminderEnabled();

    if (mounted) {
      setState(() {
        _notificationTime = time;
        _isReminderEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickNotificationTime() async {
    final hasPermissions =
        await NotificationPermissionHelper.checkAndRequestPermissions(context);

    if (!hasPermissions) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Permissions required for notifications'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select Daily Reminder Time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _notificationTime = time;
        _isReminderEnabled = true;
      });

      await ref.read(notificationServiceProvider).scheduleDailyReminder(
            hour: time.hour,
            minute: time.minute,
          );

      if (mounted) {
        // ✅ Log zaplanowanych powiadomień (debug)
        await ref.read(notificationServiceProvider).logScheduledNotifications();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ Reminder set for ${time.format(context)}'),
                const SizedBox(height: 4),
                const Text(
                  'You\'ll get a notification every day at this time',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Cancel',
              onPressed: _cancelNotification,
            ),
          ),
        );
      }
    }
  }

  Future<void> _cancelNotification() async {
    await ref.read(notificationServiceProvider).cancelDailyReminder();
    setState(() {
      _notificationTime = null;
      _isReminderEnabled = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Daily reminder cancelled'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showMigrationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Database Migration'),
          ],
        ),
        content: const Text(
          'This will migrate your data to the new structure.\n\n'
          '• A backup will be created automatically\n'
          '• Your progress will be preserved\n'
          '• Takes about 10-30 seconds\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Migrate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _runMigration();
    }
  }

  Future<void> _runMigration() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Migrating database...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please do not close the app',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      final migration = MigrationService();
      await migration.runFullMigration(user.uid);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Migration completed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Migration failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _runMigration,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications Section
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active),
                title: const Text('Daily Reminder'),
                subtitle: Text(
                  _isLoading
                      ? 'Loading...'
                      : _isReminderEnabled && _notificationTime != null
                          ? 'Every day at ${_notificationTime!.format(context)}'
                          : 'Not set',
                ),
                value: _isReminderEnabled,
                onChanged: (value) {
                  if (value) {
                    _pickNotificationTime();
                  } else {
                    _cancelNotification();
                  }
                },
              ),
              if (_isReminderEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Change Time'),
                  subtitle: _notificationTime != null
                      ? Text('Currently: ${_notificationTime!.format(context)}')
                      : null,
                  onTap: _pickNotificationTime,
                ),
              ],
              const Divider(height: 1),
              const NotificationDebugSection(),
            ],
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeName(themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Database Section
          _buildSection(
            context,
            title: 'Database',
            children: [
              ListTile(
                leading: const Icon(Icons.sync_rounded, color: Colors.orange),
                title: const Text('Database Migration'),
                subtitle: const Text('Update to new structure'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showMigrationDialog,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Account Section
          _buildSection(
            context,
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => _showSignOutDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // App Version
          Center(
            child: Text(
              'GoodLoop v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: _buildThemeSelector(context),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final current = ref.watch(themeModeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildThemeRadio(
          title: 'Light',
          value: ThemeMode.light,
          groupValue: current,
        ),
        _buildThemeRadio(
          title: 'Dark',
          value: ThemeMode.dark,
          groupValue: current,
        ),
        _buildThemeRadio(
          title: 'System',
          value: ThemeMode.system,
          groupValue: current,
        ),
      ],
    );
  }

  Widget _buildThemeRadio({
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      contentPadding: EdgeInsets.zero,
      // ignore: deprecated_member_use
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          ref.read(themeModeProvider.notifier).setThemeMode(newValue);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/welcome');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
