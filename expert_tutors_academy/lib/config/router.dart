import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';
import '../presentation/pages/public/home_page.dart';
import '../presentation/pages/public/enquiry_page.dart';
import '../presentation/pages/public/tutor_register_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/admin/admin_shell.dart';
import '../presentation/pages/admin/dashboard_page.dart';
import '../presentation/pages/admin/leads_page.dart';
import '../presentation/pages/admin/lead_detail_page.dart';
import '../presentation/pages/admin/lead_matching_page.dart';
import '../presentation/pages/admin/tutors_page.dart';
import '../presentation/pages/admin/tutor_detail_page.dart';
import '../presentation/pages/admin/assignments_page.dart';
import '../presentation/pages/admin/demos_page.dart';
import '../presentation/pages/admin/tuitions_page.dart';
import '../presentation/pages/admin/follow_ups_page.dart';
import '../presentation/pages/admin/analytics_page.dart';
import '../presentation/pages/admin/audit_logs_page.dart';
import '../presentation/pages/admin/settings_page.dart';
import '../presentation/pages/admin/notifications_page.dart';
import '../presentation/pages/tutor/tutor_shell.dart';
import '../presentation/pages/tutor/tutor_dashboard_page.dart';
import '../presentation/pages/tutor/tutor_leads_page.dart';
import '../presentation/pages/tutor/tutor_assignments_page.dart';
import '../presentation/pages/tutor/tutor_tuitions_page.dart';
import '../presentation/pages/tutor/tutor_profile_page.dart';
import '../presentation/pages/tutor/tutor_performance_page.dart';
import '../presentation/pages/tutor/tutor_notifications_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginPage = state.matchedLocation == '/login';
      final isPublicRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/enquiry' ||
          state.matchedLocation == '/register-tutor' ||
          state.matchedLocation.startsWith('/enquiry');

      // Public routes are always accessible
      if (isPublicRoute) return null;

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isLoginPage) return '/login';

      // If logged in and on login page, redirect to appropriate dashboard
      if (isLoggedIn && isLoginPage) {
        return '/admin/dashboard';
      }

      return null;
    },
    routes: [
      // ─── Public Routes ────────────────────────────────
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/enquiry',
        name: 'enquiry',
        builder: (context, state) => const EnquiryPage(),
      ),
      GoRoute(
        path: '/register-tutor',
        name: 'register-tutor',
        builder: (context, state) => const TutorRegisterPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // ─── Admin/Agent Routes ───────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            name: 'admin-dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/admin/leads',
            name: 'admin-leads',
            builder: (context, state) => const LeadsPage(),
          ),
          GoRoute(
            path: '/admin/leads/:leadId',
            name: 'admin-lead-detail',
            builder: (context, state) => LeadDetailPage(
              leadId: state.pathParameters['leadId']!,
            ),
          ),
          GoRoute(
            path: '/admin/leads/:leadId/matching',
            name: 'admin-lead-matching',
            builder: (context, state) => LeadMatchingPage(
              leadId: state.pathParameters['leadId']!,
            ),
          ),
          GoRoute(
            path: '/admin/tutors',
            name: 'admin-tutors',
            builder: (context, state) => const TutorsPage(),
          ),
          GoRoute(
            path: '/admin/tutors/:tutorId',
            name: 'admin-tutor-detail',
            builder: (context, state) => TutorDetailPage(
              tutorId: state.pathParameters['tutorId']!,
            ),
          ),
          GoRoute(
            path: '/admin/assignments',
            name: 'admin-assignments',
            builder: (context, state) => const AssignmentsPage(),
          ),
          GoRoute(
            path: '/admin/demos',
            name: 'admin-demos',
            builder: (context, state) => const DemosPage(),
          ),
          GoRoute(
            path: '/admin/tuitions',
            name: 'admin-tuitions',
            builder: (context, state) => const TuitionsPage(),
          ),
          GoRoute(
            path: '/admin/follow-ups',
            name: 'admin-follow-ups',
            builder: (context, state) => const FollowUpsPage(),
          ),
          GoRoute(
            path: '/admin/analytics',
            name: 'admin-analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/admin/notifications',
            name: 'admin-notifications',
            builder: (context, state) => const AdminNotificationsPage(),
          ),
          GoRoute(
            path: '/admin/audit-logs',
            name: 'admin-audit-logs',
            builder: (context, state) => const AuditLogsPage(),
          ),
          GoRoute(
            path: '/admin/settings',
            name: 'admin-settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),

      // ─── Tutor Routes ────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => TutorShell(child: child),
        routes: [
          GoRoute(
            path: '/tutor/dashboard',
            name: 'tutor-dashboard',
            builder: (context, state) => const TutorDashboardPage(),
          ),
          GoRoute(
            path: '/tutor/leads',
            name: 'tutor-leads',
            builder: (context, state) => const TutorLeadsPage(),
          ),
          GoRoute(
            path: '/tutor/assignments',
            name: 'tutor-assignments',
            builder: (context, state) => const TutorAssignmentsPage(),
          ),
          GoRoute(
            path: '/tutor/tuitions',
            name: 'tutor-tuitions',
            builder: (context, state) => const TutorTuitionsPage(),
          ),
          GoRoute(
            path: '/tutor/profile',
            name: 'tutor-profile',
            builder: (context, state) => const TutorProfilePage(),
          ),
          GoRoute(
            path: '/tutor/performance',
            name: 'tutor-performance',
            builder: (context, state) => const TutorPerformancePage(),
          ),
          GoRoute(
            path: '/tutor/notifications',
            name: 'tutor-notifications',
            builder: (context, state) => const TutorNotificationsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
