import 'package:cloud_firestore/cloud_firestore.dart';

/// Lead model — represents a parent enquiry
class LeadModel {
  final String id;
  final String leadNumber; // ETA-2026-00124
  final String parentName;
  final String phone;
  final String? whatsappNumber;
  final String studentName;
  final String studentClass;
  final List<String> subjects;
  final LeadLocation location;
  final String preferredMode; // HOME, ONLINE, BOTH
  final List<String> preferredDays;
  final String? preferredTiming;
  final double? budget;
  final String? additionalRequirements;
  final String status;
  final int matchCount;
  final double? bestMatchScore;
  final String? assignedTutorId;
  final String? assignedTutorName;
  final String? source;
  final List<LeadTimelineEntry> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? convertedAt;

  LeadModel({
    required this.id,
    required this.leadNumber,
    required this.parentName,
    required this.phone,
    this.whatsappNumber,
    required this.studentName,
    required this.studentClass,
    this.subjects = const [],
    required this.location,
    this.preferredMode = 'BOTH',
    this.preferredDays = const [],
    this.preferredTiming,
    this.budget,
    this.additionalRequirements,
    this.status = 'NEW',
    this.matchCount = 0,
    this.bestMatchScore,
    this.assignedTutorId,
    this.assignedTutorName,
    this.source,
    this.timeline = const [],
    required this.createdAt,
    required this.updatedAt,
    this.convertedAt,
  });

  factory LeadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeadModel(
      id: doc.id,
      leadNumber: data['leadNumber'] ?? '',
      parentName: data['parentName'] ?? '',
      phone: data['phone'] ?? '',
      whatsappNumber: data['whatsappNumber'],
      studentName: data['studentName'] ?? '',
      studentClass: data['studentClass'] ?? '',
      subjects: List<String>.from(data['subjects'] ?? []),
      location: LeadLocation.fromMap(data['location'] ?? {}),
      preferredMode: data['preferredMode'] ?? 'BOTH',
      preferredDays: List<String>.from(data['preferredDays'] ?? []),
      preferredTiming: data['preferredTiming'],
      budget: (data['budget'] as num?)?.toDouble(),
      additionalRequirements: data['additionalRequirements'],
      status: data['status'] ?? 'NEW',
      matchCount: data['matchCount'] ?? 0,
      bestMatchScore: (data['bestMatchScore'] as num?)?.toDouble(),
      assignedTutorId: data['assignedTutorId'],
      assignedTutorName: data['assignedTutorName'],
      source: data['source'],
      timeline: (data['timeline'] as List?)
              ?.map((t) => LeadTimelineEntry.fromMap(t))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      convertedAt: (data['convertedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'leadNumber': leadNumber,
      'parentName': parentName,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'studentName': studentName,
      'studentClass': studentClass,
      'subjects': subjects,
      'location': location.toMap(),
      'preferredMode': preferredMode,
      'preferredDays': preferredDays,
      'preferredTiming': preferredTiming,
      'budget': budget,
      'additionalRequirements': additionalRequirements,
      'status': status,
      'matchCount': matchCount,
      'bestMatchScore': bestMatchScore,
      'assignedTutorId': assignedTutorId,
      'assignedTutorName': assignedTutorName,
      'source': source,
      'timeline': timeline.map((t) => t.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'convertedAt': convertedAt != null ? Timestamp.fromDate(convertedAt!) : null,
    };
  }

  /// For public enquiry (no auth), create minimal write map
  Map<String, dynamic> toNewLeadFirestore() {
    return {
      'parentName': parentName,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'studentName': studentName,
      'studentClass': studentClass,
      'subjects': subjects,
      'location': location.toMap(),
      'preferredMode': preferredMode,
      'preferredDays': preferredDays,
      'preferredTiming': preferredTiming,
      'budget': budget,
      'additionalRequirements': additionalRequirements,
      'status': 'NEW',
      'matchCount': 0,
      'bestMatchScore': null,
      'assignedTutorId': null,
      'assignedTutorName': null,
      'source': 'WEBSITE',
      'timeline': [
        LeadTimelineEntry(
          action: 'LEAD_CREATED',
          description: 'Enquiry received from website',
          timestamp: DateTime.now(),
        ).toMap(),
      ],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'convertedAt': null,
    };
  }

  bool get isNew => status == 'NEW';
  bool get isConverted => status == 'CONVERTED';
  bool get isActive =>
      !['CONVERTED', 'REJECTED', 'CANCELLED', 'LOST', 'NO_RESPONSE'].contains(status);

  LeadModel copyWith({
    String? leadNumber,
    String? parentName,
    String? phone,
    String? whatsappNumber,
    String? studentName,
    String? studentClass,
    List<String>? subjects,
    LeadLocation? location,
    String? preferredMode,
    List<String>? preferredDays,
    String? preferredTiming,
    double? budget,
    String? additionalRequirements,
    String? status,
    int? matchCount,
    double? bestMatchScore,
    String? assignedTutorId,
    String? assignedTutorName,
    String? source,
    List<LeadTimelineEntry>? timeline,
    DateTime? convertedAt,
  }) {
    return LeadModel(
      id: id,
      leadNumber: leadNumber ?? this.leadNumber,
      parentName: parentName ?? this.parentName,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      studentName: studentName ?? this.studentName,
      studentClass: studentClass ?? this.studentClass,
      subjects: subjects ?? this.subjects,
      location: location ?? this.location,
      preferredMode: preferredMode ?? this.preferredMode,
      preferredDays: preferredDays ?? this.preferredDays,
      preferredTiming: preferredTiming ?? this.preferredTiming,
      budget: budget ?? this.budget,
      additionalRequirements:
          additionalRequirements ?? this.additionalRequirements,
      status: status ?? this.status,
      matchCount: matchCount ?? this.matchCount,
      bestMatchScore: bestMatchScore ?? this.bestMatchScore,
      assignedTutorId: assignedTutorId ?? this.assignedTutorId,
      assignedTutorName: assignedTutorName ?? this.assignedTutorName,
      source: source ?? this.source,
      timeline: timeline ?? this.timeline,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      convertedAt: convertedAt ?? this.convertedAt,
    );
  }
}

class LeadLocation {
  final String area;
  final String? city;
  final double? lat;
  final double? lng;

  LeadLocation({
    required this.area,
    this.city,
    this.lat,
    this.lng,
  });

  factory LeadLocation.fromMap(Map<String, dynamic> data) {
    return LeadLocation(
      area: data['area'] ?? '',
      city: data['city'],
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'area': area,
      'city': city,
      'lat': lat,
      'lng': lng,
    };
  }

  String get displayText => city != null ? '$area, $city' : area;
}

class LeadTimelineEntry {
  final String action;
  final String description;
  final String? actorId;
  final String? actorName;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  LeadTimelineEntry({
    required this.action,
    required this.description,
    this.actorId,
    this.actorName,
    required this.timestamp,
    this.metadata,
  });

  factory LeadTimelineEntry.fromMap(Map<String, dynamic> data) {
    return LeadTimelineEntry(
      action: data['action'] ?? '',
      description: data['description'] ?? '',
      actorId: data['actorId'],
      actorName: data['actorName'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'description': description,
      'actorId': actorId,
      'actorName': actorName,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}
