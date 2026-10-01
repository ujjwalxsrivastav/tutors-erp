import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';

/// Admin navigation shell — responsive sidebar/rail
class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', path: '/admin/dashboard'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Leads', path: '/admin/leads'),
    _NavItem(icon: Icons.school_outlined, activeIcon: Icons.school, label: 'Tutors', path: '/admin/tutors'),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Assignments', path: '/admin/assignments'),
    _NavItem(icon: Icons.event_outlined, activeIcon: Icons.event, label: 'Demos', path: '/admin/demos'),
    _NavItem(icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories, label: 'Tuitions', path: '/admin/tuitions'),
    _NavItem(icon: Icons.checklist_outlined, activeIcon: Icons.checklist, label: 'Follow-ups', path: '/admin/follow-ups'),
    _NavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Analytics', path: '/admin/analytics'),
    _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Notifications', path: '/admin/notifications'),
    _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'Audit Logs', path: '/admin/audit-logs'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', path: '/admin/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;
    final currentPath = GoRouterState.of(context).matchedLocation;

    int selectedIndex = _navItems.indexWhere((item) =>
        currentPath.startsWith(item.path));
    if (selectedIndex < 0) selectedIndex = 0;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 240,
              color: AppTheme.surface,
              child: Column(
                children: [
                  // Brand header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('E',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Expert Tutors',
                            style: AppTheme.titleMedium
                                .copyWith(color: AppTheme.primaryGreen),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Nav items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final item = _navItems[index];
                        final selected = index == selectedIndex;
                        return _buildSidebarItem(
                          context,
                          item,
                          selected,
                        );
                      },
                    ),
                  ),

                  // Logout
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      leading: const Icon(Icons.logout,
                          size: 20, color: AppTheme.textTertiary),
                      title: Text('Sign Out',
                          style: AppTheme.bodyMedium
                              .copyWith(color: AppTheme.textSecondary)),
                      dense: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onTap: () async {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            const VerticalDivider(width: 1),
            // Main content
            Expanded(child: child),
          ],
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => context.go(_navItems[i].path),
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppTheme.surface,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('E',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(Icons.logout, size: 20),
                      tooltip: 'Sign Out',
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ),
                ),
              ),
              destinations: _navItems
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon, size: 20),
                        selectedIcon: Icon(item.activeIcon, size: 20),
                        label: Text(item.label,
                            style: const TextStyle(fontSize: 11)),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile — bottom nav with key items only
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.clamp(0, 4),
        onDestinationSelected: (i) {
          final paths = [
            '/admin/dashboard',
            '/admin/leads',
            '/admin/tutors',
            '/admin/analytics',
            '/admin/settings',
          ];
          context.go(paths[i]);
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.people_outline), label: 'Leads'),
          NavigationDestination(
              icon: Icon(Icons.school_outlined), label: 'Tutors'),
          NavigationDestination(
              icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, _NavItem item, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        leading: Icon(
          selected ? item.activeIcon : item.icon,
          size: 20,
          color: selected ? AppTheme.primaryGreen : AppTheme.textTertiary,
        ),
        title: Text(
          item.label,
          style: AppTheme.bodyMedium.copyWith(
            color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        dense: true,
        selected: selected,
        selectedTileColor: AppTheme.primaryGreen.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => context.go(item.path),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
