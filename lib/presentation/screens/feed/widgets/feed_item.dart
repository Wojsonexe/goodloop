import 'package:flutter/material.dart';
import 'package:goodloop/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/feed_item_model.dart';

class FeedItemWidget extends StatelessWidget {
  final FeedItemModel item;
  final String? taskText; // ← PRZYJMUJEMY TEKST TASKA JEŚLI POST ZADANIOWY

  const FeedItemWidget({super.key, required this.item, this.taskText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER ===
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),

              // Username + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(item.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // === TASK BOX ===
          if (taskText != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('💝', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      taskText!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // === POST IMAGE ===
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(item.imageUrl!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
          ],

          // === POST TEXT ===
          Text(item.content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  // === AVATAR BUILDER ===
  Widget _buildAvatar() {
    if (item.userPhotoUrl != null && item.userPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(item.userPhotoUrl!),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        item.userName.isNotEmpty ? item.userName[0].toUpperCase() : '?',
        style: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}
