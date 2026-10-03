import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/services/auth_service.dart';
import '../presentation/pages/public/home_page.dart';
import '../presentation/pages/public/enquiry_page.dart';
import '../presentation/pages/public/tutor_register_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/admin_login_page.dart';
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

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, _) => notifyListeners());
    _ref.listen(currentUserProvider, (_, _) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authUser = authService.currentUser;
      final isLoggedIn = authUser != null;
      final loc = state.matchedLocation;

      // Public routes
      final isHome = loc == '/';
      final isEnquiry = loc.startsWith('/enquiry');
      final isRegisterTutor = loc == '/register-tutor';
      final isAdminLogin = loc == '/admin/login';
      final isTutorLogin = loc == '/tutor/login';
      final isOldLogin = loc == '/login';

      if (isOldLogin) {
        return '/tutor/login';
      }

      // Public pages are always accessible
      if (isHome || isEnquiry || isRegisterTutor) {
        return null;
      }

      // If user is accessing Admin Login page
      if (isAdminLogin) {
        if (isLoggedIn) {
          // If already logged in, let them access dashboard
          return '/admin/dashboard';
        }
        return null;
      }

      // If user is accessing Tutor Login page
      if (isTutorLogin) {
        if (isLoggedIn) {
          return '/tutor/dashboard';
        }
        return null;
      }

      // ─── Protected Admin Routes ─────────────────────────
      if (loc == '/admin' || loc.startsWith('/admin/')) {
        if (!isLoggedIn) {
          // Send to dedicated Admin Login
          return '/admin/login';
        }
        return null;
      }

      // ─── Protected Tutor Routes ─────────────────────────
      if (loc == '/tutor' || loc.startsWith('/tutor/')) {
        if (!isLoggedIn) {
          // Send to dedicated Tutor Login
          return '/tutor/login';
        }
        return null;
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
        redirect: (context, state) => '/tutor/login',
      ),
      GoRoute(
        path: '/tutor/login',
        name: 'tutor-login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/admin/login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginPage(),
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) => '/admin/dashboard',
      ),
      GoRoute(
        path: '/tutor',
        redirect: (context, state) => '/tutor/dashboard',
      ),

      // ─── Admin/Agent Protected Shell ───────────────────
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

      // ─── Tutor Protected Shell ─────────────────────────
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
