import 'package:comchat/crime_reporting_screen.dart';
import 'package:comchat/events_portal_screen.dart';
import 'package:comchat/homepage.dart';
import 'package:comchat/local_shop_registry_screen.dart';
import 'package:comchat/navigation_service.dart';
import 'package:comchat/social_screen.dart';
import 'package:comchat/trash_bin_tracker_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('read', isEqualTo: false)
                    .snapshots(),
                builder: (context, snap) {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  final docs = snap.data?.docs ?? [];
                  // Count distinct senderIds (chats) that have unread messages for the current user.
                  final unreadChats = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>?;
                    if (data == null) return false;
                    final sender = data['senderId'] as String?;
                    return sender == null || sender != uid;
                  }).map((d) {
                    final data = d.data() as Map<String, dynamic>?;
                    return (data == null) ? null : (data['senderId'] as String? ?? '<unknown>');
                  }).whereType<String>().toSet().length;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.people),
                      if (unreadChats > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            child: Center(
                              child: Text(unreadChats > 99 ? '99+' : unreadChats.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        )
                    ],
                  );
                },
              ),
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
