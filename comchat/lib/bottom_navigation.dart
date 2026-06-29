import 'package:comchat/ad_reels_screen.dart';
import 'package:comchat/homepage.dart';
import 'package:comchat/models/shop.dart';
import 'package:comchat/navigation_service.dart';
import 'package:comchat/profile_screen.dart';
import 'package:comchat/shop_list.dart';
import 'package:comchat/theme.dart';
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
    const ProfileScreen(),
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
    final theme = Theme.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          if (navIndex.value != index) navIndex.value = index;
        },
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: AppColors.muted,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.storefront_outlined),
                  activeIcon: Icon(Icons.storefront),
                  label: 'Shops',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_circle_outline),
                  activeIcon: Icon(Icons.play_circle_fill),
                  label: 'Ads',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
