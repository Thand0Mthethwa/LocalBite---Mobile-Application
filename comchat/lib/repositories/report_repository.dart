import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comchat/firestore_service.dart';
import 'package:comchat/models/crime_report.dart';

class ReportRepository {
  final FirestoreService _service;
  final String collectionPath;

  ReportRepository(this._service, {this.collectionPath = 'crime_reports'});

  Stream<List<CrimeReport>> watchReports() {
    return _service
        .getCollectionStream(collectionPath)
    .map((snapshot) => snapshot.docs
      .map((d) => CrimeReport.fromDoc(d))
      .toList());
  }

  /// Stream of reports created since [since]. Uses a server-side query.
  Stream<List<CrimeReport>> watchReportsSince(Duration since) {
    final from = Timestamp.fromDate(DateTime.now().subtract(since));
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .where('createdAt', isGreaterThan: from)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CrimeReport.fromDoc(d)).toList());
  }

  /// Stream that emits the count of reports created since [since].
  Stream<int> watchReportCountSince(Duration since) {
    final from = Timestamp.fromDate(DateTime.now().subtract(since));
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .where('createdAt', isGreaterThan: from)
        .snapshots()
        .map((snap) => snap.size);
  }

  /// Stream of latest [limit] reports.
  Stream<List<CrimeReport>> watchLatestReports({int limit = 10}) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CrimeReport.fromDoc(d)).toList());
  }

  Future<DocumentReference> addReport(Map<String, dynamic> data) {
    return _service.addDocument(collectionPath, data);
  }
}
