/// Task lifecycle status
enum TaskStatus {
  todo('To Do'),
  inProgress('In Progress'),
  submitted('Submitted'),
  approved('Completed'),
  needsRework('Needs Rework'),
  overdue('Overdue'),
  newTask('New');

  final String label;
  const TaskStatus(this.label);
}

/// Task urgency priority
enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  final String label;
  const TaskPriority(this.label);
}

/// Target assignee classification
enum AssigneeType {
  employee('Employee'),
  intern('Intern');

  final String label;
  const AssigneeType(this.label);
}

/// Task model
class CompanyTask {
  final String id;
  final String title;
  final String description;
  final String domain; // "Backend", "Frontend", "Mobile App", etc.
  final String team;
  final String assignedToId;
  final String assignedToName;
  final AssigneeType assigneeType;
  final String assignedById;
  final String assignedByName;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? projectId;
  final String? projectName;
  final String submissionNotes;
  final String? submissionProofUrl;
  final String? ceoReviewNotes;
  final int progressPercent; // 0-100
  final DateTime createdAt;
  final DateTime? completedAt;

  CompanyTask({
    required this.id,
    required this.title,
    required this.description,
    this.domain = 'Backend',
    this.team = 'Core Engineering',
    required this.assignedToId,
    required this.assignedToName,
    required this.assigneeType,
    required this.assignedById,
    required this.assignedByName,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.projectId,
    this.projectName,
    this.submissionNotes = '',
    this.submissionProofUrl,
    this.ceoReviewNotes,
    this.progressPercent = 0,
    required this.createdAt,
    this.completedAt,
  });

  bool get isOverdue =>
      status != TaskStatus.approved && DateTime.now().isAfter(dueDate);

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays.clamp(1, 999);
  }

  CompanyTask copyWith({
    String? id,
    String? title,
    String? description,
    String? domain,
    String? team,
    String? assignedToId,
    String? assignedToName,
    AssigneeType? assigneeType,
    String? assignedById,
    String? assignedByName,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? projectId,
    String? projectName,
    String? submissionNotes,
    String? submissionProofUrl,
    String? ceoReviewNotes,
    int? progressPercent,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return CompanyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      team: team ?? this.team,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      assigneeType: assigneeType ?? this.assigneeType,
      assignedById: assignedById ?? this.assignedById,
      assignedByName: assignedByName ?? this.assignedByName,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      submissionNotes: submissionNotes ?? this.submissionNotes,
      submissionProofUrl: submissionProofUrl ?? this.submissionProofUrl,
      ceoReviewNotes: ceoReviewNotes ?? this.ceoReviewNotes,
      progressPercent: progressPercent ?? this.progressPercent,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'domain': domain,
    'team': team,
    'assignedToId': assignedToId,
    'assignedToName': assignedToName,
    'assigneeType': assigneeType.name,
    'assignedById': assignedById,
    'assignedByName': assignedByName,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority.name,
    'status': status.name,
    'projectId': projectId,
    'projectName': projectName,
    'submissionNotes': submissionNotes,
    'submissionProofUrl': submissionProofUrl,
    'ceoReviewNotes': ceoReviewNotes,
    'progressPercent': progressPercent,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory CompanyTask.fromJson(Map<String, dynamic> json) => CompanyTask(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    domain: json['domain'] as String? ?? 'Backend',
    team: json['team'] as String? ?? 'Core Engineering',
    assignedToId: json['assignedToId'] as String,
    assignedToName: json['assignedToName'] as String,
    assigneeType: AssigneeType.values.firstWhere(
      (e) => e.name == json['assigneeType'],
      orElse: () => AssigneeType.employee,
    ),
    assignedById: json['assignedById'] as String,
    assignedByName: json['assignedByName'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    priority: TaskPriority.values.firstWhere(
      (e) => e.name == json['priority'],
      orElse: () => TaskPriority.medium,
    ),
    status: TaskStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => TaskStatus.todo,
    ),
    projectId: json['projectId'] as String?,
    projectName: json['projectName'] as String?,
    submissionNotes: json['submissionNotes'] as String? ?? '',
    submissionProofUrl: json['submissionProofUrl'] as String?,
    ceoReviewNotes: json['ceoReviewNotes'] as String?,
    progressPercent: json['progressPercent'] as int? ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
  );
}
