import 'package:comchat/announcements_screen.dart';
import 'package:comchat/chat_screen.dart';
import 'package:comchat/navigation_service.dart';
import 'package:flutter/material.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int _currentIndex = 0;

  final GlobalKey _chatKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // initialize screens here so we can provide the key to the ChatScreen
    _screens = [
      ChatScreen(key: _chatKey),
      const AnnouncementsScreen(),
    ];

    // When the global bottom nav switches to the Social tab, if the Chat
    // sub-tab is active we should mark incoming messages as read so the
    // unread badge in the main bottom navigation clears.
    navIndex.addListener(_handleNavIndex);
  }

  @override
  void dispose() {
    navIndex.removeListener(_handleNavIndex);
    super.dispose();
  }

  void _handleNavIndex() {
    if (navIndex.value == 1 && _currentIndex == 0) {
      // call the ChatScreen state's public markIncomingAsRead method if available
      try {
        final state = _chatKey.currentState;
        if (state != null) {
          // use a dynamic call to avoid referencing private State type
          (state as dynamic).markIncomingAsRead();
        }
      } catch (_) {
        // ignore errors calling into the child state
      }
    }
  }

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
          // if user switches to the Chat sub-tab while the global nav is
          // already on Social, ensure unread messages are marked read.
          if (index == 0 && navIndex.value == 1) {
            try {
              final state = _chatKey.currentState;
              if (state != null) (state as dynamic).markIncomingAsRead();
            } catch (_) {}
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Announcements',
          ),
        ],
      ),
    );
  }
}
