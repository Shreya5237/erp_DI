import 'package:flutter/material.dart';

/// Leave types recognized across the company
enum LeaveType {
  annual('Annual / Paid Leave', Color(0xFF38BDF8)),
  sick('Sick Leave', Color(0xFF10B981)),
  casual('Casual Leave', Color(0xFFF59E0B)),
  maternityPaternity('Maternity / Paternity', Color(0xFF8B5CF6)),
  unpaid('Loss of Pay (Unpaid)', Color(0xFF64748B));

  final String label;
  final Color color;
  const LeaveType(this.label, this.color);
}

/// Status of an employee leave request
enum LeaveRequestStatus {
  pending('Pending Review', Color(0xFFF59E0B)),
  approved('Approved', Color(0xFF10B981)),
  rejected('Rejected', Color(0xFFEF4444));

  final String label;
  final Color color;
  const LeaveRequestStatus(this.label, this.color);
}

/// Model representing an employee leave request in central ERP
class EmployeeLeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int daysCount;
  final String reason;
  final LeaveRequestStatus status;
  final DateTime appliedDate;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? hrComments;
  final bool hasOverlappingTeamAbsence;
  final List<String> overlappingEmployeeNames;

  EmployeeLeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.reason,
    this.status = LeaveRequestStatus.pending,
    required this.appliedDate,
    this.reviewedBy,
    this.reviewedAt,
    this.hrComments,
    this.hasOverlappingTeamAbsence = false,
    this.overlappingEmployeeNames = const [],
  });

  bool get isPending => status == LeaveRequestStatus.pending;
  bool get isApproved => status == LeaveRequestStatus.approved;
  bool get isRejected => status == LeaveRequestStatus.rejected;

  EmployeeLeaveRequest copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? department,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    int? daysCount,
    String? reason,
    LeaveRequestStatus? status,
    DateTime? appliedDate,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? hrComments,
    bool? hasOverlappingTeamAbsence,
    List<String>? overlappingEmployeeNames,
  }) {
    return EmployeeLeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysCount: daysCount ?? this.daysCount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      hrComments: hrComments ?? this.hrComments,
      hasOverlappingTeamAbsence: hasOverlappingTeamAbsence ?? this.hasOverlappingTeamAbsence,
      overlappingEmployeeNames: overlappingEmployeeNames ?? this.overlappingEmployeeNames,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'employeeName': employeeName,
    'department': department,
    'leaveType': leaveType.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'daysCount': daysCount,
    'reason': reason,
    'status': status.name,
    'appliedDate': appliedDate.toIso8601String(),
    'reviewedBy': reviewedBy,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'hrComments': hrComments,
    'hasOverlappingTeamAbsence': hasOverlappingTeamAbsence,
    'overlappingEmployeeNames': overlappingEmployeeNames,
  };

  factory EmployeeLeaveRequest.fromJson(Map<String, dynamic> json) => EmployeeLeaveRequest(
    id: json['id'] as String,
    employeeId: json['employeeId'] as String,
    employeeName: json['employeeName'] as String,
    department: json['department'] as String,
    leaveType: LeaveType.values.firstWhere(
      (t) => t.name == json['leaveType'],
      orElse: () => LeaveType.annual,
    ),
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    daysCount: json['daysCount'] as int,
    reason: json['reason'] as String,
    status: LeaveRequestStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => LeaveRequestStatus.pending,
    ),
    appliedDate: DateTime.parse(json['appliedDate'] as String),
    reviewedBy: json['reviewedBy'] as String?,
    reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
    hrComments: json['hrComments'] as String?,
    hasOverlappingTeamAbsence: json['hasOverlappingTeamAbsence'] as bool? ?? false,
    overlappingEmployeeNames: List<String>.from(json['overlappingEmployeeNames'] ?? []),
  );
}

/// Status of team member staffing requests
enum StaffingRequestStatus {
  pending('Pending', Color(0xFFF59E0B)),
  inProgress('In Progress', Color(0xFF38BDF8)),
  fulfilled('Fulfilled', Color(0xFF10B981)),
  rejected('Rejected', Color(0xFFEF4444));

  final String label;
  final Color color;
  const StaffingRequestStatus(this.label, this.color);
}

/// Staffing Request submitted by department managers to HR
class StaffingRequest {
  final String id;
  final String requestingDepartment;
  final String? projectId;
  final String? projectName;
  final String requesterName;
  final String requesterId;
  final String requiredRole;
  final List<String> requiredSkills;
  final int headcount;
  final DateTime requestedJoiningDate;
  final String urgency; // 'Urgent', 'High', 'Medium', 'Low'
  final StaffingRequestStatus status;
  final List<String> assignedEmployeeIds;
  final List<String> assignedEmployeeNames;
  final String? hrNotes;
  final DateTime submittedDate;
  final DateTime? fulfilledDate;

  StaffingRequest({
    required this.id,
    required this.requestingDepartment,
    this.projectId,
    this.projectName,
    required this.requesterName,
    required this.requesterId,
    required this.requiredRole,
    required this.requiredSkills,
    required this.headcount,
    required this.requestedJoiningDate,
    this.urgency = 'High',
    this.status = StaffingRequestStatus.pending,
    this.assignedEmployeeIds = const [],
    this.assignedEmployeeNames = const [],
    this.hrNotes,
    required this.submittedDate,
    this.fulfilledDate,
  });

  bool get isPending => status == StaffingRequestStatus.pending;
  bool get isFulfilled => status == StaffingRequestStatus.fulfilled;

  StaffingRequest copyWith({
    String? id,
    String? requestingDepartment,
    String? projectId,
    String? projectName,
    String? requesterName,
    String? requesterId,
    String? requiredRole,
    List<String>? requiredSkills,
    int? headcount,
    DateTime? requestedJoiningDate,
    String? urgency,
    StaffingRequestStatus? status,
    List<String>? assignedEmployeeIds,
    List<String>? assignedEmployeeNames,
    String? hrNotes,
    DateTime? submittedDate,
    DateTime? fulfilledDate,
  }) {
    return StaffingRequest(
      id: id ?? this.id,
      requestingDepartment: requestingDepartment ?? this.requestingDepartment,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      requesterName: requesterName ?? this.requesterName,
      requesterId: requesterId ?? this.requesterId,
      requiredRole: requiredRole ?? this.requiredRole,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      headcount: headcount ?? this.headcount,
      requestedJoiningDate: requestedJoiningDate ?? this.requestedJoiningDate,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      assignedEmployeeIds: assignedEmployeeIds ?? this.assignedEmployeeIds,
      assignedEmployeeNames: assignedEmployeeNames ?? this.assignedEmployeeNames,
      hrNotes: hrNotes ?? this.hrNotes,
      submittedDate: submittedDate ?? this.submittedDate,
      fulfilledDate: fulfilledDate ?? this.fulfilledDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestingDepartment': requestingDepartment,
    'projectId': projectId,
    'projectName': projectName,
    'requesterName': requesterName,
    'requesterId': requesterId,
    'requiredRole': requiredRole,
    'requiredSkills': requiredSkills,
    'headcount': headcount,
    'requestedJoiningDate': requestedJoiningDate.toIso8601String(),
    'urgency': urgency,
    'status': status.name,
    'assignedEmployeeIds': assignedEmployeeIds,
    'assignedEmployeeNames': assignedEmployeeNames,
    'hrNotes': hrNotes,
    'submittedDate': submittedDate.toIso8601String(),
    'fulfilledDate': fulfilledDate?.toIso8601String(),
  };

  factory StaffingRequest.fromJson(Map<String, dynamic> json) => StaffingRequest(
    id: json['id'] as String,
    requestingDepartment: json['requestingDepartment'] as String,
    projectId: json['projectId'] as String?,
    projectName: json['projectName'] as String?,
    requesterName: json['requesterName'] as String,
    requesterId: json['requesterId'] as String,
    requiredRole: json['requiredRole'] as String,
    requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
    headcount: json['headcount'] as int,
    requestedJoiningDate: DateTime.parse(json['requestedJoiningDate'] as String),
    urgency: json['urgency'] as String? ?? 'High',
    status: StaffingRequestStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => StaffingRequestStatus.pending,
    ),
    assignedEmployeeIds: List<String>.from(json['assignedEmployeeIds'] ?? []),
    assignedEmployeeNames: List<String>.from(json['assignedEmployeeNames'] ?? []),
    hrNotes: json['hrNotes'] as String?,
    submittedDate: DateTime.parse(json['submittedDate'] as String),
    fulfilledDate: json['fulfilledDate'] != null ? DateTime.parse(json['fulfilledDate'] as String) : null,
  );
}

/// Customer feedback and post-deal change request status
enum CustomerRequestStatus {
  submitted('Submitted', Color(0xFFF59E0B)),
  inReview('In Review', Color(0xFF38BDF8)),
  accepted('Accepted', Color(0xFF10B981)),
  completed('Completed', Color(0xFF06B6D4)),
  escalated('Escalated', Color(0xFFEF4444));

  final String label;
  final Color color;
  const CustomerRequestStatus(this.label, this.color);
}

/// Customer feedback and scope change coordination item tracked by HR
class CustomerChangeRequest {
  final String id;
  final String leadId;
  final String clientName;
  final String companyName;
  final String? projectName;
  final String feedbackType; // 'Change Request', 'Feedback', 'Feature Addition', 'SLA Inquiry'
  final String description;
  final String forwardedToRole; // 'Tech Lead', 'Project Manager', 'Finance Lead'
  final CustomerRequestStatus status;
  final DateTime followUpDate;
  final DateTime createdDate;
  final bool isEscalated;
  final String? resolutionNotes;

  CustomerChangeRequest({
    required this.id,
    required this.leadId,
    required this.clientName,
    required this.companyName,
    this.projectName,
    required this.feedbackType,
    required this.description,
    required this.forwardedToRole,
    this.status = CustomerRequestStatus.submitted,
    required this.followUpDate,
    required this.createdDate,
    this.isEscalated = false,
    this.resolutionNotes,
  });

  CustomerChangeRequest copyWith({
    String? id,
    String? leadId,
    String? clientName,
    String? companyName,
    String? projectName,
    String? feedbackType,
    String? description,
    String? forwardedToRole,
    CustomerRequestStatus? status,
    DateTime? followUpDate,
    DateTime? createdDate,
    bool? isEscalated,
    String? resolutionNotes,
  }) {
    return CustomerChangeRequest(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      clientName: clientName ?? this.clientName,
      companyName: companyName ?? this.companyName,
      projectName: projectName ?? this.projectName,
      feedbackType: feedbackType ?? this.feedbackType,
      description: description ?? this.description,
      forwardedToRole: forwardedToRole ?? this.forwardedToRole,
      status: status ?? this.status,
      followUpDate: followUpDate ?? this.followUpDate,
      createdDate: createdDate ?? this.createdDate,
      isEscalated: isEscalated ?? this.isEscalated,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'leadId': leadId,
    'clientName': clientName,
    'companyName': companyName,
    'projectName': projectName,
    'feedbackType': feedbackType,
    'description': description,
    'forwardedToRole': forwardedToRole,
    'status': status.name,
    'followUpDate': followUpDate.toIso8601String(),
    'createdDate': createdDate.toIso8601String(),
    'isEscalated': isEscalated,
    'resolutionNotes': resolutionNotes,
  };

  factory CustomerChangeRequest.fromJson(Map<String, dynamic> json) => CustomerChangeRequest(
    id: json['id'] as String,
    leadId: json['leadId'] as String,
    clientName: json['clientName'] as String,
    companyName: json['companyName'] as String,
    projectName: json['projectName'] as String?,
    feedbackType: json['feedbackType'] as String,
    description: json['description'] as String,
    forwardedToRole: json['forwardedToRole'] as String,
    status: CustomerRequestStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => CustomerRequestStatus.submitted,
    ),
    followUpDate: DateTime.parse(json['followUpDate'] as String),
    createdDate: DateTime.parse(json['createdDate'] as String),
    isEscalated: json['isEscalated'] as bool? ?? false,
    resolutionNotes: json['resolutionNotes'] as String?,
  );
}

/// Configurable HR Monthly Performance Targets
class HrMonthlyTargets {
  final int leaveRequestsTarget;
  final int staffingRequestsTarget;
  final int traineeReviewsTarget;
  final int customerFollowUpsTarget;

  const HrMonthlyTargets({
    this.leaveRequestsTarget = 20,
    this.staffingRequestsTarget = 10,
    this.traineeReviewsTarget = 10,
    this.customerFollowUpsTarget = 15,
  });

  HrMonthlyTargets copyWith({
    int? leaveRequestsTarget,
    int? staffingRequestsTarget,
    int? traineeReviewsTarget,
    int? customerFollowUpsTarget,
  }) {
    return HrMonthlyTargets(
      leaveRequestsTarget: leaveRequestsTarget ?? this.leaveRequestsTarget,
      staffingRequestsTarget: staffingRequestsTarget ?? this.staffingRequestsTarget,
      traineeReviewsTarget: traineeReviewsTarget ?? this.traineeReviewsTarget,
      customerFollowUpsTarget: customerFollowUpsTarget ?? this.customerFollowUpsTarget,
    );
  }
}
