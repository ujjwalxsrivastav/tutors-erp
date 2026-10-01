import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead_model.dart';
import '../models/tutor_model.dart';
import '../models/models.dart';
import 'auth_service.dart';
import 'tutor_service.dart';

/// Configurable matching weights
class MatchingWeights {
  final double location;
  final double subject;
  final double studentClass;
  final double qualification;
  final double availability;
  final double budget;
  final double experience;
  final double performance;
  final double parentPreference;

  const MatchingWeights({
    this.location = 25,
    this.subject = 20,
    this.studentClass = 15,
    this.qualification = 10,
    this.availability = 10,
    this.budget = 5,
    this.experience = 5,
    this.performance = 5,
    this.parentPreference = 5,
  });

  double get totalWeight =>
      location +
      subject +
      studentClass +
      qualification +
      availability +
      budget +
      experience +
      performance +
      parentPreference;

  factory MatchingWeights.fromMap(Map<String, dynamic> data) {
    return MatchingWeights(
      location: (data['location'] as num?)?.toDouble() ?? 25,
      subject: (data['subject'] as num?)?.toDouble() ?? 20,
      studentClass: (data['studentClass'] as num?)?.toDouble() ?? 15,
      qualification: (data['qualification'] as num?)?.toDouble() ?? 10,
      availability: (data['availability'] as num?)?.toDouble() ?? 10,
      budget: (data['budget'] as num?)?.toDouble() ?? 5,
      experience: (data['experience'] as num?)?.toDouble() ?? 5,
      performance: (data['performance'] as num?)?.toDouble() ?? 5,
      parentPreference: (data['parentPreference'] as num?)?.toDouble() ?? 5,
    );
  }

  Map<String, dynamic> toMap() => {
        'location': location,
        'subject': subject,
        'studentClass': studentClass,
        'qualification': qualification,
        'availability': availability,
        'budget': budget,
        'experience': experience,
        'performance': performance,
        'parentPreference': parentPreference,
      };
}

/// Deterministic tutor matching engine
class MatchingEngine {
  final FirebaseFirestore _firestore;
  final TutorRepository _tutorRepository;

  MatchingEngine(this._firestore, this._tutorRepository);

  /// Get matching weights from settings, or use defaults
  Future<MatchingWeights> getWeights() async {
    try {
      final doc =
          await _firestore.collection('settings').doc('matchingRules').get();
      if (doc.exists) {
        return MatchingWeights.fromMap(
            doc.data()?['weights'] ?? <String, dynamic>{});
      }
    } catch (_) {}
    return const MatchingWeights();
  }

  /// Save matching weights
  Future<void> saveWeights(MatchingWeights weights) async {
    await _firestore.collection('settings').doc('matchingRules').set({
      'weights': weights.toMap(),
    }, SetOptions(merge: true));
  }

  /// Run matching for a lead
  Future<List<TutorMatchResult>> matchTutorsForLead(LeadModel lead) async {
    final weights = await getWeights();
    final tutors = await _tutorRepository.getVerifiedTutors();

    if (tutors.isEmpty) return [];

    final results = <TutorMatchResult>[];

    for (final tutor in tutors) {
      final result = _scoreTutor(tutor, lead, weights);
      if (result.matchScore > 0) {
        results.add(result);
      }
    }

    // Sort by score descending
    results.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return results;
  }

  /// Score a single tutor against a lead
  TutorMatchResult _scoreTutor(
    TutorModel tutor,
    LeadModel lead,
    MatchingWeights weights,
  ) {
    double rawScore = 0;
    final reasons = <String>[];
    final conflicts = <String>[];

    // 1. Subject match
    final subjectScore = _scoreSubject(tutor, lead);
    rawScore += subjectScore * weights.subject;
    if (subjectScore >= 0.8) {
      final matchedSubjects = tutor.subjects
          .where((s) => lead.subjects.contains(s))
          .join(', ');
      reasons.add('✓ Teaches $matchedSubjects');
    } else if (subjectScore == 0) {
      conflicts.add('No matching subjects');
    }

    // 2. Class match
    final classScore = _scoreClass(tutor, lead);
    rawScore += classScore * weights.studentClass;
    if (classScore >= 0.8) {
      reasons.add('✓ ${lead.studentClass} experience');
    } else if (classScore == 0) {
      conflicts.add('Does not teach ${lead.studentClass}');
    }

    // 3. Location match
    final locationScore = _scoreLocation(tutor, lead);
    rawScore += locationScore * weights.location;
    if (locationScore >= 0.8) {
      reasons.add('✓ Same preferred location');
    } else if (locationScore > 0) {
      reasons.add('✓ Near preferred location');
    } else {
      conflicts.add('Location mismatch');
    }

    // 4. Teaching mode match
    final modeScore = _scoreMode(tutor, lead);
    rawScore += modeScore * weights.parentPreference;
    if (modeScore >= 1.0) {
      reasons.add('✓ Preferred teaching mode available');
    }

    // 5. Budget compatibility
    final budgetScore = _scoreBudget(tutor, lead);
    rawScore += budgetScore * weights.budget;
    if (budgetScore >= 0.8) {
      reasons.add('✓ Budget compatible');
    } else if (budgetScore < 0.3 && lead.budget != null) {
      conflicts.add('Fee may exceed budget');
    }

    // 6. Experience
    final expScore = _scoreExperience(tutor);
    rawScore += expScore * weights.experience;
    if (tutor.teachingExperience >= 3) {
      reasons.add('✓ ${tutor.teachingExperience} years experience');
    }

    // 7. Qualification
    final qualScore = _scoreQualification(tutor);
    rawScore += qualScore * weights.qualification;
    if (qualScore >= 0.8) {
      reasons.add('✓ Strong qualification (${tutor.qualification})');
    }

    // 8. Performance
    final perfScore = _scorePerformance(tutor);
    rawScore += perfScore * weights.performance;
    if (tutor.performance.conversionRate > 50) {
      reasons.add('✓ Strong conversion rate');
    }

    // 9. Availability (simplified — always 1.0 unless we have data)
    rawScore += 1.0 * weights.availability;
    reasons.add('✓ Available');

    // Verification bonus
    if (tutor.isVerified) {
      reasons.add('✓ Verified tutor');
    }

    // Normalize to 0-100
    final normalizedScore =
        (rawScore / weights.totalWeight * 100).clamp(0, 100).toDouble();

    return TutorMatchResult(
      tutorId: tutor.id,
      tutor: TutorMatchDetails(
        id: tutor.id,
        name: tutor.name,
        photoUrl: tutor.photoUrl,
        qualification: tutor.qualification,
        subjects: tutor.subjects,
        classesTaught: tutor.classesTaught,
        verificationStatus: tutor.verificationStatus,
        expectedFee: tutor.expectedFee,
        preferredLocations: tutor.preferredLocations,
        rating: tutor.rating,
        teachingMode: tutor.teachingMode,
        teachingExperience: tutor.teachingExperience,
        availability: tutor.availability,
      ),
      matchScore: normalizedScore,
      matchReasons: reasons,
      potentialConflicts: conflicts,
    );
  }

  double _scoreSubject(TutorModel tutor, LeadModel lead) {
    if (lead.subjects.isEmpty || tutor.subjects.isEmpty) return 0;
    final matches =
        tutor.subjects.where((s) => lead.subjects.contains(s)).length;
    return matches / lead.subjects.length;
  }

  double _scoreClass(TutorModel tutor, LeadModel lead) {
    if (tutor.classesTaught.contains(lead.studentClass)) return 1.0;
    // Partial credit for adjacent classes
    final classIndex = _classOrder.indexOf(lead.studentClass);
    if (classIndex < 0) return 0;
    for (final tc in tutor.classesTaught) {
      final tcIndex = _classOrder.indexOf(tc);
      if (tcIndex >= 0 && (classIndex - tcIndex).abs() <= 1) return 0.5;
    }
    return 0;
  }

  double _scoreLocation(TutorModel tutor, LeadModel lead) {
    if (tutor.preferredLocations.isEmpty) return 0.3; // No preference = partial

    final leadArea = lead.location.area.toLowerCase().trim();
    for (final loc in tutor.preferredLocations) {
      if (loc.toLowerCase().trim() == leadArea) return 1.0;
      if (loc.toLowerCase().contains(leadArea) ||
          leadArea.contains(loc.toLowerCase())) return 0.7;
    }

    // If lat/lng available, calculate approximate distance
    if (lead.location.lat != null && lead.location.lng != null) {
      // Simplified — in production use Haversine
      return 0.3;
    }

    return 0;
  }

  double _scoreMode(TutorModel tutor, LeadModel lead) {
    if (tutor.teachingMode == 'BOTH') return 1.0;
    if (lead.preferredMode == 'BOTH') return 1.0;
    if (tutor.teachingMode == lead.preferredMode) return 1.0;
    return 0.2;
  }

  double _scoreBudget(TutorModel tutor, LeadModel lead) {
    if (lead.budget == null || lead.budget == 0) return 0.5;
    if (tutor.expectedFee <= 0) return 0.5;

    final ratio = lead.budget! / tutor.expectedFee;
    if (ratio >= 1.0) return 1.0;
    if (ratio >= 0.8) return 0.7;
    if (ratio >= 0.6) return 0.4;
    return 0.1;
  }

  double _scoreExperience(TutorModel tutor) {
    if (tutor.teachingExperience >= 5) return 1.0;
    if (tutor.teachingExperience >= 3) return 0.8;
    if (tutor.teachingExperience >= 1) return 0.5;
    return 0.2;
  }

  double _scoreQualification(TutorModel tutor) {
    final q = tutor.qualification.toUpperCase();
    if (q.contains('PH.D') || q.contains('PHD')) return 1.0;
    if (q.contains('M.TECH') ||
        q.contains('M.SC') ||
        q.contains('M.A') ||
        q.contains('MBA')) return 0.9;
    if (q.contains('B.TECH') ||
        q.contains('B.E') ||
        q.contains('B.SC') ||
        q.contains('B.ED')) return 0.7;
    if (q.contains('B.A') || q.contains('B.COM')) return 0.6;
    return 0.3;
  }

  double _scorePerformance(TutorModel tutor) {
    final p = tutor.performance;
    if (p.totalLeads == 0) return 0.5; // New tutor, neutral score

    double score = 0;
    score += (p.conversionRate / 100) * 0.4;
    score += (p.acceptanceRate / 100) * 0.3;
    score += (1 - (p.cancellationRate / 100)) * 0.2;
    score += min(p.avgParentRating / 5.0, 1.0) * 0.1;

    return score.clamp(0, 1);
  }

  static const _classOrder = [
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
}

final matchingEngineProvider = Provider<MatchingEngine>((ref) {
  return MatchingEngine(
    ref.watch(firestoreProvider),
    ref.watch(tutorRepositoryProvider),
  );
});

/// Provider to get match results for a specific lead
final leadMatchesProvider =
    FutureProvider.family<List<TutorMatchResult>, LeadModel>(
        (ref, lead) async {
  return ref.watch(matchingEngineProvider).matchTutorsForLead(lead);
});
