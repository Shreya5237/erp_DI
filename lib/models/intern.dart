import 'hierarchy.dart';

/// 14 Internship & Recruitment lifecycle statuses defined in the ERP PRD
enum InternStatus {
  applied('Applied'),
  interviewScheduled('Interview Scheduled'),
  selected('Selected'),
  internshipActive('Internship Active'),
  taskAssigned('Task Assigned'),
  underEvaluation('Under Evaluation'),
  goodPerformance('Good Performance'),
  needsImprovement('Needs Improvement'),
  notInterested('Not Interested'),
  recommendedForHiring('Recommended for Hiring'),
  hired('Hired'),
  internshipExtended('Internship Extended'),
  completed('Completed'),
  closed('Not Selected / Closed');

  final String label;
  const InternStatus(this.label);
}

/// Final hiring/internship outcome status
enum InternFinalDecision {
  pending('Pending Review'),
  retain('Retained'),
  reject('Rejected'),
  notInterested('Not Interested'),
  hired('Hired as Employee'),
  extended('Internship Extended');

  final String label;
  const InternFinalDecision(this.label);
}

/// Evaluation scores on the 5 PRD criteria
class InternEvaluationRubric {
  final double taskQuality; // 1.0 - 5.0
  final double consistency; // 1.0 - 5.0
  final double interest; // 1.0 - 5.0
  final double learningProgress; // 1.0 - 5.0
  final double communication; // 1.0 - 5.0

  const InternEvaluationRubric({
    this.taskQuality = 4.0,
    this.consistency = 4.0,
    this.interest = 4.5,
    this.learningProgress = 4.0,
    this.communication = 4.0,
  });

  double get averageScore =>
      (taskQuality + consistency + interest + learningProgress + communication) / 5.0;

  Map<String, dynamic> toJson() => {
    'taskQuality': taskQuality,
    'consistency': consistency,
    'interest': interest,
    'learningProgress': learningProgress,
    'communication': communication,
  };

  factory InternEvaluationRubric.fromJson(Map<String, dynamic> json) =>
      InternEvaluationRubric(
        taskQuality: (json['taskQuality'] as num?)?.toDouble() ?? 4.0,
        consistency: (json['consistency'] as num?)?.toDouble() ?? 4.0,
        interest: (json['interest'] as num?)?.toDouble() ?? 4.5,
        learningProgress: (json['learningProgress'] as num?)?.toDouble() ?? 4.0,
        communication: (json['communication'] as num?)?.toDouble() ?? 4.0,
      );
}

/// Model representing an intern in the Friday batch recruitment & evaluation cycle
class Intern {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String college;
  final RoleCategory category;
  final String domain;
  final String team;
  final String batchId;
  final String batchName;
  final double interviewScore; // e.g. 8.5/10
  final DateTime selectionDate;
  final String? assignedPocId;
  final String? assignedPocName;
  final InternStatus status;
  final InternEvaluationRubric evaluationRubric;
  final String latestFeedback;
  final InternFinalDecision finalDecision;
  final String? closeReason; // recorded reason if closed/extended
  final bool isActive;
  final int completedTasks;
  final int totalTasks;
  final int missedUpdatesDays;
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
    this.status = InternStatus.internshipActive,
    double? performanceRating,
    InternEvaluationRubric? evaluationRubric,
    this.latestFeedback = '1-week observation period active.',
    this.finalDecision = InternFinalDecision.pending,
    this.closeReason,
    this.isActive = true,
    this.completedTasks = 0,
    this.totalTasks = 0,
    this.missedUpdatesDays = 0,
    this.lastActiveDate,
  }) : evaluationRubric = evaluationRubric ??
            (performanceRating != null
                ? InternEvaluationRubric(
                    taskQuality: performanceRating,
                    consistency: performanceRating,
                    interest: performanceRating,
                    learningProgress: performanceRating,
                    communication: performanceRating,
                  )
                : const InternEvaluationRubric());

  double get performanceRating => evaluationRubric.averageScore;

  bool get isUnderOneWeekEvaluation =>
      status == InternStatus.underEvaluation || status == InternStatus.internshipActive;

  bool get isRecommendedForHire =>
      status == InternStatus.recommendedForHiring ||
      finalDecision == InternFinalDecision.hired ||
      performanceRating >= 4.2;

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
    InternStatus? status,
    InternEvaluationRubric? evaluationRubric,
    double? performanceRating,
    String? latestFeedback,
    InternFinalDecision? finalDecision,
    String? closeReason,
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
      status: status ?? this.status,
      evaluationRubric: evaluationRubric ??
          (performanceRating != null
              ? InternEvaluationRubric(
                  taskQuality: performanceRating,
                  consistency: performanceRating,
                  interest: performanceRating,
                  learningProgress: performanceRating,
                  communication: performanceRating,
                )
              : this.evaluationRubric),
      latestFeedback: latestFeedback ?? this.latestFeedback,
      finalDecision: finalDecision ?? this.finalDecision,
      closeReason: closeReason ?? this.closeReason,
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
    'status': status.name,
    'evaluationRubric': evaluationRubric.toJson(),
    'performanceRating': performanceRating,
    'latestFeedback': latestFeedback,
    'finalDecision': finalDecision.name,
    'closeReason': closeReason,
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
    status: InternStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => InternStatus.internshipActive,
    ),
    evaluationRubric: json['evaluationRubric'] != null
        ? InternEvaluationRubric.fromJson(json['evaluationRubric'] as Map<String, dynamic>)
        : InternEvaluationRubric(
            taskQuality: (json['performanceRating'] as num?)?.toDouble() ?? 4.0,
            consistency: (json['performanceRating'] as num?)?.toDouble() ?? 4.0,
            interest: (json['performanceRating'] as num?)?.toDouble() ?? 4.5,
            learningProgress: (json['performanceRating'] as num?)?.toDouble() ?? 4.0,
            communication: (json['performanceRating'] as num?)?.toDouble() ?? 4.0,
          ),
    latestFeedback: json['latestFeedback'] as String? ?? '',
    finalDecision: InternFinalDecision.values.firstWhere(
      (e) => e.name == json['finalDecision'],
      orElse: () => InternFinalDecision.pending,
    ),
    closeReason: json['closeReason'] as String?,
    isActive: json['isActive'] as bool? ?? true,
    completedTasks: json['completedTasks'] as int? ?? 0,
    totalTasks: json['totalTasks'] as int? ?? 0,
    missedUpdatesDays: json['missedUpdatesDays'] as int? ?? 0,
    lastActiveDate: json['lastActiveDate'] != null
        ? DateTime.parse(json['lastActiveDate'] as String)
        : null,
  );
}

/// Represents a weekly intake Friday batch (50-70 candidates, ~25 selected)
class InternBatch {
  final String id;
  final String code; // e.g. "Friday Batch W41"
  final String title;
  final DateTime interviewDate;
  final int candidatesInterviewed; // 50 - 70
  final int internsSelected; // ~25
  final int activeEvaluationCount;
  final int convertedToEmployees;
  final String status;

  InternBatch({
    required this.id,
    required this.code,
    required this.title,
    DateTime? interviewDate,
    DateTime? startDate,
    int? candidatesInterviewed,
    int? interviewedCount,
    int? internsSelected,
    int? selectedCount,
    int? activeEvaluationCount,
    int? activeCount,
    this.convertedToEmployees = 0,
    this.status = '1-Week Observation Active',
  })  : interviewDate = interviewDate ?? startDate ?? DateTime.now(),
        candidatesInterviewed = candidatesInterviewed ?? interviewedCount ?? 60,
        internsSelected = internsSelected ?? selectedCount ?? 25,
        activeEvaluationCount = activeEvaluationCount ?? activeCount ?? 25;

  // Backward compatibility alias
  DateTime get startDate => interviewDate;
  int get interviewedCount => candidatesInterviewed;
  int get selectedCount => internsSelected;
  int get activeCount => activeEvaluationCount;
}
