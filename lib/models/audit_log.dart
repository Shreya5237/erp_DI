/// Represents an immutable audit trail record for compliance and CEO visibility
class AuditLog {
  final String id;
  final DateTime timestamp;
  final String actorName;
  final String actorRole;
  final String action; // e.g. "Approve Task", "Convert Lead", "Retain Intern"
  final String module; // "Tasks", "Interns", "CRM", "Projects", "Employees"
  final String details;

  AuditLog({
    required this.id,
    required this.timestamp,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.module,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'actorName': actorName,
    'actorRole': actorRole,
    'action': action,
    'module': module,
    'details': details,
  };

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    actorName: json['actorName'] as String,
    actorRole: json['actorRole'] as String,
    action: json['action'] as String,
    module: json['module'] as String,
    details: json['details'] as String,
  );
}
