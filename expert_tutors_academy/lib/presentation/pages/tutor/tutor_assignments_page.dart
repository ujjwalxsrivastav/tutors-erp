import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/tutor_service.dart';

class TutorAssignmentsPage extends ConsumerStatefulWidget {
  const TutorAssignmentsPage({super.key});

  @override
  ConsumerState<TutorAssignmentsPage> createState() => _TutorAssignmentsPageState();
}

class _TutorAssignmentsPageState extends ConsumerState<TutorAssignmentsPage> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Assignments'),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip('ALL', 'All'),
                const SizedBox(width: 8),
                _filterChip('PENDING', 'Pending'),
                const SizedBox(width: 8),
                _filterChip('ACCEPTED', 'Accepted'),
                const SizedBox(width: 8),
                _filterChip('REJECTED', 'Declined'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Assignment List
          Expanded(
            child: StreamBuilder<List<LeadAssignmentModel>>(
              stream: ref.read(assignmentServiceProvider).streamAssignmentsForTutor(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var list = snapshot.data ?? [];
                if (_selectedFilter != 'ALL') {
                  list = list.where((a) => a.status.toUpperCase() == _selectedFilter).toList();
                }

                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.assignment_outlined,
                    title: _selectedFilter == 'ALL'
                        ? 'No assignments yet'
                        : 'No ${_selectedFilter.toLowerCase()} assignments',
                    subtitle: 'New tutoring assignments will appear here once agency assigns them to you.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = list[i];
                    return _buildAssignmentCard(context, item, user.uid);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, LeadAssignmentModel item, String userId) {
    Color statusColor;
    if (item.isAccepted) {
      statusColor = AppTheme.success;
    } else if (item.isRejected) {
      statusColor = AppTheme.error;
    } else {
      statusColor = AppTheme.warning;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: item.isPending ? AppTheme.info.withValues(alpha: 0.4) : AppTheme.border,
        ),
        boxShadow: item.isPending
            ? [
                BoxShadow(
                  color: AppTheme.info.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.leadNumber,
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              StatusBadge(label: item.status, color: statusColor, filled: true),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.assignmentType} Assignment',
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assigned by ${item.assignedByName} • ${timeago.format(item.assignedAt)}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (item.matchScore != null)
                MatchScoreIndicator(score: item.matchScore!, size: 40),
            ],
          ),
          if (item.assignmentNotes != null && item.assignmentNotes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.assignmentNotes!,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept Assignment'),
                    onPressed: () async {
                      await ref.read(assignmentServiceProvider).updateAssignmentStatus(
                            item.id,
                            'ACCEPTED',
                            response: 'Accepted by tutor',
                          );
                      await ref
                          .read(tutorRepositoryProvider)
                          .incrementPerformanceCounter(userId, 'acceptedLeads');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assignment accepted successfully!')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Decline'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
                  onPressed: () => _showDeclineDialog(context, item, userId),
                ),
              ],
            ),
          ],
          if (item.tutorResponse != null && item.tutorResponse!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Response: ${item.tutorResponse}',
              style: AppTheme.bodySmall.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, LeadAssignmentModel item, String userId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to decline ${item.leadNumber}?', style: AppTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for declining',
                hintText: 'e.g., Timing conflict, location too far',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final reason = reasonCtrl.text.trim().isNotEmpty
                  ? reasonCtrl.text.trim()
                  : 'Declined by tutor';
              await ref.read(assignmentServiceProvider).updateAssignmentStatus(
                    item.id,
                    'REJECTED',
                    response: reason,
                  );
              await ref
                  .read(tutorRepositoryProvider)
                  .incrementPerformanceCounter(userId, 'rejectedLeads');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assignment declined')),
                );
              }
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}
