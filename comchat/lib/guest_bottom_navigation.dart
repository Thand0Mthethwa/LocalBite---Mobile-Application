import 'package:comchat/ad_reels_screen.dart';
import 'package:comchat/guest_homepage.dart';
import 'package:comchat/login_screen.dart';
import 'package:comchat/models/shop.dart';
import 'package:comchat/navigation_service.dart';
import 'package:comchat/shop_list.dart';
import 'package:flutter/material.dart';

class GuestBottomNavigation extends StatefulWidget {
  const GuestBottomNavigation({super.key});

  @override
  State<GuestBottomNavigation> createState() => _GuestBottomNavigationState();
}

class _GuestBottomNavigationState extends State<GuestBottomNavigation> {
  int _currentIndex = navIndex.value;
  late final PageController _pageController;

  final List<Widget> _screens = [
    const GuestHomepage(),
    const ShopList(),
    AdReelsScreen(
      ads: [
        Shop(
          id: 'sample-ad',
          name: 'Quick Bites Fast Food',
          address: '12 Market Street',
          contact: '+27 82 555 1234',
          openingTime: '08:00',
          closingTime: '22:00',
          rating: 4.5,
          imageUrls: const [],
          category: 'Fast Food',
          statusText: 'Fresh lunch deals and combo specials all week long!',
          statusDurationSeconds: 45,
          isStatusAdActive: true,
        ),
      ],
    ),
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
        tooltip: 'Sign in',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: const Icon(Icons.login),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          navIndex.value = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Shops'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Ads',
          ),
        ],
      ),
    );
  }
}
