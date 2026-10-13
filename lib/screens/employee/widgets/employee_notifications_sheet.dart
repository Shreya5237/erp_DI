import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import 'meeting_details_dialog.dart';

/// Modal bottom sheet opening from the top bar notification bell
/// Displays upcoming meeting reminders (15 mins before), task deadline alerts, and updates
class EmployeeNotificationsSheet extends StatefulWidget {
  const EmployeeNotificationsSheet({super.key});

  @override
  State<EmployeeNotificationsSheet> createState() => _EmployeeNotificationsSheetState();
}

class _EmployeeNotificationsSheetState extends State<EmployeeNotificationsSheet> {
  int _selectedFilter = 0; // 0: All, 1: Meetings, 2: Deadlines, 3: Updates
  bool _markedAllRead = false;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final myTasks = erp.myEmployeeTasks;
    final myMeetings = erp.myEmployeeMeetings;

    // Build notifications dynamically from live provider state
    final List<Map<String, dynamic>> notifications = [];

    // 1. Upcoming meeting reminders (e.g. 15 minutes before)
    for (final m in myMeetings) {
      notifications.add({
        'type': 'meeting',
        'title': 'Meeting in 15 mins: ${m.title}',
        'time': '${m.startTime} • Today',
        'subtitle': m.locationOrLink,
        'meeting': m,
        'isUrgent': true,
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFF6366F1),
      });
    }

    // 2. Overdue task alerts
    final overdueTasks = myTasks.where((t) => t.isOverdue).toList();
    for (final t in overdueTasks) {
      notifications.add({
        'type': 'deadline',
        'title': 'Overdue Alert: ${t.title}',
        'time': t.deadlineCountdownText,
        'subtitle': 'Assigned by ${t.assignedByName} • Project: ${t.projectName ?? "General"}',
        'isUrgent': true,
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFEF4444),
      });
    }

    // 3. Due today task alerts
    final dueTodayTasks = myTasks.where((t) => t.isDueToday && !t.isCompleted).toList();
    for (final t in dueTodayTasks) {
      notifications.add({
        'type': 'deadline',
        'title': 'Due Today: ${t.title}',
        'time': 'Due Today (${t.priority.label} Priority)',
        'subtitle': t.description,
        'isUrgent': t.priority.name == 'urgent',
        'icon': Icons.alarm_rounded,
        'color': const Color(0xFFF59E0B),
      });
    }

    // 4. Approaching deadline alerts (Tomorrow / 2 days)
    final dueTomorrowTasks = myTasks.where((t) => t.isDueTomorrow && !t.isCompleted).toList();
    for (final t in dueTomorrowTasks) {
      notifications.add({
        'type': 'deadline',
        'title': 'Approaching Deadline: ${t.title}',
        'time': 'Due Tomorrow',
        'subtitle': 'Project: ${t.projectName ?? "Agile Sprint"}',
        'isUrgent': false,
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFF0284C7),
      });
    }

    // 5. Updates & Assignment events
    notifications.add({
      'type': 'update',
      'title': 'New Task Assigned: Resolve Redis cache stampede',
      'time': '1 hour ago',
      'subtitle': 'Assigned by Priya Nair (Lead) to Sprint 4 Backlog',
      'isUrgent': false,
      'icon': Icons.assignment_turned_in_rounded,
      'color': const Color(0xFF10B981),
    });
    notifications.add({
      'type': 'update',
      'title': 'Schedule Confirmed: Weekly Executive Operations Sync',
      'time': '2 hours ago',
      'subtitle': 'Meeting room and Google Meet link attached',
      'isUrgent': false,
      'icon': Icons.event_available_rounded,
      'color': const Color(0xFF8B5CF6),
    });

    // Filter list
    final filtered = notifications.where((n) {
      if (_selectedFilter == 1) return n['type'] == 'meeting';
      if (_selectedFilter == 2) return n['type'] == 'deadline';
      if (_selectedFilter == 3) return n['type'] == 'update';
      return true;
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF212529), size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Notifications & Alerts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF212529),
                  ),
                ),
                const Spacer(),
                if (!_markedAllRead)
                  TextButton(
                    onPressed: () {
                      setState(() => _markedAllRead = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All alerts marked as read'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0284C7))),
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip(0, 'All Alerts (${notifications.length})'),
                const SizedBox(width: 6),
                _buildFilterChip(1, 'Meeting Reminders'),
                const SizedBox(width: 6),
                _buildFilterChip(2, 'Deadlines & Overdue'),
                const SizedBox(width: 6),
                _buildFilterChip(3, 'Updates'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Notifications List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.done_all_rounded, size: 36, color: Color(0xFF94A3B8)),
                        SizedBox(height: 8),
                        Text('All caught up!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                        Text('No active alerts in this category.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final item = filtered[idx];
                      return _buildNotificationCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF212529) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> item) {
    final Color color = item['color'] as Color;
    final bool isUrgent = item['isUrgent'] as bool;
    final isMeeting = item['type'] == 'meeting';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _markedAllRead ? const Color(0xFFF5F6F7) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUrgent && !_markedAllRead ? color.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
          width: isUrgent && !_markedAllRead ? 1.4 : 0.8,
        ),
        boxShadow: [
          if (!_markedAllRead)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item['icon'] as IconData, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['time'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item['subtitle'] as String,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isMeeting && item['meeting'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => MeetingDetailsDialog(meeting: item['meeting']),
                          );
                        },
                        icon: const Icon(Icons.videocam_rounded, size: 14, color: Colors.white),
                        label: const Text('Join Meeting', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
