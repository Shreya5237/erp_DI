/// 12-Stage Sales Pipeline Stages matching the ERP PRD
enum LeadStatus {
  newLead('New Lead'),
  contactAttempted('Contact Attempted'),
  contactEstablished('Contact Established'),
  requirementsCollected('Requirements Collected'),
  feasibilityAssessment('Feasibility Assessment'),
  proposalPrepared('Proposal / Quotation Prepared'),
  proposalSent('Proposal Sent'),
  negotiation('Negotiation'),
  internalApproval('Internal Approval'),
  clientDecision('Client Decision'),
  won('Won / Project Confirmed'),
  lost('Lost / On Hold');

  final String label;
  const LeadStatus(this.label);

  // Backward compatibility alias
  static LeadStatus get contacted => LeadStatus.contactEstablished;
  static LeadStatus get qualified => LeadStatus.requirementsCollected;
  static LeadStatus get proposal => LeadStatus.proposalPrepared;
}

/// Status of departmental feasibility review
enum FeasibilityStatus {
  pending('Pending'),
  inReview('In Review'),
  changesRequested('Changes Requested'),
  completed('Completed');

  final String label;
  const FeasibilityStatus(this.label);
}

/// HR Feasibility Review Document
class HrFeasibilityReview {
  final FeasibilityStatus status;
  final List<String> requiredSkills;
  final int estimatedEffortHours;
  final String resourceAvailabilityNotes;
  final bool needsHiring;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  HrFeasibilityReview({
    this.status = FeasibilityStatus.pending,
    this.requiredSkills = const [],
    this.estimatedEffortHours = 120,
    this.resourceAvailabilityNotes = 'Team available for upcoming sprint.',
    this.needsHiring = false,
    this.reviewedBy,
    this.reviewedAt,
  });

  HrFeasibilityReview copyWith({
    FeasibilityStatus? status,
    List<String>? requiredSkills,
    int? estimatedEffortHours,
    String? resourceAvailabilityNotes,
    bool? needsHiring,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return HrFeasibilityReview(
      status: status ?? this.status,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      estimatedEffortHours: estimatedEffortHours ?? this.estimatedEffortHours,
      resourceAvailabilityNotes: resourceAvailabilityNotes ?? this.resourceAvailabilityNotes,
      needsHiring: needsHiring ?? this.needsHiring,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'requiredSkills': requiredSkills,
    'estimatedEffortHours': estimatedEffortHours,
    'resourceAvailabilityNotes': resourceAvailabilityNotes,
    'needsHiring': needsHiring,
    'reviewedBy': reviewedBy,
    'reviewedAt': reviewedAt?.toIso8601String(),
  };

  factory HrFeasibilityReview.fromJson(Map<String, dynamic> json) => HrFeasibilityReview(
    status: FeasibilityStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => FeasibilityStatus.pending,
    ),
    requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
    estimatedEffortHours: json['estimatedEffortHours'] as int? ?? 120,
    resourceAvailabilityNotes: json['resourceAvailabilityNotes'] as String? ?? '',
    needsHiring: json['needsHiring'] as bool? ?? false,
    reviewedBy: json['reviewedBy'] as String?,
    reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
  );
}

/// Finance Feasibility Review Document
class FinanceFeasibilityReview {
  final FeasibilityStatus status;
  final double estimatedCost;
  final double quotedPrice;
  final double expectedMarginPercent;
  final String paymentTerms;
  final String budgetFeasibilityNotes;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  FinanceFeasibilityReview({
    this.status = FeasibilityStatus.pending,
    this.estimatedCost = 150000.0,
    this.quotedPrice = 250000.0,
    this.expectedMarginPercent = 40.0,
    this.paymentTerms = '30% Advance, 40% Milestone 2, 30% Delivery',
    this.budgetFeasibilityNotes = 'Margin aligns with target profitability of 35%+',
    this.reviewedBy,
    this.reviewedAt,
  });

  FinanceFeasibilityReview copyWith({
    FeasibilityStatus? status,
    double? estimatedCost,
    double? quotedPrice,
    double? expectedMarginPercent,
    String? paymentTerms,
    String? budgetFeasibilityNotes,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return FinanceFeasibilityReview(
      status: status ?? this.status,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      quotedPrice: quotedPrice ?? this.quotedPrice,
      expectedMarginPercent: expectedMarginPercent ?? this.expectedMarginPercent,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      budgetFeasibilityNotes: budgetFeasibilityNotes ?? this.budgetFeasibilityNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'estimatedCost': estimatedCost,
    'quotedPrice': quotedPrice,
    'expectedMarginPercent': expectedMarginPercent,
    'paymentTerms': paymentTerms,
    'budgetFeasibilityNotes': budgetFeasibilityNotes,
    'reviewedBy': reviewedBy,
    'reviewedAt': reviewedAt?.toIso8601String(),
  };

  factory FinanceFeasibilityReview.fromJson(Map<String, dynamic> json) => FinanceFeasibilityReview(
    status: FeasibilityStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => FeasibilityStatus.pending,
    ),
    estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 150000.0,
    quotedPrice: (json['quotedPrice'] as num?)?.toDouble() ?? 250000.0,
    expectedMarginPercent: (json['expectedMarginPercent'] as num?)?.toDouble() ?? 40.0,
    paymentTerms: json['paymentTerms'] as String? ?? '30% Advance, 70% Delivery',
    budgetFeasibilityNotes: json['budgetFeasibilityNotes'] as String? ?? '',
    reviewedBy: json['reviewedBy'] as String?,
    reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
  );
}

/// History log entry for approval workflow (Sales -> GM -> CEO -> Sales)
class LeadApprovalAction {
  final String id;
  final String action; // e.g. "Submitted to GM", "GM Approved", "CEO Approved", "Modifications Requested"
  final String authorName;
  final String authorRole;
  final String comments;
  final DateTime timestamp;

  LeadApprovalAction({
    required this.id,
    required this.action,
    required this.authorName,
    required this.authorRole,
    required this.comments,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'authorName': authorName,
    'authorRole': authorRole,
    'comments': comments,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LeadApprovalAction.fromJson(Map<String, dynamic> json) => LeadApprovalAction(
    id: json['id'] as String,
    action: json['action'] as String,
    authorName: json['authorName'] as String,
    authorRole: json['authorRole'] as String,
    comments: json['comments'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Meaningful interaction record with client
class LeadInteraction {
  final String id;
  final String type; // 'Call', 'Message', 'Meeting', 'Client Response', 'Follow-up Attempt'
  final String summary;
  final String authorName;
  final DateTime timestamp;

  LeadInteraction({
    required this.id,
    required this.type,
    required this.summary,
    required this.authorName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'summary': summary,
    'authorName': authorName,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LeadInteraction.fromJson(Map<String, dynamic> json) => LeadInteraction(
    id: json['id'] as String,
    type: json['type'] as String,
    summary: json['summary'] as String,
    authorName: json['authorName'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Model representing a client sales lead in the 12-stage pipeline
class Lead {
  final String id;
  final String clientName;
  final String companyName;
  final String domain;
  final String email;
  final String phone;
  final double dealValue;
  final LeadStatus status;
  final String assignedEmployeeId;
  final String assignedEmployeeName;
  final String source; // 'Cold Call', 'Social Media Outreach', 'Referral', 'Existing Client', 'Website Inquiry', 'Networking'
  final DateTime nextFollowUpDate;
  final int daysSinceLastContact;
  final String notes;
  final String? lostReason;
  final bool futureFollowUpAppropriate;
  final String? convertedProjectId;
  final DateTime createdAt;

  // Feasibility & Approval documents
  final String requirementsScope;
  final HrFeasibilityReview hrFeasibility;
  final FinanceFeasibilityReview financeFeasibility;
  final String internalApprovalStage; // 'Draft', 'Pending GM Review', 'Pending CEO Approval', 'Approved', 'Rejected'
  final List<LeadApprovalAction> approvalHistory;
  final List<LeadInteraction> interactions;

  Lead({
    required this.id,
    required this.clientName,
    required this.companyName,
    this.domain = 'Technology Services',
    required this.email,
    required this.phone,
    required this.dealValue,
    this.status = LeadStatus.newLead,
    required this.assignedEmployeeId,
    required this.assignedEmployeeName,
    this.source = 'Social Media Outreach',
    required this.nextFollowUpDate,
    this.daysSinceLastContact = 1,
    this.notes = '',
    this.lostReason,
    this.futureFollowUpAppropriate = true,
    this.convertedProjectId,
    required this.createdAt,
    this.requirementsScope = 'Complete software & digital marketing service package',
    HrFeasibilityReview? hrFeasibility,
    FinanceFeasibilityReview? financeFeasibility,
    this.internalApprovalStage = 'Draft',
    this.approvalHistory = const [],
    this.interactions = const [],
  })  : hrFeasibility = hrFeasibility ?? HrFeasibilityReview(),
        financeFeasibility = financeFeasibility ?? FinanceFeasibilityReview();

  bool get isFollowUpMissed {
    if (status == LeadStatus.won || status == LeadStatus.lost) return false;
    final now = DateTime.now();
    return nextFollowUpDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get needsAttentionToday => isFollowUpMissed;

  bool get isStale =>
      daysSinceLastContact >= 3 && status != LeadStatus.won && status != LeadStatus.lost;

  bool get isFeasibilityPending =>
      hrFeasibility.status != FeasibilityStatus.completed ||
      financeFeasibility.status != FeasibilityStatus.completed;

  bool get isInternalApprovalPending =>
      status == LeadStatus.internalApproval &&
      (internalApprovalStage == 'Pending GM Review' || internalApprovalStage == 'Pending CEO Approval');

  Lead copyWith({
    String? id,
    String? clientName,
    String? companyName,
    String? domain,
    String? email,
    String? phone,
    double? dealValue,
    LeadStatus? status,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    String? source,
    DateTime? nextFollowUpDate,
    int? daysSinceLastContact,
    String? notes,
    String? lostReason,
    bool? futureFollowUpAppropriate,
    String? convertedProjectId,
    DateTime? createdAt,
    String? requirementsScope,
    HrFeasibilityReview? hrFeasibility,
    FinanceFeasibilityReview? financeFeasibility,
    String? internalApprovalStage,
    List<LeadApprovalAction>? approvalHistory,
    List<LeadInteraction>? interactions,
  }) {
    return Lead(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      companyName: companyName ?? this.companyName,
      domain: domain ?? this.domain,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dealValue: dealValue ?? this.dealValue,
      status: status ?? this.status,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName ?? this.assignedEmployeeName,
      source: source ?? this.source,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      daysSinceLastContact: daysSinceLastContact ?? this.daysSinceLastContact,
      notes: notes ?? this.notes,
      lostReason: lostReason ?? this.lostReason,
      futureFollowUpAppropriate: futureFollowUpAppropriate ?? this.futureFollowUpAppropriate,
      convertedProjectId: convertedProjectId ?? this.convertedProjectId,
      createdAt: createdAt ?? this.createdAt,
      requirementsScope: requirementsScope ?? this.requirementsScope,
      hrFeasibility: hrFeasibility ?? this.hrFeasibility,
      financeFeasibility: financeFeasibility ?? this.financeFeasibility,
      internalApprovalStage: internalApprovalStage ?? this.internalApprovalStage,
      approvalHistory: approvalHistory ?? this.approvalHistory,
      interactions: interactions ?? this.interactions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientName': clientName,
    'companyName': companyName,
    'domain': domain,
    'email': email,
    'phone': phone,
    'dealValue': dealValue,
    'status': status.name,
    'assignedEmployeeId': assignedEmployeeId,
    'assignedEmployeeName': assignedEmployeeName,
    'source': source,
    'nextFollowUpDate': nextFollowUpDate.toIso8601String(),
    'daysSinceLastContact': daysSinceLastContact,
    'notes': notes,
    'lostReason': lostReason,
    'futureFollowUpAppropriate': futureFollowUpAppropriate,
    'convertedProjectId': convertedProjectId,
    'createdAt': createdAt.toIso8601String(),
    'requirementsScope': requirementsScope,
    'hrFeasibility': hrFeasibility.toJson(),
    'financeFeasibility': financeFeasibility.toJson(),
    'internalApprovalStage': internalApprovalStage,
    'approvalHistory': approvalHistory.map((a) => a.toJson()).toList(),
    'interactions': interactions.map((i) => i.toJson()).toList(),
  };

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
    id: json['id'] as String,
    clientName: json['clientName'] as String,
    companyName: json['companyName'] as String,
    domain: json['domain'] as String? ?? 'Technology Services',
    email: json['email'] as String,
    phone: json['phone'] as String,
    dealValue: (json['dealValue'] as num).toDouble(),
    status: LeadStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () {
        final legacy = json['status']?.toString().toLowerCase();
        if (legacy == 'new' || legacy == 'newlead') return LeadStatus.newLead;
        if (legacy == 'contacted') return LeadStatus.contactEstablished;
        if (legacy == 'qualified') return LeadStatus.requirementsCollected;
        if (legacy == 'proposal') return LeadStatus.proposalPrepared;
        if (legacy == 'won') return LeadStatus.won;
        if (legacy == 'lost') return LeadStatus.lost;
        return LeadStatus.newLead;
      },
    ),
    assignedEmployeeId: json['assignedEmployeeId'] as String,
    assignedEmployeeName: json['assignedEmployeeName'] as String,
    source: json['source'] as String? ?? 'Social Media Outreach',
    nextFollowUpDate: DateTime.parse(json['nextFollowUpDate'] as String),
    daysSinceLastContact: json['daysSinceLastContact'] as int? ?? 1,
    notes: json['notes'] as String? ?? '',
    lostReason: json['lostReason'] as String?,
    futureFollowUpAppropriate: json['futureFollowUpAppropriate'] as bool? ?? true,
    convertedProjectId: json['convertedProjectId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    requirementsScope: json['requirementsScope'] as String? ?? '',
    hrFeasibility: json['hrFeasibility'] != null
        ? HrFeasibilityReview.fromJson(json['hrFeasibility'] as Map<String, dynamic>)
        : null,
    financeFeasibility: json['financeFeasibility'] != null
        ? FinanceFeasibilityReview.fromJson(json['financeFeasibility'] as Map<String, dynamic>)
        : null,
    internalApprovalStage: json['internalApprovalStage'] as String? ?? 'Draft',
    approvalHistory: (json['approvalHistory'] as List<dynamic>?)
            ?.map((a) => LeadApprovalAction.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [],
    interactions: (json['interactions'] as List<dynamic>?)
            ?.map((i) => LeadInteraction.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [],
  );

  /// Factory constructor to parse LeadEntity returned from Spring Boot /api/v1/leads
  factory Lead.fromBackendJson(Map<String, dynamic> json) {
    final stageStr = (json['stage'] as String? ?? 'new_lead').toLowerCase();
    LeadStatus status;
    switch (stageStr) {
      case 'new':
      case 'new_lead':
        status = LeadStatus.newLead;
        break;
      case 'contacted':
        status = LeadStatus.contactEstablished;
        break;
      case 'qualified':
        status = LeadStatus.requirementsCollected;
        break;
      case 'proposal':
        status = LeadStatus.proposalPrepared;
        break;
      case 'won':
        status = LeadStatus.won;
        break;
      case 'lost':
        status = LeadStatus.lost;
        break;
      default:
        status = LeadStatus.newLead;
    }

    DateTime parsedFollowUp;
    try {
      parsedFollowUp = json['nextFollowUp'] != null
          ? DateTime.parse(json['nextFollowUp'] as String)
          : DateTime.now().add(const Duration(days: 2));
    } catch (_) {
      parsedFollowUp = DateTime.now().add(const Duration(days: 2));
    }

    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now();
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    return Lead(
      id: json['id'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      domain: json['domain'] as String? ?? 'Technology Services',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      dealValue: (json['dealValue'] as num?)?.toDouble() ?? 0.0,
      status: status,
      assignedEmployeeId: json['ownerId'] as String? ?? 'EMP-102',
      assignedEmployeeName: json['ownerName'] as String? ?? 'Sales Representative',
      source: json['source'] as String? ?? 'Direct Outreach',
      nextFollowUpDate: parsedFollowUp,
      notes: json['notes'] as String? ?? '',
      createdAt: parsedCreatedAt,
      futureFollowUpAppropriate: json['active'] as bool? ?? true,
    );
  }

  /// Converts LeadStatus to the backend LeadStage enum string required by PATCH /leads/{id}/stage?stage={stage}
  static String toBackendStage(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return 'new_lead';
      case LeadStatus.contactAttempted:
      case LeadStatus.contactEstablished:
        return 'contacted';
      case LeadStatus.requirementsCollected:
      case LeadStatus.feasibilityAssessment:
        return 'qualified';
      case LeadStatus.proposalPrepared:
      case LeadStatus.proposalSent:
      case LeadStatus.negotiation:
      case LeadStatus.internalApproval:
      case LeadStatus.clientDecision:
        return 'proposal';
      case LeadStatus.won:
        return 'won';
      case LeadStatus.lost:
        return 'lost';
    }
  }
}
