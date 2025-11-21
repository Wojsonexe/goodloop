import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  Future<void> completeTask(String userId, String taskId, int points) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final user = UserModel.fromFirestore(userDoc);

    final today = DateTime.now().toIso8601String().split('T')[0];
    final yesterday =
        DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0];

    int newStreak = user.streak;
    if (user.lastTaskDate == yesterday) {
      newStreak++;
    } else if (user.lastTaskDate != today) {
      newStreak = 1;
    }

    final completedTasks = [...user.completedTasks, taskId];
    final newPoints = user.points + points;

    // Check for new achievements
    final achievements = List<String>.from(user.achievements);
    if (!achievements.contains('first_task') && completedTasks.length == 1) {
      achievements.add('first_task');
    }
    if (!achievements.contains('streak_3') && newStreak >= 3) {
      achievements.add('streak_3');
    }
    if (!achievements.contains('streak_7') && newStreak >= 7) {
      achievements.add('streak_7');
    }
    if (!achievements.contains('tasks_10') && completedTasks.length >= 10) {
      achievements.add('tasks_10');
    }
    if (!achievements.contains('tasks_50') && completedTasks.length >= 50) {
      achievements.add('tasks_50');
    }
    if (!achievements.contains('points_100') && newPoints >= 100) {
      achievements.add('points_100');
    }
    if (!achievements.contains('points_500') && newPoints >= 500) {
      achievements.add('points_500');
    }

    await userRef.update({
      'points': newPoints,
      'streak': newStreak,
      'lastTaskDate': today,
      'completedTasks': completedTasks,
      'achievements': achievements,
      'taskCompletedToday': true,
    });
  }
}
