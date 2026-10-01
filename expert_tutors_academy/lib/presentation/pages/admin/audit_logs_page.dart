import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';

class AuditLogsPage extends ConsumerWidget {
  const AuditLogsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(auditLogsProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Audit Logs')),
      body: logs.when(
        data: (list) {
          if (list.isEmpty) return const EmptyState(icon: Icons.history, title: 'No audit logs', subtitle: 'System activities will be recorded here.');
          return ListView.separated(padding: const EdgeInsets.all(16), itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final log = list[i];
              return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusSm), border: Border.all(color: AppTheme.borderLight)),
                child: Row(children: [
                  Icon(_getActionIcon(log.action), size: 18, color: AppTheme.textTertiary),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${log.actorName} ${log.action.toLowerCase().replaceAll("_", " ")}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary)),
                    Text('${log.entityType} ${log.entityId} • ${timeago.format(log.timestamp)}', style: AppTheme.bodySmall),
                  ])),
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
  IconData _getActionIcon(String action) {
    if (action.contains('CREATE')) return Icons.add_circle_outline;
    if (action.contains('ASSIGN')) return Icons.assignment_ind;
    if (action.contains('VERIFY')) return Icons.verified;
    if (action.contains('REJECT')) return Icons.cancel_outlined;
    if (action.contains('UPDATE')) return Icons.edit_outlined;
    return Icons.info_outline;
  }
}
