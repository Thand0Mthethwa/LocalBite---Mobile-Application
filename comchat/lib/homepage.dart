import 'package:comchat/features_grid.dart';
import 'package:comchat/image_slider.dart';
import 'package:comchat/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:comchat/navigation_service.dart';
import 'package:comchat/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/repositories/event_repository.dart';
import 'package:comchat/repositories/shop_repository.dart';
import 'package:comchat/models/crime_report.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final repo = ReportRepository(FirestoreService());
  final eventRepo = EventRepository();
  final shopRepo = ShopRepository();
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Page'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: const CircleAvatar(child: Icon(Icons.person)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero banner with brand gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connect, report, and find local services in your area.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const ImageSlider(),

              const SizedBox(height: 16),

              const FeaturesGrid(),

            ],
          ),
        ),
      ),
    );
  }

  // Helper that tells BottomNavigation to switch tabs. This implementation
  // expects the BottomNavigation to be an ancestor that responds to index via
  // a simple pop+push route (we keep this lightweight). If you prefer,
  // Provider or callback wiring may be applied instead.
  void _navigateTo(BuildContext context, int tabIndex) {
    // Update the global navIndex to request that BottomNavigation switch tabs.
    navIndex.value = tabIndex;
  }
}
