import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/feed_item_model.dart';
import '../../data/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

final feedStreamProvider = StreamProvider<List<FeedItemModel>>((ref) {
  final feedRepo = ref.watch(feedRepositoryProvider);
  return feedRepo.getFeed(limit: 50);
});

class FeedController extends StateNotifier<AsyncValue<void>> {
  final FeedRepository _feedRepository;

  FeedController(this._feedRepository) : super(const AsyncValue.data(null));

  Future<void> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
    String? imageUrl,
    String? taskId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _feedRepository.createPost(
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        imageUrl: imageUrl,
        taskId: taskId,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _feedRepository.likePost(postId, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _feedRepository.unlikePost(postId, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String postId, String userId) async {
    state = const AsyncValue.loading();
    try {
      await _feedRepository.deletePost(postId, userId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final feedControllerProvider =
    StateNotifierProvider<FeedController, AsyncValue<void>>((ref) {
      final feedRepo = ref.watch(feedRepositoryProvider);
      return FeedController(feedRepo);
    });
