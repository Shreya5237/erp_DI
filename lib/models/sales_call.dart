import 'package:flutter/material.dart';

/// Call outcome options matching Section 1 of Sales App concept
enum CallOutcome {
  interested('Interested', Color(0xFF10B981)),
  followUpRequired('Follow-up Required', Color(0xFFF59E0B)),
  noResponse('No Response', Color(0xFF64748B)),
  notInterested('Not Interested', Color(0xFFEF4444));

  final String label;
  final Color color;
  const CallOutcome(this.label, this.color);
}

/// Model representing a sales cold call or follow-up call
class SalesCall {
  final String id;
  final String? leadId;
  final String customerName;
  final String companyName;
  final String phone;
  final DateTime timestamp;
  final CallOutcome outcome;
  final String notes;
  final DateTime? nextFollowUpDate;
  final int durationSeconds;
  final bool isCompleted;
  final double? dealValue;
  final String priority; // 'Urgent', 'High', 'Medium', 'Low'
  final String? forwardedTo; // 'Manager', 'HR', 'Finance'

  SalesCall({
    required this.id,
    this.leadId,
    required this.customerName,
    required this.companyName,
    required this.phone,
    required this.timestamp,
    this.outcome = CallOutcome.followUpRequired,
    this.notes = '',
    this.nextFollowUpDate,
    this.durationSeconds = 180,
    this.isCompleted = true,
    this.dealValue,
    this.priority = 'Medium',
    this.forwardedTo,
  });

  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  bool get isFollowUpToday {
    if (nextFollowUpDate == null) return false;
    final now = DateTime.now();
    return nextFollowUpDate!.year == now.year &&
        nextFollowUpDate!.month == now.month &&
        nextFollowUpDate!.day == now.day;
  }

  bool get isFollowUpOverdue {
    if (nextFollowUpDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextFollowUpDate!.isBefore(today);
  }

  int get daysOverdue {
    if (!isFollowUpOverdue || nextFollowUpDate == null) return 0;
    return DateTime.now().difference(nextFollowUpDate!).inDays.clamp(1, 999);
  }

  SalesCall copyWith({
    String? id,
    String? leadId,
    String? customerName,
    String? companyName,
    String? phone,
    DateTime? timestamp,
    CallOutcome? outcome,
    String? notes,
    DateTime? nextFollowUpDate,
    int? durationSeconds,
    bool? isCompleted,
    double? dealValue,
    String? priority,
    String? forwardedTo,
  }) {
    return SalesCall(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      customerName: customerName ?? this.customerName,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      timestamp: timestamp ?? this.timestamp,
      outcome: outcome ?? this.outcome,
      notes: notes ?? this.notes,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      dealValue: dealValue ?? this.dealValue,
      priority: priority ?? this.priority,
      forwardedTo: forwardedTo ?? this.forwardedTo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'leadId': leadId,
    'customerName': customerName,
    'companyName': companyName,
    'phone': phone,
    'timestamp': timestamp.toIso8601String(),
    'outcome': outcome.name,
    'notes': notes,
    'nextFollowUpDate': nextFollowUpDate?.toIso8601String(),
    'durationSeconds': durationSeconds,
    'isCompleted': isCompleted,
    'dealValue': dealValue,
    'priority': priority,
    'forwardedTo': forwardedTo,
  };

  factory SalesCall.fromJson(Map<String, dynamic> json) => SalesCall(
    id: json['id'] as String,
    leadId: json['leadId'] as String?,
    customerName: json['customerName'] as String,
    companyName: json['companyName'] as String,
    phone: json['phone'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    outcome: CallOutcome.values.firstWhere(
      (o) => o.name == json['outcome'],
      orElse: () => CallOutcome.interested,
    ),
    notes: json['notes'] as String? ?? '',
    nextFollowUpDate: json['nextFollowUpDate'] != null
        ? DateTime.parse(json['nextFollowUpDate'] as String)
        : null,
    durationSeconds: json['durationSeconds'] as int? ?? 180,
    isCompleted: json['isCompleted'] as bool? ?? true,
    dealValue: (json['dealValue'] as num?)?.toDouble(),
    priority: json['priority'] as String? ?? 'Medium',
    forwardedTo: json['forwardedTo'] as String?,
  );
}
