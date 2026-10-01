import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/services/tutor_service.dart';

class TutorDetailPage extends ConsumerWidget {
  final String tutorId;
  const TutorDetailPage({super.key, required this.tutorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: ref.read(tutorRepositoryProvider).streamTutor(tutorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final tutor = snapshot.data;
        if (tutor == null) return Scaffold(appBar: AppBar(title: const Text('Tutor')), body: const EmptyState(icon: Icons.person_off_outlined, title: 'Tutor not found'));

        final isDesktop = MediaQuery.of(context).size.width > 1000;

        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          appBar: AppBar(
            title: Text(tutor.name),
            actions: [
              if (tutor.isPending) ...[
                ElevatedButton(onPressed: () => _verify(ref, tutorId, 'VERIFIED'), child: const Text('Verify')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => _verify(ref, tutorId, 'REJECTED'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error), child: const Text('Reject')),
              ],
              if (tutor.isVerified) OutlinedButton(onPressed: () => _verify(ref, tutorId, 'SUSPENDED'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.warning), child: const Text('Suspend')),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: isDesktop
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 3, child: _buildProfile(tutor)),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildPerformance(tutor)),
                  ])
                : Column(children: [_buildProfile(tutor), const SizedBox(height: 24), _buildPerformance(tutor)]),
          ),
        );
      },
    );
  }

  Widget _buildProfile(TutorModel tutor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 32, backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1), child: Text(tutor.name.isNotEmpty ? tutor.name[0] : '?', style: AppTheme.displaySmall.copyWith(color: AppTheme.primaryGreen))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(tutor.name, style: AppTheme.headlineLarge), if (tutor.isVerified) ...[const SizedBox(width: 8), const Icon(Icons.verified, color: AppTheme.success)]]),
              const SizedBox(height: 4),
              StatusBadge.verification(tutor.verificationStatus),
            ])),
          ]),
          const SizedBox(height: 16),
          InfoRow(label: 'Email', value: tutor.email, icon: Icons.email_outlined),
          InfoRow(label: 'Phone', value: tutor.phone, icon: Icons.phone_outlined),
          InfoRow(label: 'Gender', value: tutor.gender, icon: Icons.person_outline),
          InfoRow(label: 'Qualification', value: '${tutor.qualification}${tutor.institution != null ? " — ${tutor.institution}" : ""}', icon: Icons.school_outlined),
          InfoRow(label: 'Experience', value: '${tutor.teachingExperience} years', icon: Icons.work_outline),
          InfoRow(label: 'Subjects', value: tutor.subjects.join(', '), icon: Icons.book_outlined),
          InfoRow(label: 'Classes', value: tutor.classesTaught.join(', '), icon: Icons.class_outlined),
          InfoRow(label: 'Mode', value: tutor.teachingMode, icon: Icons.laptop_outlined),
          InfoRow(label: 'Location', value: tutor.preferredLocations.join(', '), icon: Icons.location_on_outlined),
          InfoRow(label: 'Fee', value: '₹${tutor.expectedFee.toStringAsFixed(0)}/month', icon: Icons.currency_rupee),
          InfoRow(label: 'Languages', value: tutor.languages.join(', '), icon: Icons.language),
          if (tutor.aboutTutor != null) InfoRow(label: 'About', value: tutor.aboutTutor!, icon: Icons.info_outline),
        ]),
      ),
    ]);
  }

  Widget _buildPerformance(TutorModel tutor) {
    final p = tutor.performance;
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Performance', style: AppTheme.titleLarge),
        const SizedBox(height: 16),
        _perfRow('Total Leads', '${p.totalLeads}'),
        _perfRow('Accepted', '${p.acceptedLeads}'),
        _perfRow('Rejected', '${p.rejectedLeads}'),
        _perfRow('Converted', '${p.convertedLeads}'),
        _perfRow('Active Tuitions', '${p.activeTuitions}'),
        _perfRow('Completed', '${p.completedTuitions}'),
        _perfRow('Cancelled', '${p.cancelledTuitions}'),
        const Divider(height: 24),
        _perfRow('Conversion Rate', '${p.conversionRate.toStringAsFixed(1)}%', color: AppTheme.success),
        _perfRow('Acceptance Rate', '${p.acceptanceRate.toStringAsFixed(1)}%'),
        _perfRow('Cancellation Rate', '${p.cancellationRate.toStringAsFixed(1)}%', color: p.cancellationRate > 20 ? AppTheme.error : null),
        _perfRow('Response Rate', '${p.responseRate.toStringAsFixed(1)}%'),
        _perfRow('Rating', tutor.rating > 0 ? '${tutor.rating.toStringAsFixed(1)} / 5.0' : 'No ratings'),
        _perfRow('Complaints', '${p.parentComplaints}'),
      ]),
    );
  }

  Widget _perfRow(String label, String value, {Color? color}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTheme.bodyMedium),
      Text(value, style: AppTheme.titleMedium.copyWith(color: color)),
    ]));
  }

  Future<void> _verify(WidgetRef ref, String tutorId, String status) async {
    await ref.read(tutorRepositoryProvider).updateVerification(tutorId, status, 'admin');
  }
}
