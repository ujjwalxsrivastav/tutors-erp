import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/services/lead_service.dart';
import '../../../data/services/whatsapp_service.dart';

/// Multi-step enquiry form — no auth required
class EnquiryPage extends ConsumerStatefulWidget {
  const EnquiryPage({super.key});

  @override
  ConsumerState<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends ConsumerState<EnquiryPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  // Form data
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _budgetController = TextEditingController();
  final _additionalController = TextEditingController();

  String _selectedClass = '';
  final List<String> _selectedSubjects = [];
  String _preferredMode = 'HOME';
  final List<String> _selectedDays = [];
  String _preferredTiming = '';
  bool _whatsappSameAsPhone = true;

  @override
  void dispose() {
    _parentNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _studentNameController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _budgetController.dispose();
    _additionalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    if (_isSuccess) {
      return _buildSuccessScreen(context);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('E',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
            Text('Expert Tutors Academy',
                style: AppTheme.titleMedium
                    .copyWith(color: AppTheme.primaryGreen)),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 0 : 16,
            vertical: 32,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Find Your Perfect Tutor',
                  style: AppTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us your tuition requirements and we\'ll match you with the best tutors.',
                  style: AppTheme.bodyLarge
                      .copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Progress
                _buildProgressIndicator(),

                const SizedBox(height: 24),

                // Form card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.elevationSm,
                  ),
                  child: Form(
                    key: _formKey,
                    child: _buildCurrentStep(),
                  ),
                ),

                const SizedBox(height: 20),

                // Navigation
                _buildNavButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const steps = ['Student Info', 'Subject & Class', 'Preferences'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i <= _currentStep;
          final isCurrent = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive
                          ? AppTheme.primaryGreen
                          : AppTheme.border,
                    ),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryGreen
                        : AppTheme.surfaceVariant,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                            width: 3)
                        : null,
                  ),
                  child: Center(
                    child: i < _currentStep
                        ? const Icon(Icons.check,
                            size: 16, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color:
                                  isActive ? Colors.white : AppTheme.textTertiary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < _currentStep
                          ? AppTheme.primaryGreen
                          : AppTheme.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1StudentInfo();
      case 1:
        return _buildStep2SubjectClass();
      case 2:
        return _buildStep3Preferences();
      default:
        return const SizedBox();
    }
  }

  // ─── Step 1: Student & Parent Info ────────────────────
  Widget _buildStep1StudentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student & Parent Information',
            style: AppTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Basic details to help us reach you',
            style: AppTheme.bodyMedium),
        const SizedBox(height: 24),

        _buildLabel('Parent Name'),
        TextFormField(
          controller: _parentNameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline, size: 20),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 16),

        _buildLabel('Phone Number'),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: const InputDecoration(
            hintText: '10-digit mobile number',
            prefixIcon: Icon(Icons.phone_outlined, size: 20),
            prefixText: '+91 ',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter phone number';
            if (v.trim().length != 10) return 'Please enter 10-digit number';
            return null;
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Checkbox(
              value: _whatsappSameAsPhone,
              onChanged: (v) => setState(() => _whatsappSameAsPhone = v!),
              activeColor: AppTheme.primaryGreen,
            ),
            Text('WhatsApp number same as phone',
                style: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.textPrimary)),
          ],
        ),

        if (!_whatsappSameAsPhone) ...[
          const SizedBox(height: 8),
          _buildLabel('WhatsApp Number'),
          TextFormField(
            controller: _whatsappController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              hintText: '10-digit WhatsApp number',
              prefixIcon: Icon(Icons.chat_outlined, size: 20),
              prefixText: '+91 ',
            ),
          ),
        ],

        const SizedBox(height: 16),
        _buildLabel('Student Name'),
        TextFormField(
          controller: _studentNameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter student\'s name',
            prefixIcon: Icon(Icons.school_outlined, size: 20),
          ),
          validator: (v) => v == null || v.trim().isEmpty
              ? 'Please enter student name'
              : null,
        ),
      ],
    );
  }

  // ─── Step 2: Subject & Class ──────────────────────────
  Widget _buildStep2SubjectClass() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subject & Class', style: AppTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('What does the student need help with?',
            style: AppTheme.bodyMedium),
        const SizedBox(height: 24),

        _buildLabel('Class'),
        DropdownButtonFormField<String>(
          initialValue: _selectedClass.isEmpty ? null : _selectedClass,
          decoration: const InputDecoration(
            hintText: 'Select class',
            prefixIcon: Icon(Icons.class_outlined, size: 20),
          ),
          items: AppConstants.classes
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _selectedClass = v ?? ''),
          validator: (v) =>
              v == null || v.isEmpty ? 'Please select class' : null,
        ),
        const SizedBox(height: 20),

        _buildLabel('Subjects (select one or more)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.subjects.map((subject) {
            final selected = _selectedSubjects.contains(subject);
            return FilterChip(
              label: Text(subject),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _selectedSubjects.add(subject);
                  } else {
                    _selectedSubjects.remove(subject);
                  }
                });
              },
              selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.primaryGreen,
              labelStyle: AppTheme.labelMedium.copyWith(
                color: selected
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
              ),
            );
          }).toList(),
        ),
        if (_selectedSubjects.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one subject',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
            ),
          ),
      ],
    );
  }

  // ─── Step 3: Preferences ─────────────────────────────
  Widget _buildStep3Preferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferences', style: AppTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Help us find the best match for you',
            style: AppTheme.bodyMedium),
        const SizedBox(height: 24),

        _buildLabel('Location / Area'),
        TextFormField(
          controller: _locationController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g., Sector 62, Noida',
            prefixIcon: Icon(Icons.location_on_outlined, size: 20),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Please enter location' : null,
        ),
        const SizedBox(height: 16),

        _buildLabel('City'),
        TextFormField(
          controller: _cityController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g., Noida, Delhi, Gurgaon',
            prefixIcon: Icon(Icons.location_city_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel('Preferred Teaching Mode'),
        const SizedBox(height: 8),
        Row(
          children: AppConstants.teachingModes.map((mode) {
            final selected = _preferredMode == mode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(
                      mode == 'HOME'
                          ? '🏠 Home'
                          : mode == 'ONLINE'
                              ? '💻 Online'
                              : '🔄 Both',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _preferredMode = mode),
                  selectedColor:
                      AppTheme.primaryGreen.withValues(alpha: 0.15),
                  backgroundColor: AppTheme.surfaceVariant,
                  labelStyle: AppTheme.labelMedium.copyWith(
                    color: selected
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary,
                  ),
                  showCheckmark: false,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        _buildLabel('Preferred Days'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.daysOfWeek.map((day) {
            final selected = _selectedDays.contains(day);
            return FilterChip(
              label: Text(day.substring(0, 3)),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                });
              },
              selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.primaryGreen,
              labelStyle: AppTheme.labelMedium.copyWith(
                color: selected
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        _buildLabel('Preferred Timing'),
        DropdownButtonFormField<String>(
          initialValue: _preferredTiming.isEmpty ? null : _preferredTiming,
          decoration: const InputDecoration(
            hintText: 'Select preferred timing',
            prefixIcon: Icon(Icons.access_time, size: 20),
          ),
          items: [
            'Morning (8 AM - 12 PM)',
            'Afternoon (12 PM - 4 PM)',
            'Evening (4 PM - 7 PM)',
            'Night (7 PM - 10 PM)',
            'Flexible',
          ]
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _preferredTiming = v ?? ''),
        ),
        const SizedBox(height: 16),

        _buildLabel('Monthly Budget (Optional)'),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'e.g., 5000',
            prefixIcon: Icon(Icons.currency_rupee, size: 20),
            suffixText: '/ month',
          ),
        ),
        const SizedBox(height: 16),

        _buildLabel('Additional Requirements (Optional)'),
        TextFormField(
          controller: _additionalController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText:
                'Any specific requirements? Board preference, special focus areas, etc.',
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTheme.labelLarge),
    );
  }

  Widget _buildNavButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: () => setState(() => _currentStep--),
            child: const Text('← Back'),
          ),
        const Spacer(),
        if (_currentStep < 2)
          ElevatedButton(
            onPressed: _validateAndNext,
            child: const Text('Next →'),
          )
        else
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitEnquiry,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit Enquiry →'),
          ),
      ],
    );
  }

  void _validateAndNext() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_selectedClass.isNotEmpty && _selectedSubjects.isNotEmpty) {
        setState(() => _currentStep++);
      } else {
        if (_selectedClass.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a class')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please select at least one subject')),
          );
        }
      }
    }
  }

  Future<void> _submitEnquiry() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your location')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final lead = LeadModel(
        id: '',
        leadNumber: '', // Will be generated server-side
        parentName: _parentNameController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsappNumber: _whatsappSameAsPhone
            ? _phoneController.text.trim()
            : _whatsappController.text.trim(),
        studentName: _studentNameController.text.trim(),
        studentClass: _selectedClass,
        subjects: _selectedSubjects,
        location: LeadLocation(
          area: _locationController.text.trim(),
          city: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : null,
        ),
        preferredMode: _preferredMode,
        preferredDays: _selectedDays,
        preferredTiming:
            _preferredTiming.isNotEmpty ? _preferredTiming : null,
        budget: _budgetController.text.trim().isNotEmpty
            ? double.tryParse(_budgetController.text.trim())
            : null,
        additionalRequirements:
            _additionalController.text.trim().isNotEmpty
                ? _additionalController.text.trim()
                : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final leadRepo = ref.read(leadRepositoryProvider);
      await leadRepo.createLead(lead);

      // Trigger WhatsApp notification (dev fallback)
      try {
        final whatsapp = ref.read(whatsAppServiceProvider);
        await whatsapp.sendNewLeadNotification(
          leadNumber: 'New Lead',
          studentName: lead.studentName,
          studentClass: lead.studentClass,
          subjects: lead.subjects,
          location: lead.location.displayText,
          mode: lead.preferredMode,
          timing: lead.preferredTiming,
          budget: lead.budget,
          viewLeadUrl: 'https://app.experttutorsacademy.com/admin/leads',
        );
      } catch (_) {
        // WhatsApp notification is non-blocking
      }

      setState(() {
        _isSuccess = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitEnquiry,
            ),
          ),
        );
      }
    }
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your tuition requirement has been received.',
                style: AppTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Expert Tutors Academy will contact you shortly.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  'We\'ll match you with the best tutors for ${_selectedSubjects.join(', ')} — $_selectedClass',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
