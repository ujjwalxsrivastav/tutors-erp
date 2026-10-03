import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

/// Premium public homepage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ─────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppTheme.white,
            elevation: 0,
            toolbarHeight: 70,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'E',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Expert Tutors Academy',
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              if (isDesktop) ...[
                TextButton(
                  onPressed: () {},
                  child: Text('How It Works',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textPrimary)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Subjects',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textPrimary)),
                ),
                TextButton(
                  onPressed: () => context.go('/tutor/login'),
                  child: Text('For Tutors',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textPrimary)),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton(
                onPressed: () => context.go('/register-tutor'),
                child: const Text('Become a Tutor'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => context.go('/tutor/login'),
                icon: const Icon(Icons.school_outlined, size: 16),
                label: const Text('Tutor Login'),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // ─── Hero Section ─────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: isDesktop ? 80 : 48,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGreen.withValues(alpha: 0.03),
                    AppTheme.accentGold.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(child: _buildHeroContent(context)),
                        const SizedBox(width: 64),
                        Expanded(child: _buildHeroVisual()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildHeroContent(context),
                        const SizedBox(height: 40),
                        _buildHeroVisual(),
                      ],
                    ),
            ),
          ),

          // ─── How It Works ────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 64,
              ),
              child: Column(
                children: [
                  Text(
                    'How It Works',
                    style: AppTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get started with quality home tuition in 3 simple steps',
                    style: AppTheme.bodyLarge
                        .copyWith(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildStepCard(
                        number: '1',
                        icon: Icons.edit_note_outlined,
                        title: 'Share Your Requirement',
                        description:
                            'Tell us about the subject, class, and your preferred schedule. It takes less than 2 minutes.',
                      ),
                      _buildStepCard(
                        number: '2',
                        icon: Icons.people_outline,
                        title: 'Get Matched',
                        description:
                            'Our smart engine matches you with verified tutors based on subject expertise, location, and availability.',
                      ),
                      _buildStepCard(
                        number: '3',
                        icon: Icons.school_outlined,
                        title: 'Start Learning',
                        description:
                            'Meet your tutor, attend a demo class, and begin your learning journey with confidence.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Why Expert Tutors ───────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 64,
              ),
              color: AppTheme.backgroundLight,
              child: Column(
                children: [
                  Text(
                    'Why Expert Tutors Academy',
                    style: AppTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.verified_outlined,
                        title: 'Verified Tutors',
                        description:
                            'Every tutor is thoroughly screened and verified for qualifications and experience.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.psychology_outlined,
                        title: 'Smart Matching',
                        description:
                            'Our matching engine considers 9+ factors to find your ideal tutor.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.location_on_outlined,
                        title: 'Local Experts',
                        description:
                            'Find tutors in your area for convenient home or online tuition.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.free_cancellation_outlined,
                        title: 'Free Demo Class',
                        description:
                            'Try before you commit. Schedule a free demo with your matched tutor.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Quality Guaranteed',
                        description:
                            'Continuous performance tracking ensures consistent teaching quality.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.support_agent_outlined,
                        title: 'Dedicated Support',
                        description:
                            'Our team manages the entire process — you just focus on learning.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Subjects ────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 64,
              ),
              child: Column(
                children: [
                  Text(
                    'Subjects We Cover',
                    style: AppTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'From school to competitive exams, we have experts for every subject',
                    style: AppTheme.bodyLarge
                        .copyWith(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      'Mathematics',
                      'Physics',
                      'Chemistry',
                      'Biology',
                      'English',
                      'Hindi',
                      'Social Science',
                      'Computer Science',
                      'Accountancy',
                      'Economics',
                      'Business Studies',
                      'French',
                      'Sanskrit',
                      'Music',
                      'Art & Drawing',
                    ]
                        .map((s) => Chip(
                              label: Text(s),
                              backgroundColor:
                                  AppTheme.primaryGreen.withValues(alpha: 0.08),
                              labelStyle: AppTheme.labelMedium.copyWith(
                                color: AppTheme.primaryGreen,
                              ),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // ─── Tutor CTA ──────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 32,
              ),
              padding: EdgeInsets.all(isDesktop ? 56 : 32),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Column(
                children: [
                  Text(
                    'Are You a Tutor?',
                    style: AppTheme.displaySmall.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Join Expert Tutors Academy and connect with students in your area.\nGrow your teaching career with verified leads.',
                    style:
                        AppTheme.bodyLarge.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/register-tutor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.textOnGold,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Register as a Tutor →'),
                  ),
                ],
              ),
            ),
          ),

          // ─── FAQ ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 64,
              ),
              child: Column(
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: AppTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      children: [
                        _buildFaqItem(
                          'How quickly will I get a tutor?',
                          'Most students are matched with a tutor within 24-48 hours. Our matching engine works immediately to find the best available tutors for your requirements.',
                        ),
                        _buildFaqItem(
                          'Is registration required to submit an enquiry?',
                          'No! Parents can submit a tuition enquiry without creating an account. Simply fill out the form and we\'ll take care of the rest.',
                        ),
                        _buildFaqItem(
                          'How are tutors verified?',
                          'Every tutor goes through a multi-step verification process including qualification checks, experience validation, and identity verification before they can receive student leads.',
                        ),
                        _buildFaqItem(
                          'Can I switch tutors?',
                          'Absolutely. If you\'re not satisfied with your tutor, simply contact us and we\'ll assign a replacement tutor at no extra cost.',
                        ),
                        _buildFaqItem(
                          'What if I want online tuition?',
                          'We offer both home and online tuition. You can select your preferred mode while submitting your enquiry.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Footer ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 40,
              ),
              color: AppTheme.primaryGreenDark,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text('E',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expert Tutors Academy',
                        style: AppTheme.titleMedium
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© ${DateTime.now().year} Expert Tutors Academy. All rights reserved.',
                    style:
                        AppTheme.bodySmall.copyWith(color: Colors.white38),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── Floating CTA ────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/enquiry'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.search),
        label: const Text('Find a Tutor'),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '✨ Trusted by 500+ families',
            style:
                AppTheme.labelMedium.copyWith(color: AppTheme.accentGoldDark),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Find the Right\nTutor. Learn Better.',
          style: AppTheme.displayLarge,
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.supportingText,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/enquiry'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                textStyle:
                    AppTheme.labelLarge.copyWith(fontSize: 16),
              ),
              child: const Text('Find a Tutor →'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/register-tutor'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                textStyle:
                    AppTheme.labelLarge.copyWith(fontSize: 16),
              ),
              child: const Text('Become a Tutor'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _buildHeroStat('500+', 'Happy\nFamilies'),
            const SizedBox(width: 32),
            _buildHeroStat('200+', 'Verified\nTutors'),
            const SizedBox(width: 32),
            _buildHeroStat('20+', 'Subjects\nCovered'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTheme.headlineLarge.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildHeroVisual() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.08),
            AppTheme.accentGold.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: AppTheme.primaryGreen.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Expert Tutors Academy',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.primaryGreen.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Personalized Home Tuition',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(28),
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, color: AppTheme.primaryGreen, size: 24),
              ],
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(description, style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return SizedBox(
      width: 280,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.titleLarge),
            const SizedBox(height: 6),
            Text(description, style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: AppTheme.titleMedium),
      childrenPadding:
          const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(answer, style: AppTheme.bodyMedium)],
    );
  }
}
