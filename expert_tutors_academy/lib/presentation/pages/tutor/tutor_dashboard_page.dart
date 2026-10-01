import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';
import '../../../data/services/auth_service.dart';

class TutorDashboardPage extends ConsumerWidget {
  const TutorDashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.go('/tutor/notifications')),
        IconButton(icon: const Icon(Icons.logout), onPressed: () async { await ref.read(authServiceProvider).signOut(); if (context.mounted) context.go('/login'); }),
        const SizedBox(width: 8),
      ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome!', style: AppTheme.headlineLarge),
        const SizedBox(height: 4),
        Text('Here\'s your activity overview.', style: AppTheme.bodyMedium),
        const SizedBox(height: 24),

        // Pending assignments
        const SectionHeader(title: 'Pending Assignments'),
        StreamBuilder(
          stream: ref.read(assignmentServiceProvider).streamPendingAssignments(user.uid),
          builder: (context, snapshot) {
            final assignments = snapshot.data ?? [];
            if (assignments.isEmpty) return const EmptyState(icon: Icons.inbox_outlined, title: 'No pending assignments');
            return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: assignments.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final a = assignments[i];
                return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.info.withValues(alpha: 0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a.leadNumber, style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryGreen)),
                    const SizedBox(height: 8),
                    if (a.matchScore != null) Row(children: [MatchScoreIndicator(score: a.matchScore!, size: 36), const SizedBox(width: 12), Text('Match Score', style: AppTheme.bodySmall)]),
                    const SizedBox(height: 12),
                    Row(children: [
                      ElevatedButton(onPressed: () async {
                        await ref.read(assignmentServiceProvider).updateAssignmentStatus(a.id, 'ACCEPTED', response: 'Accepted');
                        ref.read(tutorRepositoryProvider).incrementPerformanceCounter(user.uid, 'acceptedLeads');
                      }, child: const Text('Accept')),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: () async {
                        await ref.read(assignmentServiceProvider).updateAssignmentStatus(a.id, 'REJECTED', response: 'Declined');
                        ref.read(tutorRepositoryProvider).incrementPerformanceCounter(user.uid, 'rejectedLeads');
                      }, style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error), child: const Text('Decline')),
                    ]),
                  ]),
                );
              },
            );
          },
        ),
        const SizedBox(height: 32),

        // Active tuitions
        const SectionHeader(title: 'Active Tuitions'),
        StreamBuilder(
          stream: ref.read(tuitionServiceProvider).streamTutorTuitions(user.uid),
          builder: (context, snapshot) {
            final tuitions = (snapshot.data ?? []).where((t) => t.isActive).toList();
            if (tuitions.isEmpty) return const EmptyState(icon: Icons.auto_stories_outlined, title: 'No active tuitions');
            return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: tuitions.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final t = tuitions[i];
                return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Text(t.studentName, style: AppTheme.titleMedium), const Spacer(), StatusBadge(label: 'ACTIVE', color: AppTheme.success, filled: true)]),
                    const SizedBox(height: 4),
                    Text('${t.subject} — ${t.studentClass}', style: AppTheme.bodySmall),
                    Text('${t.location} • ₹${t.tutorPayout.toStringAsFixed(0)}/mo', style: AppTheme.bodySmall),
                  ]),
                );
              },
            );
          },
        ),
      ])),
    );
  }
}

// Import needed
import '../../../data/services/tutor_service.dart';
