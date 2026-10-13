import 'hierarchy.dart';
import 'department.dart';

/// Model representing an employee in Digital Inertia adhering to Section 7 of ERP PRD
class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // e.g. "Technology Lead", "Frontend / Web Developer"
  final RoleCategory category; // Technical or Non-Technical
  final String department; // "Finance", "Sales", "Marketing", "HR", "Technical"
  final String departmentId; // "DEPT-FIN", "DEPT-SAL", "DEPT-MKT", "DEPT-HR", "DEPT-TECH"
  final String? subDepartmentId; // e.g. "DEPT-TEC-FE"
  final String? subDepartmentName; // e.g. "Frontend"
  final String team; // "Mobile Team", "Core API", "Client Strategy", "HR & Talent"
  final String reportingManager;
  final DateTime joiningDate;
  final String employmentStatus; // "Full-time", "Probation", "Notice Period", "Deactivated"
  final bool isPOC; // Point of Contact for interns
  final bool isActive;
  final bool isPresentToday;
  final int attendanceDays; // Distinct from working days & task completion
  final int totalWorkingDays;
  final List<String> skills;
  final List<String> assignedProjectNames;
  final List<String> assignedInternIds;
  final int activeTaskCount;
  final int completedTaskCount;
  final double performanceScore; // 1.0 - 5.0 based on measurable records
  final String avatarUrl;

  // Employee Mobile App Companion Fields
  final int leaveBalance;
  final int casualLeaves;
  final int sickLeaves;
  final int paidLeaves;
  final String employmentType; // "Permanent Employee" or "Intern"
  final String? batchDetails; // e.g. "Batch 2025-Q1 Engineering"
  final String emergencyContact;
  final String bio;
  final String location;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.category = RoleCategory.technical,
    required this.department,
    String? departmentId,
    this.subDepartmentId,
    this.subDepartmentName,
    this.team = 'Core Engineering',
    this.reportingManager = 'Laven Lokesh (CEO)',
    DateTime? joiningDate,
    this.employmentStatus = 'Full-time',
    this.isPOC = false,
    this.isActive = true,
    this.isPresentToday = true,
    this.attendanceDays = 21,
    this.totalWorkingDays = 22,
    this.skills = const [],
    this.assignedProjectNames = const [],
    this.assignedInternIds = const [],
    this.activeTaskCount = 0,
    this.completedTaskCount = 14,
    this.performanceScore = 4.7,
    this.avatarUrl = '',
    this.leaveBalance = 14,
    this.casualLeaves = 6,
    this.sickLeaves = 5,
    this.paidLeaves = 3,
    this.employmentType = 'Permanent Employee',
    this.batchDetails = 'Batch 2025-Q1 Engineering',
    this.emergencyContact = '+91 98201 99887 (Family)',
    this.bio = 'Lead Engineer passionate about responsive mobile architecture, clean interfaces, and resilient high-throughput cloud services.',
    this.location = 'Bengaluru HQ • Hybrid',
  })  : departmentId = departmentId ?? CompanyDepartment.fromName(department).departmentId,
        joiningDate = joiningDate ?? DateTime(2025, 1, 15);

  double get attendanceRatio =>
      totalWorkingDays > 0 ? (attendanceDays / totalWorkingDays) * 100 : 0.0;

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    RoleCategory? category,
    String? department,
    String? departmentId,
    String? subDepartmentId,
    String? subDepartmentName,
    String? team,
    String? reportingManager,
    DateTime? joiningDate,
    String? employmentStatus,
    bool? isPOC,
    bool? isActive,
    bool? isPresentToday,
    int? attendanceDays,
    int? totalWorkingDays,
    List<String>? skills,
    List<String>? assignedProjectNames,
    List<String>? assignedInternIds,
    int? activeTaskCount,
    int? completedTaskCount,
    double? performanceScore,
    String? avatarUrl,
    int? leaveBalance,
    int? casualLeaves,
    int? sickLeaves,
    int? paidLeaves,
    String? employmentType,
    String? batchDetails,
    String? emergencyContact,
    String? bio,
    String? location,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      category: category ?? this.category,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      subDepartmentId: subDepartmentId ?? this.subDepartmentId,
      subDepartmentName: subDepartmentName ?? this.subDepartmentName,
      team: team ?? this.team,
      reportingManager: reportingManager ?? this.reportingManager,
      joiningDate: joiningDate ?? this.joiningDate,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      isPOC: isPOC ?? this.isPOC,
      isActive: isActive ?? this.isActive,
      isPresentToday: isPresentToday ?? this.isPresentToday,
      attendanceDays: attendanceDays ?? this.attendanceDays,
      totalWorkingDays: totalWorkingDays ?? this.totalWorkingDays,
      skills: skills ?? this.skills,
      assignedProjectNames: assignedProjectNames ?? this.assignedProjectNames,
      assignedInternIds: assignedInternIds ?? this.assignedInternIds,
      activeTaskCount: activeTaskCount ?? this.activeTaskCount,
      completedTaskCount: completedTaskCount ?? this.completedTaskCount,
      performanceScore: performanceScore ?? this.performanceScore,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      casualLeaves: casualLeaves ?? this.casualLeaves,
      sickLeaves: sickLeaves ?? this.sickLeaves,
      paidLeaves: paidLeaves ?? this.paidLeaves,
      employmentType: employmentType ?? this.employmentType,
      batchDetails: batchDetails ?? this.batchDetails,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bio: bio ?? this.bio,
      location: location ?? this.location,
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
    'departmentId': departmentId,
    'subDepartmentId': subDepartmentId,
    'subDepartmentName': subDepartmentName,
    'team': team,
    'reportingManager': reportingManager,
    'joiningDate': joiningDate.toIso8601String(),
    'employmentStatus': employmentStatus,
    'isPOC': isPOC,
    'isActive': isActive,
    'isPresentToday': isPresentToday,
    'attendanceDays': attendanceDays,
    'totalWorkingDays': totalWorkingDays,
    'skills': skills,
    'assignedProjectNames': assignedProjectNames,
    'assignedInternIds': assignedInternIds,
    'activeTaskCount': activeTaskCount,
    'completedTaskCount': completedTaskCount,
    'performanceScore': performanceScore,
    'avatarUrl': avatarUrl,
    'leaveBalance': leaveBalance,
    'casualLeaves': casualLeaves,
    'sickLeaves': sickLeaves,
    'paidLeaves': paidLeaves,
    'employmentType': employmentType,
    'batchDetails': batchDetails,
    'emergencyContact': emergencyContact,
    'bio': bio,
    'location': location,
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
    departmentId: json['departmentId'] as String?,
    subDepartmentId: json['subDepartmentId'] as String?,
    subDepartmentName: json['subDepartmentName'] as String?,
    team: json['team'] as String? ?? 'General',
    reportingManager: json['reportingManager'] as String? ?? 'Laven Lokesh (CEO)',
    joiningDate: json['joiningDate'] != null
        ? DateTime.parse(json['joiningDate'] as String)
        : DateTime(2025, 1, 15),
    employmentStatus: json['employmentStatus'] as String? ?? 'Full-time',
    isPOC: json['isPOC'] as bool? ?? false,
    isActive: json['isActive'] as bool? ?? true,
    isPresentToday: json['isPresentToday'] as bool? ?? true,
    attendanceDays: json['attendanceDays'] as int? ?? 21,
    totalWorkingDays: json['totalWorkingDays'] as int? ?? 22,
    skills: List<String>.from(json['skills'] ?? []),
    assignedProjectNames: List<String>.from(json['assignedProjectNames'] ?? []),
    assignedInternIds: List<String>.from(json['assignedInternIds'] ?? []),
    activeTaskCount: json['activeTaskCount'] as int? ?? 0,
    completedTaskCount: json['completedTaskCount'] as int? ?? 14,
    performanceScore: (json['performanceScore'] as num?)?.toDouble() ?? 4.7,
    avatarUrl: json['avatarUrl'] as String? ?? '',
    leaveBalance: json['leaveBalance'] as int? ?? 14,
    casualLeaves: json['casualLeaves'] as int? ?? 6,
    sickLeaves: json['sickLeaves'] as int? ?? 5,
    paidLeaves: json['paidLeaves'] as int? ?? 3,
    employmentType: json['employmentType'] as String? ?? 'Permanent Employee',
    batchDetails: json['batchDetails'] as String? ?? 'Batch 2025-Q1 Engineering',
    emergencyContact: json['emergencyContact'] as String? ?? '+91 98201 99887 (Family)',
    bio: json['bio'] as String? ?? 'Lead Engineer specializing in Frontend & Mobile Architecture.',
    location: json['location'] as String? ?? 'Bengaluru HQ • Hybrid',
  );
}
