import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodloop/data/models/task_model.dart';
import 'package:goodloop/logger.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _tasksCollection =>
      _firestore.collection('dailyTasks');

  Future<List<TaskModel>> getGlobalDailyTasks() async {
    try {
      final snapshot = await _tasksCollection.get();
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      logger.e('Błąd pobierania zadań: $e');
      return [];
    }
  }

  Future<void> createTask(TaskModel task) async {
    await _tasksCollection.add(task.toMap());
  }

  Future<bool> hasCompletedTaskToday(String userId, String taskId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_tasks_history')
          .where('taskId', isEqualTo: taskId)
          .where('completedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      logger.e('❌ Error checking task completion: $e');
      return false;
    }
  }

  String getTimeUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Stream<List<Map<String, dynamic>>> getCompletedTasksHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('completed_tasks_history')
        .orderBy('completedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      final historySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_tasks_history')
          .get();

      return {
        'totalPoints': userData['totalPoints'] ?? 0,
        'completedTasks': userData['completedTasks'] ?? 0,
        'streakDays': userData['streakDays'] ?? 0,
        'level': userData['level'] ?? 1,
        'completedTasksCount': historySnapshot.docs.length,
      };
    } catch (e) {
      logger.e('❌ Error getting user stats: $e');
      return {};
    }
  }
}
