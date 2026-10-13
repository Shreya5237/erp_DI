/// Represents a scheduled company meeting (Section 10 of ERP PRD)
class Meeting {
  final String id;
  final String title;
  final List<String> participantNames;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String locationOrLink;
  final String agenda;
  final String organizerName;
  final String departmentOrProject;
  final String status; // 'Scheduled', 'In Progress', 'Completed', 'Cancelled'

  Meeting({
    required this.id,
    required this.title,
    required this.participantNames,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.locationOrLink,
    required this.agenda,
    required this.organizerName,
    required this.departmentOrProject,
    this.status = 'Scheduled',
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'participantNames': participantNames,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'locationOrLink': locationOrLink,
    'agenda': agenda,
    'organizerName': organizerName,
    'departmentOrProject': departmentOrProject,
    'status': status,
  };

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json['id'] as String,
    title: json['title'] as String,
    participantNames: List<String>.from(json['participantNames'] ?? []),
    date: DateTime.parse(json['date'] as String),
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    locationOrLink: json['locationOrLink'] as String,
    agenda: json['agenda'] as String,
    organizerName: json['organizerName'] as String,
    departmentOrProject: json['departmentOrProject'] as String,
    status: json['status'] as String? ?? 'Scheduled',
  );
}
