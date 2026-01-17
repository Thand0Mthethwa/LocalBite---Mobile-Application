import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of a collection
  Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    return _db.collection(collectionPath).snapshots();
  }

  // Get a stream of a document
  Stream<DocumentSnapshot> getDocumentStream(String collectionPath, String documentId) {
    return _db.collection(collectionPath).doc(documentId).snapshots();
  }

  // Add a document to a collection
  Future<DocumentReference> addDocument(String collectionPath, Map<String, dynamic> data) {
    return _db.collection(collectionPath).add(data);
  }

  // Update a document in a collection
  Future<void> updateDocument(String collectionPath, String documentId, Map<String, dynamic> data) {
    return _db.collection(collectionPath).doc(documentId).update(data);
  }

  // Delete a document from a collection
  Future<void> deleteDocument(String collectionPath, String documentId) {
    return _db.collection(collectionPath).doc(documentId).delete();
  }
}
