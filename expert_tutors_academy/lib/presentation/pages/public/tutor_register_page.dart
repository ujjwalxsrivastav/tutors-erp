import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/tutor_service.dart';

/// Complete tutor registration page
class TutorRegisterPage extends ConsumerStatefulWidget {
  const TutorRegisterPage({super.key});

  @override
  ConsumerState<TutorRegisterPage> createState() => _TutorRegisterPageState();
}

class _TutorRegisterPageState extends ConsumerState<TutorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _gender = '';
  final List<String> _selectedSubjects = [];
  final List<String> _selectedClasses = [];
  String _teachingMode = 'BOTH';
  final List<String> _languages = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _qualificationCtrl.dispose();
    _institutionCtrl.dispose();
    _experienceCtrl.dispose();
    _feeCtrl.dispose();
    _aboutCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(child: Text('E', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
            ),
            const SizedBox(width: 8),
            Text('Register as a Tutor', style: AppTheme.titleMedium.copyWith(color: AppTheme.primaryGreen)),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Join Expert Tutors Academy', style: AppTheme.displaySmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Create your tutor profile and start receiving tuition leads.', style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 24),

                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Container(
                    width: 80, height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i <= _step ? AppTheme.primaryGreen : AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                ),
                const SizedBox(height: 24),

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
                    child: _buildStep(),
                  ),
                ),
                const SizedBox(height: 20),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildPersonalInfo();
      case 1: return _buildTeachingInfo();
      case 2: return _buildAvailability();
      default: return const SizedBox();
    }
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Information', style: AppTheme.headlineSmall),
        const SizedBox(height: 20),
        _label('Full Name'),
        TextFormField(controller: _nameCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Enter your full name'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
        const SizedBox(height: 14),
        _label('Email'),
        TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'you@example.com'), validator: (v) => v?.contains('@') != true ? 'Valid email required' : null),
        const SizedBox(height: 14),
        _label('Phone'),
        TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)], decoration: const InputDecoration(hintText: '10-digit number', prefixText: '+91 '), validator: (v) => v?.length != 10 ? '10-digit number required' : null),
        const SizedBox(height: 14),
        _label('Password'),
        TextFormField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Min 6 characters'), validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null),
        const SizedBox(height: 14),
        _label('Gender'),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(label: Text(g), selected: _gender == g, onSelected: (_) => setState(() => _gender = g), showCheckmark: false),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTeachingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Teaching Profile', style: AppTheme.headlineSmall),
        const SizedBox(height: 20),
        _label('Highest Qualification'),
        DropdownButtonFormField<String>(
          value: _qualificationCtrl.text.isNotEmpty ? _qualificationCtrl.text : null,
          decoration: const InputDecoration(hintText: 'Select qualification'),
          items: AppConstants.qualifications.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
          onChanged: (v) => _qualificationCtrl.text = v ?? '',
          validator: (v) => v == null ? 'Required' : null,
        ),
        const SizedBox(height: 14),
        _label('Institution'),
        TextFormField(controller: _institutionCtrl, decoration: const InputDecoration(hintText: 'Your college/university')),
        const SizedBox(height: 14),
        _label('Teaching Experience (years)'),
        TextFormField(controller: _experienceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g., 3')),
        const SizedBox(height: 14),
        _label('Subjects You Teach'),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: AppConstants.subjects.map((s) {
          final sel = _selectedSubjects.contains(s);
          return FilterChip(label: Text(s), selected: sel, onSelected: (v) => setState(() { v ? _selectedSubjects.add(s) : _selectedSubjects.remove(s); }), selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15), checkmarkColor: AppTheme.primaryGreen);
        }).toList()),
        const SizedBox(height: 14),
        _label('Classes You Teach'),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: AppConstants.classes.map((c) {
          final sel = _selectedClasses.contains(c);
          return FilterChip(label: Text(c), selected: sel, onSelected: (v) => setState(() { v ? _selectedClasses.add(c) : _selectedClasses.remove(c); }), selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15), checkmarkColor: AppTheme.primaryGreen);
        }).toList()),
      ],
    );
  }

  Widget _buildAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Availability & Preferences', style: AppTheme.headlineSmall),
        const SizedBox(height: 20),
        _label('Teaching Mode'),
        Row(children: AppConstants.teachingModes.map((m) => Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: SizedBox(width: double.infinity, child: Text(m == 'HOME' ? '🏠 Home' : m == 'ONLINE' ? '💻 Online' : '🔄 Both', textAlign: TextAlign.center)), selected: _teachingMode == m, onSelected: (_) => setState(() => _teachingMode = m), showCheckmark: false, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10)),
        ))).toList()),
        const SizedBox(height: 14),
        _label('Preferred Location / Area'),
        TextFormField(controller: _locationCtrl, decoration: const InputDecoration(hintText: 'e.g., Sector 62, Noida'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
        const SizedBox(height: 14),
        _label('Expected Monthly Fee (₹)'),
        TextFormField(controller: _feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g., 5000', prefixText: '₹ ')),
        const SizedBox(height: 14),
        _label('Languages'),
        Wrap(spacing: 6, runSpacing: 6, children: ['English', 'Hindi', 'Bengali', 'Tamil', 'Telugu', 'Marathi', 'Gujarati', 'Kannada', 'Punjabi', 'Urdu'].map((l) {
          final sel = _languages.contains(l);
          return FilterChip(label: Text(l), selected: sel, onSelected: (v) => setState(() { v ? _languages.add(l) : _languages.remove(l); }), selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15), checkmarkColor: AppTheme.primaryGreen);
        }).toList()),
        const SizedBox(height: 14),
        _label('About You (Optional)'),
        TextFormField(controller: _aboutCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Brief introduction about your teaching approach')),
      ],
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: AppTheme.labelLarge));

  Widget _buildButtons() {
    return Row(children: [
      if (_step > 0) OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('← Back')),
      const Spacer(),
      if (_step < 2) ElevatedButton(onPressed: () { if (_formKey.currentState?.validate() ?? false) setState(() => _step++); }, child: const Text('Next →'))
      else ElevatedButton(
        onPressed: _isSubmitting ? null : _register,
        child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Register →'),
      ),
    ]);
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSubjects.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one subject'))); return; }

    setState(() => _isSubmitting = true);
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.register(email: _emailCtrl.text.trim(), password: _passwordCtrl.text, name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim(), role: 'TUTOR');

      final tutorRepo = ref.read(tutorRepositoryProvider);
      await tutorRepo.createTutorWithId(user.uid, TutorModel(
        id: user.uid, userId: user.uid, name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim(), email: _emailCtrl.text.trim(),
        gender: _gender, qualification: _qualificationCtrl.text, institution: _institutionCtrl.text.isNotEmpty ? _institutionCtrl.text : null,
        teachingExperience: int.tryParse(_experienceCtrl.text) ?? 0, subjects: _selectedSubjects, classesTaught: _selectedClasses,
        teachingMode: _teachingMode, preferredLocations: _locationCtrl.text.isNotEmpty ? [_locationCtrl.text.trim()] : [],
        languages: _languages, expectedFee: double.tryParse(_feeCtrl.text) ?? 0,
        aboutTutor: _aboutCtrl.text.isNotEmpty ? _aboutCtrl.text : null, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ));

      await authService.signOut(); // Sign out after registration
      setState(() { _isSuccess = true; _isSubmitting = false; });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
    }
  }

  Widget _buildSuccessScreen() {
    return Scaffold(backgroundColor: AppTheme.backgroundLight, body: Center(child: Container(
      constraints: const BoxConstraints(maxWidth: 500), padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, size: 48, color: AppTheme.success)),
        const SizedBox(height: 24),
        Text('Registration Successful!', style: AppTheme.headlineLarge, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('Your profile is under review. We\'ll verify your details and notify you once approved.', style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Go to Login')),
      ]),
    )));
  }
}
