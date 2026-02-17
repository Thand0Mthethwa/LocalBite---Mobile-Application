import 'package:flutter/material.dart';
import 'package:comchat/FirestoreService.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/viewmodels/crime_reporting_viewmodel.dart';
import 'package:comchat/models/crime_report.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class CrimeReportingScreen extends StatefulWidget {
  const CrimeReportingScreen({super.key});

  @override
  State<CrimeReportingScreen> createState() => _CrimeReportingScreenState();
}

class _CrimeReportingScreenState extends State<CrimeReportingScreen> {
  late final CrimeReportingViewModel _vm;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Position? _currentPosition;

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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  void _showReportDialog() {
    _currentPosition = null;
    _titleController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Crime Report'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 16),
                    if (_currentPosition != null)
                      Text(
                          'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _getCurrentLocation();
                        setState(() {});
                      },
                      icon: const Icon(Icons.location_on),
                      label: const Text('Get Location'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty) {
                  await _vm.addReport(
                    _titleController.text,
                    _descriptionController.text,
                    latitude: _currentPosition?.latitude,
                    longitude: _currentPosition?.longitude,
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and description cannot be empty.')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crime Reporting'),
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
                  const ListTile(
                    leading: Icon(Icons.warning, color: Colors.red),
                    title: Text('Emergencies — Call 24/7 (toll-free)'),
                    subtitle: Text('Tap a number to call'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Emergencies'),
                    subtitle: const Text('112'),
                    onTap: () => _callNumber('112'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_police),
                    title: const Text('Police'),
                    subtitle: const Text('10111'),
                    onTap: () => _callNumber('10111'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_hospital),
                    title: const Text('Ambulance'),
                    subtitle: const Text('10177'),
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final reports = snapshot.data ?? [];
                if (reports.isEmpty) {
                  return const Center(child: Text('No reports yet'));
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
        onPressed: _showReportDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
