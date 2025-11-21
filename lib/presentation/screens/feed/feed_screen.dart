import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goodloop/core/constants/app_colors.dart';
import 'package:goodloop/domain/providers/task_provider.dart';

import 'widgets/feed_item.dart';

final feedStreamProvider = StreamProvider((ref) {
  return ref.watch(feedRepositoryProvider).getFeedStream();
});

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community Feed')),
      body: feedAsync.when(
        data: (feedItems) {
          if (feedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    'No stories yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share your kindness!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feedItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FeedItemWidget(item: feedItems[index]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error loading feed: $error')),
      ),
    );
  }
}
