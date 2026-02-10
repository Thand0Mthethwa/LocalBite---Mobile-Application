import 'package:flutter/material.dart';
import 'package:comchat/FirestoreService.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/viewmodels/crime_reporting_viewmodel.dart';
import 'package:comchat/models/crime_report.dart';

class CrimeReportingScreen extends StatefulWidget {
  const CrimeReportingScreen({super.key});

  @override
  State<CrimeReportingScreen> createState() => _CrimeReportingScreenState();
}

class _CrimeReportingScreenState extends State<CrimeReportingScreen> {
  late final CrimeReportingViewModel _vm;

  @override
  void initState() {
    super.initState();
    final service = FirestoreService();
    final repo = ReportRepository(service);
    _vm = CrimeReportingViewModel(repo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crime Reporting'),
      ),
      body: StreamBuilder<List<CrimeReport>>(
        stream: _vm.watchReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return Center(child: Text('No reports yet'));
          }
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final r = reports[index];
              return ListTile(
                title: Text(r.title),
                subtitle: Text(r.description),
                trailing: Text(r.createdAt.toDate().toLocal().toString()),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // For demo: add a simple report
          await _vm.addReport('Report Crime', 'Created from MVVM refactor');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
