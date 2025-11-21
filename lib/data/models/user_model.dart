import "package:cloud_firestore/cloud_firestore.dart";

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int points;
  final int streak;
  final String? lastTaskDate;
  final List<String> completedTasks;
  final List<String> achievements;
  final String? currentTask;
  final bool taskCompletedToday;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.points = 0,
    this.streak = 0,
    this.lastTaskDate,
    this.completedTasks = const [],
    this.achievements = const [],
    this.currentTask,
    this.taskCompletedToday = false,
    required this.createdAt,
  });

  String get level {
    if (points < 100) return 'Starter';
    if (points < 300) return 'Helper';
    if (points < 500) return 'Inspirator';
    return 'Guardian';
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      lastTaskDate: data['lastTaskDate'],
      completedTasks: List<String>.from(data['completedTasks'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      currentTask: data['currentTask'],
      taskCompletedToday: data['taskCompletedToday'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'points': points,
      'streak': streak,
      'lastTaskDate': lastTaskDate,
      'completedTasks': completedTasks,
      'achievements': achievements,
      'currentTask': currentTask,
      'taskCompletedToday': taskCompletedToday,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    int? points,
    int? streak,
    String? lastTaskDate,
    List<String>? completedTasks,
    List<String>? achievements,
    String? currentTask,
    bool? taskCompletedToday,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      lastTaskDate: lastTaskDate ?? this.lastTaskDate,
      completedTasks: completedTasks ?? this.completedTasks,
      achievements: achievements ?? this.achievements,
      currentTask: currentTask ?? this.currentTask,
      taskCompletedToday: taskCompletedToday ?? this.taskCompletedToday,
      createdAt: createdAt,
    );
  }
}
