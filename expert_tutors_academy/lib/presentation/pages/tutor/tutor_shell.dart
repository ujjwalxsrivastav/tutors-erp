import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TutorShell extends ConsumerWidget {
  final Widget child;
  const TutorShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final items = [
      ('/tutor/dashboard', Icons.dashboard_outlined, 'Home'),
      ('/tutor/leads', Icons.people_outline, 'Leads'),
      ('/tutor/assignments', Icons.assignment_outlined, 'Assigned'),
      ('/tutor/tuitions', Icons.auto_stories_outlined, 'Tuitions'),
      ('/tutor/profile', Icons.person_outline, 'Profile'),
    ];
    int selected = items.indexWhere((i) => currentPath.startsWith(i.$1));
    if (selected < 0) selected = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => context.go(items[i].$1),
        destinations: items.map((i) => NavigationDestination(icon: Icon(i.$2), label: i.$3)).toList(),
      ),
    );
  }
}
