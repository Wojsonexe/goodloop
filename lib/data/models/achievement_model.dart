class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });

  static List<AchievementModel> getAllAchievements(List<String> unlockedIds) {
    final achievements = [
      AchievementModel(
        id: 'first_task',
        title: 'First Steps',
        description: 'Complete your first task',
        icon: '🌟',
      ),
      AchievementModel(
        id: 'streak_3',
        title: '3-Day Streak',
        description: 'Complete tasks for 3 days in a row',
        icon: '🔥',
      ),
      AchievementModel(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Complete tasks for 7 days in a row',
        icon: '⚡',
      ),
      AchievementModel(
        id: 'tasks_10',
        title: 'Dedicated Helper',
        description: 'Complete 10 tasks',
        icon: '💪',
      ),
      AchievementModel(
        id: 'tasks_50',
        title: 'Kindness Champion',
        description: 'Complete 50 tasks',
        icon: '👑',
      ),
      AchievementModel(
        id: 'points_100',
        title: 'Century Club',
        description: 'Earn 100 points',
        icon: '💯',
      ),
      AchievementModel(
        id: 'points_500',
        title: 'High Achiever',
        description: 'Earn 500 points',
        icon: '🏆',
      ),
      AchievementModel(
        id: 'share_5',
        title: 'Community Builder',
        description: 'Share 5 reflections',
        icon: '🌍',
      ),
    ];

    return achievements.map((achievement) {
      return AchievementModel(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        isUnlocked: unlockedIds.contains(achievement.id),
      );
    }).toList();
  }
}
