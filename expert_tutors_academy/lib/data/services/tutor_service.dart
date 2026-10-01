import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tutor_model.dart';
import 'auth_service.dart';

/// Tutor repository — handles all tutor CRUD and queries
class TutorRepository {
  final FirebaseFirestore _firestore;
  static const _collection = 'tutors';

  TutorRepository(this._firestore);

  CollectionReference get _tutorsRef => _firestore.collection(_collection);

  /// Create a new tutor profile
  Future<String> createTutor(TutorModel tutor) async {
    final docRef = await _tutorsRef.add(tutor.toFirestore());
    return docRef.id;
  }

  /// Create tutor with specific ID (linked to auth UID)
  Future<void> createTutorWithId(String id, TutorModel tutor) async {
    await _tutorsRef.doc(id).set(tutor.toFirestore());
  }

  /// Get a single tutor by ID
  Future<TutorModel?> getTutor(String id) async {
    final doc = await _tutorsRef.doc(id).get();
    if (!doc.exists) return null;
    return TutorModel.fromFirestore(doc);
  }

  /// Get tutor by userId
  Future<TutorModel?> getTutorByUserId(String userId) async {
    final snapshot = await _tutorsRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return TutorModel.fromFirestore(snapshot.docs.first);
  }

  /// Stream a single tutor
  Stream<TutorModel?> streamTutor(String id) {
    return _tutorsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TutorModel.fromFirestore(doc);
    });
  }

  /// Get all tutors with optional filters
  Future<List<TutorModel>> getTutors({
    String? verificationStatus,
    List<String>? subjects,
    List<String>? classes,
    String? teachingMode,
    String? location,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _tutorsRef.orderBy('name');

    if (verificationStatus != null) {
      query = query.where('verificationStatus', isEqualTo: verificationStatus);
    }
    if (teachingMode != null && teachingMode != 'BOTH') {
      query = query.where('teachingMode', whereIn: [teachingMode, 'BOTH']);
    }

    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    var results =
        snapshot.docs.map((doc) => TutorModel.fromFirestore(doc)).toList();

    // Client-side filtering for array-contains-any constraints
    if (subjects != null && subjects.isNotEmpty) {
      results = results.where((t) {
        return t.subjects.any((s) => subjects.contains(s));
      }).toList();
    }
    if (classes != null && classes.isNotEmpty) {
      results = results.where((t) {
        return t.classesTaught.any((c) => classes.contains(c));
      }).toList();
    }
    if (location != null && location.isNotEmpty) {
      results = results.where((t) {
        return t.preferredLocations
            .any((l) => l.toLowerCase().contains(location.toLowerCase()));
      }).toList();
    }

    return results;
  }

  /// Stream all tutors
  Stream<List<TutorModel>> streamTutors({String? verificationStatus}) {
    Query query = _tutorsRef.orderBy('name');

    if (verificationStatus != null) {
      query = query.where('verificationStatus', isEqualTo: verificationStatus);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TutorModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update tutor profile
  Future<void> updateTutor(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _tutorsRef.doc(id).update(data);
  }

  /// Update verification status
  Future<void> updateVerification(
    String tutorId,
    String status,
    String verifiedBy,
  ) async {
    await _tutorsRef.doc(tutorId).update({
      'verificationStatus': status,
      'verifiedBy': verifiedBy,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update tutor performance metrics
  Future<void> updatePerformance(
    String tutorId,
    Map<String, dynamic> performanceUpdates,
  ) async {
    final updates = <String, dynamic>{};
    for (final entry in performanceUpdates.entries) {
      updates['performance.${entry.key}'] = entry.value;
    }
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _tutorsRef.doc(tutorId).update(updates);
  }

  /// Increment a performance counter
  Future<void> incrementPerformanceCounter(
    String tutorId,
    String field, [
    int increment = 1,
  ]) async {
    await _tutorsRef.doc(tutorId).update({
      'performance.$field': FieldValue.increment(increment),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Search tutors by name
  Future<List<TutorModel>> searchTutors(String query) async {
    if (query.isEmpty) return [];

    final snapshot = await _tutorsRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => TutorModel.fromFirestore(doc))
        .toList();
  }

  /// Get verified tutors for matching
  Future<List<TutorModel>> getVerifiedTutors() async {
    final snapshot = await _tutorsRef
        .where('verificationStatus', isEqualTo: 'VERIFIED')
        .get();

    return snapshot.docs
        .map((doc) => TutorModel.fromFirestore(doc))
        .toList();
  }

  /// Get tutor count
  Future<int> getTutorCount({String? verificationStatus}) async {
    Query query = _tutorsRef;
    if (verificationStatus != null) {
      query = query.where('verificationStatus', isEqualTo: verificationStatus);
    }
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }
}

final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  return TutorRepository(ref.watch(firestoreProvider));
});

/// Stream all tutors
final allTutorsProvider = StreamProvider<List<TutorModel>>((ref) {
  return ref.watch(tutorRepositoryProvider).streamTutors();
});

/// Stream verified tutors
final verifiedTutorsProvider = StreamProvider<List<TutorModel>>((ref) {
  return ref
      .watch(tutorRepositoryProvider)
      .streamTutors(verificationStatus: 'VERIFIED');
});
