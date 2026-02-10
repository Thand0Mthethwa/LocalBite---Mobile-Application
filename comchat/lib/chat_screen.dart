import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'FirestoreService.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();

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
    });
  }

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

                return ListView.builder(
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

                    String timeLabel = '';
                    if (dt != null) {
                      final now = DateTime.now();
                      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
                        timeLabel = DateFormat.jm().format(dt);
                      } else {
                        timeLabel = DateFormat.yMMMd().add_jm().format(dt);
                      }
                    }

                    // Grouping: hide avatar+name when previous message (chronologically) is from same sender
                    bool showHeader = true;
                    if (index > 0) {
                      final prev = docs[index - 1];
                      final prevSender = (prev.data() as Map<String, dynamic>)['senderId'] as String?;
                      if (prevSender != null && prevSender == senderId) showHeader = false;
                    }

                    return Padding(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(senderName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      Text(timeLabel, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                                    ],
                                  ),
                                if (!showHeader) Text(timeLabel, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(text),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
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
}
