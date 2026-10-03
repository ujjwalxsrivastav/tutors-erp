import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/tutor_service.dart';

class TutorProfilePage extends ConsumerStatefulWidget {
  const TutorProfilePage({super.key});

  @override
  ConsumerState<TutorProfilePage> createState() => _TutorProfilePageState();
}

class _TutorProfilePageState extends ConsumerState<TutorProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out')),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/tutor/login');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<TutorModel?>(
        future: ref.read(tutorRepositoryProvider).getTutorByUserId(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tutor = snapshot.data;
          if (tutor == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off_outlined, size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  Text('Tutor profile not found', style: AppTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Please complete your registration first.', style: AppTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/register-tutor'),
                    child: const Text('Complete Registration'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        child: Text(
                          tutor.name.isNotEmpty ? tutor.name[0].toUpperCase() : 'T',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tutor.name, style: AppTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text(tutor.email, style: AppTheme.bodySmall),
                            Text(tutor.phone, style: AppTheme.bodySmall),
                            const SizedBox(height: 8),
                            StatusBadge(
                              label: tutor.verificationStatus,
                              color: tutor.isVerified
                                  ? AppTheme.success
                                  : tutor.verificationStatus == 'PENDING'
                                      ? AppTheme.warning
                                      : AppTheme.error,
                              filled: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Academic & Professional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Academic & Experience'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.school_outlined, 'Qualification', tutor.qualification),
                      if (tutor.institution != null && tutor.institution!.isNotEmpty)
                        _infoRow(Icons.account_balance_outlined, 'Institution', tutor.institution!),
                      _infoRow(
                        Icons.work_outline,
                        'Experience',
                        '${tutor.teachingExperience} years',
                      ),
                      _infoRow(Icons.cast_for_education, 'Mode', tutor.teachingMode),
                      _infoRow(
                        Icons.payments_outlined,
                        'Expected Fee',
                        '₹${tutor.expectedFee.toStringAsFixed(0)} / month',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subjects & Classes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Subjects & Classes'),
                      const SizedBox(height: 12),
                      Text('Subjects', style: AppTheme.labelMedium),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: tutor.subjects
                            .map((s) => Chip(
                                  label: Text(s),
                                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                  labelStyle: TextStyle(color: AppTheme.primaryGreen),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Text('Classes Taught', style: AppTheme.labelMedium),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: tutor.classesTaught
                            .map((c) => Chip(
                                  label: Text(c),
                                  backgroundColor: AppTheme.surfaceVariant,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Preferred Locations
                if (tutor.preferredLocations.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Service Locations'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: tutor.preferredLocations
                              .map((loc) => Chip(
                                    avatar: const Icon(Icons.location_on, size: 16),
                                    label: Text(loc),
                                  ))
                              .toList(),
                        ),
                        if (tutor.travelRadius != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Travel radius: ${tutor.travelRadius} km',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // About / Bio
                if (tutor.aboutTutor != null && tutor.aboutTutor!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'About Tutor'),
                        const SizedBox(height: 8),
                        Text(tutor.aboutTutor!, style: AppTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action to update
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile & Availability'),
                    onPressed: () => _showEditDialog(context, tutor),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value, style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TutorModel tutor) {
    final feeCtrl = TextEditingController(text: tutor.expectedFee.toStringAsFixed(0));
    final bioCtrl = TextEditingController(text: tutor.aboutTutor ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: feeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Expected Monthly Fee (₹)',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'About You / Bio',
                  hintText: 'Describe your teaching philosophy and strengths...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newFee = double.tryParse(feeCtrl.text.trim()) ?? tutor.expectedFee;
              final newBio = bioCtrl.text.trim();
              Navigator.pop(ctx);

              await ref.read(tutorRepositoryProvider).updateTutor(tutor.id, {
                'expectedFee': newFee,
                'aboutTutor': newBio,
              });

              setState(() {});
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
