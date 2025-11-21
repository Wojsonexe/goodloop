import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String text;
  final int difficulty;
  final String category;

  TaskModel({
    required this.id,
    required this.text,
    required this.difficulty,
    required this.category,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      text: data['text'] ?? '',
      difficulty: data['difficulty'] ?? 1,
      category: data['category'] ?? 'kindness',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'text': text, 'difficulty': difficulty, 'category': category};
  }

  int get pointsValue => difficulty * 10;
}
