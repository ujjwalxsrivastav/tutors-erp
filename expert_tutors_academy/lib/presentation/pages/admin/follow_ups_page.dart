import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';

class FollowUpsPage extends ConsumerWidget {
  const FollowUpsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followUps = ref.watch(dueFollowUpsProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Follow-ups')),
      body: followUps.when(
        data: (list) {
          if (list.isEmpty) return const EmptyState(icon: Icons.checklist_outlined, title: 'No follow-ups due', subtitle: 'All caught up! Follow-ups will appear when they\'re due.');
          return ListView.separated(padding: const EdgeInsets.all(16), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final f = list[i];
              return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
                color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: f.isOverdue ? AppTheme.error.withValues(alpha: 0.3) : AppTheme.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    if (f.isOverdue) ...[Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.errorLight, borderRadius: BorderRadius.circular(12)), child: Text('OVERDUE', style: AppTheme.labelSmall.copyWith(color: AppTheme.error))), const SizedBox(width: 8)],
                    Text(f.entityNumber ?? f.entityId, style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryGreen)),
                    const Spacer(),
                    Text(DateFormat('dd MMM').format(f.dueDate), style: AppTheme.bodySmall),
                  ]),
                  const SizedBox(height: 8),
                  Text(f.type.replaceAll('_', ' '), style: AppTheme.titleMedium),
                  if (f.notes != null) ...[const SizedBox(height: 4), Text(f.notes!, style: AppTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis)],
                  const SizedBox(height: 12),
                  Row(children: [
                    ElevatedButton.icon(onPressed: () => ref.read(followUpServiceProvider).completeFollowUp(f.id), icon: const Icon(Icons.check, size: 16), label: const Text('Done'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () => ref.read(followUpServiceProvider).skipFollowUp(f.id), child: const Text('Skip')),
                  ]),
                ]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
      ),
    );
  }
}
