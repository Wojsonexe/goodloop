import "package:cloud_firestore/cloud_firestore.dart";

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final int completedTasks;
  final int streakDays;
  final int totalPoints;
  final DateTime createdAt;
  final DateTime lastActive;
  final List<String> achievements;
  final int level;
  final DateTime? lastTaskCompletedDate;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.completedTasks = 0,
    this.streakDays = 0,
    this.totalPoints = 0,
    required this.createdAt,
    required this.lastActive,
    required this.level,
    this.achievements = const [],
    this.lastTaskCompletedDate,
  });

  // ✅ DODANE GETTERY DO KOMPATYBILNOŚCI
  String get id => uid;
  String? get photoUrl => photoURL;
  int get streak => streakDays;
  int get points => totalPoints;

  // ✅ Sprawdzenie czy zadanie zostało ukończone dzisiaj
  bool get taskCompletedToday {
    if (lastTaskCompletedDate == null) return false;
    final now = DateTime.now();
    final lastCompleted = lastTaskCompletedDate!;
    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoURL: map['photoURL'] as String?,
      completedTasks: (map['completedTasks'] as num?)?.toInt() ?? 0,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
      createdAt: _parseTimestamp(map['createdAt']),
      lastActive: _parseTimestamp(map['lastActive']),
      achievements: _parseStringList(map['achievements']),
      level: (map['level'] as num?)?.toInt() ?? 1,
      lastTaskCompletedDate:
          map['lastTaskCompletedDate'] != null
              ? _parseTimestamp(map['lastTaskCompletedDate'])
              : null,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'completedTasks': completedTasks,
      'streakDays': streakDays,
      'totalPoints': totalPoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'achievements': achievements,
      'level': level,
      'lastTaskCompletedDate':
          lastTaskCompletedDate != null
              ? Timestamp.fromDate(lastTaskCompletedDate!)
              : null,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    int? completedTasks,
    int? streakDays,
    int? totalPoints,
    int? level,
    DateTime? createdAt,
    DateTime? lastActive,
    List<String>? achievements,
    DateTime? lastTaskCompletedDate,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      completedTasks: completedTasks ?? this.completedTasks,
      streakDays: streakDays ?? this.streakDays,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      achievements: achievements ?? this.achievements,
      lastTaskCompletedDate:
          lastTaskCompletedDate ?? this.lastTaskCompletedDate,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
  }
}
