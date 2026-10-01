import 'package:cloud_firestore/cloud_firestore.dart';

/// Complete tutor profile model
class TutorModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String? photoUrl;
  final String gender;
  final DateTime? dateOfBirth;
  final String qualification;
  final String? institution;
  final int teachingExperience; // years
  final List<String> subjects;
  final List<String> classesTaught;
  final String teachingMode; // HOME, ONLINE, BOTH
  final List<String> preferredLocations;
  final double? travelRadius; // km
  final List<String> languages;
  final Map<String, dynamic> availability;
  final double expectedFee;
  final String? aboutTutor;
  final String? previousExperience;
  final bool demoAvailability;
  final String verificationStatus; // PENDING, VERIFIED, REJECTED, SUSPENDED
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final List<TutorDocument> documents;
  final TutorPerformance performance;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  TutorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    this.photoUrl,
    required this.gender,
    this.dateOfBirth,
    required this.qualification,
    this.institution,
    this.teachingExperience = 0,
    this.subjects = const [],
    this.classesTaught = const [],
    this.teachingMode = 'BOTH',
    this.preferredLocations = const [],
    this.travelRadius,
    this.languages = const [],
    this.availability = const {},
    this.expectedFee = 0,
    this.aboutTutor,
    this.previousExperience,
    this.demoAvailability = true,
    this.verificationStatus = 'PENDING',
    this.verifiedBy,
    this.verifiedAt,
    this.documents = const [],
    TutorPerformance? performance,
    this.rating = 0,
    this.ratingCount = 0,
    required this.createdAt,
    required this.updatedAt,
  }) : performance = performance ?? TutorPerformance.empty();

  factory TutorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TutorModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      gender: data['gender'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      qualification: data['qualification'] ?? '',
      institution: data['institution'],
      teachingExperience: data['teachingExperience'] ?? 0,
      subjects: List<String>.from(data['subjects'] ?? []),
      classesTaught: List<String>.from(data['classesTaught'] ?? []),
      teachingMode: data['teachingMode'] ?? 'BOTH',
      preferredLocations: List<String>.from(data['preferredLocations'] ?? []),
      travelRadius: (data['travelRadius'] as num?)?.toDouble(),
      languages: List<String>.from(data['languages'] ?? []),
      availability: Map<String, dynamic>.from(data['availability'] ?? {}),
      expectedFee: (data['expectedFee'] as num?)?.toDouble() ?? 0,
      aboutTutor: data['aboutTutor'],
      previousExperience: data['previousExperience'],
      demoAvailability: data['demoAvailability'] ?? true,
      verificationStatus: data['verificationStatus'] ?? 'PENDING',
      verifiedBy: data['verifiedBy'],
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      documents: (data['documents'] as List?)
              ?.map((d) => TutorDocument.fromMap(d))
              .toList() ??
          [],
      performance: data['performance'] != null
          ? TutorPerformance.fromMap(data['performance'])
          : TutorPerformance.empty(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: data['ratingCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'gender': gender,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'qualification': qualification,
      'institution': institution,
      'teachingExperience': teachingExperience,
      'subjects': subjects,
      'classesTaught': classesTaught,
      'teachingMode': teachingMode,
      'preferredLocations': preferredLocations,
      'travelRadius': travelRadius,
      'languages': languages,
      'availability': availability,
      'expectedFee': expectedFee,
      'aboutTutor': aboutTutor,
      'previousExperience': previousExperience,
      'demoAvailability': demoAvailability,
      'verificationStatus': verificationStatus,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'documents': documents.map((d) => d.toMap()).toList(),
      'performance': performance.toMap(),
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isVerified => verificationStatus == 'VERIFIED';
  bool get isPending => verificationStatus == 'PENDING';

  TutorModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? gender,
    DateTime? dateOfBirth,
    String? qualification,
    String? institution,
    int? teachingExperience,
    List<String>? subjects,
    List<String>? classesTaught,
    String? teachingMode,
    List<String>? preferredLocations,
    double? travelRadius,
    List<String>? languages,
    Map<String, dynamic>? availability,
    double? expectedFee,
    String? aboutTutor,
    String? previousExperience,
    bool? demoAvailability,
    String? verificationStatus,
    String? verifiedBy,
    DateTime? verifiedAt,
    List<TutorDocument>? documents,
    TutorPerformance? performance,
    double? rating,
    int? ratingCount,
  }) {
    return TutorModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      qualification: qualification ?? this.qualification,
      institution: institution ?? this.institution,
      teachingExperience: teachingExperience ?? this.teachingExperience,
      subjects: subjects ?? this.subjects,
      classesTaught: classesTaught ?? this.classesTaught,
      teachingMode: teachingMode ?? this.teachingMode,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      travelRadius: travelRadius ?? this.travelRadius,
      languages: languages ?? this.languages,
      availability: availability ?? this.availability,
      expectedFee: expectedFee ?? this.expectedFee,
      aboutTutor: aboutTutor ?? this.aboutTutor,
      previousExperience: previousExperience ?? this.previousExperience,
      demoAvailability: demoAvailability ?? this.demoAvailability,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      documents: documents ?? this.documents,
      performance: performance ?? this.performance,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class TutorDocument {
  final String name;
  final String type; // QUALIFICATION, IDENTITY, EXPERIENCE, OTHER
  final String url;
  final DateTime uploadedAt;

  TutorDocument({
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedAt,
  });

  factory TutorDocument.fromMap(Map<String, dynamic> data) {
    return TutorDocument(
      name: data['name'] ?? '',
      type: data['type'] ?? 'OTHER',
      url: data['url'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'url': url,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}

class TutorPerformance {
  final int totalLeads;
  final int acceptedLeads;
  final int rejectedLeads;
  final int convertedLeads;
  final int cancelledTuitions;
  final int activeTuitions;
  final int completedTuitions;
  final double avgResponseTimeHours;
  final int parentComplaints;
  final double avgParentRating;

  TutorPerformance({
    this.totalLeads = 0,
    this.acceptedLeads = 0,
    this.rejectedLeads = 0,
    this.convertedLeads = 0,
    this.cancelledTuitions = 0,
    this.activeTuitions = 0,
    this.completedTuitions = 0,
    this.avgResponseTimeHours = 0,
    this.parentComplaints = 0,
    this.avgParentRating = 0,
  });

  factory TutorPerformance.empty() => TutorPerformance();

  factory TutorPerformance.fromMap(Map<String, dynamic> data) {
    return TutorPerformance(
      totalLeads: data['totalLeads'] ?? 0,
      acceptedLeads: data['acceptedLeads'] ?? 0,
      rejectedLeads: data['rejectedLeads'] ?? 0,
      convertedLeads: data['convertedLeads'] ?? 0,
      cancelledTuitions: data['cancelledTuitions'] ?? 0,
      activeTuitions: data['activeTuitions'] ?? 0,
      completedTuitions: data['completedTuitions'] ?? 0,
      avgResponseTimeHours: (data['avgResponseTimeHours'] as num?)?.toDouble() ?? 0,
      parentComplaints: data['parentComplaints'] ?? 0,
      avgParentRating: (data['avgParentRating'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalLeads': totalLeads,
      'acceptedLeads': acceptedLeads,
      'rejectedLeads': rejectedLeads,
      'convertedLeads': convertedLeads,
      'cancelledTuitions': cancelledTuitions,
      'activeTuitions': activeTuitions,
      'completedTuitions': completedTuitions,
      'avgResponseTimeHours': avgResponseTimeHours,
      'parentComplaints': parentComplaints,
      'avgParentRating': avgParentRating,
    };
  }

  double get conversionRate =>
      acceptedLeads > 0 ? (convertedLeads / acceptedLeads) * 100 : 0;

  double get acceptanceRate =>
      totalLeads > 0 ? (acceptedLeads / totalLeads) * 100 : 0;

  double get cancellationRate {
    final total = activeTuitions + completedTuitions + cancelledTuitions;
    return total > 0 ? (cancelledTuitions / total) * 100 : 0;
  }

  double get responseRate =>
      totalLeads > 0
          ? ((acceptedLeads + rejectedLeads) / totalLeads) * 100
          : 0;
}
