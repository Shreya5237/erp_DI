import 'package:flutter/material.dart';

/// Status of a departmental resource request
enum ResourceRequestStatus {
  pending('Pending Review', Color(0xFFF59E0B)),
  approved('Approved', Color(0xFF10B981)),
  rejected('Rejected', Color(0xFFEF4444)),
  clarificationRequested('Needs Clarification', Color(0xFF8B5CF6)),
  fulfilled('Fulfilled', Color(0xFF06B6D4));

  final String label;
  final Color color;
  const ResourceRequestStatus(this.label, this.color);
}

/// Expense allocation breakdown item within a project budget
class BudgetExpenseAllocation {
  final String id;
  final String category; // 'Cloud Infrastructure', 'Developer Hours', 'Hardware & Tooling', 'Travel & Onsite', 'Design & Assets'
  final double allocatedAmount;
  final double spentAmount;
  final String description;

  BudgetExpenseAllocation({
    required this.id,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    this.description = '',
  });

  double get remainingAmount => allocatedAmount - spentAmount;
  double get utilizationRatio => allocatedAmount > 0 ? (spentAmount / allocatedAmount).clamp(0.0, 1.5) : 0.0;
  bool get isOverspent => spentAmount > allocatedAmount;

  BudgetExpenseAllocation copyWith({
    String? id,
    String? category,
    double? allocatedAmount,
    double? spentAmount,
    String? description,
  }) {
    return BudgetExpenseAllocation(
      id: id ?? this.id,
      category: category ?? this.category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'allocatedAmount': allocatedAmount,
    'spentAmount': spentAmount,
    'description': description,
  };

  factory BudgetExpenseAllocation.fromJson(Map<String, dynamic> json) => BudgetExpenseAllocation(
    id: json['id'] as String,
    category: json['category'] as String,
    allocatedAmount: (json['allocatedAmount'] as num).toDouble(),
    spentAmount: (json['spentAmount'] as num).toDouble(),
    description: json['description'] as String? ?? '',
  );
}

/// Record of an approved budget adjustment or allocation revision
class BudgetAdjustmentRecord {
  final String id;
  final double previousBudget;
  final double adjustmentAmount;
  final double newBudget;
  final String reason;
  final String approvedBy;
  final DateTime timestamp;

  BudgetAdjustmentRecord({
    required this.id,
    required this.previousBudget,
    required this.adjustmentAmount,
    required this.newBudget,
    required this.reason,
    required this.approvedBy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'previousBudget': previousBudget,
    'adjustmentAmount': adjustmentAmount,
    'newBudget': newBudget,
    'reason': reason,
    'approvedBy': approvedBy,
    'timestamp': timestamp.toIso8601String(),
  };

  factory BudgetAdjustmentRecord.fromJson(Map<String, dynamic> json) => BudgetAdjustmentRecord(
    id: json['id'] as String,
    previousBudget: (json['previousBudget'] as num).toDouble(),
    adjustmentAmount: (json['adjustmentAmount'] as num).toDouble(),
    newBudget: (json['newBudget'] as num).toDouble(),
    reason: json['reason'] as String,
    approvedBy: json['approvedBy'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Project Budget entity managed by the Finance team
class ProjectBudget {
  final String projectId;
  final String projectName;
  final String clientName;
  final String domain;
  final double approvedBudget;
  final double spentAmount;
  final List<BudgetExpenseAllocation> allocations;
  final List<BudgetAdjustmentRecord> adjustmentHistory;
  final DateTime lastUpdated;

  ProjectBudget({
    required this.projectId,
    required this.projectName,
    required this.clientName,
    this.domain = 'Technology Services',
    required this.approvedBudget,
    required this.spentAmount,
    this.allocations = const [],
    this.adjustmentHistory = const [],
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  double get remainingBalance => approvedBudget - spentAmount;
  double get utilizationPercentage => approvedBudget > 0 ? (spentAmount / approvedBudget) : 0.0;
  bool get isExceeded => spentAmount > approvedBudget;
  bool get isApproachingLimit => utilizationPercentage >= 0.85 && !isExceeded;

  ProjectBudget copyWith({
    String? projectId,
    String? projectName,
    String? clientName,
    String? domain,
    double? approvedBudget,
    double? spentAmount,
    List<BudgetExpenseAllocation>? allocations,
    List<BudgetAdjustmentRecord>? adjustmentHistory,
    DateTime? lastUpdated,
  }) {
    return ProjectBudget(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      domain: domain ?? this.domain,
      approvedBudget: approvedBudget ?? this.approvedBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      allocations: allocations ?? this.allocations,
      adjustmentHistory: adjustmentHistory ?? this.adjustmentHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'projectName': projectName,
    'clientName': clientName,
    'domain': domain,
    'approvedBudget': approvedBudget,
    'spentAmount': spentAmount,
    'allocations': allocations.map((a) => a.toJson()).toList(),
    'adjustmentHistory': adjustmentHistory.map((h) => h.toJson()).toList(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory ProjectBudget.fromJson(Map<String, dynamic> json) => ProjectBudget(
    projectId: json['projectId'] as String,
    projectName: json['projectName'] as String,
    clientName: json['clientName'] as String,
    domain: json['domain'] as String? ?? 'Technology Services',
    approvedBudget: (json['approvedBudget'] as num).toDouble(),
    spentAmount: (json['spentAmount'] as num).toDouble(),
    allocations: (json['allocations'] as List? ?? [])
        .map((a) => BudgetExpenseAllocation.fromJson(a as Map<String, dynamic>))
        .toList(),
    adjustmentHistory: (json['adjustmentHistory'] as List? ?? [])
        .map((h) => BudgetAdjustmentRecord.fromJson(h as Map<String, dynamic>))
        .toList(),
    lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : DateTime.now(),
  );
}

/// Resource Request entity submitted by departments to Finance
class ResourceRequest {
  final String id;
  final String requestingDepartment; // 'Technology and Engineering', 'Corporate Growth & Sales', 'HR & People Ops', 'Digital Marketing', 'Client Experience Engineering'
  final String requestedResource;
  final int quantity;
  final double estimatedCost;
  final String purpose;
  final String? projectId;
  final String? projectName;
  final String requesterName;
  final String requesterId;
  final DateTime submittedDate;
  final ResourceRequestStatus status;
  final String? financeComments;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final double? allocatedBudget;

  ResourceRequest({
    required this.id,
    required this.requestingDepartment,
    required this.requestedResource,
    required this.quantity,
    required this.estimatedCost,
    required this.purpose,
    this.projectId,
    this.projectName,
    required this.requesterName,
    required this.requesterId,
    required this.submittedDate,
    this.status = ResourceRequestStatus.pending,
    this.financeComments,
    this.reviewedBy,
    this.reviewedAt,
    this.allocatedBudget,
  });

  bool get isPending => status == ResourceRequestStatus.pending;
  bool get isApproved => status == ResourceRequestStatus.approved;
  bool get isRejected => status == ResourceRequestStatus.rejected;
  bool get isClarificationRequested => status == ResourceRequestStatus.clarificationRequested;

  ResourceRequest copyWith({
    String? id,
    String? requestingDepartment,
    String? requestedResource,
    int? quantity,
    double? estimatedCost,
    String? purpose,
    String? projectId,
    String? projectName,
    String? requesterName,
    String? requesterId,
    DateTime? submittedDate,
    ResourceRequestStatus? status,
    String? financeComments,
    String? reviewedBy,
    DateTime? reviewedAt,
    double? allocatedBudget,
  }) {
    return ResourceRequest(
      id: id ?? this.id,
      requestingDepartment: requestingDepartment ?? this.requestingDepartment,
      requestedResource: requestedResource ?? this.requestedResource,
      quantity: quantity ?? this.quantity,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      purpose: purpose ?? this.purpose,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      requesterName: requesterName ?? this.requesterName,
      requesterId: requesterId ?? this.requesterId,
      submittedDate: submittedDate ?? this.submittedDate,
      status: status ?? this.status,
      financeComments: financeComments ?? this.financeComments,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestingDepartment': requestingDepartment,
    'requestedResource': requestedResource,
    'quantity': quantity,
    'estimatedCost': estimatedCost,
    'purpose': purpose,
    'projectId': projectId,
    'projectName': projectName,
    'requesterName': requesterName,
    'requesterId': requesterId,
    'submittedDate': submittedDate.toIso8601String(),
    'status': status.name,
    'financeComments': financeComments,
    'reviewedBy': reviewedBy,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'allocatedBudget': allocatedBudget,
  };

  factory ResourceRequest.fromJson(Map<String, dynamic> json) => ResourceRequest(
    id: json['id'] as String,
    requestingDepartment: json['requestingDepartment'] as String,
    requestedResource: json['requestedResource'] as String,
    quantity: json['quantity'] as int,
    estimatedCost: (json['estimatedCost'] as num).toDouble(),
    purpose: json['purpose'] as String,
    projectId: json['projectId'] as String?,
    projectName: json['projectName'] as String?,
    requesterName: json['requesterName'] as String,
    requesterId: json['requesterId'] as String,
    submittedDate: DateTime.parse(json['submittedDate'] as String),
    status: ResourceRequestStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => ResourceRequestStatus.pending,
    ),
    financeComments: json['financeComments'] as String?,
    reviewedBy: json['reviewedBy'] as String?,
    reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
    allocatedBudget: (json['allocatedBudget'] as num?)?.toDouble(),
  );
}
