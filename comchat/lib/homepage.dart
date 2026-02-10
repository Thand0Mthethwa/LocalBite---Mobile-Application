import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  title: Text('No recent activity'),
                  subtitle: Text('You will see reports and updates here.'),
                ),
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
    // Find the nearest Navigator and push the BottomNavigation again so that
    // it rebuilds with the new index via a query parameter is an advanced
    // option. For now we'll just show a SnackBar to indicate action.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to tab $tabIndex (implement routing)')),
    );
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
