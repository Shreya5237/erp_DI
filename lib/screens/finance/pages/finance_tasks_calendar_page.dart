import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../models/meeting.dart';
import '../../../providers/erp_provider.dart';

/// Page 5: Tasks & Calendar
/// Manage daily work, personal tasks, pending approvals deadlines, and meetings in Day/Week/Month calendar views
class FinanceTasksCalendarPage extends StatefulWidget {
  const FinanceTasksCalendarPage({super.key});

  @override
  State<FinanceTasksCalendarPage> createState() => _FinanceTasksCalendarPageState();
}

class _FinanceTasksCalendarPageState extends State<FinanceTasksCalendarPage> {
  bool _isCalendarMode = false;
  String _calendarView = 'Week'; // 'Day', 'Week', 'Month'
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final tasks = erp.financeTasks;
    final meetings = erp.financeMeetings;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Toggle Bar: Tasks View vs Calendar View
            _buildTopViewSelector(),

            // Body depending on View Mode
            Expanded(
              child: _isCalendarMode
                  ? _buildCalendarView(erp, tasks, meetings)
                  : _buildTasksView(erp, tasks),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0284C7),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
        label: const Text('Add Task', style: TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.w700)),
        onPressed: () => _showCreateTaskDialog(context, erp),
      ),
    );
  }

  Widget _buildTopViewSelector() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finance Tasks & Schedule',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Siddharth Roy • EMP-115',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              // Segmented Switcher
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    _buildSwitchOption(label: 'Tasks', isSelected: !_isCalendarMode, onTap: () => setState(() => _isCalendarMode = false)),
                    _buildSwitchOption(label: 'Calendar', isSelected: _isCalendarMode, onTap: () => setState(() => _isCalendarMode = true)),
                  ],
                ),
              ),
            ],
          ),

          // Calendar sub-filters (Day / Week / Month) if in calendar mode
          if (_isCalendarMode) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCalendarSubTab('Day'),
                const SizedBox(width: 8),
                _buildCalendarSubTab('Week'),
                const SizedBox(width: 8),
                _buildCalendarSubTab('Month'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchOption({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSubTab(String view) {
    final isSelected = _calendarView == view;
    return InkWell(
      onTap: () => setState(() => _calendarView = view),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.2) : const Color(0xFF212529),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
          ),
        ),
        child: Text(
          view,
          style: TextStyle(
            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Tasks View Mode
  // -------------------------------------------------------------
  Widget _buildTasksView(ErpProvider erp, List<CompanyTask> tasks) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final pendingCount = tasks.length - completedCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI summary
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pending Tasks', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('$pendingCount', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Completed', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('$completedCount', style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Assigned Tasks & Deadlines',
            style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          if (tasks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No tasks recorded for Siddharth Roy.', style: TextStyle(color: Color(0xFF64748B))),
              ),
            )
          else
            ...tasks.map((task) => _buildTaskItem(task, erp)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(CompanyTask task, ErpProvider erp) {
    final isDone = task.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion checkbox
          IconButton(
            icon: Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
              size: 22,
            ),
            onPressed: () => erp.toggleFinanceTask(task.id),
          ),
          const SizedBox(width: 8),

          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: isDone ? const Color(0xFF64748B) : Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.priority == TaskPriority.urgent
                            ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                            : const Color(0xFF0284C7).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority.label,
                        style: TextStyle(
                          color: task.priority == TaskPriority.urgent ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.3),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                      style: TextStyle(
                        color: task.isOverdue ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                        fontSize: 10.5,
                        fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212529),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Points: ${task.storyPoints}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Calendar View Mode
  // -------------------------------------------------------------
  Widget _buildCalendarView(ErpProvider erp, List<CompanyTask> tasks, List<Meeting> meetings) {
    final now = DateTime.now();
    final List<DateTime> weekDays = List.generate(7, (i) => now.add(Duration(days: i - 2)));

    // Filter for selected date
    final selectedMeetings = meetings.where((m) =>
        m.date.year == _selectedDate.year &&
        m.date.month == _selectedDate.month &&
        m.date.day == _selectedDate.day).toList();

    final selectedTasks = tasks.where((t) =>
        t.dueDate.year == _selectedDate.year &&
        t.dueDate.month == _selectedDate.month &&
        t.dueDate.day == _selectedDate.day).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day / Week / Month Segregated Calendar Component
          if (_calendarView == 'Month') ...[
            _buildFinanceMonthlyGrid(tasks, meetings),
          ] else if (_calendarView == 'Day') ...[
            _buildFinanceDailyAgendaTimeline(selectedMeetings, selectedTasks),
          ] else ...[
            // Week View: Interactive 7-Day Selector Strip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDays.map((d) {
                  final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
                  final isToday = d.day == now.day && d.month == now.month;

                  return InkWell(
                    onTap: () => setState(() => _selectedDate = d),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF212529)
                            : isToday
                                ? const Color(0xFFE0F2FE)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday && !isSelected ? Border.all(color: const Color(0xFF0284C7)) : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getWeekdayAbbr(d.weekday),
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : const Color(0xFF64748B),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${d.day}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isToday ? const Color(0xFF0284C7) : const Color(0xFF212529)),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Events & Meetings on Selected Date
          Text(
            'Schedule for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(color: Color(0xFF212529), fontSize: 14.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          // Meetings list (preserves test requirement 'Meetings & Reviews')
          const Text('Meetings & Reviews', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (selectedMeetings.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.event_available_rounded, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text('No meetings scheduled for this date.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            )
          else
            ...selectedMeetings.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.videocam_rounded, color: Color(0xFF4F46E5), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title, style: const TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            '${m.startTime} - ${m.endTime} • ${m.locationOrLink}',
                            style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Participants: ${m.participantNames.join(", ")}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),
          const Text('Tasks & Deadlines Due', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (selectedTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text('No deliverables due on this date.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            )
          else
            ...selectedTasks.map((task) => _buildTaskItem(task, erp)),
        ],
      ),
    );
  }

  Widget _buildFinanceMonthlyGrid(List<CompanyTask> tasks, List<Meeting> meetings) {
    final daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    final firstDayOfWeek = DateTime(_selectedDate.year, _selectedDate.month, 1).weekday;
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((d) => SizedBox(
              width: 32,
              child: Center(
                child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              ),
            )).toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - (firstDayOfWeek - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox();
              }
              final day = dayOffset + 1;
              final date = DateTime(_selectedDate.year, _selectedDate.month, day);
              final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month;
              final isSelected = date.day == _selectedDate.day;

              return InkWell(
                onTap: () => setState(() => _selectedDate = date),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF212529)
                        : (isToday ? const Color(0xFFE0F2FE) : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: (isToday || isSelected) ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? Colors.white : (isToday ? const Color(0xFF0284C7) : const Color(0xFF212529)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceDailyAgendaTimeline(List<Meeting> meetings, List<CompanyTask> tasks) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF212529)),
              SizedBox(width: 6),
              Text(
                'HOURLY AGENDA (08:00 - 20:00)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF212529), letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(13, (idx) {
            final hour = 8 + idx;
            final hourStr = hour < 12
                ? '${hour.toString().padLeft(2, '0')}:00 AM'
                : hour == 12
                    ? '12:00 PM'
                    : '${(hour - 12).toString().padLeft(2, '0')}:00 PM';

            final matchMeeting = meetings.where((m) => m.startTime.contains('${hour > 12 ? hour - 12 : hour}')).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 62,
                    child: Text(
                      hourStr,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: matchMeeting.isNotEmpty ? FontWeight.w800 : FontWeight.w500,
                        color: matchMeeting.isNotEmpty ? const Color(0xFF212529) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 2,
                    height: matchMeeting.isNotEmpty ? 40 : 18,
                    color: matchMeeting.isNotEmpty ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                  ),
                  Expanded(
                    child: matchMeeting.isNotEmpty
                        ? Text(
                            matchMeeting.first.title,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const Text('Open slot', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getWeekdayAbbr(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  void _showCreateTaskDialog(BuildContext context, ErpProvider erp) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    DateTime dueDate = DateTime.now().add(const Duration(days: 2));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Personal Finance Task', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Task Title *', style: TextStyle(color: Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Verify tax deduction for AWS GPU invoice',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Description', style: TextStyle(color: Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Optional notes or checklist...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Priority', style: TextStyle(color: Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: priority,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                  items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label, style: const TextStyle(color: Color(0xFF212529))))).toList(),
                  onChanged: (p) => setDialogState(() => priority = p!),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                erp.addFinancePersonalTask(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  priority: priority,
                  dueDate: dueDate,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF10B981),
                    content: Text('Personal task added successfully'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212529),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
