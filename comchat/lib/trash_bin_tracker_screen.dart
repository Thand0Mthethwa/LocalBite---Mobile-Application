import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:comchat/firestore_service.dart';

class TrashBinTrackerScreen extends StatefulWidget {
  const TrashBinTrackerScreen({super.key});

  @override
  State<TrashBinTrackerScreen> createState() => _TrashBinTrackerScreenState();
}

class _TrashBinTrackerScreenState extends State<TrashBinTrackerScreen> {
  final FirestoreService _db = FirestoreService();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  Future<void> _scheduleForDate(BuildContext context, DateTime day) async {
    final notesController = TextEditingController();
    // The dialog uses the surrounding BuildContext; we capture the
    // ScaffoldMessenger before awaiting and check `mounted` after the
    // async operation to avoid using the context unsafely. Suppress the
    // lint here as the usage is intentional and guarded.
    // ignore: use_build_context_synchronously
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Schedule pickup for ${day.toLocal().toString().split(' ').first}'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'E.g. leave at front gate'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;

    final messenger = ScaffoldMessenger.of(context);

    await _db.addDocument('trash_pickups', {
      'date': Timestamp.fromDate(DateTime(day.year, day.month, day.day)),
      'createdAt': Timestamp.now(),
      'notes': notesController.text.trim(),
    });

    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('Pickup scheduled for ${day.toLocal().toString().split(' ').first}')));
  }

  Future<void> _deletePickup(String docId) async {
    await _db.deleteDocument('trash_pickups', docId);
  }

  Widget _buildCalendar(AsyncSnapshot<QuerySnapshot> snapshot) {
    final docs = snapshot.data?.docs ?? [];
    // Build a set of yyyy-mm-dd strings for quick lookup
    final scheduled = <String>{};
    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final ts = data['date'];
      if (ts is Timestamp) {
        final dt = ts.toDate();
        scheduled.add('${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}');
      }
    }

    final year = _visibleMonth.year;
    final month = _visibleMonth.month;
    final firstOfMonth = DateTime(year, month, 1);
    final weekdayOffset = firstOfMonth.weekday % 7; // make Sunday=0
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final cells = <Widget>[];
    // weekday headers
    const weekdayLabels = ['S','M','T','W','T','F','S'];
    for (final w in weekdayLabels) {
      cells.add(Center(child: Text(w, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))));
    }

    // leading empty cells
    for (int i = 0; i < weekdayOffset; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final dt = DateTime(year, month, day);
      final key = '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
      final isScheduled = scheduled.contains(key);

      cells.add(GestureDetector(
        onTap: () => _scheduleForDate(context, dt),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isScheduled ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$day', style: TextStyle(fontSize: 13, color: isScheduled ? Theme.of(context).colorScheme.primary : null)),
              if (isScheduled)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Text('${_monthNames[month - 1]} $year', style: Theme.of(context).textTheme.titleMedium),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            TextButton(onPressed: () => setState(() => _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month)), child: const Text('Today')),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash Bin Tracker'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Open the month-grid and let user tap a day, but also allow picking today quickly
          final today = DateTime.now();
          await _scheduleForDate(context, DateTime(today.year, today.month, today.day));
        },
        icon: const Icon(Icons.add),
        label: const Text('Schedule pickup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month-grid calendar
            StreamBuilder<QuerySnapshot>(
              stream: _db.getCollectionStream('trash_pickups'),
              builder: (context, snapshot) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _buildCalendar(snapshot),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text('Upcoming pickups', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.getCollectionStream('trash_pickups'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  // Map documents into dated items and sort upcoming first
                  final items = docs
                      .map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final ts = data['date'];
                        DateTime? date;
                        if (ts is Timestamp) date = ts.toDate();
                        return {
                          'id': d.id,
                          'date': date,
                          'raw': data,
                        };
                      })
                      .where((m) => m['date'] != null)
                      .toList();

                  items.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

                  if (items.isEmpty) {
                    return Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline, size: 48, color: theme.colorScheme.primary),
                              const SizedBox(height: 12),
                              const Text('No pickups scheduled'),
                              const SizedBox(height: 8),
                              Text('Tap a day on the calendar above or use the button below to schedule a trash pickup.'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final id = item['id'] as String;
                      final date = item['date'] as DateTime;
                      final formatted = date.toLocal().toString().split(' ').first;
                      final isPast = date.isBefore(DateTime.now());
                      final notes = (item['raw'] as Map<String, dynamic>)['notes'] as String?;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPast ? theme.colorScheme.error.withOpacity(0.12) : theme.colorScheme.primary.withOpacity(0.12),
                          child: Icon(Icons.delete, color: isPast ? theme.colorScheme.error : theme.colorScheme.primary),
                        ),
                        title: Text('Pickup on $formatted'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notes != null && notes.isNotEmpty) Text(notes),
                            Text(isPast ? 'Missed or completed' : 'Scheduled'),
                          ],
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete pickup',
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete pickup'),
                                content: Text('Delete pickup scheduled for $formatted?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await _deletePickup(id);
                            }
                          },
                        ),
                        onTap: () {
                          // Offer quick reschedule via date picker
                          showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          ).then((newDate) async {
                            if (newDate == null) return;
                            await _db.updateDocument('trash_pickups', id, {
                              'date': Timestamp.fromDate(DateTime(newDate.year, newDate.month, newDate.day)),
                            });
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
