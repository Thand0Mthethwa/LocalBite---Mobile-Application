import 'package:comchat/announcements_screen.dart';
import 'package:comchat/chat_screen.dart';
import 'package:comchat/crime_reporting_screen.dart';
import 'package:comchat/events_portal_screen.dart';
import 'package:comchat/local_shop_registry_screen.dart';
import 'package:comchat/map_screen.dart';
import 'package:comchat/social_screen.dart';
import 'package:comchat/trash_bin_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:comchat/feature_card.dart';

class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      children: [
        FeatureCard(
          title: 'Trash Bin Tracker',
          icon: Icons.delete,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TrashBinTrackerScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'Crime Reporting',
          icon: Icons.warning,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CrimeReportingScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'Local Shop Registry',
          icon: Icons.store,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LocalShopRegistryScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'Events Portal',
          icon: Icons.event,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventsPortalScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'Announcements',
          icon: Icons.announcement,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnnouncementsScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'Social Screen',
          icon: Icons.people,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SocialScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'Map',
          icon: Icons.map,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MapScreen(),
              ),
            );
          },
        ),
        FeatureCard(
          title: 'Chat',
          icon: Icons.chat,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
