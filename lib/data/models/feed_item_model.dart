// lib/data/models/feed_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FeedItemModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final String? taskId; // Opcjonalnie - jeśli post jest powiązany z taskiem

  FeedItemModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    this.taskId,
  });

  factory FeedItemModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedItemModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Anonymous',
      userPhotoUrl: map['userPhotoUrl'] as String?,
      content: map['content'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      likedBy: _parseStringList(map['likedBy']),
      createdAt: _parseTimestamp(map['createdAt']),
      taskId: map['taskId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'taskId': taskId,
    };
  }

  FeedItemModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? content,
    String? imageUrl,
    int? likesCount,
    List<String>? likedBy,
    DateTime? createdAt,
    String? taskId,
  }) {
    return FeedItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      taskId: taskId ?? this.taskId,
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

  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} dni temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} godz. temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min. temu';
    } else {
      return 'Przed chwilą';
    }
  }
}
