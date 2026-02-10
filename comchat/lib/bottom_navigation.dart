import 'package:comchat/crime_reporting_screen.dart';
import 'package:comchat/events_portal_screen.dart';
import 'package:comchat/homepage.dart';
import 'package:comchat/local_shop_registry_screen.dart';
import 'package:comchat/social_screen.dart';
import 'package:comchat/trash_bin_tracker_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Homepage(),
    const SocialScreen(),
    const TrashBinTrackerScreen(),
    const CrimeReportingScreen(),
    const LocalShopRegistryScreen(),
    const EventsPortalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Trash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Safety',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Commerce',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}
