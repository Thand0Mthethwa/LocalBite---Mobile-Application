import 'package:cloud_firestore/cloud_firestore.dart';

class ShopRepository {
  final String collectionPath;

  ShopRepository({this.collectionPath = 'shops'});

  Stream<int> watchShopCountSince(Duration since) {
    final from = Timestamp.fromDate(DateTime.now().subtract(since));
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .where('createdAt', isGreaterThan: from)
        .snapshots()
        .map((snap) => snap.size);
  }

  Stream<List<Map<String, dynamic>>> watchLatestShops({int limit = 10}) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
