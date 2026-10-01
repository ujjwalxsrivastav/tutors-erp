import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/services/matching_engine.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  MatchingWeights? _weights;
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadWeights(); }

  Future<void> _loadWeights() async {
    final engine = ref.read(matchingEngineProvider);
    final weights = await engine.getWeights();
    setState(() { _weights = weights; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Matching Engine Weights', style: AppTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Configure the importance of each factor in tutor matching. Values should sum to 100.', style: AppTheme.bodyMedium),
                  const SizedBox(height: 24),
                  _weightSlider('Location', _weights!.location, (v) => setState(() => _weights = MatchingWeights(location: v, subject: _weights!.subject, studentClass: _weights!.studentClass, qualification: _weights!.qualification, availability: _weights!.availability, budget: _weights!.budget, experience: _weights!.experience, performance: _weights!.performance, parentPreference: _weights!.parentPreference))),
                  _weightSlider('Subject', _weights!.subject, (v) => setState(() => _weights = MatchingWeights(location: _weights!.location, subject: v, studentClass: _weights!.studentClass, qualification: _weights!.qualification, availability: _weights!.availability, budget: _weights!.budget, experience: _weights!.experience, performance: _weights!.performance, parentPreference: _weights!.parentPreference))),
                  _weightSlider('Class', _weights!.studentClass, (v) => setState(() => _weights = MatchingWeights(location: _weights!.location, subject: _weights!.subject, studentClass: v, qualification: _weights!.qualification, availability: _weights!.availability, budget: _weights!.budget, experience: _weights!.experience, performance: _weights!.performance, parentPreference: _weights!.parentPreference))),
                  _weightSlider('Qualification', _weights!.qualification, (v) => setState(() => _weights = MatchingWeights(location: _weights!.location, subject: _weights!.subject, studentClass: _weights!.studentClass, qualification: v, availability: _weights!.availability, budget: _weights!.budget, experience: _weights!.experience, performance: _weights!.performance, parentPreference: _weights!.parentPreference))),
                  _weightSlider('Availability', _weights!.availability, (v) => setState(() => _weights = MatchingWeights(location: _weights!.location, subject: _weights!.subject, studentClass: _weights!.studentClass, qualification: _weights!.qualification, availability: v, budget: _weights!.budget, experience: _weights!.experience, performance: _weights!.performance, parentPreference: _weights!.parentPreference))),
                  _weightSlider('Budget', _weights!.budget, (v) => setState(() => _weights = MatchingWeights(location: _weights!.location, subject: _weights!.subject, studentClass: _weights!.studentClass, qualification: _weights!.qualification, availability: _weights!.availability, budget: v, experience: _weights!.experience, performance: _weights!.performance, parentPreference: _weights!.parentPreference))),
                  _weightSlider('Experience', _weights!.experience, (v) => setState(() => _weights = MatchingWeights(location: _weights!.location, subject: _weights!.subject, studentClass: _weights!.studentClass, qualification: _weights!.qualification, availability: _weights!.availability, budget: _weights!.budget, experience: v, performance: _weights!.performance, parentPreference: _weights!.parentPreference))),
                  _weightSlider('Performance', _weights!.performance, (v) => setState(() => _weights = MatchingWeights(location: _weights!.location, subject: _weights!.subject, studentClass: _weights!.studentClass, qualification: _weights!.qualification, availability: _weights!.availability, budget: _weights!.budget, experience: _weights!.experience, performance: v, parentPreference: _weights!.parentPreference))),
                  _weightSlider('Parent Pref.', _weights!.parentPreference, (v) => setState(() => _weights = MatchingWeights(location: _weights!.location, subject: _weights!.subject, studentClass: _weights!.studentClass, qualification: _weights!.qualification, availability: _weights!.availability, budget: _weights!.budget, experience: _weights!.experience, performance: _weights!.performance, parentPreference: v))),
                  const SizedBox(height: 16),
                  Text('Total: ${_weights!.totalWeight.toStringAsFixed(0)}', style: AppTheme.titleMedium.copyWith(color: _weights!.totalWeight == 100 ? AppTheme.success : AppTheme.warning)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () async {
                    await ref.read(matchingEngineProvider).saveWeights(_weights!);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weights saved successfully')));
                  }, child: const Text('Save Weights')),
                ]),
              ),
            ])),
    );
  }

  Widget _weightSlider(String label, double value, ValueChanged<double> onChanged) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: AppTheme.bodyMedium)),
      Expanded(child: Slider(value: value, min: 0, max: 50, divisions: 50, onChanged: onChanged, activeColor: AppTheme.primaryGreen)),
      SizedBox(width: 40, child: Text(value.toStringAsFixed(0), style: AppTheme.titleMedium, textAlign: TextAlign.right)),
    ]));
  }
}
