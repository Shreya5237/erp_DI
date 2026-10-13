/// Task lifecycle status adhering to the Agile ERP Specification:
/// Backlog, To Do, In Progress, In Review, Blocked, Done
enum TaskStatus {
  backlog('Backlog'),
  todo('To Do'),
  inProgress('In Progress'),
  inReview('In Review'),
  blocked('Blocked'),
  done('Done'),
  
  // Legacy compatibility values
  submitted('In Review'),
  approved('Done'),
  needsRework('Needs Rework'),
  overdue('Overdue'),
  newTask('To Do');

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

/// Company Task model with full Agile workflow support
class CompanyTask {
  final String id;
  final String title;
  final String description;
  final String domain; // "Backend", "Frontend", "Mobile App", "UI/UX", "SEO / Content"
  final String team;
  final String department; // "Technology and Engineering", "Digital Marketing", "HR", etc.
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
  final String? sprintName; // e.g. "Sprint 1", "Sprint 2"
  final int storyPoints;
  final String submissionNotes;
  final String? submissionProofUrl;
  final String? ceoReviewNotes;
  final String? blockerReason; // Description if blocked
  final int progressPercent; // 0-100
  final DateTime createdAt;
  final DateTime? completedAt;

  CompanyTask({
    required this.id,
    required this.title,
    required this.description,
    this.domain = 'Backend',
    this.team = 'Core Engineering',
    this.department = 'Technology and Engineering',
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
    this.sprintName = 'Sprint 1',
    this.storyPoints = 3,
    this.submissionNotes = '',
    this.submissionProofUrl,
    this.ceoReviewNotes,
    this.blockerReason,
    this.progressPercent = 0,
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted =>
      status == TaskStatus.done || status == TaskStatus.approved;

  bool get isOngoing =>
      status == TaskStatus.inProgress ||
      status == TaskStatus.inReview ||
      status == TaskStatus.submitted ||
      (status == TaskStatus.blocked && !isCompleted);

  bool get isUpcoming =>
      status == TaskStatus.todo ||
      status == TaskStatus.backlog ||
      status == TaskStatus.newTask;

  bool get isBlocked =>
      status == TaskStatus.blocked || (blockerReason != null && blockerReason!.isNotEmpty);

  bool get isOverdue =>
      !isCompleted && (status == TaskStatus.overdue || DateTime.now().isAfter(dueDate));

  int get daysOverdue {
    if (!isOverdue) return 0;
    final diff = DateTime.now().difference(dueDate).inDays;
    return diff <= 0 ? 1 : diff.clamp(1, 999);
  }

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }

  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate.year == tomorrow.year && dueDate.month == tomorrow.month && dueDate.day == tomorrow.day;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.difference(today).inDays;
  }

  String get deadlineCountdownText {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue by ${daysOverdue}d';
    if (isDueToday) return 'Due today';
    if (isDueTomorrow) return 'Due tomorrow';
    final rem = daysRemaining;
    if (rem > 0) return 'Due in $rem days';
    return 'Due soon';
  }

  bool get isPersonalTask =>
      assignedById == assignedToId || assignedById == 'PERSONAL' || assignedByName.toLowerCase().contains('personal');

  String get effectiveDepartment {
    if (department.isNotEmpty &&
        department != 'Technology and Engineering' &&
        department != 'Engineering') {
      return department;
    }
    final d = domain.toLowerCase();
    final t = team.toLowerCase();
    if (d.contains('ai') || d.contains('ml') || t.contains('intelligence')) {
      return 'Applied AI';
    }
    if (d.contains('design') || d.contains('ui') || d.contains('ux')) {
      return 'UI/UX Design';
    }
    if (d.contains('seo') || d.contains('market') || d.contains('content')) {
      return 'Digital Marketing';
    }
    if (d.contains('sales') || d.contains('biz') || d.contains('lead')) {
      return 'Sales & BD';
    }
    if (d.contains('hr') || d.contains('talent') || d.contains('recruit')) {
      return 'Human Resources';
    }
    if (d.contains('ops') || d.contains('finance') || d.contains('account')) {
      return 'Operations & Finance';
    }
    return 'Engineering';
  }

  /// Determines if task is eligible for progress calculation formula:
  /// Completed eligible tasks / Total eligible tasks * 100
  bool get isEligibleForProgress =>
      assignedToId.isNotEmpty && assignedToId != 'UNASSIGNED';

  CompanyTask copyWith({
    String? id,
    String? title,
    String? description,
    String? domain,
    String? team,
    String? department,
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
    String? sprintName,
    int? storyPoints,
    String? submissionNotes,
    String? submissionProofUrl,
    String? ceoReviewNotes,
    String? blockerReason,
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
      department: department ?? this.department,
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
      sprintName: sprintName ?? this.sprintName,
      storyPoints: storyPoints ?? this.storyPoints,
      submissionNotes: submissionNotes ?? this.submissionNotes,
      submissionProofUrl: submissionProofUrl ?? this.submissionProofUrl,
      ceoReviewNotes: ceoReviewNotes ?? this.ceoReviewNotes,
      blockerReason: blockerReason ?? this.blockerReason,
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
    'department': department,
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
    'sprintName': sprintName,
    'storyPoints': storyPoints,
    'submissionNotes': submissionNotes,
    'submissionProofUrl': submissionProofUrl,
    'ceoReviewNotes': ceoReviewNotes,
    'blockerReason': blockerReason,
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
    department: json['department'] as String? ?? 'Technology and Engineering',
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
      orElse: () {
        final raw = json['status']?.toString().toLowerCase();
        if (raw == 'done' || raw == 'approved') return TaskStatus.done;
        if (raw == 'in_progress' || raw == 'inprogress') return TaskStatus.inProgress;
        if (raw == 'in_review' || raw == 'inreview' || raw == 'submitted') return TaskStatus.inReview;
        if (raw == 'blocked') return TaskStatus.blocked;
        if (raw == 'backlog') return TaskStatus.backlog;
        return TaskStatus.todo;
      },
    ),
    projectId: json['projectId'] as String?,
    projectName: json['projectName'] as String?,
    sprintName: json['sprintName'] as String? ?? 'Sprint 1',
    storyPoints: json['storyPoints'] as int? ?? 3,
    submissionNotes: json['submissionNotes'] as String? ?? '',
    submissionProofUrl: json['submissionProofUrl'] as String?,
    ceoReviewNotes: json['ceoReviewNotes'] as String?,
    blockerReason: json['blockerReason'] as String?,
    progressPercent: json['progressPercent'] as int? ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
  );
}
