import 'dart:async';

import 'package:comchat/models/shop.dart';
import 'package:comchat/shop_details_screen.dart';
import 'package:flutter/material.dart';

class AdReelsScreen extends StatefulWidget {
  final List<Shop> ads;

  const AdReelsScreen({super.key, required this.ads});

  @override
  State<AdReelsScreen> createState() => _AdReelsScreenState();
}

class _AdReelsScreenState extends State<AdReelsScreen> {
  late final PageController _pageController;
  late final List<Shop> _activeAds;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _activeAds = widget.ads.where((ad) => ad.isStatusAdActive).toList();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_activeAds.length < 2) {
      return;
    }
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        return;
      }
      final nextPage = (_pageController.page?.toInt() ?? 0) + 1;
      if (nextPage >= _activeAds.length) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weekly specials'),
        centerTitle: true,
      ),
      body: _activeAds.isEmpty
          ? const Center(
              child: Text(
                'No weekly specials yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _activeAds.length,
              itemBuilder: (context, index) {
                final ad = _activeAds[index];
                return _AdReelCard(ad: ad);
              },
            ),
    );
  }
}

class _AdReelCard extends StatelessWidget {
  final Shop ad;

  const _AdReelCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ad.imageUrls.isNotEmpty ? ad.imageUrls.first : null;
    final hasImage = imageUrl != null && imageUrl.startsWith('http');

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackBackground(),
          )
        else
          _buildFallbackBackground(),
        Positioned(
          left: 16,
          top: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Featured meal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: 16,
          child: Column(
            children: [
              _ActionButton(icon: Icons.favorite, label: 'Like'),
              const SizedBox(height: 12),
              _ActionButton(icon: Icons.chat_bubble, label: 'Chat'),
              const SizedBox(height: 12),
              _ActionButton(icon: Icons.shopping_cart, label: 'Order'),
            ],
          ),
        ),
        Positioned(
          left: 16,
          bottom: 90,
          child: GestureDetector(
            onTap: () => _openShop(context, ad),
            child: Row(
              children: const [
                Icon(Icons.keyboard_arrow_up, color: Colors.white70),
                SizedBox(width: 6),
                Text(
                  'Swipe up to view shop',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      ad.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.statusText ?? 'Check out this food business!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${ad.statusDurationSeconds ?? 30}s • ${ad.category} • Budget-friendly',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (ad.weeklySpecialPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Budget recommendation: R${ad.weeklySpecialPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _openShop(context, ad),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Order now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange.shade700, Colors.deepOrange.shade900],
        ),
      ),
    );
  }
}

void _openShop(BuildContext context, Shop ad) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ShopDetailsScreen(shop: ad)),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
