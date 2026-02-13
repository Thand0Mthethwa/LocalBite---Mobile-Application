import 'package:cloud_firestore/cloud_firestore.dart';

class CrimeReport {
  final String id;
  final String title;
  final String description;
  final Timestamp createdAt;

  CrimeReport({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory CrimeReport.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrimeReport(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
