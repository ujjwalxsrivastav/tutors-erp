import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/services/operational_services.dart';
import '../../../data/services/auth_service.dart';

class TutorTuitionsPage extends ConsumerStatefulWidget {
  const TutorTuitionsPage({super.key});

  @override
  ConsumerState<TutorTuitionsPage> createState() => _TutorTuitionsPageState();
}

class _TutorTuitionsPageState extends ConsumerState<TutorTuitionsPage> {
  String _selectedFilter = 'ALL';
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Active Tuitions'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip('ALL', 'All'),
                const SizedBox(width: 8),
                _filterChip('ACTIVE', 'Active'),
                const SizedBox(width: 8),
                _filterChip('PAUSED', 'Paused'),
                const SizedBox(width: 8),
                _filterChip('COMPLETED', 'Completed'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<TuitionModel>>(
              stream: ref.read(tuitionServiceProvider).streamTutorTuitions(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var list = snapshot.data ?? [];
                if (_selectedFilter != 'ALL') {
                  list = list.where((t) => t.status.toUpperCase() == _selectedFilter).toList();
                }

                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.auto_stories_outlined,
                    title: _selectedFilter == 'ALL'
                        ? 'No tuitions yet'
                        : 'No ${_selectedFilter.toLowerCase()} tuitions',
                    subtitle: 'Confirmed tuitions converted from leads will appear here.',
                  );
                }

                // Calculate summary stats
                final activeCount = list.where((t) => t.isActive).length;
                final monthlyEarnings = list
                    .where((t) => t.isActive)
                    .fold<double>(0, (sum, t) => sum + t.tutorPayout);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$activeCount',
                                style: AppTheme.headlineMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Active Batches',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                          Container(height: 36, width: 1, color: Colors.white24),
                          Column(
                            children: [
                              Text(
                                _currencyFormat.format(monthlyEarnings),
                                style: AppTheme.headlineMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Monthly Payout',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Tuition Cards
                    ...list.map((tuition) => _buildTuitionCard(context, tuition)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }

  Widget _buildTuitionCard(BuildContext context, TuitionModel tuition) {
    Color statusColor;
    switch (tuition.status.toUpperCase()) {
      case 'ACTIVE':
        statusColor = AppTheme.success;
        break;
      case 'PAUSED':
        statusColor = AppTheme.warning;
        break;
      case 'COMPLETED':
        statusColor = AppTheme.info;
        break;
      default:
        statusColor = AppTheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Text(
                  tuition.studentName,
                  style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              StatusBadge(label: tuition.status, color: statusColor, filled: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${tuition.subject} • Class ${tuition.studentClass}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  tuition.location,
                  style: AppTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Parent: ${tuition.parentName}',
                style: AppTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                'Payout: ${_currencyFormat.format(tuition.tutorPayout)}/mo',
                style: AppTheme.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Text(
                'Started: ${DateFormat('dd MMM yyyy').format(tuition.startDate)}',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
              const Spacer(),
              if (tuition.parentPhone.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.call, size: 20, color: AppTheme.primaryGreen),
                  tooltip: 'Call Parent',
                  onPressed: () => launchUrl(Uri.parse('tel:${tuition.parentPhone}')),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, size: 20, color: AppTheme.success),
                  tooltip: 'WhatsApp Parent',
                  onPressed: () {
                    final cleanPhone = tuition.parentPhone.replaceAll(RegExp(r'\D'), '');
                    launchUrl(
                      Uri.parse('https://wa.me/$cleanPhone?text=Hello%20${Uri.encodeComponent(tuition.parentName)},%20I%20am%20your%20tutor%20for%20${Uri.encodeComponent(tuition.subject)}.'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
