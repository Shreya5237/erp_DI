import 'hierarchy.dart';

/// Final hiring/internship outcome status
enum InternFinalDecision {
  pending('Pending Review'),
  retain('Retained'),
  reject('Rejected'),
  notInterested('Not Interested');

  final String label;
  const InternFinalDecision(this.label);
}

/// Model representing an intern
class Intern {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String college;
  final RoleCategory category;
  final String domain; // "Backend", "Frontend", "Mobile App", etc.
  final String team;
  final String batchId;
  final String batchName;
  final double interviewScore; // e.g. 8.5/10
  final DateTime selectionDate;
  final String? assignedPocId;
  final String? assignedPocName;
  final double performanceRating; // e.g. 4.2 / 5.0
  final String latestFeedback;
  final InternFinalDecision finalDecision;
  final bool isActive;
  final int completedTasks;
  final int totalTasks;
  final int missedUpdatesDays; // Number of consecutive missed daily standup updates
  final DateTime? lastActiveDate;

  Intern({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.college,
    this.category = RoleCategory.technical,
    required this.domain,
    this.team = 'Core Team',
    required this.batchId,
    required this.batchName,
    required this.interviewScore,
    required this.selectionDate,
    this.assignedPocId,
    this.assignedPocName,
    this.performanceRating = 4.0,
    this.latestFeedback = 'Orientation completed.',
    this.finalDecision = InternFinalDecision.pending,
    this.isActive = true,
    this.completedTasks = 0,
    this.totalTasks = 0,
    this.missedUpdatesDays = 0,
    this.lastActiveDate,
  });

  Intern copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? college,
    RoleCategory? category,
    String? domain,
    String? team,
    String? batchId,
    String? batchName,
    double? interviewScore,
    DateTime? selectionDate,
    String? assignedPocId,
    String? assignedPocName,
    double? performanceRating,
    String? latestFeedback,
    InternFinalDecision? finalDecision,
    bool? isActive,
    int? completedTasks,
    int? totalTasks,
    int? missedUpdatesDays,
    DateTime? lastActiveDate,
  }) {
    return Intern(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      college: college ?? this.college,
      category: category ?? this.category,
      domain: domain ?? this.domain,
      team: team ?? this.team,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      interviewScore: interviewScore ?? this.interviewScore,
      selectionDate: selectionDate ?? this.selectionDate,
      assignedPocId: assignedPocId ?? this.assignedPocId,
      assignedPocName: assignedPocName ?? this.assignedPocName,
      performanceRating: performanceRating ?? this.performanceRating,
      latestFeedback: latestFeedback ?? this.latestFeedback,
      finalDecision: finalDecision ?? this.finalDecision,
      isActive: isActive ?? this.isActive,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      missedUpdatesDays: missedUpdatesDays ?? this.missedUpdatesDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'college': college,
    'category': category.name,
    'domain': domain,
    'team': team,
    'batchId': batchId,
    'batchName': batchName,
    'interviewScore': interviewScore,
    'selectionDate': selectionDate.toIso8601String(),
    'assignedPocId': assignedPocId,
    'assignedPocName': assignedPocName,
    'performanceRating': performanceRating,
    'latestFeedback': latestFeedback,
    'finalDecision': finalDecision.name,
    'isActive': isActive,
    'completedTasks': completedTasks,
    'totalTasks': totalTasks,
    'missedUpdatesDays': missedUpdatesDays,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
  };

  factory Intern.fromJson(Map<String, dynamic> json) => Intern(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    college: json['college'] as String,
    category: RoleCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => RoleCategory.technical,
    ),
    domain: json['domain'] as String,
    team: json['team'] as String? ?? 'Core Team',
    batchId: json['batchId'] as String,
    batchName: json['batchName'] as String,
    interviewScore: (json['interviewScore'] as num).toDouble(),
    selectionDate: DateTime.parse(json['selectionDate'] as String),
    assignedPocId: json['assignedPocId'] as String?,
    assignedPocName: json['assignedPocName'] as String?,
    performanceRating: (json['performanceRating'] as num?)?.toDouble() ?? 4.0,
    latestFeedback: json['latestFeedback'] as String? ?? '',
    finalDecision: InternFinalDecision.values.firstWhere(
      (e) => e.name == json['finalDecision'],
      orElse: () => InternFinalDecision.pending,
    ),
    isActive: json['isActive'] as bool? ?? true,
    completedTasks: json['completedTasks'] as int? ?? 0,
    totalTasks: json['totalTasks'] as int? ?? 0,
    missedUpdatesDays: json['missedUpdatesDays'] as int? ?? 0,
    lastActiveDate: json['lastActiveDate'] != null
        ? DateTime.parse(json['lastActiveDate'] as String)
        : null,
  );
}

/// Represents a weekly intake batch
class InternBatch {
  final String id;
  final String code; // e.g. "Batch 2026-W41"
  final String title;
  final DateTime startDate;
  final int interviewedCount;
  final int selectedCount;
  final int activeCount;
  final String status;

  InternBatch({
    required this.id,
    required this.code,
    required this.title,
    required this.startDate,
    required this.interviewedCount,
    required this.selectedCount,
    required this.activeCount,
    this.status = 'Active',
  });
}
