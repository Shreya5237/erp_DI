/// CRM Sales Lead Stages
enum LeadStatus {
  newLead('New'),
  contacted('Contacted'),
  qualified('Qualified'),
  proposal('Proposal'),
  won('Won'),
  lost('Lost');

  final String label;
  const LeadStatus(this.label);
}

/// Model representing a client sales lead
class Lead {
  final String id;
  final String clientName;
  final String companyName;
  final String domain; // "IT Consulting", "Mobile App", "Solar Solutions", "Web Platform"
  final String email;
  final String phone;
  final double dealValue;
  final LeadStatus status;
  final String assignedEmployeeId;
  final String assignedEmployeeName;
  final String source;
  final DateTime nextFollowUpDate;
  final int daysSinceLastContact;
  final String notes;
  final String? convertedProjectId;
  final DateTime createdAt;

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
    this.source = 'Outbound',
    required this.nextFollowUpDate,
    this.daysSinceLastContact = 1,
    this.notes = '',
    this.convertedProjectId,
    required this.createdAt,
  });

  bool get isFollowUpMissed {
    if (status == LeadStatus.won || status == LeadStatus.lost) return false;
    final now = DateTime.now();
    return nextFollowUpDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get needsAttentionToday => isFollowUpMissed;

  bool get isStale => daysSinceLastContact >= 3 && status != LeadStatus.won && status != LeadStatus.lost;

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
    String? convertedProjectId,
    DateTime? createdAt,
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
      convertedProjectId: convertedProjectId ?? this.convertedProjectId,
      createdAt: createdAt ?? this.createdAt,
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
    'convertedProjectId': convertedProjectId,
    'createdAt': createdAt.toIso8601String(),
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
      orElse: () => LeadStatus.newLead,
    ),
    assignedEmployeeId: json['assignedEmployeeId'] as String,
    assignedEmployeeName: json['assignedEmployeeName'] as String,
    source: json['source'] as String? ?? 'Outbound',
    nextFollowUpDate: DateTime.parse(json['nextFollowUpDate'] as String),
    daysSinceLastContact: json['daysSinceLastContact'] as int? ?? 1,
    notes: json['notes'] as String? ?? '',
    convertedProjectId: json['convertedProjectId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
