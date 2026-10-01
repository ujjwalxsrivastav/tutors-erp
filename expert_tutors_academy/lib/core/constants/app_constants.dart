// Core constants for Expert Tutors Academy
class AppConstants {
  AppConstants._();

  // Brand
  static const String appName = 'Expert Tutors Academy';
  static const String tagline = 'Find the Right Tutor. Learn Better.';
  static const String supportingText =
      'Personalized home and online tuition from qualified tutors.';

  // Lead ID format
  static const String leadPrefix = 'ETA';

  // Roles
  static const String roleSuperAdmin = 'SUPER_ADMIN';
  static const String roleAgent = 'AGENT';
  static const String roleTutor = 'TUTOR';

  // Lead statuses
  static const String leadStatusNew = 'NEW';
  static const String leadStatusMatching = 'MATCHING';
  static const String leadStatusMatched = 'MATCHED';
  static const String leadStatusTutorSuggested = 'TUTOR_SUGGESTED';
  static const String leadStatusAssigned = 'ASSIGNED';
  static const String leadStatusContacted = 'CONTACTED';
  static const String leadStatusDemoScheduled = 'DEMO_SCHEDULED';
  static const String leadStatusConverted = 'CONVERTED';
  static const String leadStatusRejected = 'REJECTED';
  static const String leadStatusCancelled = 'CANCELLED';
  static const String leadStatusNoResponse = 'NO_RESPONSE';
  static const String leadStatusLost = 'LOST';

  static const List<String> leadStatuses = [
    leadStatusNew,
    leadStatusMatching,
    leadStatusMatched,
    leadStatusTutorSuggested,
    leadStatusAssigned,
    leadStatusContacted,
    leadStatusDemoScheduled,
    leadStatusConverted,
    leadStatusRejected,
    leadStatusCancelled,
    leadStatusNoResponse,
    leadStatusLost,
  ];

  // Tutor verification statuses
  static const String verificationPending = 'PENDING';
  static const String verificationVerified = 'VERIFIED';
  static const String verificationRejected = 'REJECTED';
  static const String verificationSuspended = 'SUSPENDED';

  // Assignment types
  static const String assignmentAutomatic = 'AUTOMATIC';
  static const String assignmentRecommended = 'RECOMMENDED';
  static const String assignmentManual = 'MANUAL';

  // Assignment statuses
  static const String assignmentPending = 'PENDING';
  static const String assignmentAccepted = 'ACCEPTED';
  static const String assignmentRejected = 'REJECTED';
  static const String assignmentCancelled = 'CANCELLED';

  // Tuition statuses
  static const String tuitionActive = 'ACTIVE';
  static const String tuitionPaused = 'PAUSED';
  static const String tuitionCompleted = 'COMPLETED';
  static const String tuitionCancelled = 'CANCELLED';

  // Demo statuses
  static const String demoScheduled = 'SCHEDULED';
  static const String demoCompleted = 'COMPLETED';
  static const String demoCancelled = 'CANCELLED';
  static const String demoNoShow = 'NO_SHOW';

  // Follow-up statuses
  static const String followUpPending = 'PENDING';
  static const String followUpCompleted = 'COMPLETED';
  static const String followUpSkipped = 'SKIPPED';

  // Teaching modes
  static const String modeHome = 'HOME';
  static const String modeOnline = 'ONLINE';
  static const String modeBoth = 'BOTH';

  static const List<String> teachingModes = [modeHome, modeOnline, modeBoth];

  // Common subjects
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Hindi',
    'Social Science',
    'History',
    'Geography',
    'Political Science',
    'Economics',
    'Computer Science',
    'Accountancy',
    'Business Studies',
    'Sanskrit',
    'French',
    'German',
    'Spanish',
    'Music',
    'Art & Drawing',
    'Physical Education',
    'Environmental Science',
    'General Science',
  ];

  // Classes
  static const List<String> classes = [
    'Nursery',
    'LKG',
    'UKG',
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
    'Graduation',
    'Post Graduation',
    'Competitive Exams',
  ];

  // Days of week
  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Qualifications
  static const List<String> qualifications = [
    'High School (10th)',
    'Senior Secondary (12th)',
    'Diploma',
    'B.A.',
    'B.Sc.',
    'B.Com.',
    'B.Tech / B.E.',
    'BCA',
    'BBA',
    'B.Ed.',
    'M.A.',
    'M.Sc.',
    'M.Com.',
    'M.Tech / M.E.',
    'MCA',
    'MBA',
    'M.Ed.',
    'Ph.D.',
    'Other',
  ];

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String tutorsCollection = 'tutors';
  static const String leadsCollection = 'leads';
  static const String leadAssignmentsCollection = 'leadAssignments';
  static const String tuitionsCollection = 'tuitions';
  static const String demosCollection = 'demos';
  static const String followUpsCollection = 'followUps';
  static const String notificationsCollection = 'notifications';
  static const String auditLogsCollection = 'auditLogs';
  static const String settingsCollection = 'settings';

  // Pagination
  static const int defaultPageSize = 20;
  static const int searchDebounceMs = 400;
}
