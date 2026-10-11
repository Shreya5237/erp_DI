import 'hierarchy.dart';

/// Model representing an employee in Digital Inertia
class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // e.g. "Frontend Developer", "Backend Developer"
  final RoleCategory category; // Technical or Non-Technical
  final String department; // "Engineering", "Sales & BD", "Product", "Operations"
  final String team; // "Mobile Team", "Core API", "Enterprise Sales"
  final bool isPOC; // Point of Contact for interns
  final bool isActive;
  final List<String> assignedInternIds;
  final int activeTaskCount;
  final String avatarUrl;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.category = RoleCategory.technical,
    required this.department,
    this.team = 'Core Engineering',
    this.isPOC = false,
    this.isActive = true,
    this.assignedInternIds = const [],
    this.activeTaskCount = 0,
    this.avatarUrl = '',
  });

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    RoleCategory? category,
    String? department,
    String? team,
    bool? isPOC,
    bool? isActive,
    List<String>? assignedInternIds,
    int? activeTaskCount,
    String? avatarUrl,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      category: category ?? this.category,
      department: department ?? this.department,
      team: team ?? this.team,
      isPOC: isPOC ?? this.isPOC,
      isActive: isActive ?? this.isActive,
      assignedInternIds: assignedInternIds ?? this.assignedInternIds,
      activeTaskCount: activeTaskCount ?? this.activeTaskCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'category': category.name,
    'department': department,
    'team': team,
    'isPOC': isPOC,
    'isActive': isActive,
    'assignedInternIds': assignedInternIds,
    'activeTaskCount': activeTaskCount,
    'avatarUrl': avatarUrl,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    role: json['role'] as String,
    category: RoleCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => RoleCategory.technical,
    ),
    department: json['department'] as String,
    team: json['team'] as String? ?? 'General',
    isPOC: json['isPOC'] as bool? ?? false,
    isActive: json['isActive'] as bool? ?? true,
    assignedInternIds: List<String>.from(json['assignedInternIds'] ?? []),
    activeTaskCount: json['activeTaskCount'] as int? ?? 0,
    avatarUrl: json['avatarUrl'] as String? ?? '',
  );
}
