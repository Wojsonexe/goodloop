import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goodloop/data/models/achievement_model.dart';
import 'package:goodloop/logger.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

final userAchievementsProvider =
    StreamProvider.family<List<AchievementModel>, String>(
  (ref, userId) {
    final repo = ref.watch(achievementRepositoryProvider);
    return repo.getUserAchievements(userId);
  },
);

final achievementCheckerProvider = Provider<AchievementChecker>((ref) {
  return AchievementChecker(ref);
});

class AchievementChecker {
  final Ref ref;

  AchievementChecker(this.ref);

  Future<List<String>> checkAfterTaskCompletion(
    String userId,
    int completedTasks,
    int streakDays,
    DateTime completionTime,
  ) async {
    final repo = ref.read(achievementRepositoryProvider);
    final unlockedAchievements = <String>[];

    try {
      final checks = [
        _checkFirstTask(userId, completedTasks, repo),
        _checkTenTasks(userId, completedTasks, repo),
        _checkFiftyTasks(userId, completedTasks, repo),
        _checkHundredTasks(userId, completedTasks, repo),
        _checkWeekStreak(userId, streakDays, repo),
        _checkEarlyBird(userId, completionTime, repo),
        _checkNightOwl(userId, completionTime, repo),
      ];

      final results = await Future.wait(checks);

      for (var result in results) {
        if (result != null) {
          unlockedAchievements.add(result);
        }
      }

      return unlockedAchievements;
    } catch (e) {
      logger.e('Error checking achievements: $e');
      return [];
    }
  }

  Future<String?> _checkFirstTask(
    String userId,
    int completedTasks,
    AchievementRepository repo,
  ) async {
    if (completedTasks >= 1) {
      final isUnlocked = await repo.isAchievementUnlocked(userId, 'first_task');
      if (!isUnlocked) {
        await repo.unlockAchievement(userId, 'first_task');
        return 'first_task';
      }
    }
    return null;
  }

  Future<String?> _checkTenTasks(
    String userId,
    int completedTasks,
    AchievementRepository repo,
  ) async {
    if (completedTasks >= 10) {
      final isUnlocked = await repo.isAchievementUnlocked(userId, 'ten_tasks');
      if (!isUnlocked) {
        await repo.unlockAchievement(userId, 'ten_tasks');
        return 'ten_tasks';
      }
    }
    return null;
  }

  Future<String?> _checkFiftyTasks(
    String userId,
    int completedTasks,
    AchievementRepository repo,
  ) async {
    if (completedTasks >= 50) {
      final isUnlocked =
          await repo.isAchievementUnlocked(userId, 'fifty_tasks');
      if (!isUnlocked) {
        await repo.unlockAchievement(userId, 'fifty_tasks');
        return 'fifty_tasks';
      }
    }
    return null;
  }

  Future<String?> _checkHundredTasks(
    String userId,
    int completedTasks,
    AchievementRepository repo,
  ) async {
    if (completedTasks >= 100) {
      final isUnlocked =
          await repo.isAchievementUnlocked(userId, 'hundred_tasks');
      if (!isUnlocked) {
        await repo.unlockAchievement(userId, 'hundred_tasks');
        return 'hundred_tasks';
      }
    }
    return null;
  }

  Future<String?> _checkWeekStreak(
    String userId,
    int streakDays,
    AchievementRepository repo,
  ) async {
    if (streakDays >= 7) {
      final isUnlocked =
          await repo.isAchievementUnlocked(userId, 'week_streak');
      if (!isUnlocked) {
        await repo.unlockAchievement(userId, 'week_streak');
        return 'week_streak';
      }
    }
    return null;
  }

  Future<String?> _checkEarlyBird(
    String userId,
    DateTime completionTime,
    AchievementRepository repo,
  ) async {
    if (completionTime.hour < 8) {
      final isUnlocked = await repo.isAchievementUnlocked(userId, 'early_bird');
      if (!isUnlocked) {
        await repo.unlockAchievement(userId, 'early_bird');
        return 'early_bird';
      }
    }
    return null;
  }

  Future<String?> _checkNightOwl(
    String userId,
    DateTime completionTime,
    AchievementRepository repo,
  ) async {
    if (completionTime.hour >= 22 || completionTime.hour < 4) {
      final isUnlocked = await repo.isAchievementUnlocked(userId, 'night_owl');
      if (!isUnlocked) {
        await repo.unlockAchievement(userId, 'night_owl');
        return 'night_owl';
      }
    }
    return null;
  }
}
