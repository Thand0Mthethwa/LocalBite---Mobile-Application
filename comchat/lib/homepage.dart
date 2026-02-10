import 'package:flutter/material.dart';
import 'package:comchat/navigation_service.dart';
import 'package:comchat/FirestoreService.dart';
import 'package:comchat/repositories/report_repository.dart';
import 'package:comchat/models/crime_report.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ReportRepository(FirestoreService());
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Hub'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect, report, and find local services in your community.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),

              // KPI cards
              StreamBuilder<int>(
                stream: repo.watchReportCountSince(const Duration(days: 1)),
                builder: (context, snapshot) {
                  final newReports = snapshot.data ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _KpiCard(
                        label: 'New reports (24h)',
                        value: newReports.toString(),
                        color: theme.colorScheme.primary,
                      ),
                      _KpiCard(
                        label: 'Events today',
                        value: '—',
                        color: theme.colorScheme.secondary,
                      ),
                      _KpiCard(
                        label: 'Local shops',
                        value: '—',
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              // Quick actions grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _ActionCard(
                    icon: Icons.people,
                    label: 'Social',
                    color: theme.colorScheme.primary,
                    onTap: () => _navigateTo(context, 1),
                  ),
                  _ActionCard(
                    icon: Icons.delete,
                    label: 'Trash Tracker',
                    color: theme.colorScheme.secondary,
                    onTap: () => _navigateTo(context, 2),
                  ),
                  _ActionCard(
                    icon: Icons.security,
                    label: 'Safety',
                    color: theme.colorScheme.primary,
                    onTap: () => _navigateTo(context, 3),
                  ),
                  _ActionCard(
                    icon: Icons.shop,
                    label: 'Local Shops',
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
