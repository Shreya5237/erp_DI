/// Represents an internal executive approval card (Section 4.5 & 9.5 of ERP PRD)
enum ApprovalStatus {
  pendingGm('Pending GM Review'),
  pendingCeo('Pending CEO Approval'),
  approved('Approved'),
  rejected('Rejected'),
  changesRequested('Changes Requested');

  final String label;
  const ApprovalStatus(this.label);
}

class CompanyApprovalRequest {
  final String id;
  final String title;
  final String submittingDepartment;
  final String submittedByName;
  final String submittedByRole;
  final DateTime submittedDate;
  final double dealValueOrBudget;
  final String summary;
  final String? leadId;
  final String? projectId;
  final ApprovalStatus status;
  final String? reviewNotes;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  CompanyApprovalRequest({
    required this.id,
    required this.title,
    required this.submittingDepartment,
    required this.submittedByName,
    required this.submittedByRole,
    required this.submittedDate,
    required this.dealValueOrBudget,
    required this.summary,
    this.leadId,
    this.projectId,
    this.status = ApprovalStatus.pendingCeo,
    this.reviewNotes,
    this.reviewedAt,
    this.reviewedBy,
  });

  bool get isAwaitingExecutiveAction =>
      status == ApprovalStatus.pendingCeo || status == ApprovalStatus.pendingGm;

  CompanyApprovalRequest copyWith({
    String? id,
    String? title,
    String? submittingDepartment,
    String? submittedByName,
    String? submittedByRole,
    DateTime? submittedDate,
    double? dealValueOrBudget,
    String? summary,
    String? leadId,
    String? projectId,
    ApprovalStatus? status,
    String? reviewNotes,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return CompanyApprovalRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      submittingDepartment: submittingDepartment ?? this.submittingDepartment,
      submittedByName: submittedByName ?? this.submittedByName,
      submittedByRole: submittedByRole ?? this.submittedByRole,
      submittedDate: submittedDate ?? this.submittedDate,
      dealValueOrBudget: dealValueOrBudget ?? this.dealValueOrBudget,
      summary: summary ?? this.summary,
      leadId: leadId ?? this.leadId,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'submittingDepartment': submittingDepartment,
    'submittedByName': submittedByName,
    'submittedByRole': submittedByRole,
    'submittedDate': submittedDate.toIso8601String(),
    'dealValueOrBudget': dealValueOrBudget,
    'summary': summary,
    'leadId': leadId,
    'projectId': projectId,
    'status': status.name,
    'reviewNotes': reviewNotes,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'reviewedBy': reviewedBy,
  };

  factory CompanyApprovalRequest.fromJson(Map<String, dynamic> json) =>
    CompanyApprovalRequest(
      id: json['id'] as String,
      title: json['title'] as String,
      submittingDepartment: json['submittingDepartment'] as String,
      submittedByName: json['submittedByName'] as String,
      submittedByRole: json['submittedByRole'] as String,
      submittedDate: DateTime.parse(json['submittedDate'] as String),
      dealValueOrBudget: (json['dealValueOrBudget'] as num).toDouble(),
      summary: json['summary'] as String,
      leadId: json['leadId'] as String?,
      projectId: json['projectId'] as String?,
      status: ApprovalStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ApprovalStatus.pendingCeo,
      ),
      reviewNotes: json['reviewNotes'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewedBy: json['reviewedBy'] as String?,
    );
}
