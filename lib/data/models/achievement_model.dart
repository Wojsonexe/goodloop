import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodloop/logger.dart';

enum AchievementType {
  firstTask,
  weekStreak,
  tenTasks,
  fiftyTasks,
  hundredTasks,
  socialButterfly,
  helper,
  legend,
  earlyBird,
  nightOwl,
}

class AchievementModel {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final String iconUrl;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.iconUrl,
    this.points = 50,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  String get icon => iconUrl;

  factory AchievementModel.fromMap(Map<String, dynamic> map, String id) {
    return AchievementModel(
      id: id,
      type: _parseTypeFromString(map['type'] as String?),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconUrl: map['iconUrl'] as String? ?? '',
      points: (map['points'] as num?)?.toInt() ?? 50,
      isUnlocked: map['isUnlocked'] as bool? ?? false,
      unlockedAt: _parseTimestamp(map['unlockedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'points': points,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }

  AchievementModel copyWith({
    String? id,
    AchievementType? type,
    String? title,
    String? description,
    String? iconUrl,
    int? points,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      points: points ?? this.points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static AchievementType _parseTypeFromString(String? value) {
    if (value == null) return AchievementType.firstTask;
    try {
      return AchievementType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AchievementType.firstTask,
      );
    } catch (e) {
      return AchievementType.firstTask;
    }
  }

  static List<AchievementModel> getAllAchievements() {
    return [
      AchievementModel(
        id: 'first_task',
        type: AchievementType.firstTask,
        title: 'Pierwsze kroki',
        description: 'Ukończ swoje pierwsze zadanie',
        iconUrl: '🎯',
        points: 10,
      ),
      AchievementModel(
        id: 'week_streak',
        type: AchievementType.weekStreak,
        title: 'Tygodniowy wojownik',
        description: 'Wykonuj zadania przez 7 dni z rzędu',
        iconUrl: '🔥',
        points: 50,
      ),
      AchievementModel(
        id: 'ten_tasks',
        type: AchievementType.tenTasks,
        title: 'Pomocnik',
        description: 'Ukończ 10 zadań',
        iconUrl: '⭐',
        points: 30,
      ),
      AchievementModel(
        id: 'fifty_tasks',
        type: AchievementType.fiftyTasks,
        title: 'Mistrz Dobroci',
        description: 'Ukończ 50 zadań',
        iconUrl: '🏆',
        points: 100,
      ),
      AchievementModel(
        id: 'hundred_tasks',
        type: AchievementType.hundredTasks,
        title: 'Legenda',
        description: 'Ukończ 100 zadań',
        iconUrl: '👑',
        points: 200,
      ),
      AchievementModel(
        id: 'social_butterfly',
        type: AchievementType.socialButterfly,
        title: 'Motyl Społeczny',
        description: 'Opublikuj 10 postów',
        iconUrl: '🦋',
        points: 40,
      ),
      AchievementModel(
        id: 'early_bird',
        type: AchievementType.earlyBird,
        title: 'Ranny ptaszek',
        description: 'Ukończ zadanie przed 8:00',
        iconUrl: '🌅',
        points: 25,
      ),
      AchievementModel(
        id: 'night_owl',
        type: AchievementType.nightOwl,
        title: 'Nocny marek',
        description: 'Ukończ zadanie po 22:00',
        iconUrl: '🦉',
        points: 25,
      ),
    ];
  }
}

class AchievementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _achievementsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements');
  }

  Future<void> initializeAchievements(String userId) async {
    try {
      final achievements = AchievementModel.getAllAchievements();

      final batch = _firestore.batch();
      for (final achievement in achievements) {
        final docRef = _achievementsCollection(userId).doc(achievement.id);
        batch.set(docRef, achievement.toMap());
      }
      await batch.commit();

      logger.i('✅ Achievements initialized for user: $userId');
    } catch (e) {
      logger.e('❌ Error initializing achievements: $e');
      rethrow;
    }
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      await _achievementsCollection(userId).doc(achievementId).update({
        'isUnlocked': true,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
      logger.i('✅ Achievement unlocked: $achievementId');
    } catch (e) {
      logger.e('❌ Error unlocking achievement: $e');
      rethrow;
    }
  }

  Stream<List<AchievementModel>> getUserAchievements(String userId) {
    return _achievementsCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => AchievementModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  Future<void> checkAchievements(
    String userId,
    int completedTasks,
    int streakDays,
  ) async {
    try {
      if (completedTasks >= 1) {
        await unlockAchievement(userId, 'first_task');
      }

      if (completedTasks >= 10) {
        await unlockAchievement(userId, 'ten_tasks');
      }

      if (completedTasks >= 50) {
        await unlockAchievement(userId, 'fifty_tasks');
      }

      if (completedTasks >= 100) {
        await unlockAchievement(userId, 'hundred_tasks');
      }

      if (streakDays >= 7) {
        await unlockAchievement(userId, 'week_streak');
      }
    } catch (e) {
      logger.e('❌ Error checking achievements: $e');
    }
  }

  Future<bool> isAchievementUnlocked(
      String userId, String achievementId) async {
    try {
      final doc =
          await _achievementsCollection(userId).doc(achievementId).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['isUnlocked'] ?? false;
      }
      return false;
    } catch (e) {
      logger.e('❌ Error checking achievement status: $e');
      return false;
    }
  }
}
