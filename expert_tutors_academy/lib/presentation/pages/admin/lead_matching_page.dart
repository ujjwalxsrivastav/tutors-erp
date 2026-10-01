import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/models/models.dart';
import '../../../data/services/lead_service.dart';
import '../../../data/services/matching_engine.dart';
import '../../../data/services/operational_services.dart';
import '../../../data/services/auth_service.dart';

class LeadMatchingPage extends ConsumerStatefulWidget {
  final String leadId;

  const LeadMatchingPage({super.key, required this.leadId});

  @override
  ConsumerState<LeadMatchingPage> createState() => _LeadMatchingPageState();
}

class _LeadMatchingPageState extends ConsumerState<LeadMatchingPage> {
  List<TutorMatchResult>? _matches;
  bool _isLoading = true;
  String? _error;
  LeadModel? _lead;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final leadRepo = ref.read(leadRepositoryProvider);
      final lead = await leadRepo.getLead(widget.leadId);

      if (lead == null) {
        setState(() {
          _error = 'Lead not found';
          _isLoading = false;
        });
        return;
      }

      final matchingEngine = ref.read(matchingEngineProvider);
      final matches = await matchingEngine.matchTutorsForLead(lead);

      // Update lead with match results
      if (matches.isNotEmpty) {
        await leadRepo.updateLeadMatches(
          lead.id,
          matches.length,
          matches.first.matchScore,
        );
      }

      setState(() {
        _lead = lead;
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tutor Matching')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tutor Matching')),
        body: ErrorState(message: _error!, onRetry: _loadData),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
            'Matching — ${_lead?.leadNumber ?? ''}'),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Re-match'),
            onPressed: _loadData,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Lead info
                SizedBox(
                  width: 360,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildLeadInfo(),
                  ),
                ),
                const VerticalDivider(width: 1),
                // Right: Matched tutors
                Expanded(
                  child: _buildMatchResults(),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildLeadInfo(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildMatchResults(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLeadInfo() {
    final lead = _lead!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Lead Requirement', style: AppTheme.titleLarge),
              const Spacer(),
              StatusBadge.leadStatus(lead.status),
            ],
          ),
          const SizedBox(height: 16),
          InfoRow(
            label: 'Student',
            value: lead.studentName,
            icon: Icons.school_outlined,
          ),
          InfoRow(
            label: 'Class',
            value: lead.studentClass,
            icon: Icons.class_outlined,
          ),
          InfoRow(
            label: 'Subjects',
            value: lead.subjects.join(', '),
            icon: Icons.book_outlined,
          ),
          InfoRow(
            label: 'Location',
            value: lead.location.displayText,
            icon: Icons.location_on_outlined,
          ),
          InfoRow(
            label: 'Mode',
            value: lead.preferredMode,
            icon: Icons.laptop_outlined,
          ),
          if (lead.preferredTiming != null)
            InfoRow(
              label: 'Timing',
              value: lead.preferredTiming!,
              icon: Icons.access_time,
            ),
          if (lead.budget != null)
            InfoRow(
              label: 'Budget',
              value: '₹${lead.budget!.toStringAsFixed(0)}/mo',
              icon: Icons.currency_rupee,
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(Icons.people_outline,
                    size: 18, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  '${_matches?.length ?? 0} tutors matched',
                  style: AppTheme.titleMedium
                      .copyWith(color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchResults() {
    if (_matches == null || _matches!.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No matching tutors found',
        subtitle:
            'Try adjusting the requirements or adding more verified tutors.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _matches!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildMatchCard(_matches![index]),
    );
  }

  Widget _buildMatchCard(TutorMatchResult match) {
    final tutor = match.tutor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: match.matchScore >= 80
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.border,
        ),
        boxShadow: AppTheme.elevationSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    AppTheme.primaryGreen.withValues(alpha: 0.1),
                backgroundImage: tutor.photoUrl != null
                    ? NetworkImage(tutor.photoUrl!)
                    : null,
                child: tutor.photoUrl == null
                    ? Text(
                        tutor.name.isNotEmpty
                            ? tutor.name[0].toUpperCase()
                            : '?',
                        style: AppTheme.headlineMedium
                            .copyWith(color: AppTheme.primaryGreen),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(tutor.name, style: AppTheme.titleLarge),
                        if (tutor.verificationStatus == 'VERIFIED') ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified,
                              size: 16, color: AppTheme.success),
                        ],
                      ],
                    ),
                    Text(
                      '${tutor.qualification} • ${tutor.teachingExperience} yr exp',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              MatchScoreIndicator(score: match.matchScore, size: 52),
            ],
          ),
          const SizedBox(height: 12),

          // Details row
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildChip(Icons.location_on_outlined,
                  tutor.preferredLocations.take(2).join(', ')),
              _buildChip(Icons.currency_rupee,
                  '₹${tutor.expectedFee.toStringAsFixed(0)}/mo'),
              _buildChip(Icons.star_outline,
                  tutor.rating > 0 ? '${tutor.rating.toStringAsFixed(1)}' : 'New'),
              _buildChip(Icons.laptop_outlined, tutor.teachingMode),
            ],
          ),
          const SizedBox(height: 12),

          // Match reasons
          if (match.matchReasons.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: match.matchReasons.take(5).map((reason) {
                return Text(
                  reason,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.success,
                    fontSize: 11,
                  ),
                );
              }).toList(),
            ),
          ],

          // Conflicts
          if (match.potentialConflicts.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: match.potentialConflicts.map((conflict) {
                return Text(
                  '⚠ $conflict',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.warning,
                    fontSize: 11,
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              OutlinedButton(
                onPressed: () =>
                    context.go('/admin/tutors/${match.tutorId}'),
                child: const Text('View Profile'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _assignTutor(match),
                child: const Text('Assign'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Contact'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }

  Future<void> _assignTutor(TutorMatchResult match) async {
    final lead = _lead!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Tutor'),
        content: Text(
            'Assign ${match.tutor.name} to ${lead.studentName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Create assignment record
      final assignmentService = ref.read(assignmentServiceProvider);
      await assignmentService.createAssignment(
        LeadAssignmentModel(
          id: '',
          leadId: lead.id,
          leadNumber: lead.leadNumber,
          tutorId: match.tutorId,
          tutorName: match.tutor.name,
          assignedBy: ref.read(authStateProvider).value?.uid ?? '',
          assignedByName: 'Agent',
          assignedAt: DateTime.now(),
          assignmentType: 'RECOMMENDED',
          matchScore: match.matchScore,
          createdAt: DateTime.now(),
        ),
      );

      // Update lead
      final leadRepo = ref.read(leadRepositoryProvider);
      await leadRepo.assignTutorToLead(
        lead.id,
        match.tutorId,
        match.tutor.name,
        ref.read(authStateProvider).value?.uid ?? '',
        'Agent',
      );

      // Update tutor performance
      final tutorService = ref.read(tutorRepositoryProvider);
      await tutorService.incrementPerformanceCounter(
          match.tutorId, 'totalLeads');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${match.tutor.name} assigned to this lead'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.go('/admin/leads/${lead.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
