import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead_model.dart';
import '../models/models.dart';
import 'auth_service.dart';

/// Lead repository — handles all lead CRUD and queries
class LeadRepository {
  final FirebaseFirestore _firestore;
  static const _collection = 'leads';

  LeadRepository(this._firestore);

  CollectionReference get _leadsRef => _firestore.collection(_collection);

  /// Create a new lead (public enquiry — no auth required)
  Future<String> createLead(LeadModel lead) async {
    // Generate sequential lead number
    final leadNumber = await _generateLeadNumber();

    final data = lead.toNewLeadFirestore();
    data['leadNumber'] = leadNumber;

    final docRef = await _leadsRef.add(data);
    return docRef.id;
  }

  /// Generate a sequential lead number: ETA-2026-00124
  Future<String> _generateLeadNumber() async {
    final year = DateTime.now().year;
    final counterRef = _firestore.collection('settings').doc('leadSequence');

    return _firestore.runTransaction<String>((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentSequence = 0;
      int currentYear = year;

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentYear = data['currentYear'] ?? year;
        currentSequence = data['currentSequence'] ?? 0;

        // Reset sequence for new year
        if (currentYear != year) {
          currentSequence = 0;
          currentYear = year;
        }
      }

      currentSequence++;

      transaction.set(counterRef, {
        'currentYear': currentYear,
        'currentSequence': currentSequence,
      });

      return 'ETA-$currentYear-${currentSequence.toString().padLeft(5, '0')}';
    });
  }

  /// Get a single lead by ID
  Future<LeadModel?> getLead(String id) async {
    final doc = await _leadsRef.doc(id).get();
    if (!doc.exists) return null;
    return LeadModel.fromFirestore(doc);
  }

  /// Stream a single lead (real-time updates)
  Stream<LeadModel?> streamLead(String id) {
    return _leadsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return LeadModel.fromFirestore(doc);
    });
  }

  /// Get leads with filters and pagination
  Future<List<LeadModel>> getLeads({
    String? status,
    String? assignedTutorId,
    int limit = 20,
    DocumentSnapshot? startAfter,
    String orderBy = 'createdAt',
    bool descending = true,
  }) async {
    Query query = _leadsRef.orderBy(orderBy, descending: descending);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    if (assignedTutorId != null) {
      query = query.where('assignedTutorId', isEqualTo: assignedTutorId);
    }

    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => LeadModel.fromFirestore(doc)).toList();
  }

  /// Stream leads (real-time)
  Stream<List<LeadModel>> streamLeads({
    String? status,
    int limit = 50,
  }) {
    Query query =
        _leadsRef.orderBy('createdAt', descending: true).limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LeadModel.fromFirestore(doc)).toList();
    });
  }

  /// Stream all active leads for dashboard
  Stream<List<LeadModel>> streamActiveLeads() {
    return _leadsRef
        .where('status', whereIn: [
          'NEW',
          'MATCHING',
          'MATCHED',
          'TUTOR_SUGGESTED',
          'ASSIGNED',
          'CONTACTED',
          'DEMO_SCHEDULED',
        ])
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LeadModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Update lead status with timeline entry
  Future<void> updateLeadStatus(
    String leadId,
    String newStatus, {
    String? actorId,
    String? actorName,
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    final timelineEntry = {
      'action': 'STATUS_CHANGED',
      'description': description ?? 'Status changed to $newStatus',
      'actorId': actorId,
      'actorName': actorName,
      'timestamp': Timestamp.now(),
      'metadata': {'newStatus': newStatus, ...?additionalData},
    };

    await _leadsRef.doc(leadId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([timelineEntry]),
      if (newStatus == 'CONVERTED')
        'convertedAt': FieldValue.serverTimestamp(),
      ...?additionalData,
    });
  }

  /// Update lead with match results
  Future<void> updateLeadMatches(
    String leadId,
    int matchCount,
    double bestMatchScore,
  ) async {
    await _leadsRef.doc(leadId).update({
      'matchCount': matchCount,
      'bestMatchScore': bestMatchScore,
      'status': matchCount > 0 ? 'MATCHED' : 'NEW',
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        {
          'action': 'MATCHING_COMPLETED',
          'description': matchCount > 0
              ? '$matchCount tutors matched (best: ${bestMatchScore.toStringAsFixed(0)}%)'
              : 'No matching tutors found',
          'timestamp': Timestamp.now(),
        }
      ]),
    });
  }

  /// Assign tutor to lead
  Future<void> assignTutorToLead(
    String leadId,
    String tutorId,
    String tutorName,
    String assignedBy,
    String assignedByName,
  ) async {
    await _leadsRef.doc(leadId).update({
      'assignedTutorId': tutorId,
      'assignedTutorName': tutorName,
      'status': 'ASSIGNED',
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([
        {
          'action': 'TUTOR_ASSIGNED',
          'description': '$tutorName assigned to this lead',
          'actorId': assignedBy,
          'actorName': assignedByName,
          'timestamp': Timestamp.now(),
          'metadata': {'tutorId': tutorId},
        }
      ]),
    });
  }

  /// Get lead counts by status (for dashboard metrics)
  Future<Map<String, int>> getLeadCounts() async {
    final snapshot = await _leadsRef.get();
    final counts = <String, int>{};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'UNKNOWN';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  /// Search leads by lead number or parent name
  Future<List<LeadModel>> searchLeads(String query) async {
    if (query.isEmpty) return [];

    // Search by lead number
    final byNumber = await _leadsRef
        .where('leadNumber', isGreaterThanOrEqualTo: query.toUpperCase())
        .where('leadNumber',
            isLessThanOrEqualTo: '${query.toUpperCase()}\uf8ff')
        .limit(10)
        .get();

    // Search by parent name
    final byName = await _leadsRef
        .where('parentName', isGreaterThanOrEqualTo: query)
        .where('parentName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    final results = <String, LeadModel>{};
    for (final doc in [...byNumber.docs, ...byName.docs]) {
      results[doc.id] = LeadModel.fromFirestore(doc);
    }
    return results.values.toList();
  }
}

final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepository(ref.watch(firestoreProvider));
});

/// Stream provider for all active leads
final activeLeadsProvider = StreamProvider<List<LeadModel>>((ref) {
  return ref.watch(leadRepositoryProvider).streamActiveLeads();
});

/// Stream provider for leads by status
final leadsByStatusProvider =
    StreamProvider.family<List<LeadModel>, String?>((ref, status) {
  return ref.watch(leadRepositoryProvider).streamLeads(status: status);
});
