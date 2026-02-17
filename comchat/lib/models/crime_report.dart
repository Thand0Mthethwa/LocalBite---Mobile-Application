import 'package:cloud_firestore/cloud_firestore.dart';

class CrimeReport {
  final String id;
  final String title;
  final String description;
  final Timestamp createdAt;
  final double? latitude;
  final double? longitude;

  CrimeReport({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory CrimeReport.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrimeReport(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
    );
  }
}
