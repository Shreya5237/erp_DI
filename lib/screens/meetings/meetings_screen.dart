import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/meeting.dart';

/// Meetings Scheduling and Attendance Hub adhering to Section 10 of the ERP PRD
class MeetingsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MeetingsScreen({super.key, this.onBack});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final meetings = erp.allMeetings;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF212529), size: 18),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: const Text(
          'Meetings & Operations Sync',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF212529), size: 24),
            onPressed: () => _showScheduleMeetingDialog(context, erp),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${erp.todayMeetings.length} Meetings Today',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                        ),
                        const Text(
                          'Role-aware agenda coordination and participant attendance tracking',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showScheduleMeetingDialog(context, erp),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: const Color(0xFF212529),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Schedule', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Scheduled Meetings',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 12),
            if (meetings.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text('No meetings scheduled yet.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ),
              ),
            ] else ...[
              ...meetings.map((m) => _buildMeetingCard(m)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingCard(Meeting m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${m.startTime} – ${m.endTime}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  m.departmentOrProject,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  m.status,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            m.title,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
          ),
          const SizedBox(height: 4),
          Text(
            m.agenda,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.link_rounded, size: 14, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  m.locationOrLink,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Organizer: ${m.organizerName} • ${m.participantNames.join(", ")}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  void _showScheduleMeetingDialog(BuildContext context, ErpProvider erp) {
    final titleController = TextEditingController();
    final agendaController = TextEditingController();
    final locationController = TextEditingController(text: 'Conference Room 1 / Google Meet');
    final startController = TextEditingController(text: '11:00 AM');
    final endController = TextEditingController(text: '12:00 PM');
    String department = 'All Departments';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Schedule Company Meeting', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Meeting Title',
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: agendaController,
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Agenda Description',
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Location or Meet Link',
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startController,
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          filled: true,
                          fillColor: const Color(0xFFF5F6F7),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endController,
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          filled: true,
                          fillColor: const Color(0xFFF5F6F7),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212529),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final newMtg = Meeting(
                  id: 'MTG-${DateTime.now().millisecondsSinceEpoch % 1000}',
                  title: titleController.text.trim().isNotEmpty ? titleController.text.trim() : 'Project Sync',
                  participantNames: [erp.currentUserName, 'Arjun Sharma', 'Rajesh Kumar'],
                  date: DateTime.now(),
                  startTime: startController.text.trim(),
                  endTime: endController.text.trim(),
                  locationOrLink: locationController.text.trim(),
                  agenda: agendaController.text.trim(),
                  organizerName: erp.currentUserName,
                  departmentOrProject: department,
                );
                erp.addMeeting(newMtg);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting scheduled! Attendees notified.')));
              },
              child: const Text('Confirm Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
