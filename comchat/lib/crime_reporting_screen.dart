import 'package:flutter/material.dart';
import 'package:comchat/FirestoreService.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/viewmodels/crime_reporting_viewmodel.dart';
import 'package:comchat/models/crime_report.dart';
import 'package:url_launcher/url_launcher.dart';

class CrimeReportingScreen extends StatefulWidget {
  const CrimeReportingScreen({super.key});

  @override
  State<CrimeReportingScreen> createState() => _CrimeReportingScreenState();
}

class _CrimeReportingScreenState extends State<CrimeReportingScreen> {
  late final CrimeReportingViewModel _vm;

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot place call to $number')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error trying to call $number')),
      );
    }
  }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              color: Colors.red[50],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.warning, color: Colors.red),
                    title: Text('Emergencies — Call 24/7 (toll-free)'),
                    subtitle: Text('Tap a number to call'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Emergencies'),
                    subtitle: Text('112'),
                    onTap: () => _callNumber('112'),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_police),
                    title: Text('Police'),
                    subtitle: Text('10111'),
                    onTap: () => _callNumber('10111'),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_hospital),
                    title: Text('Ambulance'),
                    subtitle: Text('10177'),
                    onTap: () => _callNumber('10177'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CrimeReport>>(
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
          ),
        ],
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
