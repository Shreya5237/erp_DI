/// Represents the 5 approved primary operating departments of Digital Inertia
enum CompanyDepartment {
  finance('Finance', 'Finance', 'DEPT-FIN', [
    'Accounts',
    'Payroll',
    'Budgeting',
    'Invoicing',
  ]),
  sales('Sales', 'Sales', 'DEPT-SAL', [
    'Business Development',
    'Lead Management',
    'Client Acquisition',
    'Account Management',
  ]),
  marketing('Marketing', 'Marketing', 'DEPT-MKT', [
    'Digital Marketing',
    'SEO',
    'Social Media',
    'Content Marketing',
    'Branding',
  ]),
  hr('HR', 'HR', 'DEPT-HR', [
    'Recruitment',
    'Onboarding',
    'Training',
    'Leave Management',
    'Performance Management',
  ]),
  technical('Technical', 'Technical', 'DEPT-TECH', [
    'Frontend',
    'Backend',
    'Full-stack',
    'Mobile Development',
    'UI/UX',
    'QA',
    'DevOps',
    'AI/ML',
  ]);

  static const CompanyDepartment engineering = CompanyDepartment.technical;

  final String title;
  final String shortName;
  final String departmentId;
  final List<String> subcategories;

  // Backward compatibility getter
  List<String> get predefinedRoles => subcategories;

  const CompanyDepartment(this.title, this.shortName, this.departmentId, this.subcategories);

  static CompanyDepartment fromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('hr') || lower.contains('human') || lower.contains('people')) return CompanyDepartment.hr;
    if (lower.contains('sales') || lower.contains('business') || lower.contains('growth')) return CompanyDepartment.sales;
    if (lower.contains('finance') || lower.contains('account')) return CompanyDepartment.finance;
    if (lower.contains('marketing') || lower.contains('content')) return CompanyDepartment.marketing;
    return CompanyDepartment.technical;
  }
}

/// Dynamic Department structure matching the Spring Boot backend
class DepartmentItem {
  final String id;
  final String name;
  final String code;
  final String? parentId;
  final String? parentName;
  final String description;
  final bool active;
  final List<DepartmentItem> subcategories;

  const DepartmentItem({
    required this.id,
    required this.name,
    required this.code,
    this.parentId,
    this.parentName,
    this.description = '',
    this.active = true,
    this.subcategories = const [],
  });

  bool get isTopLevel => parentId == null;

  factory DepartmentItem.fromJson(Map<String, dynamic> json) {
    var subs = <DepartmentItem>[];
    if (json['subcategories'] is List) {
      subs = (json['subcategories'] as List)
          .map((item) => DepartmentItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return DepartmentItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      parentId: json['parentId'] as String?,
      parentName: json['parentName'] as String?,
      description: json['description'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      subcategories: subs,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'parentId': parentId,
    'parentName': parentName,
    'description': description,
    'active': active,
    'subcategories': subcategories.map((s) => s.toJson()).toList(),
  };
}

/// Department stats for executive insights
class DepartmentMetric {
  final CompanyDepartment department;
  final int totalEmployees;
  final int presentToday;
  final int activeTasks;
  final int completedTasksThisWeek;
  final double workloadRatio; // 0.0 - 1.0

  const DepartmentMetric({
    required this.department,
    required this.totalEmployees,
    required this.presentToday,
    required this.activeTasks,
    required this.completedTasksThisWeek,
    required this.workloadRatio,
  });

  double get attendancePercentage =>
      totalEmployees > 0 ? (presentToday / totalEmployees) * 100 : 0.0;
}
