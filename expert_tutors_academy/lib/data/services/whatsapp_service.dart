import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WhatsApp integration service abstraction.
/// In production, this connects to WhatsApp Cloud API through Cloud Functions.
/// In development, it logs messages instead of sending.
abstract class WhatsAppService {
  /// Send a new lead notification to the agency
  Future<void> sendNewLeadNotification({
    required String leadNumber,
    required String studentName,
    required String studentClass,
    required List<String> subjects,
    required String location,
    required String mode,
    required String? timing,
    required double? budget,
    required String viewLeadUrl,
  });

  /// Send a tutor assignment notification
  Future<void> sendTutorAssignmentNotification({
    required String tutorName,
    required String tutorPhone,
    required String leadNumber,
    required String studentClass,
    required List<String> subjects,
    required String location,
  });

  /// Send a demo reminder
  Future<void> sendDemoReminder({
    required String recipientPhone,
    required String recipientName,
    required String demoDate,
    required String demoTime,
    required String location,
    required String studentName,
  });
}

/// Development fallback — logs messages to console
class DevelopmentWhatsAppService implements WhatsAppService {
  @override
  Future<void> sendNewLeadNotification({
    required String leadNumber,
    required String studentName,
    required String studentClass,
    required List<String> subjects,
    required String location,
    required String mode,
    required String? timing,
    required double? budget,
    required String viewLeadUrl,
  }) async {
    final message = '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 WhatsApp Notification (DEV)
━━━━━━━━━━━━━━━━━━━━━━━━━━━

NEW LEAD 🚨

Lead ID: $leadNumber
Student: $studentName
Class: $studentClass
Subject: ${subjects.join(', ')}
Location: $location
Mode: $mode
Preferred timing: ${timing ?? 'Not specified'}
Budget: ${budget != null ? '₹$budget/month' : 'Not specified'}

View Lead: $viewLeadUrl

━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
    // ignore: avoid_print
    print(message);
  }

  @override
  Future<void> sendTutorAssignmentNotification({
    required String tutorName,
    required String tutorPhone,
    required String leadNumber,
    required String studentClass,
    required List<String> subjects,
    required String location,
  }) async {
    // ignore: avoid_print
    print('''
📱 [DEV] WhatsApp to $tutorName ($tutorPhone):
You have been assigned to $leadNumber
Class: $studentClass | Subject: ${subjects.join(', ')} | Location: $location
''');
  }

  @override
  Future<void> sendDemoReminder({
    required String recipientPhone,
    required String recipientName,
    required String demoDate,
    required String demoTime,
    required String location,
    required String studentName,
  }) async {
    // ignore: avoid_print
    print('''
📱 [DEV] WhatsApp Demo Reminder to $recipientName ($recipientPhone):
Demo on $demoDate at $demoTime
Location: $location
Student: $studentName
''');
  }
}

/// Production WhatsApp service — connects to Cloud Functions
/// which in turn call WhatsApp Cloud API
class ProductionWhatsAppService implements WhatsAppService {
  // In production, this would call a Cloud Function endpoint
  // that handles the WhatsApp Cloud API integration.
  //
  // Required environment variables (on Cloud Functions):
  //   WHATSAPP_PHONE_NUMBER_ID   - Your WhatsApp Business phone number ID
  //   WHATSAPP_ACCESS_TOKEN      - Meta Cloud API access token
  //   WHATSAPP_BUSINESS_ACCOUNT_ID - Your business account ID
  //   AGENCY_PHONE_NUMBER        - Agency notification phone number

  @override
  Future<void> sendNewLeadNotification({
    required String leadNumber,
    required String studentName,
    required String studentClass,
    required List<String> subjects,
    required String location,
    required String mode,
    required String? timing,
    required double? budget,
    required String viewLeadUrl,
  }) async {
    // TODO: Call Cloud Function endpoint
    // POST /api/whatsapp/send-lead-notification
    throw UnimplementedError(
      'Production WhatsApp integration requires Cloud Functions setup. '
      'See documentation for WHATSAPP_PHONE_NUMBER_ID, WHATSAPP_ACCESS_TOKEN configuration.',
    );
  }

  @override
  Future<void> sendTutorAssignmentNotification({
    required String tutorName,
    required String tutorPhone,
    required String leadNumber,
    required String studentClass,
    required List<String> subjects,
    required String location,
  }) async {
    throw UnimplementedError('Configure WhatsApp Cloud API credentials.');
  }

  @override
  Future<void> sendDemoReminder({
    required String recipientPhone,
    required String recipientName,
    required String demoDate,
    required String demoTime,
    required String location,
    required String studentName,
  }) async {
    throw UnimplementedError('Configure WhatsApp Cloud API credentials.');
  }
}

/// Toggle between development and production
const bool _isProduction = false;

final whatsAppServiceProvider = Provider<WhatsAppService>((ref) {
  if (_isProduction) {
    return ProductionWhatsAppService();
  }
  return DevelopmentWhatsAppService();
});
