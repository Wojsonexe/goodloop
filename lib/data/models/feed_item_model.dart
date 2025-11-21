import 'package:cloud_firestore/cloud_firestore.dart';

class FeedItemModel {
  final String id;
  final String taskId;
  final String content;
  final DateTime timestamp;
  final String? taskText;

  FeedItemModel({
    required this.id,
    required this.taskId,
    required this.content,
    required this.timestamp,
    this.taskText,
  });

  factory FeedItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedItemModel(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      taskText: data['taskText'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'taskText': taskText,
    };
  }
}
