import 'package:cloud_firestore/cloud_firestore.dart';

/// Lead assignment record
class LeadAssignmentModel {
  final String id;
  final String leadId;
  final String leadNumber;
  final String tutorId;
  final String tutorName;
  final String assignedBy;
  final String assignedByName;
  final DateTime assignedAt;
  final String assignmentType; // AUTOMATIC, RECOMMENDED, MANUAL
  final String? assignmentNotes;
  final String status; // PENDING, ACCEPTED, REJECTED, CANCELLED
  final double? matchScore;
  final String? tutorResponse;
  final DateTime? respondedAt;
  final DateTime createdAt;

  LeadAssignmentModel({
    required this.id,
    required this.leadId,
    required this.leadNumber,
    required this.tutorId,
    required this.tutorName,
    required this.assignedBy,
    required this.assignedByName,
    required this.assignedAt,
    this.assignmentType = 'MANUAL',
    this.assignmentNotes,
    this.status = 'PENDING',
    this.matchScore,
    this.tutorResponse,
    this.respondedAt,
    required this.createdAt,
  });

  factory LeadAssignmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeadAssignmentModel(
      id: doc.id,
      leadId: data['leadId'] ?? '',
      leadNumber: data['leadNumber'] ?? '',
      tutorId: data['tutorId'] ?? '',
      tutorName: data['tutorName'] ?? '',
      assignedBy: data['assignedBy'] ?? '',
      assignedByName: data['assignedByName'] ?? '',
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignmentType: data['assignmentType'] ?? 'MANUAL',
      assignmentNotes: data['assignmentNotes'],
      status: data['status'] ?? 'PENDING',
      matchScore: (data['matchScore'] as num?)?.toDouble(),
      tutorResponse: data['tutorResponse'],
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'leadId': leadId,
      'leadNumber': leadNumber,
      'tutorId': tutorId,
      'tutorName': tutorName,
      'assignedBy': assignedBy,
      'assignedByName': assignedByName,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'assignmentType': assignmentType,
      'assignmentNotes': assignmentNotes,
      'status': status,
      'matchScore': matchScore,
      'tutorResponse': tutorResponse,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
}

/// Tuition record (converted lead)
class TuitionModel {
  final String id;
  final String leadId;
  final String leadNumber;
  final String tutorId;
  final String tutorName;
  final String studentName;
  final String parentName;
  final String parentPhone;
  final String subject;
  final String studentClass;
  final String location;
  final DateTime startDate;
  final double monthlyFee;
  final double agencyCommission;
  final double tutorPayout;
  final String status; // ACTIVE, PAUSED, COMPLETED, CANCELLED
  final DateTime? renewalDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TuitionModel({
    required this.id,
    required this.leadId,
    required this.leadNumber,
    required this.tutorId,
    required this.tutorName,
    required this.studentName,
    required this.parentName,
    required this.parentPhone,
    required this.subject,
    required this.studentClass,
    required this.location,
    required this.startDate,
    this.monthlyFee = 0,
    this.agencyCommission = 0,
    this.tutorPayout = 0,
    this.status = 'ACTIVE',
    this.renewalDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TuitionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TuitionModel(
      id: doc.id,
      leadId: data['leadId'] ?? '',
      leadNumber: data['leadNumber'] ?? '',
      tutorId: data['tutorId'] ?? '',
      tutorName: data['tutorName'] ?? '',
      studentName: data['studentName'] ?? '',
      parentName: data['parentName'] ?? '',
      parentPhone: data['parentPhone'] ?? '',
      subject: data['subject'] ?? '',
      studentClass: data['studentClass'] ?? '',
      location: data['location'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      monthlyFee: (data['monthlyFee'] as num?)?.toDouble() ?? 0,
      agencyCommission: (data['agencyCommission'] as num?)?.toDouble() ?? 0,
      tutorPayout: (data['tutorPayout'] as num?)?.toDouble() ?? 0,
      status: data['status'] ?? 'ACTIVE',
      renewalDate: (data['renewalDate'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'leadId': leadId,
      'leadNumber': leadNumber,
      'tutorId': tutorId,
      'tutorName': tutorName,
      'studentName': studentName,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'subject': subject,
      'studentClass': studentClass,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'monthlyFee': monthlyFee,
      'agencyCommission': agencyCommission,
      'tutorPayout': tutorPayout,
      'status': status,
      'renewalDate': renewalDate != null ? Timestamp.fromDate(renewalDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isActive => status == 'ACTIVE';
}

/// Demo scheduling record
class DemoModel {
  final String id;
  final String leadId;
  final String leadNumber;
  final String tutorId;
  final String tutorName;
  final String studentName;
  final String parentName;
  final String parentPhone;
  final DateTime date;
  final String time;
  final String location;
  final String? notes;
  final String status; // SCHEDULED, COMPLETED, CANCELLED, NO_SHOW
  final String? outcome;
  final DateTime createdAt;

  DemoModel({
    required this.id,
    required this.leadId,
    required this.leadNumber,
    required this.tutorId,
    required this.tutorName,
    required this.studentName,
    required this.parentName,
    required this.parentPhone,
    required this.date,
    required this.time,
    required this.location,
    this.notes,
    this.status = 'SCHEDULED',
    this.outcome,
    required this.createdAt,
  });

  factory DemoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DemoModel(
      id: doc.id,
      leadId: data['leadId'] ?? '',
      leadNumber: data['leadNumber'] ?? '',
      tutorId: data['tutorId'] ?? '',
      tutorName: data['tutorName'] ?? '',
      studentName: data['studentName'] ?? '',
      parentName: data['parentName'] ?? '',
      parentPhone: data['parentPhone'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      notes: data['notes'],
      status: data['status'] ?? 'SCHEDULED',
      outcome: data['outcome'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'leadId': leadId,
      'leadNumber': leadNumber,
      'tutorId': tutorId,
      'tutorName': tutorName,
      'studentName': studentName,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'notes': notes,
      'status': status,
      'outcome': outcome,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Follow-up task
class FollowUpModel {
  final String id;
  final String entityType; // LEAD, TUITION, ASSIGNMENT
  final String entityId;
  final String? entityNumber; // lead number
  final String assignedTo;
  final String? assignedToName;
  final DateTime dueDate;
  final String type;
  final String? notes;
  final String status; // PENDING, COMPLETED, SKIPPED
  final DateTime? completedAt;
  final DateTime? nextFollowUpDate;
  final DateTime createdAt;

  FollowUpModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.entityNumber,
    required this.assignedTo,
    this.assignedToName,
    required this.dueDate,
    required this.type,
    this.notes,
    this.status = 'PENDING',
    this.completedAt,
    this.nextFollowUpDate,
    required this.createdAt,
  });

  factory FollowUpModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FollowUpModel(
      id: doc.id,
      entityType: data['entityType'] ?? '',
      entityId: data['entityId'] ?? '',
      entityNumber: data['entityNumber'],
      assignedTo: data['assignedTo'] ?? '',
      assignedToName: data['assignedToName'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? '',
      notes: data['notes'],
      status: data['status'] ?? 'PENDING',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      nextFollowUpDate: (data['nextFollowUpDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'entityType': entityType,
      'entityId': entityId,
      'entityNumber': entityNumber,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'dueDate': Timestamp.fromDate(dueDate),
      'type': type,
      'notes': notes,
      'status': status,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'nextFollowUpDate':
          nextFollowUpDate != null ? Timestamp.fromDate(nextFollowUpDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  bool get isOverdue => isPending && dueDate.isBefore(DateTime.now());
}

/// In-app notification
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      type: d['type'] ?? '',
      data: d['data'] as Map<String, dynamic>?,
      read: d['read'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'read': read,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Audit log entry
class AuditLogModel {
  final String id;
  final String actorId;
  final String actorRole;
  final String actorName;
  final String action;
  final String entityType;
  final String entityId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AuditLogModel({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.actorName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
    this.metadata,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AuditLogModel(
      id: doc.id,
      actorId: d['actorId'] ?? '',
      actorRole: d['actorRole'] ?? '',
      actorName: d['actorName'] ?? '',
      action: d['action'] ?? '',
      entityType: d['entityType'] ?? '',
      entityId: d['entityId'] ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: d['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'actorId': actorId,
      'actorRole': actorRole,
      'actorName': actorName,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'timestamp': FieldValue.serverTimestamp(),
      'metadata': metadata,
    };
  }
}

/// Match result from the matching engine
class TutorMatchResult {
  final String tutorId;
  final TutorMatchDetails tutor;
  final double matchScore; // 0-100
  final List<String> matchReasons;
  final List<String> potentialConflicts;

  TutorMatchResult({
    required this.tutorId,
    required this.tutor,
    required this.matchScore,
    this.matchReasons = const [],
    this.potentialConflicts = const [],
  });
}

/// Lightweight tutor info for match results
class TutorMatchDetails {
  final String id;
  final String name;
  final String? photoUrl;
  final String qualification;
  final List<String> subjects;
  final List<String> classesTaught;
  final String verificationStatus;
  final double expectedFee;
  final List<String> preferredLocations;
  final double rating;
  final String teachingMode;
  final int teachingExperience;
  final Map<String, dynamic> availability;

  TutorMatchDetails({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.qualification,
    this.subjects = const [],
    this.classesTaught = const [],
    required this.verificationStatus,
    this.expectedFee = 0,
    this.preferredLocations = const [],
    this.rating = 0,
    required this.teachingMode,
    this.teachingExperience = 0,
    this.availability = const {},
  });
}
