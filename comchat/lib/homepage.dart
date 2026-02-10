import 'package:flutter/material.dart';
import 'package:comchat/navigation_service.dart';
import 'package:comchat/FirestoreService.dart';
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
              // profile action (expand later)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile tapped')));
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
