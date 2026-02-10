import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple repository for events collection. Keeps API similar to ReportRepository
class EventRepository {
  final String collectionPath;

  EventRepository({this.collectionPath = 'events'});

  Stream<List<Map<String, dynamic>>> watchLatestEvents({int limit = 10}) {
  return FirebaseFirestore.instance
    .collection(collectionPath)
    .orderBy('startAt', descending: true)
    .limit(limit)
    .snapshots()
    .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<int> watchEventCountSince(Duration since) {
    final from = Timestamp.fromDate(DateTime.now().subtract(since));
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .where('createdAt', isGreaterThan: from)
        .snapshots()
        .map((snap) => snap.size);
  }
}
