import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comchat/FirestoreService.dart';
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

  Future<DocumentReference> addReport(Map<String, dynamic> data) {
    return _service.addDocument(collectionPath, data);
  }
}
