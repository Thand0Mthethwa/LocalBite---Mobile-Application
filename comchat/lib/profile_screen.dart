import 'package:comchat/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:comchat/theme.dart';
import 'dart:async';
import 'dart:convert';

class PurchaseHistory {
  final String id;
  final String foodName;
  final double amount;
  final DateTime date;

  PurchaseHistory({
    required this.id,
    required this.foodName,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'foodName': foodName,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) =>
      PurchaseHistory(
        id: map['id'],
        foodName: map['foodName'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
      );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  Position? _currentPosition;
  String? _currentAddress;
  StreamSubscription<Position>? _positionStream;
  List<PurchaseHistory> _purchaseHistory = [];
  double _totalSpent = 0.0;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _loadPurchaseHistory();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    await _clearPurchaseHistory();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable the services',
            ),
          ),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return false;
    }
    return true;
  }

  void _startLocationUpdates() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    _positionStream = Geolocator.getPositionStream().listen((
      Position position,
    ) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng(position);
    });
  }

  Future<void> _loadPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('purchaseHistory') ?? [];

    setState(() {
      _purchaseHistory = historyJson
          .map((item) => PurchaseHistory.fromMap(jsonDecode(item)))
          .toList();
      _purchaseHistory.sort((a, b) => b.date.compareTo(a.date));
      _totalSpent = _purchaseHistory.fold(
        0.0,
        (sum, item) => sum + item.amount,
      );
    });
  }

  Future<void> _addPurchase(String foodName, double amount) async {
    final purchase = PurchaseHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: foodName,
      amount: amount,
      date: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('purchaseHistory') ?? [];
    historyJson.add(jsonEncode(purchase.toMap()));
    await prefs.setStringList('purchaseHistory', historyJson);

    await _loadPurchaseHistory();
  }

  Future<void> _clearPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('purchaseHistory');
    await _loadPurchaseHistory();
  }

  void _showAddPurchaseDialog() {
    final foodController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: foodController,
              decoration: const InputDecoration(labelText: 'Food Item'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (R)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (foodController.text.isNotEmpty && amount > 0) {
                _addPurchase(foodController.text, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    )
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _user == null
          ? const Center(child: Text('Please log in to see your profile.'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_user!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User data not found.'));
                }

                final userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                final name = userData['name'] as String? ?? 'N/A';
                final surname = userData['surname'] as String? ?? '';
                final area = userData['area'] as String? ?? 'N/A';
                final photoUrl = userData['photoUrl'] as String?;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: photoUrl != null
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt),
                                  onPressed: () {
                                    // TODO: Implement profile photo change
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Name',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '$name $surname',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Area',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          area,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Live Location',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_currentPosition == null)
                          const Text('Getting location...')
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Address',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                _currentAddress ?? 'Getting address...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warmCream,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Spent',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  Text(
                                    'R${_totalSpent.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Purchases',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  Text(
                                    '${_purchaseHistory.length}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Purchase History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            if (_purchaseHistory.isNotEmpty)
                              GestureDetector(
                                onTap: _clearPurchaseHistory,
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_purchaseHistory.isEmpty)
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No purchases yet',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _purchaseHistory.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final purchase = _purchaseHistory[index];
                              final formattedDate =
                                  '${purchase.date.day}/${purchase.date.month}/${purchase.date.year} ${purchase.date.hour}:${purchase.date.minute.toString().padLeft(2, '0')}';

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.warmCream,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            purchase.foodName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'R${purchase.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showAddPurchaseDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add Purchase',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
