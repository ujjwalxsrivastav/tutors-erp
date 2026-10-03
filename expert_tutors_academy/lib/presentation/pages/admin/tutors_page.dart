import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/services/tutor_service.dart';

class TutorsPage extends ConsumerStatefulWidget {
  const TutorsPage({super.key});
  @override ConsumerState<TutorsPage> createState() => _TutorsPageState();
}

class _TutorsPageState extends ConsumerState<TutorsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  @override void initState() { super.initState(); _tabCtrl = TabController(length: 4, vsync: this); }
  @override void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Verified', 'Pending', 'Rejected'];
    final statuses = [null, 'VERIFIED', 'PENDING', 'REJECTED'];
    final currentStatus = statuses[_tabCtrl.index];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Tutors'),
        bottom: TabBar(controller: _tabCtrl, tabs: tabs.map((t) => Tab(text: t)).toList(), onTap: (_) => setState(() {})),
      ),
      body: StreamBuilder(
        stream: ref.read(tutorRepositoryProvider).streamTutors(verificationStatus: currentStatus),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final tutors = snapshot.data ?? [];
          if (tutors.isEmpty) return const EmptyState(icon: Icons.school_outlined, title: 'No tutors found');

          return ListView.separated(
            padding: const EdgeInsets.all(16), itemCount: tutors.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _buildTutorCard(context, ref, tutors[i]),
          );
        },
      ),
    );
  }

  Widget _buildTutorCard(BuildContext context, WidgetRef ref, TutorModel tutor) {
    return GestureDetector(
      onTap: () => context.go('/admin/tutors/${tutor.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
        child: Row(children: [
          CircleAvatar(radius: 24, backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
            child: Text(tutor.name.isNotEmpty ? tutor.name[0].toUpperCase() : '?', style: AppTheme.headlineMedium.copyWith(color: AppTheme.primaryGreen))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tutor.name, style: AppTheme.titleMedium),
              if (tutor.isVerified) ...[const SizedBox(width: 6), const Icon(Icons.verified, size: 16, color: AppTheme.success)],
              const SizedBox(width: 8),
              StatusBadge.verification(tutor.verificationStatus),
            ]),
            const SizedBox(height: 4),
            Text('${tutor.qualification} • ${tutor.teachingExperience} yr exp', style: AppTheme.bodySmall),
            Text(tutor.subjects.take(3).join(', '), style: AppTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${tutor.expectedFee.toStringAsFixed(0)}', style: AppTheme.titleMedium.copyWith(color: AppTheme.accentGoldDark)),
            const SizedBox(height: 4),
            if (tutor.rating > 0) Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 14, color: AppTheme.accentGold), const SizedBox(width: 2), Text(tutor.rating.toStringAsFixed(1), style: AppTheme.bodySmall)]),
          ]),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 20),
        ]),
      ),
    );
  }
}
