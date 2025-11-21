import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goodloop/domain/providers/auth_provider.dart';

import '../../../data/models/achievement_model.dart';
import 'widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          final achievements = AchievementModel.getAllAchievements(
            user.achievements,
          );

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AchievementCard(achievement: achievements[index]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
