import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';

class DemosPage extends ConsumerWidget {
  const DemosPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysDemos = ref.watch(todaysDemosProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Demos')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Today\'s Demos'),
        todaysDemos.when(
          data: (demos) {
            if (demos.isEmpty) return const EmptyState(icon: Icons.event_outlined, title: 'No demos today');
            return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: demos.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _buildDemoCard(context, ref, demos[i]));
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(message: e.toString()),
        ),
        const SizedBox(height: 32),
        const SectionHeader(title: 'All Demos'),
        StreamBuilder(
          stream: ref.read(demoServiceProvider).streamDemos(),
          builder: (context, snapshot) {
            final allDemos = snapshot.data ?? [];
            if (allDemos.isEmpty) return const EmptyState(icon: Icons.event_outlined, title: 'No demos scheduled');
            return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: allDemos.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _buildDemoCard(context, ref, allDemos[i]));
          },
        ),
      ])),
    );
  }

  Widget _buildDemoCard(BuildContext context, WidgetRef ref, DemoModel demo) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: demo.isToday ? AppTheme.info.withValues(alpha: 0.3) : AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(demo.leadNumber, style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryGreen)),
          const Spacer(),
          StatusBadge(label: demo.status, color: demo.status == 'COMPLETED' ? AppTheme.success : demo.status == 'CANCELLED' ? AppTheme.error : AppTheme.info),
        ]),
        const SizedBox(height: 8),
        Text('${demo.studentName} with ${demo.tutorName}', style: AppTheme.titleMedium),
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.calendar_today, size: 14, color: AppTheme.textTertiary), const SizedBox(width: 4),
          Text(DateFormat('dd MMM yyyy').format(demo.date), style: AppTheme.bodySmall),
          const SizedBox(width: 12),
          Icon(Icons.access_time, size: 14, color: AppTheme.textTertiary), const SizedBox(width: 4),
          Text(demo.time, style: AppTheme.bodySmall),
          const SizedBox(width: 12),
          Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textTertiary), const SizedBox(width: 4),
          Expanded(child: Text(demo.location, style: AppTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        if (demo.status == 'SCHEDULED') ...[
          const SizedBox(height: 12),
          Row(children: [
            OutlinedButton(onPressed: () => ref.read(demoServiceProvider).updateDemoOutcome(demo.id, 'COMPLETED', 'Demo completed'), child: const Text('Mark Complete')),
            const SizedBox(width: 8),
            TextButton(onPressed: () => ref.read(demoServiceProvider).updateDemoOutcome(demo.id, 'NO_SHOW', null), child: const Text('No Show')),
          ]),
        ],
      ]),
    );
  }
}
