import 'package:comchat/announcements_screen.dart';
import 'package:comchat/chat_screen.dart';
import 'package:comchat/controllers/chat_controller.dart';
import 'package:comchat/navigation_service.dart';
import 'package:flutter/material.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int _currentIndex = 0;

  // Use a typed controller instead of relying on GlobalKey/currentState casts.
  late final ChatController _chatController;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // initialize screens here and provide the typed controller to ChatScreen
    _chatController = ChatController();
    _screens = [
      ChatScreen(controller: _chatController),
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
      // call the typed controller to mark incoming messages as read
      try {
        _chatController.markIncomingAsRead();
      } catch (_) {}
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
              _chatController.markIncomingAsRead();
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
