import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goodloop/domain/providers/achievement_provider.dart';
import 'package:goodloop/logger.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final activeTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);

      return Stream.fromFuture(taskRepo.getGlobalDailyTasks())
          .asyncExpand((globalTasks) {
        return FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('completed_tasks_history')
            .snapshots()
            .map((snapshot) {
          final completedIds = snapshot.docs.map((doc) => doc.id).toSet();

          return globalTasks.where((task) {
            return !completedIds.contains(task.id);
          }).toList();
        });
      });
    },
    loading: () => Stream.value([]),
    error: (error, stack) {
      logger.e("Błąd w activeTasksProvider");
      return Stream.value([]);
    },
  );
});

class TaskController extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _taskRepository;
  final String userId;
  final Ref ref;

  TaskController(this._taskRepository, this.userId, this.ref)
      : super(const AsyncValue.data(null));

  Future<List<dynamic>> completeTask(String taskId, int points) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final batch = FirebaseFirestore.instance.batch();

      final completedRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('completed_tasks')
          .doc(taskId);

      batch.set(
          completedRef,
          {
            'taskId': taskId,
            'lastCompletedAt': Timestamp.fromDate(now),
            'points': points,
          },
          SetOptions(merge: true));

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      batch.update(userRef, {
        'points': FieldValue.increment(points),
        'completedTaskIds': FieldValue.increment(1),
      });

      await batch.commit();

      final userDoc = await userRef.get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final completedTasks = userData['completedTasks'] ?? 0;
      final streakDays = userData['streak'] ?? 0;

      final achievementChecker = ref.read(achievementCheckerProvider);
      final unlockedAchievements =
          await achievementChecker.checkAfterTaskCompletion(
        userId,
        completedTasks,
        streakDays,
        now,
      );

      state = const AsyncValue.data(null);
      return unlockedAchievements;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
    TaskCategory category = TaskCategory.other,
    DateTime? dueDate,
    int points = 10,
  }) async {
    state = const AsyncValue.loading();
    try {
      final task = TaskModel(
        id: '',
        title: title,
        description: description,
        category: category,
        points: points,
        createdAt: DateTime.now(),
        dueDate: dueDate,
      );
      await _taskRepository.createTask(task);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final taskControllerProvider =
    StateNotifierProvider.family<TaskController, AsyncValue<void>, String>((
  ref,
  userId,
) {
  final taskRepo = ref.watch(taskRepositoryProvider);
  return TaskController(taskRepo, userId, ref);
});
