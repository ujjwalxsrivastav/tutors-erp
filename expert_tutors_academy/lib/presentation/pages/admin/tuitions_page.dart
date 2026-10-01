import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';

class TuitionsPage extends ConsumerWidget {
  const TuitionsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tuitions = ref.watch(allTuitionsProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Tuitions')),
      body: tuitions.when(
        data: (list) {
          if (list.isEmpty) return const EmptyState(icon: Icons.auto_stories_outlined, title: 'No tuitions yet', subtitle: 'Tuitions will appear here when leads are converted.');
          return ListView.separated(padding: const EdgeInsets.all(16), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final t = list[i];
              return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text(t.leadNumber, style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryGreen)), const Spacer(), StatusBadge(label: t.status, color: t.isActive ? AppTheme.success : AppTheme.textTertiary)]),
                  const SizedBox(height: 8),
                  Text('${t.studentName} — ${t.subject}', style: AppTheme.titleMedium),
                  Text('${t.studentClass} • Tutor: ${t.tutorName}', style: AppTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('₹${t.monthlyFee.toStringAsFixed(0)}/mo', style: AppTheme.titleMedium.copyWith(color: AppTheme.accentGoldDark)),
                    const SizedBox(width: 12),
                    Text('Commission: ₹${t.agencyCommission.toStringAsFixed(0)}', style: AppTheme.bodySmall),
                    const Spacer(),
                    if (t.isActive) PopupMenuButton<String>(
                      onSelected: (v) => ref.read(tuitionServiceProvider).updateTuitionStatus(t.id, v),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'PAUSED', child: Text('Pause')),
                        const PopupMenuItem(value: 'COMPLETED', child: Text('Complete')),
                        const PopupMenuItem(value: 'CANCELLED', child: Text('Cancel')),
                      ],
                    ),
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
