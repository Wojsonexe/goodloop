import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory {
  kindness,
  health,
  sport,
  learning,
  other,
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final int points;
  final int difficulty;
  final DateTime? createdAt;
  final DateTime? dueDate;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = TaskCategory.other,
    this.points = 10,
    this.difficulty = 1,
    this.createdAt,
    this.dueDate,
  });

  String get timeUntilAvailableFormatted {
    if (dueDate == null) return "Dostępne wkrótce";
    final now = DateTime.now();
    if (now.isAfter(dueDate!)) return "Dostępne";
    final difference = dueDate!.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return "${hours}h ${minutes}m";
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['text'] as String? ??
          map['title'] as String? ??
          'Zadanie bez tytułu',
      description: map['description'] as String? ?? '',
      category: _parseCategory(map['category']),
      points: (map['points'] as num?)?.toInt() ?? 10,
      difficulty: (map['difficulty'] as num?)?.toInt() ?? 1,
      createdAt: _parseTimestamp(map['createdAt']),
      dueDate: _parseTimestamp(map['dueDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': title,
      'description': description,
      'category': category.name,
      'points': points,
      'difficulty': difficulty,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    };
  }

  static TaskCategory _parseCategory(dynamic value) {
    if (value == null) return TaskCategory.other;
    return TaskCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      orElse: () => TaskCategory.other,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
