import 'package:flutter/material.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/models/crime_report.dart';

class CrimeReportingViewModel extends ChangeNotifier {
  final ReportRepository _repository;

  CrimeReportingViewModel(this._repository);

  Stream<List<CrimeReport>> watchReports() => _repository.watchReports();

  Future<void> addReport(String title, String description, {double? latitude, double? longitude}) async {
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now(),
      'latitude': latitude,
      'longitude': longitude,
    };
    await _repository.addReport(data);
  }
}
