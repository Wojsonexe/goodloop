import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:goodloop/core/constants/app_colors.dart';
import 'package:goodloop/data/models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: achievement.isUnlocked ? 1.0 : 0.5,
      child:
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  achievement.isUnlocked
                      ? AppColors.cardGradient
                      : LinearGradient(
                        colors: [Colors.grey[300]!, Colors.grey[200]!],
                      ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    achievement.isUnlocked
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color:
                        achievement.isUnlocked
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (achievement.isUnlocked)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 24,
                            )
                          else
                            Icon(Icons.lock, color: Colors.grey[400], size: 24),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: (achievement.isUnlocked ? 0 : 200).ms).fadeIn(),
    );
  }
}
