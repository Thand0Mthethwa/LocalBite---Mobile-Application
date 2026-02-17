import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'FirestoreService.dart';
import 'controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  /// Optional external controller. If not provided the screen will create
  /// an internal controller for local operations.
  final ChatController? controller;

  const ChatScreen({super.key, this.controller});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pressTimer;
  String? _activeMessageId;
  late final ChatController _controller;
  

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _ensureDisplayNameThenSend();
      _messageController.clear();
    }
  }

  Future<void> _ensureDisplayNameThenSend() async {
    User? user = FirebaseAuth.instance.currentUser;
    String senderName = 'Anonymous';
    String? senderPhoto;
    String? senderId;

    if (user != null) {
      if (user.displayName == null || user.displayName!.trim().isEmpty) {
        final entered = await _askForDisplayName(context);
        if (entered != null && entered.trim().isNotEmpty) {
          await user.updateDisplayName(entered.trim());
          await user.reload();
        }
      }
      // re-read current user properties safely
      final current = FirebaseAuth.instance.currentUser;
      senderName = current?.displayName ?? 'Anonymous';
      senderPhoto = current?.photoURL;
      senderId = current?.uid;
    }

    await _firestoreService.addDocument('messages', {
      'text': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'senderName': senderName,
      'senderPhotoUrl': senderPhoto,
      'senderId': senderId,
      // mark new messages as unread by default; recipients will see the badge
      'read': false,
    });
    // show a quick confirmation to the sender
    if (!mounted) return;
    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ChatController();
    // When opening the chat screen, mark incoming unread messages as read so the badge clears
    // (WhatsApp-like behaviour: opening the chat clears unread counts).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.markIncomingAsRead();
    });
  }

  /// Marks incoming unread messages as read for the current user.
  ///
  /// Returns the number of documents updated. This method intentionally
  /// queries all documents with `read == false` and performs a client-side
  /// filter to ensure we mark only messages where the sender is not the
  /// current user (including messages with null senderId). Doing the
  /// filtering client-side avoids edge cases with Firestore's `isNotEqualTo`.
  // markIncomingAsRead moved to ChatController

  Future<String?> _askForDisplayName(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set display name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display name', hintText: 'How should others see you?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Skip')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) return controller.text.trim();
    return null;
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Chat'),
        actions: [
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final updated = await _controller.markIncomingAsRead();
              if (!mounted) return;
            
            },
            child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getCollectionStream('messages'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // Sort messages by timestamp ascending (oldest first) for grouping
                final docs = snapshot.data!.docs
                    .map((d) => d)
                    .toList()
                  ..sort((a, b) {
                    final ta = (a.data() as Map<String, dynamic>)['timestamp'];
                    final tb = (b.data() as Map<String, dynamic>)['timestamp'];
                    if (ta is Timestamp && tb is Timestamp) return ta.compareTo(tb);
                    if (ta is Timestamp) return -1;
                    if (tb is Timestamp) return 1;
                    return 0;
                  });

                // After the frame, ensure we scroll to bottom so newest messages are visible
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                // Compute index of first unread incoming message so we can render a WhatsApp-like
                // 'New messages' divider at that point. We treat messages as unread when
                // 'read' == false and senderId != current user.
                final currentUid = FirebaseAuth.instance.currentUser?.uid;
                final firstUnreadIndex = docs.indexWhere((m) {
                  final data = m.data() as Map<String, dynamic>;
                  final sender = data['senderId'] as String?;
                  return (data['read'] == false) && (sender != null && sender != currentUid);
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final message = docs[index];
                    final data = message.data() as Map<String, dynamic>;
                    final text = data['text'] as String? ?? '';
                    final senderName = data['senderName'] as String? ?? 'Anonymous';
                    final senderPhoto = data['senderPhotoUrl'] as String?;
                    final senderId = data['senderId'] as String?;
                    final ts = data['timestamp'];

                    DateTime? dt;
                    if (ts is Timestamp) dt = ts.toDate().toLocal();

                    // Unread state is handled via the 'New messages' divider below.

                    // Grouping: hide avatar+name when previous message (chronologically) is from same sender
                    bool showHeader = true;
                    if (index > 0) {
                      final prev = docs[index - 1];
                      final prevSender = (prev.data() as Map<String, dynamic>)['senderId'] as String?;
                      if (prevSender != null && prevSender == senderId) {
                        showHeader = false;
                      }
                    }

                    final theme = Theme.of(context);
                    final msgId = message.id;
                    final isMe = senderId != null && senderId == currentUid;

                    // Helper handlers for press-and-hold to show exact time
                    void handleTapDown(TapDownDetails d) {
                      _pressTimer?.cancel();
                      _pressTimer = Timer(const Duration(seconds: 2), () {
                        setState(() => _activeMessageId = msgId);
                      });
                    }

                    void handleTapUp(TapUpDetails d) {
                      _pressTimer?.cancel();
                      if (_activeMessageId == msgId) setState(() => _activeMessageId = null);
                    }

                    void handleTapCancel() {
                      _pressTimer?.cancel();
                      if (_activeMessageId == msgId) setState(() => _activeMessageId = null);
                    }

                    final showExact = _activeMessageId == msgId && dt != null;

                    // Build the message bubble widget first, then optionally insert a
                    // WhatsApp-style 'New messages' divider before the first unread message.
                    Widget messageWidget;
                    if (isMe) {
                      messageWidget = GestureDetector(
                        onTapDown: handleTapDown,
                        onTapUp: handleTapUp,
                        onTapCancel: handleTapCancel,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (showHeader) Text(senderName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(text, style: TextStyle(color: theme.colorScheme.onPrimary)),
                                  ),
                                  if (showExact) const SizedBox(height: 6),
                                  if (showExact)
                                    Text(DateFormat.yMMMd().add_jm().format(dt), style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      messageWidget = GestureDetector(
                        onTapDown: handleTapDown,
                        onTapUp: handleTapUp,
                        onTapCancel: handleTapCancel,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: senderPhoto != null
                                        ? CircleAvatar(backgroundImage: NetworkImage(senderPhoto))
                                        : CircleAvatar(child: Text(senderName.isNotEmpty ? senderName[0].toUpperCase() : '?')),
                                  )
                                else
                                  const SizedBox(width: 48),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (showHeader) Text(senderName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(text),
                                      ),
                                      if (showExact) const SizedBox(height: 6),
                                      if (showExact)
                                          Text(DateFormat.yMMMd().add_jm().format(dt), style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // If this index is where unread messages start, render a centered divider
                    // similar to WhatsApp's 'new messages' marker.
                    if (index == firstUnreadIndex) {
                      final divider = Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(16)),
                            child: const Text('New messages', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      );
                      return Column(children: [divider, messageWidget]);
                    }

                    return messageWidget;
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (_) {
      // If animate fails (e.g., no position), ignore.
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pressTimer?.cancel();
    super.dispose();
  }
}
