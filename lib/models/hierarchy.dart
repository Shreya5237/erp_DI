/// Category for company roles and departments
enum RoleCategory {
  technical('Technical'),
  nonTechnical('Non-Technical');

  final String label;
  const RoleCategory(this.label);
}

/// A configurable company role
class CompanyRole {
  final String id;
  final String name;
  final RoleCategory category;

  CompanyRole({
    required this.id,
    required this.name,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
  };

  factory CompanyRole.fromJson(Map<String, dynamic> json) => CompanyRole(
    id: json['id'] as String,
    name: json['name'] as String,
    category: RoleCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => RoleCategory.technical,
    ),
  );
}

/// Configurable performance and exception alert thresholds
class AlertThresholds {
  int taskOverdueDays; // Alert if task overdue by >= N days (default: 1)
  int internMissedUpdatesDays; // Alert if intern missed updates for >= N days (default: 2)
  double internLowScoreCutoff; // Alert if intern rating < N (default: 3.0)
  int projectBehindProgressPercent; // Alert if project progress is >= N% behind schedule (default: 15)
  int leadStaleDays; // Alert if lead untouched for >= N days (default: 3)
  int employeeWorkloadCapacity; // Alert if employee has > N active tasks (default: 4)

  AlertThresholds({
    this.taskOverdueDays = 1,
    this.internMissedUpdatesDays = 2,
    this.internLowScoreCutoff = 3.0,
    this.projectBehindProgressPercent = 15,
    this.leadStaleDays = 3,
    this.employeeWorkloadCapacity = 4,
  });

  AlertThresholds copyWith({
    int? taskOverdueDays,
    int? internMissedUpdatesDays,
    double? internLowScoreCutoff,
    int? projectBehindProgressPercent,
    int? leadStaleDays,
    int? employeeWorkloadCapacity,
  }) {
    return AlertThresholds(
      taskOverdueDays: taskOverdueDays ?? this.taskOverdueDays,
      internMissedUpdatesDays: internMissedUpdatesDays ?? this.internMissedUpdatesDays,
      internLowScoreCutoff: internLowScoreCutoff ?? this.internLowScoreCutoff,
      projectBehindProgressPercent: projectBehindProgressPercent ?? this.projectBehindProgressPercent,
      leadStaleDays: leadStaleDays ?? this.leadStaleDays,
      employeeWorkloadCapacity: employeeWorkloadCapacity ?? this.employeeWorkloadCapacity,
    );
  }
}

/// System Threshold Alert Item
class ThresholdAlert {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'tasks', 'interns', 'projects', 'leads', 'employees'
  final String time;
  final bool isUrgent;

  ThresholdAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.time,
    this.isUrgent = true,
  });
}
