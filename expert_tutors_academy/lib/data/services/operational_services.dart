import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'auth_service.dart';

/// Assignment service — manages tutor-lead assignments
class AssignmentService {
  final FirebaseFirestore _firestore;
  static const _collection = 'leadAssignments';

  AssignmentService(this._firestore);

  CollectionReference get _ref => _firestore.collection(_collection);

  /// Create a new assignment
  Future<String> createAssignment(LeadAssignmentModel assignment) async {
    final docRef = await _ref.add(assignment.toFirestore());
    return docRef.id;
  }

  /// Get assignments for a lead
  Future<List<LeadAssignmentModel>> getAssignmentsForLead(
      String leadId) async {
    final snapshot = await _ref
        .where('leadId', isEqualTo: leadId)
        .orderBy('assignedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => LeadAssignmentModel.fromFirestore(doc))
        .toList();
  }

  /// Get assignments for a tutor
  Stream<List<LeadAssignmentModel>> streamAssignmentsForTutor(
      String tutorId) {
    return _ref
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('assignedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LeadAssignmentModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get pending assignments for a tutor
  Stream<List<LeadAssignmentModel>> streamPendingAssignments(
      String tutorId) {
    return _ref
        .where('tutorId', isEqualTo: tutorId)
        .where('status', isEqualTo: 'PENDING')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LeadAssignmentModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update assignment status (tutor accept/reject)
  Future<void> updateAssignmentStatus(
    String assignmentId,
    String status, {
    String? response,
  }) async {
    await _ref.doc(assignmentId).update({
      'status': status,
      'tutorResponse': response,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream all assignments (for admin)
  Stream<List<LeadAssignmentModel>> streamAllAssignments({
    String? status,
    int limit = 50,
  }) {
    Query query =
        _ref.orderBy('assignedAt', descending: true).limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LeadAssignmentModel.fromFirestore(doc))
          .toList();
    });
  }
}

/// Tuition service — manages converted tuitions
class TuitionService {
  final FirebaseFirestore _firestore;
  static const _collection = 'tuitions';

  TuitionService(this._firestore);

  CollectionReference get _ref => _firestore.collection(_collection);

  /// Create a tuition record
  Future<String> createTuition(TuitionModel tuition) async {
    final docRef = await _ref.add(tuition.toFirestore());
    return docRef.id;
  }

  /// Get tuition by ID
  Future<TuitionModel?> getTuition(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) return null;
    return TuitionModel.fromFirestore(doc);
  }

  /// Stream all tuitions
  Stream<List<TuitionModel>> streamTuitions({String? status}) {
    Query query = _ref.orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TuitionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream tuitions for a tutor
  Stream<List<TuitionModel>> streamTutorTuitions(String tutorId) {
    return _ref
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TuitionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update tuition status
  Future<void> updateTuitionStatus(String id, String status) async {
    await _ref.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get active tuition count
  Future<int> getActiveTuitionCount() async {
    final snapshot =
        await _ref.where('status', isEqualTo: 'ACTIVE').count().get();
    return snapshot.count ?? 0;
  }
}

/// Demo service
class DemoService {
  final FirebaseFirestore _firestore;
  static const _collection = 'demos';

  DemoService(this._firestore);

  CollectionReference get _ref => _firestore.collection(_collection);

  /// Create a demo
  Future<String> createDemo(DemoModel demo) async {
    final docRef = await _ref.add(demo.toFirestore());
    return docRef.id;
  }

  /// Stream today's demos
  Stream<List<DemoModel>> streamTodaysDemos() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _ref
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DemoModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream all demos
  Stream<List<DemoModel>> streamDemos({String? status}) {
    Query query = _ref.orderBy('date', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DemoModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update demo outcome
  Future<void> updateDemoOutcome(
      String id, String status, String? outcome) async {
    await _ref.doc(id).update({
      'status': status,
      'outcome': outcome,
    });
  }
}

/// Follow-up service
class FollowUpService {
  final FirebaseFirestore _firestore;
  static const _collection = 'followUps';

  FollowUpService(this._firestore);

  CollectionReference get _ref => _firestore.collection(_collection);

  /// Create a follow-up
  Future<String> createFollowUp(FollowUpModel followUp) async {
    final docRef = await _ref.add(followUp.toFirestore());
    return docRef.id;
  }

  /// Stream pending follow-ups
  Stream<List<FollowUpModel>> streamPendingFollowUps({String? assignedTo}) {
    Query query = _ref
        .where('status', isEqualTo: 'PENDING')
        .orderBy('dueDate');

    if (assignedTo != null) {
      query = query.where('assignedTo', isEqualTo: assignedTo);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FollowUpModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream due follow-ups (due today or overdue)
  Stream<List<FollowUpModel>> streamDueFollowUps() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final startOfTomorrow =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    return _ref
        .where('status', isEqualTo: 'PENDING')
        .where('dueDate', isLessThan: Timestamp.fromDate(startOfTomorrow))
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FollowUpModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Complete a follow-up
  Future<void> completeFollowUp(String id, {DateTime? nextDate}) async {
    final updates = <String, dynamic>{
      'status': 'COMPLETED',
      'completedAt': FieldValue.serverTimestamp(),
    };
    if (nextDate != null) {
      updates['nextFollowUpDate'] = Timestamp.fromDate(nextDate);
    }
    await _ref.doc(id).update(updates);
  }

  /// Skip a follow-up
  Future<void> skipFollowUp(String id) async {
    await _ref.doc(id).update({
      'status': 'SKIPPED',
    });
  }
}

/// Audit log service
class AuditService {
  final FirebaseFirestore _firestore;
  static const _collection = 'auditLogs';

  AuditService(this._firestore);

  CollectionReference get _ref => _firestore.collection(_collection);

  /// Create an audit log entry
  Future<void> log({
    required String actorId,
    required String actorRole,
    required String actorName,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    await _ref.add({
      'actorId': actorId,
      'actorRole': actorRole,
      'actorName': actorName,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'timestamp': FieldValue.serverTimestamp(),
      'metadata': metadata,
    });
  }

  /// Stream audit logs
  Stream<List<AuditLogModel>> streamAuditLogs({int limit = 100}) {
    return _ref
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AuditLogModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get audit logs for an entity
  Future<List<AuditLogModel>> getEntityAuditLogs(
      String entityType, String entityId) async {
    final snapshot = await _ref
        .where('entityType', isEqualTo: entityType)
        .where('entityId', isEqualTo: entityId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AuditLogModel.fromFirestore(doc))
        .toList();
  }
}

/// Notification service (in-app)
class NotificationService {
  final FirebaseFirestore _firestore;
  static const _collection = 'notifications';

  NotificationService(this._firestore);

  CollectionReference get _ref => _firestore.collection(_collection);

  /// Create a notification
  Future<void> createNotification(NotificationModel notification) async {
    await _ref.add(notification.toFirestore());
  }

  /// Stream notifications for a user
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _ref
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream unread count
  Stream<int> streamUnreadCount(String userId) {
    return _ref
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark as read
  Future<void> markAsRead(String notificationId) async {
    await _ref.doc(notificationId).update({'read': true});
  }

  /// Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _ref
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}

// ─── Providers ────────────────────────────────────────────────

final assignmentServiceProvider = Provider<AssignmentService>((ref) {
  return AssignmentService(ref.watch(firestoreProvider));
});

final tuitionServiceProvider = Provider<TuitionService>((ref) {
  return TuitionService(ref.watch(firestoreProvider));
});

final demoServiceProvider = Provider<DemoService>((ref) {
  return DemoService(ref.watch(firestoreProvider));
});

final followUpServiceProvider = Provider<FollowUpService>((ref) {
  return FollowUpService(ref.watch(firestoreProvider));
});

final auditServiceProvider = Provider<AuditService>((ref) {
  return AuditService(ref.watch(firestoreProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(firestoreProvider));
});

// ─── Stream Providers ─────────────────────────────────────────

final activeTuitionsProvider = StreamProvider<List<TuitionModel>>((ref) {
  return ref.watch(tuitionServiceProvider).streamTuitions(status: 'ACTIVE');
});

final allTuitionsProvider = StreamProvider<List<TuitionModel>>((ref) {
  return ref.watch(tuitionServiceProvider).streamTuitions();
});

final todaysDemosProvider = StreamProvider<List<DemoModel>>((ref) {
  return ref.watch(demoServiceProvider).streamTodaysDemos();
});

final dueFollowUpsProvider = StreamProvider<List<FollowUpModel>>((ref) {
  return ref.watch(followUpServiceProvider).streamDueFollowUps();
});

final auditLogsProvider = StreamProvider<List<AuditLogModel>>((ref) {
  return ref.watch(auditServiceProvider).streamAuditLogs();
});
