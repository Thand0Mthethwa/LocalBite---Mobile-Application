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
        title: Text('Community Hub'),
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
                      'Connect, report, and find local services in your community.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search reports, shops, events',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (q) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search: $q')));
                },
              ),

              const SizedBox(height: 12),

              // Mini calendar preview (14-day horizontal)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: SizedBox(
                    height: 80,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirestoreService().getCollectionStream('trash_pickups'),
                      builder: (context, snap) {
                        final docs = snap.data?.docs ?? [];
                        final scheduled = <String>{};
                        for (final d in docs) {
                          final data = d.data() as Map<String, dynamic>;
                          final ts = data['date'];
                          if (ts is Timestamp) {
                            final dt = ts.toDate();
                            scheduled.add('${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}');
                          }
                        }

                        final items = List.generate(14, (i) {
                          final dt = DateTime.now().add(Duration(days: i));
                          final key = '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
                          final isScheduled = scheduled.contains(key);
                          return GestureDetector(
                            onTap: () => navIndex.value = 2, // go to Trash tab
                            child: Container(
                              width: 64,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isScheduled ? theme.colorScheme.primary.withOpacity(0.12) : theme.colorScheme.surface,
                                    child: Text('${dt.day}', style: TextStyle(color: isScheduled ? theme.colorScheme.primary : null)),
                                  ),
                                  const SizedBox(height: 6),
                                  if (isScheduled)
                                    Container(width: 6, height: 6, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)),
                                ],
                              ),
                            ),
                          );
                        });

                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: items,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // KPI cards
              // KPI cards (responsive)
              StreamBuilder<int>(
                stream: repo.watchReportCountSince(const Duration(days: 1)),
                builder: (context, snapshot) {
                  final newReports = snapshot.data ?? 0;
                  return Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.report,
                          label: 'New reports (24h)',
                          value: newReports.toString(),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<int>(
                          stream: eventRepo.watchEventCountSince(const Duration(days: 1)),
                          builder: (context, evSnap) {
                            final eventsToday = evSnap.data ?? 0;
                            return _KpiCard(
                              icon: Icons.event,
                              label: 'Events today',
                              value: eventsToday.toString(),
                              color: theme.colorScheme.secondary,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<int>(
                          stream: shopRepo.watchShopCountSince(const Duration(days: 365 * 10)),
                          builder: (context, sSnap) {
                            final shops = sSnap.data ?? 0;
                            return _KpiCard(
                              icon: Icons.store,
                              label: 'Local shops',
                              value: shops.toString(),
                              color: theme.colorScheme.primary,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              // Quick actions as compact CTA buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _CtaButton(
                    icon: Icons.people,
                    label: 'Social',
                    color: theme.colorScheme.primary,
                    onTap: () => _navigateTo(context, 1),
                  ),
                  // Prominent Report Crime CTA
                  GestureDetector(
                    onTap: () => _navigateTo(context, 3),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.secondary,
                            child: Icon(Icons.report, color: theme.colorScheme.onSecondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Report Crime', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onSecondaryContainer)),
                                const SizedBox(height: 4),
                                Text('Quickly report incidents', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer.withOpacity(0.9))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _CtaButton(
                    icon: Icons.delete,
                    label: 'Trash',
                    color: theme.colorScheme.secondary,
                    onTap: () => _navigateTo(context, 2),
                  ),
                  _CtaButton(
                    icon: Icons.security,
                    label: 'Safety',
                    color: theme.colorScheme.primary,
                    onTap: () => _navigateTo(context, 3),
                  ),
                  _CtaButton(
                    icon: Icons.shop,
                    label: 'Shops',
                    color: theme.colorScheme.secondary,
                    onTap: () => _navigateTo(context, 4),
                  ),
                ],
              ),

                  const SizedBox(height: 20),

                  // Nearby events carousel
                  Text('Nearby events', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: eventRepo.watchLatestEvents(limit: 10),
                      builder: (context, snap) {
                        final events = snap.data ?? [];
                        if (events.isEmpty) {
                          return Center(child: Text('No upcoming events', style: theme.textTheme.bodySmall));
                        }
                        // ensure events are sorted ascending by startAt when possible
                        events.sort((a, b) {
                          final ta = a['startAt'];
                          final tb = b['startAt'];
                          DateTime? da, db;
                          if (ta is Timestamp) da = ta.toDate();
                          if (tb is Timestamp) db = tb.toDate();
                          if (da != null && db != null) return da.compareTo(db);
                          return 0;
                        });
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          itemBuilder: (context, index) {
                            final e = events[index];
                            final title = (e['title'] as String?) ?? 'Event';
                            final startAt = e['startAt'];
                            String when = '';
                            if (startAt is Timestamp) when = DateFormat.MMMd().add_jm().format(startAt.toDate().toLocal());
                            final color = theme.colorScheme.primary.withOpacity(0.08);
                            return GestureDetector(
                              onTap: () => _navigateTo(context, 5),
                              child: Container(
                                width: 220,
                                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                        const SizedBox(width: 6),
                                        Text(when, style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

              // Community activity feed
              const SizedBox(height: 6),
              Text('Community activity', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService().getCollectionStream('messages'),
                    builder: (context, snap) {
                      final docs = snap.data?.docs ?? [];
                      // sort descending by timestamp
                      docs.sort((a, b) {
                        final ta = (a.data() as Map<String, dynamic>)['timestamp'];
                        final tb = (b.data() as Map<String, dynamic>)['timestamp'];
                        if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
                        if (ta is Timestamp) return -1;
                        if (tb is Timestamp) return 1;
                        return 0;
                      });
                      final items = docs.take(4).toList();
                      if (items.isEmpty) {
                        return ListTile(
                          leading: Icon(Icons.forum, color: theme.colorScheme.primary),
                          title: const Text('No recent community posts'),
                          subtitle: const Text('Be the first to say hello!'),
                          onTap: () => _navigateTo(context, 1),
                        );
                      }
                      return Column(
                        children: items.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final text = data['text'] as String? ?? '';
                          final sender = data['senderName'] as String? ?? 'Someone';
                          final photo = data['senderPhotoUrl'] as String?;
                          final ts = data['timestamp'];
                          String when = '';
                          if (ts is Timestamp) {
                            when = DateFormat.yMMMd().add_jm().format(ts.toDate().toLocal());
                          }
                          return ListTile(
                            leading: photo != null ? CircleAvatar(backgroundImage: NetworkImage(photo)) : CircleAvatar(child: Text(sender.isNotEmpty ? sender[0].toUpperCase() : '?')),
                            title: Text(sender, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Text(when, style: theme.textTheme.bodySmall),
                            onTap: () => _navigateTo(context, 1),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Recent activity',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              // Recent reports list (streamed)
              StreamBuilder<List<CrimeReport>>(
                stream: repo.watchLatestReports(limit: 8),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reports = snapshot.data ?? [];
                  if (reports.isEmpty) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        title: const Text('No recent activity'),
                        subtitle: const Text('You will see reports and updates here.'),
                      ),
                    );
                  }
                  return Column(
                    children: reports.map((r) {
                      return ListTile(
                        leading: CircleAvatar(child: Icon(Icons.report, color: theme.colorScheme.onPrimary), backgroundColor: theme.colorScheme.primary),
                        title: Text(r.title.isNotEmpty ? r.title : 'Untitled'),
                        subtitle: Text(r.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text(r.createdAt.toDate().toLocal().toString().split(' ').first),
                        onTap: () {
                          // Navigate to report detail or show dialog (not implemented)
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open: ${r.title}')));
                        },
                      );
                    }).toList(),
                  );
                },
              ),
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

class _CtaButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CtaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_pressed ? 0.14 : 0.06),
                  blurRadius: _pressed ? 10 : 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.color.withOpacity(0.12),
                      child: Icon(widget.icon, color: widget.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(widget.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7))),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
