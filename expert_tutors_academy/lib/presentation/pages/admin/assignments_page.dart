import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/services/operational_services.dart';

class AssignmentsPage extends ConsumerWidget {
  const AssignmentsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Assignments')),
      body: StreamBuilder(
        stream: ref.read(assignmentServiceProvider).streamAllAssignments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final assignments = snapshot.data ?? [];
          if (assignments.isEmpty) return const EmptyState(icon: Icons.assignment_outlined, title: 'No assignments yet', subtitle: 'Assignments will appear here when tutors are assigned to leads.');
          return ListView.separated(padding: const EdgeInsets.all(16), itemCount: assignments.length, separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = assignments[i];
              return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Text(a.leadNumber, style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryGreen)), const SizedBox(width: 8), StatusBadge(label: a.status, color: a.isAccepted ? AppTheme.success : a.isRejected ? AppTheme.error : AppTheme.warning)]),
                    const SizedBox(height: 6),
                    Text('Tutor: ${a.tutorName}', style: AppTheme.titleMedium),
                    Text('Assigned by ${a.assignedByName} • ${a.assignmentType}', style: AppTheme.bodySmall),
                    Text(timeago.format(a.assignedAt), style: AppTheme.bodySmall),
                  ])),
                  if (a.matchScore != null) MatchScoreIndicator(score: a.matchScore!, size: 40),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
