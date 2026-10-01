import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/models/models.dart';
import '../../../data/services/lead_service.dart';
import '../../../data/services/operational_services.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(leadsByStatusProvider(null));
    final tuitions = ref.watch(allTuitionsProvider);
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(padding: EdgeInsets.all(isDesktop ? 24 : 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Analytics Overview', style: AppTheme.headlineLarge),
        const SizedBox(height: 24),

        // Lead Funnel
        leads.when(
          data: (allLeads) {
            final statusCounts = <String, int>{};
            for (final l in allLeads) { statusCounts[l.status] = (statusCounts[l.status] ?? 0) + 1; }
            final total = allLeads.length;
            final matched = (statusCounts['MATCHED'] ?? 0) + (statusCounts['ASSIGNED'] ?? 0) + (statusCounts['DEMO_SCHEDULED'] ?? 0) + (statusCounts['CONVERTED'] ?? 0);
            final assigned = (statusCounts['ASSIGNED'] ?? 0) + (statusCounts['DEMO_SCHEDULED'] ?? 0) + (statusCounts['CONVERTED'] ?? 0);
            final demo = (statusCounts['DEMO_SCHEDULED'] ?? 0) + (statusCounts['CONVERTED'] ?? 0);
            final converted = statusCounts['CONVERTED'] ?? 0;

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Lead Funnel', style: AppTheme.titleLarge),
                  const SizedBox(height: 20),
                  _funnelRow('New', total, total, AppTheme.statusNew),
                  _funnelRow('Matched', matched, total, AppTheme.statusMatched),
                  _funnelRow('Assigned', assigned, total, AppTheme.statusAssigned),
                  _funnelRow('Demo', demo, total, AppTheme.info),
                  _funnelRow('Converted', converted, total, AppTheme.success),
                ]),
              ),
              const SizedBox(height: 24),

              // Status breakdown
              isDesktop
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _buildStatusChart(statusCounts)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildMetrics(allLeads, ref)),
                  ])
                : Column(children: [
                    _buildStatusChart(statusCounts),
                    const SizedBox(height: 24),
                    _buildMetrics(allLeads, ref),
                  ]),
            ]);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(message: e.toString()),
        ),
      ])),
    );
  }

  Widget _funnelRow(String label, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text(label, style: AppTheme.labelLarge), const Spacer(), Text('$count', style: AppTheme.titleMedium), const SizedBox(width: 8), Text('${(pct * 100).toStringAsFixed(0)}%', style: AppTheme.bodySmall)]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct, backgroundColor: AppTheme.surfaceVariant, color: color, minHeight: 8)),
    ]));
  }

  Widget _buildStatusChart(Map<String, int> statusCounts) {
    final entries = statusCounts.entries.toList();
    if (entries.isEmpty) return const SizedBox();

    return Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Lead Status Distribution', style: AppTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(height: 200, child: PieChart(PieChartData(
          sections: entries.map((e) => PieChartSectionData(
            value: e.value.toDouble(), title: '${e.value}',
            color: AppTheme.getLeadStatusColor(e.key),
            radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          )).toList(),
          sectionsSpace: 2, centerSpaceRadius: 40,
        ))),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 8, children: entries.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.getLeadStatusColor(e.key), borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6), Text('${e.key.replaceAll("_", " ")} (${e.value})', style: AppTheme.bodySmall),
        ])).toList()),
      ]),
    );
  }

  Widget _buildMetrics(List<LeadModel> leads, WidgetRef ref) {
    final total = leads.length;
    final converted = leads.where((l) => l.status == 'CONVERTED').length;
    final convRate = total > 0 ? (converted / total * 100) : 0.0;

    return Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Key Metrics', style: AppTheme.titleLarge),
        const SizedBox(height: 16),
        _metricRow('Total Leads', '$total'),
        _metricRow('Converted', '$converted'),
        _metricRow('Conversion Rate', '${convRate.toStringAsFixed(1)}%'),
        _metricRow('Rejected', '${leads.where((l) => l.status == "REJECTED").length}'),
        _metricRow('Cancelled', '${leads.where((l) => l.status == "CANCELLED").length}'),
        _metricRow('No Response', '${leads.where((l) => l.status == "NO_RESPONSE").length}'),
      ]),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTheme.bodyMedium),
      Text(value, style: AppTheme.titleMedium),
    ]));
  }
}
