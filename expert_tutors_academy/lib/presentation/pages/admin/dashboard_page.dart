import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/services/lead_service.dart';
import '../../../data/services/operational_services.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLeads = ref.watch(activeLeadsProvider);
    final todaysDemos = ref.watch(todaysDemosProvider);
    final dueFollowUps = ref.watch(dueFollowUpsProvider);
    final activeTuitions = ref.watch(activeTuitionsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/admin/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeLeadsProvider);
          ref.invalidate(todaysDemosProvider);
          ref.invalidate(dueFollowUpsProvider);
          ref.invalidate(activeTuitionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Welcome ─────────────────────────────
              Text('Overview', style: AppTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Your agency at a glance',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ─── Metrics Grid ────────────────────────
              activeLeads.when(
                data: (leads) {
                  final newLeads =
                      leads.where((l) => l.status == 'NEW').length;
                  final matchedLeads =
                      leads.where((l) => l.status == 'MATCHED').length;
                  final assignedLeads = leads
                      .where((l) => l.status == 'ASSIGNED')
                      .length;

                  final metrics = [
                    MetricCard(
                      label: 'New Leads',
                      value: '$newLeads',
                      icon: Icons.fiber_new_outlined,
                      color: AppTheme.statusNew,
                      onTap: () => context.go('/admin/leads'),
                    ),
                    MetricCard(
                      label: 'Matched',
                      value: '$matchedLeads',
                      icon: Icons.link,
                      color: AppTheme.statusMatched,
                      onTap: () => context.go('/admin/leads'),
                    ),
                    MetricCard(
                      label: 'Assigned',
                      value: '$assignedLeads',
                      icon: Icons.assignment_ind_outlined,
                      color: AppTheme.statusAssigned,
                      onTap: () => context.go('/admin/assignments'),
                    ),
                    activeTuitions.when(
                      data: (tuitions) => MetricCard(
                        label: 'Active Tuitions',
                        value: '${tuitions.length}',
                        icon: Icons.auto_stories_outlined,
                        color: AppTheme.success,
                        onTap: () => context.go('/admin/tuitions'),
                      ),
                      loading: () => const MetricCard(
                        label: 'Active Tuitions',
                        value: '...',
                        icon: Icons.auto_stories_outlined,
                        color: AppTheme.success,
                      ),
                      error: (_, _) => const MetricCard(
                        label: 'Active Tuitions',
                        value: '-',
                        icon: Icons.auto_stories_outlined,
                        color: AppTheme.success,
                      ),
                    ),
                    todaysDemos.when(
                      data: (demos) => MetricCard(
                        label: 'Demos Today',
                        value: '${demos.length}',
                        icon: Icons.event_outlined,
                        color: AppTheme.info,
                        onTap: () => context.go('/admin/demos'),
                      ),
                      loading: () => const MetricCard(
                        label: 'Demos Today',
                        value: '...',
                        icon: Icons.event_outlined,
                        color: AppTheme.info,
                      ),
                      error: (_, _) => const MetricCard(
                        label: 'Demos Today',
                        value: '-',
                        icon: Icons.event_outlined,
                        color: AppTheme.info,
                      ),
                    ),
                    dueFollowUps.when(
                      data: (followUps) => MetricCard(
                        label: 'Follow-ups Due',
                        value: '${followUps.length}',
                        icon: Icons.checklist_outlined,
                        color: AppTheme.warning,
                        onTap: () => context.go('/admin/follow-ups'),
                      ),
                      loading: () => const MetricCard(
                        label: 'Follow-ups Due',
                        value: '...',
                        icon: Icons.checklist_outlined,
                        color: AppTheme.warning,
                      ),
                      error: (_, _) => const MetricCard(
                        label: 'Follow-ups Due',
                        value: '-',
                        icon: Icons.checklist_outlined,
                        color: AppTheme.warning,
                      ),
                    ),
                  ];

                  return _buildMetricsGrid(metrics, isDesktop);
                },
                loading: () => _buildMetricsGrid(
                  List.generate(
                    6,
                    (_) => const MetricCard(
                      label: 'Loading...',
                      value: '...',
                      icon: Icons.hourglass_empty,
                    ),
                  ),
                  isDesktop,
                ),
                error: (err, _) => ErrorState(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(activeLeadsProvider),
                ),
              ),

              const SizedBox(height: 32),

              // ─── Priority Leads ──────────────────────
              SectionHeader(
                title: 'Priority Leads',
                trailing: TextButton(
                  onPressed: () => context.go('/admin/leads'),
                  child: const Text('View All →'),
                ),
              ),
              activeLeads.when(
                data: (leads) {
                  // Sort: NEW first, then by createdAt desc
                  final priorityLeads = [...leads]
                    ..sort((a, b) {
                      if (a.status == 'NEW' && b.status != 'NEW') return -1;
                      if (b.status == 'NEW' && a.status != 'NEW') return 1;
                      return b.createdAt.compareTo(a.createdAt);
                    });

                  final displayLeads = priorityLeads.take(8).toList();

                  if (displayLeads.isEmpty) {
                    return const EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No active leads',
                      subtitle:
                          'New leads from parent enquiries will appear here.',
                    );
                  }

                  return _buildLeadsList(context, displayLeads, isDesktop);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => ErrorState(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(activeLeadsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(List<Widget> metrics, bool isDesktop) {
    if (isDesktop) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.0,
        children: metrics,
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: metrics,
    );
  }

  Widget _buildLeadsList(
      BuildContext context, List<LeadModel> leads, bool isDesktop) {
    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.6,
        ),
        itemCount: leads.length,
        itemBuilder: (context, index) =>
            _buildLeadCard(context, leads[index]),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          _buildLeadCard(context, leads[index]),
    );
  }

  Widget _buildLeadCard(BuildContext context, LeadModel lead) {
    return GestureDetector(
      onTap: () => context.go('/admin/leads/${lead.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: lead.isNew
                ? AppTheme.statusNew.withValues(alpha: 0.3)
                : AppTheme.border,
          ),
          boxShadow: AppTheme.elevationSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  lead.leadNumber.isNotEmpty ? lead.leadNumber : 'New Lead',
                  style: AppTheme.labelMedium
                      .copyWith(color: AppTheme.primaryGreen),
                ),
                const Spacer(),
                StatusBadge.leadStatus(lead.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${lead.studentClass} • ${lead.subjects.join(", ")}',
              style: AppTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: AppTheme.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    lead.location.displayText,
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (lead.matchCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${lead.matchCount} matches',
                      style: AppTheme.labelSmall
                          .copyWith(color: AppTheme.success),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  timeago.format(lead.createdAt),
                  style: AppTheme.bodySmall,
                ),
                const Spacer(),
                if (lead.budget != null)
                  Text(
                    '₹${lead.budget!.toStringAsFixed(0)}/mo',
                    style: AppTheme.labelSmall
                        .copyWith(color: AppTheme.accentGoldDark),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
