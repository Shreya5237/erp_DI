/// Project delivery status
enum ProjectStatus {
  planning('Planning'),
  inProgress('In Progress'),
  onHold('On Hold'),
  completed('Completed'),
  delayed('Delayed');

  final String label;
  const ProjectStatus(this.label);
}

/// Project milestone item
class ProjectMilestone {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;

  ProjectMilestone({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });

  ProjectMilestone copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return ProjectMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) => ProjectMilestone(
    id: json['id'] as String,
    title: json['title'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

/// Model representing a client project adhering to Sections 5 & 6 of ERP PRD
class Project {
  final String id;
  final String name;
  final String clientName;
  final String domain; // "Mobile App", "Web Platform", "Digital Marketing", "AI & Automation"
  final String team;
  final List<String> assignedDepartments; // Multi-dept: Tech & Marketing cross-collaboration
  final String description;
  final String deliverablesScope;
  final double budget;
  final String ownerEmployeeId;
  final String ownerEmployeeName;
  final List<String> teamMemberNames;
  final List<ProjectMilestone> milestones;
  final double progress; // 0.0 to 1.0 (actual)
  final double plannedProgress; // 0.0 to 1.0 (target based on timeline)
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime deadline;
  final List<String> activeBlockers;
  final String? sourceLeadId;
  final bool hasResourceConflict;
  final String? resourceConflictNotes;

  Project({
    required this.id,
    required this.name,
    required this.clientName,
    this.domain = 'Mobile App',
    this.team = 'Core Engineering',
    this.assignedDepartments = const ['Technology and Engineering'],
    required this.description,
    this.deliverablesScope = 'Full frontend, backend API, UI design & SEO launch package',
    required this.budget,
    required this.ownerEmployeeId,
    required this.ownerEmployeeName,
    this.teamMemberNames = const [],
    this.milestones = const [],
    this.progress = 0.0,
    this.plannedProgress = 0.5,
    this.status = ProjectStatus.inProgress,
    required this.startDate,
    required this.deadline,
    this.activeBlockers = const [],
    this.sourceLeadId,
    this.hasResourceConflict = false,
    this.resourceConflictNotes,
  });

  bool get hasBlockers => activeBlockers.isNotEmpty;

  /// Behind progress percentage (0 - 100)
  int get behindSchedulePercent {
    final diff = ((plannedProgress - progress) * 100).round();
    return diff > 0 ? diff : 0;
  }

  bool get isDelayed =>
      status == ProjectStatus.delayed ||
      behindSchedulePercent >= 15 ||
      (status != ProjectStatus.completed && DateTime.now().isAfter(deadline));

  Project copyWith({
    String? id,
    String? name,
    String? clientName,
    String? domain,
    String? team,
    List<String>? assignedDepartments,
    String? description,
    String? deliverablesScope,
    double? budget,
    String? ownerEmployeeId,
    String? ownerEmployeeName,
    List<String>? teamMemberNames,
    List<ProjectMilestone>? milestones,
    double? progress,
    double? plannedProgress,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? deadline,
    List<String>? activeBlockers,
    String? sourceLeadId,
    bool? hasResourceConflict,
    String? resourceConflictNotes,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      domain: domain ?? this.domain,
      team: team ?? this.team,
      assignedDepartments: assignedDepartments ?? this.assignedDepartments,
      description: description ?? this.description,
      deliverablesScope: deliverablesScope ?? this.deliverablesScope,
      budget: budget ?? this.budget,
      ownerEmployeeId: ownerEmployeeId ?? this.ownerEmployeeId,
      ownerEmployeeName: ownerEmployeeName ?? this.ownerEmployeeName,
      teamMemberNames: teamMemberNames ?? this.teamMemberNames,
      milestones: milestones ?? this.milestones,
      progress: progress ?? this.progress,
      plannedProgress: plannedProgress ?? this.plannedProgress,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      activeBlockers: activeBlockers ?? this.activeBlockers,
      sourceLeadId: sourceLeadId ?? this.sourceLeadId,
      hasResourceConflict: hasResourceConflict ?? this.hasResourceConflict,
      resourceConflictNotes: resourceConflictNotes ?? this.resourceConflictNotes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'clientName': clientName,
    'domain': domain,
    'team': team,
    'assignedDepartments': assignedDepartments,
    'description': description,
    'deliverablesScope': deliverablesScope,
    'budget': budget,
    'ownerEmployeeId': ownerEmployeeId,
    'ownerEmployeeName': ownerEmployeeName,
    'teamMemberNames': teamMemberNames,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'progress': progress,
    'plannedProgress': plannedProgress,
    'status': status.name,
    'startDate': startDate.toIso8601String(),
    'deadline': deadline.toIso8601String(),
    'activeBlockers': activeBlockers,
    'sourceLeadId': sourceLeadId,
    'hasResourceConflict': hasResourceConflict,
    'resourceConflictNotes': resourceConflictNotes,
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    name: json['name'] as String,
    clientName: json['clientName'] as String,
    domain: json['domain'] as String? ?? 'Mobile App',
    team: json['team'] as String? ?? 'Core Engineering',
    assignedDepartments: List<String>.from(json['assignedDepartments'] ?? ['Technology and Engineering']),
    description: json['description'] as String,
    deliverablesScope: json['deliverablesScope'] as String? ?? 'Full scope deliverables',
    budget: (json['budget'] as num).toDouble(),
    ownerEmployeeId: json['ownerEmployeeId'] as String,
    ownerEmployeeName: json['ownerEmployeeName'] as String,
    teamMemberNames: List<String>.from(json['teamMemberNames'] ?? []),
    milestones: (json['milestones'] as List<dynamic>?)
            ?.map((m) => ProjectMilestone.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [],
    progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    plannedProgress: (json['plannedProgress'] as num?)?.toDouble() ?? 0.5,
    status: ProjectStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => ProjectStatus.inProgress,
    ),
    startDate: DateTime.parse(json['startDate'] as String),
    deadline: DateTime.parse(json['deadline'] as String),
    activeBlockers: List<String>.from(json['activeBlockers'] ?? []),
    sourceLeadId: json['sourceLeadId'] as String?,
    hasResourceConflict: json['hasResourceConflict'] as bool? ?? false,
    resourceConflictNotes: json['resourceConflictNotes'] as String?,
  );
}
