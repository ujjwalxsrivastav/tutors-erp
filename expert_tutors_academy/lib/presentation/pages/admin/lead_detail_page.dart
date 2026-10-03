import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/services/lead_service.dart';
import '../../../data/services/operational_services.dart';
import '../../../data/models/models.dart';
import '../../../data/services/tutor_service.dart';

class LeadDetailPage extends ConsumerWidget {
  final String leadId;

  const LeadDetailPage({super.key, required this.leadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

    return StreamBuilder(
      stream: ref.read(leadRepositoryProvider).streamLead(leadId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final lead = snapshot.data;
        if (lead == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lead')),
            body: const EmptyState(
              icon: Icons.error_outline,
              title: 'Lead not found',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          appBar: AppBar(
            title: Text(lead.leadNumber.isNotEmpty
                ? lead.leadNumber
                : 'New Lead'),
            actions: [
              if (lead.isActive)
                ElevatedButton.icon(
                  onPressed: () =>
                      context.go('/admin/leads/$leadId/matching'),
                  icon: const Icon(Icons.people_outline, size: 18),
                  label: const Text('View Matches'),
                ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (action) =>
                    _handleAction(context, ref, lead, action),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'schedule_demo',
                      child: Text('Schedule Demo')),
                  const PopupMenuItem(
                      value: 'create_followup',
                      child: Text('Create Follow-up')),
                  const PopupMenuItem(
                      value: 'convert', child: Text('Convert to Tuition')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                      value: 'cancel', child: Text('Cancel Lead')),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3, child: _buildDetails(context, lead)),
                      const SizedBox(width: 24),
                      Expanded(
                          flex: 2, child: _buildTimeline(context, lead)),
                    ],
                  )
                : Column(
                    children: [
                      _buildDetails(context, lead),
                      const SizedBox(height: 24),
                      _buildTimeline(context, lead),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDetails(BuildContext context, LeadModel lead) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status + header
        Container(
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
                  StatusBadge.leadStatus(lead.status),
                  const Spacer(),
                  Text(
                    'Created ${timeago.format(lead.createdAt)}',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(lead.studentName, style: AppTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                '${lead.studentClass} • ${lead.subjects.join(", ")}',
                style: AppTheme.bodyLarge
                    .copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Student details
        _buildInfoCard('Student Information', [
          InfoRow(label: 'Student', value: lead.studentName, icon: Icons.school_outlined),
          InfoRow(label: 'Class', value: lead.studentClass, icon: Icons.class_outlined),
          InfoRow(label: 'Subjects', value: lead.subjects.join(', '), icon: Icons.book_outlined),
        ]),
        const SizedBox(height: 16),

        // Parent details
        _buildInfoCard('Parent Information', [
          InfoRow(label: 'Name', value: lead.parentName, icon: Icons.person_outline),
          InfoRow(label: 'Phone', value: lead.phone, icon: Icons.phone_outlined),
          if (lead.whatsappNumber != null)
            InfoRow(label: 'WhatsApp', value: lead.whatsappNumber!, icon: Icons.chat_outlined),
        ]),
        const SizedBox(height: 16),

        // Preferences
        _buildInfoCard('Preferences', [
          InfoRow(label: 'Location', value: lead.location.displayText, icon: Icons.location_on_outlined),
          InfoRow(label: 'Mode', value: lead.preferredMode, icon: Icons.laptop_outlined),
          if (lead.preferredDays.isNotEmpty)
            InfoRow(label: 'Days', value: lead.preferredDays.join(', '), icon: Icons.calendar_today_outlined),
          if (lead.preferredTiming != null)
            InfoRow(label: 'Timing', value: lead.preferredTiming!, icon: Icons.access_time),
          if (lead.budget != null)
            InfoRow(label: 'Budget', value: '₹${lead.budget!.toStringAsFixed(0)}/month', icon: Icons.currency_rupee),
          if (lead.additionalRequirements != null)
            InfoRow(label: 'Notes', value: lead.additionalRequirements!, icon: Icons.notes_outlined),
        ]),
        const SizedBox(height: 16),

        // Matching info
        if (lead.matchCount > 0)
          _buildInfoCard('Matching', [
            InfoRow(label: 'Matches', value: '${lead.matchCount} tutors', icon: Icons.people_outline),
            if (lead.bestMatchScore != null)
              InfoRow(label: 'Best Match', value: '${lead.bestMatchScore!.toStringAsFixed(0)}%', icon: Icons.star_outline),
            if (lead.assignedTutorName != null)
              InfoRow(label: 'Assigned To', value: lead.assignedTutorName!, icon: Icons.person_pin_outlined),
          ]),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
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
          Text(title, style: AppTheme.titleLarge),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, LeadModel lead) {
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
          Text('Timeline', style: AppTheme.titleLarge),
          const SizedBox(height: 16),
          if (lead.timeline.isEmpty)
            Text('No timeline entries yet.',
                style: AppTheme.bodyMedium)
          else
            ...lead.timeline.reversed.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.description,
                              style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeago.format(entry.timestamp),
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    LeadModel lead,
    String action,
  ) {
    switch (action) {
      case 'schedule_demo':
        _showScheduleDemoDialog(context, ref, lead);
        break;
      case 'convert':
        _showConvertDialog(context, ref, lead);
        break;
      case 'cancel':
        _cancelLead(context, ref, lead);
        break;
      case 'create_followup':
        _showFollowUpDialog(context, ref, lead);
        break;
    }
  }

  void _showScheduleDemoDialog(
      BuildContext context, WidgetRef ref, LeadModel lead) {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController(
        text: lead.location.displayText);
    final notesController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Demo'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today, size: 20),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    selectedDate = date;
                    dateController.text =
                        '${date.day}/${date.month}/${date.year}';
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'e.g., 4:00 PM',
                  prefixIcon: Icon(Icons.access_time, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedDate == null || timeController.text.isEmpty) return;

              try {
                final demoService = ref.read(demoServiceProvider);
                await demoService.createDemo(
                  DemoModel(
                    id: '',
                    leadId: lead.id,
                    leadNumber: lead.leadNumber,
                    tutorId: lead.assignedTutorId ?? '',
                    tutorName: lead.assignedTutorName ?? '',
                    studentName: lead.studentName,
                    parentName: lead.parentName,
                    parentPhone: lead.phone,
                    date: selectedDate!,
                    time: timeController.text,
                    location: locationController.text,
                    notes: notesController.text.isNotEmpty
                        ? notesController.text
                        : null,
                    createdAt: DateTime.now(),
                  ),
                );

                await ref.read(leadRepositoryProvider).updateLeadStatus(
                      lead.id,
                      'DEMO_SCHEDULED',
                      description: 'Demo scheduled for ${dateController.text} at ${timeController.text}',
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo scheduled successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showConvertDialog(
      BuildContext context, WidgetRef ref, LeadModel lead) {
    final feeController = TextEditingController(
        text: lead.budget?.toStringAsFixed(0) ?? '');
    final commissionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to Tuition'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will create a tuition record for ${lead.studentName}.',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Fee (₹)',
                  prefixIcon: Icon(Icons.currency_rupee, size: 20),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commissionController,
                decoration: const InputDecoration(
                  labelText: 'Agency Commission (₹)',
                  prefixIcon: Icon(Icons.percent, size: 20),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final fee = double.tryParse(feeController.text) ?? 0;
              final commission =
                  double.tryParse(commissionController.text) ?? 0;

              try {
                final tuitionService = ref.read(tuitionServiceProvider);
                await tuitionService.createTuition(
                  TuitionModel(
                    id: '',
                    leadId: lead.id,
                    leadNumber: lead.leadNumber,
                    tutorId: lead.assignedTutorId ?? '',
                    tutorName: lead.assignedTutorName ?? '',
                    studentName: lead.studentName,
                    parentName: lead.parentName,
                    parentPhone: lead.phone,
                    subject: lead.subjects.join(', '),
                    studentClass: lead.studentClass,
                    location: lead.location.displayText,
                    startDate: DateTime.now(),
                    monthlyFee: fee,
                    agencyCommission: commission,
                    tutorPayout: fee - commission,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );

                await ref.read(leadRepositoryProvider).updateLeadStatus(
                      lead.id,
                      'CONVERTED',
                      description:
                          'Lead converted to tuition. Monthly fee: ₹${fee.toStringAsFixed(0)}',
                    );

                // Update tutor performance
                if (lead.assignedTutorId != null) {
                  final tutorService = ref.read(tutorRepositoryProvider);
                  await tutorService.incrementPerformanceCounter(
                      lead.assignedTutorId!, 'convertedLeads');
                  await tutorService.incrementPerformanceCounter(
                      lead.assignedTutorId!, 'activeTuitions');
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Lead converted to tuition!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }

  void _cancelLead(
      BuildContext context, WidgetRef ref, LeadModel lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Lead'),
        content: Text(
            'Are you sure you want to cancel ${lead.leadNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error),
            onPressed: () async {
              await ref.read(leadRepositoryProvider).updateLeadStatus(
                    lead.id,
                    'CANCELLED',
                    description: 'Lead cancelled',
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFollowUpDialog(
      BuildContext context, WidgetRef ref, LeadModel lead) {
    final notesController = TextEditingController();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Follow-up'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  prefixIcon: Icon(Icons.calendar_today, size: 20),
                ),
                readOnly: true,
                onTap: () async {
                  dueDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (dueDate == null) return;
              try {
                await ref.read(followUpServiceProvider).createFollowUp(
                      FollowUpModel(
                        id: '',
                        entityType: 'LEAD',
                        entityId: lead.id,
                        entityNumber: lead.leadNumber,
                        assignedTo: '',
                        dueDate: dueDate!,
                        type: 'LEAD_FOLLOW_UP',
                        notes: notesController.text.isNotEmpty
                            ? notesController.text
                            : null,
                        createdAt: DateTime.now(),
                      ),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Follow-up created')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
