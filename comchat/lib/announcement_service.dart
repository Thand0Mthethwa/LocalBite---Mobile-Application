import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of a collection
  Stream<QuerySnapshot> getAnnouncementsStream() {
    return _db.collection('announcements').orderBy('timestamp', descending: true).snapshots();
  }

  // Add a document to a collection
  Future<DocumentReference> addAnnouncement(String title, String content) {
    return _db.collection('announcements').add({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
