import 'package:comchat/crime_reporting_screen.dart';
import 'package:comchat/events_portal_screen.dart';
import 'package:comchat/homepage.dart';
import 'package:comchat/local_shop_registry_screen.dart';
import 'package:comchat/navigation_service.dart';
import 'package:comchat/social_screen.dart';
import 'package:comchat/trash_bin_tracker_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = navIndex.value;
  late final PageController _pageController;

  final List<Widget> _screens = [
    const Homepage(),
    const SocialScreen(),
    const TrashBinTrackerScreen(),
    const CrimeReportingScreen(),
    const LocalShopRegistryScreen(),
    const EventsPortalScreen(),
  ];

  late final VoidCallback _navListener;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    // Listen to global navIndex changes and update local index accordingly.
    _navListener = () {
      final newIndex = navIndex.value;
      if (newIndex != _currentIndex && mounted) {
        _pageController.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    };
    navIndex.addListener(_navListener);
  }

  @override
  void dispose() {
    _pageController.dispose();
    navIndex.removeListener(_navListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          // Keep both local and global state in sync when user swipes.
          setState(() => _currentIndex = index);
          if (navIndex.value != index) navIndex.value = index;
        },
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Sign out',
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
        child: const Icon(Icons.logout),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          navIndex.value = index;
          _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
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
