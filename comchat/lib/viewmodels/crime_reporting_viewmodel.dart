import 'package:flutter/material.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/models/crime_report.dart';

class CrimeReportingViewModel extends ChangeNotifier {
  final ReportRepository _repository;

  CrimeReportingViewModel(this._repository);

  Stream<List<CrimeReport>> watchReports() => _repository.watchReports();

  Future<void> addReport(String title, String description) async {
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now(),
    };
    await _repository.addReport(data);
  }
}
