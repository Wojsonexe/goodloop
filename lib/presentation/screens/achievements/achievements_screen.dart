import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goodloop/domain/providers/achievement_provider.dart';
import 'package:goodloop/domain/providers/auth_provider.dart';

import '../../../data/models/achievement_model.dart';
import 'widgets/achievement_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          final achievementsAsync =
              ref.watch(userAchievementsProvider(user.id));

          return achievementsAsync.when(
            data: (achievements) {
              if (achievements.isEmpty) {
                // Inicjalizuj achievementy jeśli nie istnieją
                _initializeAchievements(ref, user.id);
                return const Center(child: CircularProgressIndicator());
              }

              // Sortuj: odblokowane na górze
              final sortedAchievements =
                  List<AchievementModel>.from(achievements)
                    ..sort((a, b) {
                      if (a.isUnlocked && !b.isUnlocked) return -1;
                      if (!a.isUnlocked && b.isUnlocked) return 1;
                      return 0;
                    });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedAchievements.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AchievementCard(
                      achievement: sortedAchievements[index],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error loading achievements',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Future<void> _initializeAchievements(WidgetRef ref, String userId) async {
    final repo = ref.read(achievementRepositoryProvider);
    await repo.initializeAchievements(userId);
  }
}
