import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final friendServiceProvider = Provider<FriendService>((ref) => FriendService());

final friendsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(friendServiceProvider);
  return service.getFriendsStream();
});

final requestsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(friendServiceProvider);
  return service.getRequestsStream();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final service = ref.watch(friendServiceProvider);
  return service.searchUsers(query);
});

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getFriendsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .orderBy('since', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'uid': doc.id})
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getRequestsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'uid': doc.id})
            .toList());
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final result = await _firestore
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThan: '$query\uf8ff')
        .limit(20)
        .get();

    final currentUserId = _auth.currentUser?.uid;

    return result.docs
        .map((doc) => {...doc.data(), 'uid': doc.id})
        .where((user) => user['uid'] != currentUserId)
        .toList();
  }

  Future<void> sendFriendRequest(String targetUserId, String myName) async {
    final currentUserId = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('friend_requests')
        .doc(currentUserId)
        .set({
      'fromUid': currentUserId,
      'fromName': myName,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(
      String requesterId, String requesterName, String myName) async {
    final currentUserId = _auth.currentUser!.uid;
    final batch = _firestore.batch();

    final myFriendRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(requesterId);

    batch.set(myFriendRef, {
      'uid': requesterId,
      'displayName': requesterName,
      'since': FieldValue.serverTimestamp(),
    });

    final theirFriendRef = _firestore
        .collection('users')
        .doc(requesterId)
        .collection('friends')
        .doc(currentUserId);

    batch.set(theirFriendRef, {
      'uid': currentUserId,
      'displayName': myName,
      'since': FieldValue.serverTimestamp(),
    });

    final requestRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .doc(requesterId);

    batch.delete(requestRef);

    await batch.commit();
  }

  Future<void> rejectFriendRequest(String requesterId) async {
    final currentUserId = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friend_requests')
        .doc(requesterId)
        .delete();
  }

  Future<void> removeFriend(String friendId) async {
    final currentUserId = _auth.currentUser!.uid;
    final batch = _firestore.batch();

    final myFriendRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendId);

    final theirFriendRef = _firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(currentUserId);

    batch.delete(myFriendRef);
    batch.delete(theirFriendRef);

    await batch.commit();
  }
}
