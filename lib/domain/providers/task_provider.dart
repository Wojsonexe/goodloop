import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/models/task_model.dart';
import '../../data/models/feed_item_model.dart';
import 'auth_provider.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());
final feedRepositoryProvider = Provider((ref) => FeedRepository());

final currentTaskProvider = FutureProvider<TaskModel?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user?.currentTask == null) return null;
  return ref.watch(taskRepositoryProvider).getTask(user!.currentTask!);
});

class TaskController extends StateNotifier<AsyncValue<void>> {
  final UserRepository _userRepository;
  final FeedRepository _feedRepository;
  final TaskRepository _taskRepository;

  TaskController(
    this._userRepository,
    this._feedRepository,
    this._taskRepository,
  ) : super(const AsyncValue.data(null));

  Future<void> completeTask(
    String userId,
    String taskId,
    int points,
    String? reflection,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _userRepository.completeTask(userId, taskId, points);

      if (reflection != null && reflection.isNotEmpty) {
        final task = await _taskRepository.getTask(taskId);
        final feedItem = FeedItemModel(
          id: '',
          taskId: taskId,
          content: reflection,
          timestamp: DateTime.now(),
          taskText: task?.text,
        );
        await _feedRepository.addFeedItem(feedItem);
      }
    });
  }
}

final taskControllerProvider =
    StateNotifierProvider<TaskController, AsyncValue<void>>((ref) {
      return TaskController(
        ref.watch(userRepositoryProvider),
        ref.watch(feedRepositoryProvider),
        ref.watch(taskRepositoryProvider),
      );
    });
