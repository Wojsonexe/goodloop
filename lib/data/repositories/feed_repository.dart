import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goodloop/logger.dart';
import '../models/feed_item_model.dart';

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepository(),
);

class FeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _feedCollection => _firestore.collection('feed');

  // ✅ DODANA metoda getFeedStream (brakująca w oryginalnym pliku)
  Stream<List<FeedItemModel>> getFeedStream({int limit = 20}) {
    return _feedCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => FeedItemModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Future<String> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
    String? imageUrl,
    String? taskId,
  }) async {
    try {
      final post = FeedItemModel(
        id: '',
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        taskId: taskId,
      );

      final docRef = await _feedCollection.add(post.toMap());
      logger.i('✅ Post created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      logger.e('❌ Error creating post: $e');
      rethrow;
    }
  }

  Stream<List<FeedItemModel>> getFeed({int limit = 20}) {
    return _feedCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => FeedItemModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Stream<List<FeedItemModel>> getUserPosts(String userId) {
    return _feedCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => FeedItemModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  Future<FeedItemModel?> getPost(String postId) async {
    try {
      final doc = await _feedCollection.doc(postId).get();
      if (!doc.exists) return null;
      return FeedItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      logger.e('❌ Error getting post: $e');
      return null;
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _feedCollection.doc(postId).update({
        'likesCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
      logger.i('✅ Post liked: $postId');
    } catch (e) {
      logger.e('❌ Error liking post: $e');
      rethrow;
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _feedCollection.doc(postId).update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
      logger.i('✅ Post unliked: $postId');
    } catch (e) {
      logger.e('❌ Error unliking post: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String postId, String userId) async {
    try {
      final post = await getPost(postId);
      if (post == null) {
        throw Exception('Post not found');
      }

      if (post.userId != userId) {
        throw Exception('Unauthorized: Not the post author');
      }

      await _feedCollection.doc(postId).delete();
      logger.i('✅ Post deleted: $postId');
    } catch (e) {
      logger.e('❌ Error deleting post: $e');
      rethrow;
    }
  }

  Future<void> updatePost(
    String postId,
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final post = await getPost(postId);
      if (post == null) {
        throw Exception('Post not found');
      }

      if (post.userId != userId) {
        throw Exception('Unauthorized: Not the post author');
      }

      await _feedCollection.doc(postId).update(updates);
      logger.i('✅ Post updated: $postId');
    } catch (e) {
      logger.e('❌ Error updating post: $e');
      rethrow;
    }
  }

  Future<List<FeedItemModel>> getNextPage({
    required DocumentSnapshot lastDocument,
    int limit = 20,
  }) async {
    try {
      final snapshot =
          await _feedCollection
              .orderBy('createdAt', descending: true)
              .startAfterDocument(lastDocument)
              .limit(limit)
              .get();

      return snapshot.docs
          .map(
            (doc) => FeedItemModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      logger.e('❌ Error getting next page: $e');
      return [];
    }
  }

  Future<List<FeedItemModel>> getTrendingPosts({int limit = 10}) async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final snapshot =
          await _feedCollection
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo),
              )
              .orderBy('createdAt', descending: true)
              .orderBy('likesCount', descending: true)
              .limit(limit)
              .get();

      return snapshot.docs
          .map(
            (doc) => FeedItemModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      logger.e('❌ Error getting trending posts: $e');
      return [];
    }
  }
}
