import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A lightweight controller for chat-related operations that don't require
/// direct access to widget state. This lets parent widgets call methods like
/// `markIncomingAsRead` without relying on GlobalKey/state casts.
class ChatController {
  ChatController();

  /// Marks incoming unread messages as read for the current user.
  /// Returns the number of documents updated.
  Future<int> markIncomingAsRead() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return 0;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('messages')
          .where('read', isEqualTo: false)
          .get();
      if (snap.docs.isEmpty) return 0;
      final batch = FirebaseFirestore.instance.batch();
      var updated = 0;
      for (var doc in snap.docs) {
        final sender = (doc.data() as dynamic)['senderId'] as String?;
        if (sender == null || sender != currentUid) {
          batch.update(doc.reference, {'read': true});
          updated++;
        }
      }
      if (updated > 0) await batch.commit();
      return updated;
    } catch (e, st) {
      // ignore: avoid_print
      print('ChatController.markIncomingAsRead error: $e\n$st');
      return 0;
    }
  }
}
