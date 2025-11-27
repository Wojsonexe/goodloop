// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goodloop/core/constants/app_colors.dart';
import 'package:goodloop/domain/providers/auth_provider.dart';
import 'package:goodloop/domain/providers/theme_provider.dart';
import '../../../domain/providers/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay? _notificationTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationTime();
  }

  Future<void> _loadNotificationTime() async {
    final service = ref.read(notificationServiceProvider);
    final time = await service.getScheduledTime();

    if (mounted) {
      setState(() {
        _notificationTime = time;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickNotificationTime() async {
    final now = TimeOfDay.now();
    final time = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? now,
    );

    if (time != null) {
      setState(() => _notificationTime = time);
      await ref.read(notificationServiceProvider).scheduleDailyReminder(
            hour: time.hour,
            minute: time.minute,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ustawiono przypomnienie na ${time.format(context)}'),
            action: SnackBarAction(
              label: 'Anuluj',
              onPressed: _cancelNotification,
            ),
          ),
        );
      }
    }
  }

  Future<void> _cancelNotification() async {
    await ref.read(notificationServiceProvider).cancelDailyReminder();
    setState(() => _notificationTime = null);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('Daily Reminder'),
                subtitle: Text(
                  _notificationTime != null
                      ? 'Every day at ${_notificationTime!.format(context)}'
                      : 'Not set',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickNotificationTime,
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          Center(
            child: Text(
              'GoodLoop v1.0.0',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
        content: buildThemeSelector(context),
      ),
    );
  }

  Widget buildThemeSelector(BuildContext context) {
    final current = ref.watch(themeModeProvider);

    // The RadioGroup now handles the current value and the onChanged callback
    return RadioGroup<ThemeMode>(
      groupValue: current,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          ref.read(themeModeProvider.notifier).setThemeMode(newValue);
          Navigator.pop(context);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeRadio(title: 'Light', value: ThemeMode.light),
          _buildThemeRadio(title: 'Dark', value: ThemeMode.dark),
          _buildThemeRadio(title: 'System', value: ThemeMode.system),
        ],
      ),
    );
  }

  Widget _buildThemeRadio({required String title, required ThemeMode value}) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: value,
      contentPadding: EdgeInsets.zero, // Makes it fit better in dialogs
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
