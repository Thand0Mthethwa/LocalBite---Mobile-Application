import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:comchat/models/crime_report.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/FirestoreService.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};
  late final ReportRepository _reportRepository;

  @override
  void initState() {
    super.initState();
    _reportRepository = ReportRepository(FirestoreService());
    _loadCrimeReports();
  }

  void _loadCrimeReports() {
    _reportRepository.watchReports().listen((reports) {
      final markers = <Marker>{};
      for (final report in reports) {
        if (report.latitude != null && report.longitude != null) {
          markers.add(
            Marker(
              markerId: MarkerId(report.id),
              position: LatLng(report.latitude!, report.longitude!),
              infoWindow: InfoWindow(
                title: report.title,
                snippet: report.description,
              ),
            ),
          );
        }
      }
      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crime Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0), // Default location, will be updated
          zoom: 2,
        ),
        markers: _markers,
      ),
    );
  }
}
