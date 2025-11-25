import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodloop/logger.dart';
import '../models/task_model.dart';
import 'user_repository.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserRepository _userRepository = UserRepository();

  CollectionReference _tasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  Future<String> createTask(TaskModel task) async {
    try {
      final docRef = await _tasksCollection(task.userId).add(task.toMap());
      logger.i('✅ Task created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      logger.e('❌ Error creating task: $e');
      rethrow;
    }
  }

  Stream<List<TaskModel>> getUserTasks(String userId) {
    return _tasksCollection(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  Stream<List<TaskModel>> getActiveTasks(String userId) {
    return _tasksCollection(userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Stream<List<TaskModel>> getCompletedTasks(String userId) {
    return _tasksCollection(userId)
        .where('isCompleted', isEqualTo: true)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Future<TaskModel?> getTask(String userId, String taskId) async {
    try {
      final doc = await _tasksCollection(userId).doc(taskId).get();
      if (!doc.exists) return null;
      return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      logger.e('❌ Error getting task: $e');
      return null;
    }
  }

  Future<void> updateTask(
    String userId,
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _tasksCollection(userId).doc(taskId).update(updates);
      logger.i('✅ Task updated: $taskId');
    } catch (e) {
      logger.e('❌ Error updating task: $e');
      rethrow;
    }
  }

  Future<void> completeTask(String userId, String taskId, int points) async {
    try {
      await _tasksCollection(userId).doc(taskId).update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
      });

      await _userRepository.incrementCompletedTasks(userId, points);

      logger.i('✅ Task completed: $taskId');
    } catch (e) {
      logger.e('❌ Error completing task: $e');
      rethrow;
    }
  }

  Future<void> uncompleteTask(String userId, String taskId, int points) async {
    try {
      await _tasksCollection(
        userId,
      ).doc(taskId).update({'isCompleted': false, 'completedAt': null});

      await _userRepository.incrementCompletedTasks(userId, -points);

      logger.i('✅ Task uncompleted: $taskId');
    } catch (e) {
      logger.e('❌ Error uncompleting task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _tasksCollection(userId).doc(taskId).delete();
      logger.i('✅ Task deleted: $taskId');
    } catch (e) {
      logger.e('❌ Error deleting task: $e');
      rethrow;
    }
  }

  Stream<List<TaskModel>> getTasksByCategory(
    String userId,
    TaskCategory category,
  ) {
    return _tasksCollection(userId)
        .where('category', isEqualTo: category.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Stream<List<TaskModel>> getTodayTasks(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _tasksCollection(userId)
        .where(
          'dueDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => TaskModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Future<int> getWeeklyCompletedCount(String userId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      final snapshot =
          await _tasksCollection(userId)
              .where('isCompleted', isEqualTo: true)
              .where(
                'completedAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .get();

      return snapshot.docs.length;
    } catch (e) {
      logger.e('❌ Error getting weekly count: $e');
      return 0;
    }
  }
}
