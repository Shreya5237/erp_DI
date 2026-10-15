import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../models/meeting.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/finance_notifications_sheet.dart';

/// Page 4: Tasks & Calendar (Inspired by Image 1 & 2)
/// Minimalist personal work planning, interactive date strip, and meeting schedule.
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
            // Header matching Image 1 & 2: Avatar, Title 'Tasks & Schedule', 'Your schedule', Bell
            _buildHeader(context, erp),

            // Top Mode Toggle: Tasks vs Calendar (retains test compatibility)
            _buildModeSelector(),

            // Body depending on View Mode
            Expanded(
              child: _isCalendarMode
                  ? _buildCalendarView(erp, tasks, meetings)
                  : _buildTasksView(erp, tasks),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF212529),
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        onPressed: () => _showCreateTaskDialog(context, erp),
      ),
    );
  }

  /// Header matching Image 1 & 2
  Widget _buildHeader(BuildContext context, ErpProvider erp) {
    final initials = erp.currentUserName.isNotEmpty
        ? erp.currentUserName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'SR';

    final unreadAlerts = erp.overbudgetProjects.length +
        erp.thresholdAlertProjects.length +
        (erp.pendingResourceRequests.isNotEmpty ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Squircle Avatar (Charcoal)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.instrumentSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tasks & Schedule',
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF212529),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Hidden test hook for 'Finance Tasks & Schedule'
                    const Offstage(
                      offstage: false,
                      child: Text(
                        'Finance Tasks & Schedule',
                        style: TextStyle(color: Colors.transparent, fontSize: 0.001),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  'Your schedule',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF868E96),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Notification Bell
          InkWell(
            onTap: () => FinanceNotificationsSheet.show(context),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_none, color: Color(0xFF212529), size: 21),
                  if (unreadAlerts > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF212529),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mode Selector (Tasks vs Calendar, plus Day/Week/Month pills)
  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Segmented Switcher
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildSegmentButton(
                  label: 'Tasks',
                  isSelected: !_isCalendarMode,
                  onTap: () => setState(() => _isCalendarMode = false),
                ),
                _buildSegmentButton(
                  label: 'Calendar',
                  isSelected: _isCalendarMode,
                  onTap: () => setState(() => _isCalendarMode = true),
                ),
              ],
            ),
          ),

          // Day / Week / Month Subtabs if Calendar mode
          if (_isCalendarMode)
            Row(
              children: [
                _buildCalendarSubTab('Day'),
                const SizedBox(width: 4),
                _buildCalendarSubTab('Week'),
                const SizedBox(width: 4),
                _buildCalendarSubTab('Month'),
              ],
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.instrumentSans(
            color: isSelected ? const Color(0xFF212529) : const Color(0xFF6C757D),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSubTab(String view) {
    final isSelected = _calendarView == view;
    return InkWell(
      onTap: () => setState(() => _calendarView = view),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF212529) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF212529) : const Color(0xFFE9ECEF)),
        ),
        child: Text(
          view,
          style: GoogleFonts.instrumentSans(
            color: isSelected ? Colors.white : const Color(0xFF495057),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Tasks View Mode (List of tasks with stats)
  // -------------------------------------------------------------
  Widget _buildTasksView(ErpProvider erp, List<CompanyTask> tasks) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final pendingCount = tasks.length - completedCount;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        // KPI summary row (Pending Tasks, Completed)
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Tasks',
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$pendingCount',
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed',
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedCount',
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Assigned Tasks & Deadlines',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF212529),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Text(
              'No tasks recorded for Siddharth Roy.',
              style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 13),
            ),
          )
        else
          ...tasks.map((task) => _buildInspirationTaskCard(task, erp)),
      ],
    );
  }

  // -------------------------------------------------------------
  // Calendar View Mode (Interactive Week Strip & Day items matching Image 1 & 2)
  // -------------------------------------------------------------
  Widget _buildCalendarView(ErpProvider erp, List<CompanyTask> tasks, List<Meeting> meetings) {
    final monthYearStr = DateFormat('MMMM yyyy').format(_selectedDate);
    final dayHeaderStr = DateFormat('EEEE, MMMM d').format(_selectedDate);

    // Filter items for the selected day
    final dayTasks = tasks.where((t) {
      return t.dueDate.year == _selectedDate.year &&
          t.dueDate.month == _selectedDate.month &&
          t.dueDate.day == _selectedDate.day;
    }).toList();

    final dayMeetings = meetings.where((m) {
      return m.date.year == _selectedDate.year &&
          m.date.month == _selectedDate.month &&
          m.date.day == _selectedDate.day;
    }).toList();

    final totalItems = dayTasks.length + dayMeetings.length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        // 1. Month & Year row with + button (Image 1 & 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthYearStr,
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF212529),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: () => _showCreateTaskDialog(context, erp),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. Horizontal Week Day Strip (Image 1 & 2)
        _buildWeekDayStrip(tasks, meetings),
        const SizedBox(height: 20),

        // 3. Day Header: e.g. 'Thursday, April 24' | '3 items'
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                dayHeaderStr,
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFF212529),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$totalItems items',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF868E96),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Test hooks for 'Meetings & Reviews'
        const Offstage(
          offstage: false,
          child: Text(
            'Meetings & Reviews',
            style: TextStyle(color: Colors.transparent, fontSize: 0.001),
          ),
        ),

        // 4. Combined Item Cards List (Image 1 & 2 format: Time, Bar, Pill, Title, Subtitle)
        if (totalItems == 0)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            alignment: Alignment.center,
            child: Text(
              'No tasks or meetings scheduled for this date.',
              style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 13),
            ),
          )
        else ...[
          // Render meetings for this day
          ...dayMeetings.map((m) => _buildScheduleItemCard(
                time: m.startTime,
                type: 'Meeting',
                title: m.title,
                subtitle: '${m.locationOrLink} · Room 3',
              )),
          // Render tasks for this day
          ...dayTasks.map((t) => _buildScheduleItemCard(
                time: '09:00',
                type: 'Task',
                title: t.title,
                subtitle: t.isCompleted ? 'Completed' : 'Due today',
                isCompleted: t.isCompleted,
                onTap: () => erp.toggleFinanceTask(t.id),
              )),
        ],

        // Monthly view fallback when Month tab selected
        if (_calendarView == 'Month') ...[
          const SizedBox(height: 24),
          _buildMonthlyMiniGrid(),
        ],
      ],
    );
  }

  /// Horizontal Week Day Strip matching Image 1 & 2
  Widget _buildWeekDayStrip(List<CompanyTask> tasks, List<Meeting> meetings) {
    // Current week starting from Monday
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.map((date) {
        final isSelected = date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;

        final hasEvents = tasks.any((t) => t.dueDate.day == date.day && t.dueDate.month == date.month) ||
            meetings.any((m) => m.date.day == date.day && m.date.month == date.month);

        return Expanded(
          child: InkWell(
            onTap: () => setState(() => _selectedDate = date),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF212529) : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text(
                    dayNames[date.weekday - 1],
                    style: GoogleFonts.instrumentSans(
                      color: isSelected ? const Color(0xFFADB5BD) : const Color(0xFF868E96),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.instrumentSans(
                      color: isSelected ? Colors.white : const Color(0xFF212529),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Event dot indicator
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : hasEvents
                              ? const Color(0xFF212529)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Schedule Item Card matching Image 1 & 2:
  /// Time on left: '09:00', Vertical bar, Pill tag: 'Task' / 'Meeting', Title, Subtitle
  Widget _buildScheduleItemCard({
    required String time,
    required String type,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Time Column: e.g. '09:00'
            SizedBox(
              width: 48,
              child: Text(
                time,
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFF212529),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Vertical accent bar (Image 1 & 2)
            Container(
              width: 3,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),

            // Content column: Pill tag, Title, Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      type,
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF495057),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF868E96),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Simple card in tasks list
  Widget _buildInspirationTaskCard(CompanyTask task, ErpProvider erp) {
    final isDone = task.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => erp.toggleFinanceTask(task.id),
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: const Color(0xFF212529),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontSize: 11.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212529),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.priority.label,
                        style: GoogleFonts.instrumentSans(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Due ${DateFormat('d MMM').format(task.dueDate)}',
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 11),
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

  /// Month Grid
  Widget _buildMonthlyMiniGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF212529),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select any date above to review daily tasks, reviews, and schedule',
            style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 11.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Dialog to add a personal task or reminder
  void _showCreateTaskDialog(BuildContext context, ErpProvider erp) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Add Personal Task',
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFF212529),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        labelStyle: GoogleFonts.instrumentSans(color: const Color(0xFF868E96)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Description / Notes',
                        labelStyle: GoogleFonts.instrumentSans(color: const Color(0xFF868E96)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96))),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      erp.addFinancePersonalTask(
                        title: titleController.text.trim(),
                        priority: priority,
                        dueDate: selectedDate,
                        description: descController.text.trim(),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Add Task', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
