import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/firestore_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};
  late final ReportRepository _reportRepository;
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  Placemark? _placemark;
  bool _isMapFullScreen = false;
  CameraPosition? _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _reportRepository = ReportRepository(FirestoreService());
    _initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 2,
    );
    _loadCrimeReports();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
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
        _markers.removeWhere((marker) => marker.markerId.value != 'currentLocation');
        _markers.addAll(markers);
      });
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location services are disabled. Please enable the services')));
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      }
      return false;
    }
    return true;
  }

  void _startLocationUpdates() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition();
    _updateMapWithPosition(position);

    _positionStreamSubscription = Geolocator.getPositionStream().listen((position) {
      _updateMapWithPosition(position);
    });
  }

  Future<void> _getCurrentLocationAndPlacemark() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition();
    _updateMapWithPosition(position);
  }

  void _updateMapWithPosition(Position position) async {
    if (!mounted) return;

    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    setState(() {
      if (placemarks.isNotEmpty) {
        _placemark = placemarks.first;
      }

      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14,
      );

      _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        _initialCameraPosition!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Map'),
      ),
      body: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMapFullScreen = !_isMapFullScreen;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isMapFullScreen
                        ? mediaQuery.size.height
                        : mediaQuery.size.height * 0.5,
                    width: mediaQuery.size.width,
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: _initialCameraPosition!,
                      markers: _markers,
                    ),
                  ),
                ),
                if (_placemark != null && !_isMapFullScreen)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      margin: const EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your Location',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Municipality: ${_placemark?.locality}'),
                            Text(
                                'Address: ${_placemark?.street}, ${_placemark?.subAdministrativeArea}, ${_placemark?.administrativeArea}'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocationAndPlacemark,
        tooltip: 'Get Current Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
