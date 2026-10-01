import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';
import '../../../data/services/auth_service.dart';

class TutorLeadsPage extends ConsumerWidget {
  const TutorLeadsPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('My Leads')),
      body: StreamBuilder(
        stream: ref.read(assignmentServiceProvider).streamAssignmentsForTutor(user.uid),
        builder: (context, snapshot) {
          final assignments = snapshot.data ?? [];
          if (assignments.isEmpty) return const EmptyState(icon: Icons.people_outline, title: 'No leads yet', subtitle: 'New tuition opportunities will appear here.');
          return ListView.separated(padding: const EdgeInsets.all(16), itemCount: assignments.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final a = assignments[i];
              return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text(a.leadNumber, style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryGreen)), const Spacer(), StatusBadge(label: a.status, color: a.isAccepted ? AppTheme.success : a.isRejected ? AppTheme.error : AppTheme.warning)]),
                  const SizedBox(height: 8),
                  Text('${a.assignmentType} Assignment', style: AppTheme.titleMedium),
                  if (a.matchScore != null) Text('Match: ${a.matchScore!.toStringAsFixed(0)}%', style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryGreen)),
                  if (a.isPending) ...[const SizedBox(height: 12), Row(children: [
                    ElevatedButton(onPressed: () => ref.read(assignmentServiceProvider).updateAssignmentStatus(a.id, 'ACCEPTED', response: 'Accepted'), child: const Text('Accept')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () => ref.read(assignmentServiceProvider).updateAssignmentStatus(a.id, 'REJECTED', response: 'Declined'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error), child: const Text('Decline')),
                  ])],
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
