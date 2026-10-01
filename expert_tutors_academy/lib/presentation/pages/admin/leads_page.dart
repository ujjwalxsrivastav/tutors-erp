import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/services/lead_service.dart';

class LeadsPage extends ConsumerStatefulWidget {
  const LeadsPage({super.key});

  @override
  ConsumerState<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends ConsumerState<LeadsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _statusFilter;
  String _searchQuery = '';

  final _tabs = const [
    Tab(text: 'All'),
    Tab(text: 'New'),
    Tab(text: 'Matched'),
    Tab(text: 'Assigned'),
    Tab(text: 'Demo'),
    Tab(text: 'Converted'),
    Tab(text: 'Closed'),
  ];

  final _statusMap = const [
    null, 'NEW', 'MATCHED', 'ASSIGNED', 'DEMO_SCHEDULED', 'CONVERTED', null
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _statusFilter = _statusMap[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadsByStatusProvider(_statusFilter));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Leads'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs,
          tabAlignment: TabAlignment.start,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search dialog
              showSearch(
                context: context,
                delegate: _LeadSearchDelegate(ref),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: leadsAsync.when(
        data: (leads) {
          if (leads.isEmpty) {
            return EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No leads found',
              subtitle: _statusFilter != null
                  ? 'No leads with status "${_statusFilter!.replaceAll("_", " ")}"'
                  : 'New leads from enquiries will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: leads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _buildLeadCard(context, leads[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(leadsByStatusProvider(_statusFilter)),
        ),
      ),
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
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lead.leadNumber.isNotEmpty
                            ? lead.leadNumber
                            : 'Pending',
                        style: AppTheme.labelMedium
                            .copyWith(color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge.leadStatus(lead.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${lead.studentName} — ${lead.studentClass}',
                    style: AppTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lead.subjects.join(", ")} • ${lead.location.displayText}',
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        timeago.format(lead.createdAt),
                        style: AppTheme.bodySmall,
                      ),
                      if (lead.matchCount > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.people_outline,
                            size: 14, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${lead.matchCount} matches',
                          style: AppTheme.bodySmall
                              .copyWith(color: AppTheme.success),
                        ),
                      ],
                      if (lead.assignedTutorName != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.person_outline,
                            size: 14, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          lead.assignedTutorName!,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (lead.budget != null)
                  Text(
                    '₹${lead.budget!.toStringAsFixed(0)}',
                    style: AppTheme.titleMedium
                        .copyWith(color: AppTheme.accentGoldDark),
                  ),
                const SizedBox(height: 8),
                if (lead.bestMatchScore != null)
                  MatchScoreIndicator(
                      score: lead.bestMatchScore!, size: 36),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppTheme.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LeadSearchDelegate extends SearchDelegate<String?> {
  final WidgetRef ref;

  _LeadSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.length < 2) {
      return const Center(
        child: Text('Type at least 2 characters to search'),
      );
    }

    return FutureBuilder(
      future: ref.read(leadRepositoryProvider).searchLeads(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final leads = snapshot.data ?? [];
        if (leads.isEmpty) {
          return Center(child: Text('No leads found for "$query"'));
        }
        return ListView.builder(
          itemCount: leads.length,
          itemBuilder: (context, index) {
            final lead = leads[index];
            return ListTile(
              title: Text('${lead.leadNumber} — ${lead.studentName}'),
              subtitle: Text(
                  '${lead.studentClass} • ${lead.subjects.join(", ")}'),
              trailing: StatusBadge.leadStatus(lead.status),
              onTap: () {
                close(context, lead.id);
                context.go('/admin/leads/${lead.id}');
              },
            );
          },
        );
      },
    );
  }
}
