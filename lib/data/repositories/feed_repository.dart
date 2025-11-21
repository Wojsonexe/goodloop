import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodloop/data/models/feed_item_model.dart';

class FeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FeedItemModel>> getFeedStream() {
    return _firestore
        .collection('feed')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => FeedItemModel.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> addFeedItem(FeedItemModel item) async {
    await _firestore.collection('feed').add(item.toFirestore());
  }
}
