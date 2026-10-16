import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/employee.dart';
import '../../../models/hierarchy.dart';
import '../../../models/meeting.dart';
import '../../../models/task.dart';
import '../../../models/sales_call.dart';
import '../widgets/meeting_details_dialog.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/employee_task_detail_modal.dart';

/// Screen 5: Unified Employee Calendar
/// Adhering strictly to PRD Section 10 & Multi-Department Calendar Requirements:
/// - Every employee across all departments (Technical, Sales, Finance, HR, Marketing) has their own calendar
/// - Segregated into Daily, Weekly, and Monthly views
/// - Hourly agenda timeline in Daily view
/// - Interactive scheduled meetings, deliverables, tasks, and follow-ups
/// - Switch between employees or lock to active user
class EmployeeCalendarPage extends StatefulWidget {
  final Employee? employee;
  final String? employeeId;
  final bool showAppBar;
  final bool allowEmployeeSwitching;

  const EmployeeCalendarPage({
    super.key,
    this.employee,
    this.employeeId,
    this.showAppBar = false,
    this.allowEmployeeSwitching = false,
  });

  @override
  State<EmployeeCalendarPage> createState() => _EmployeeCalendarPageState();
}

class _EmployeeCalendarPageState extends State<EmployeeCalendarPage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String _viewMode = 'Month'; // 'Day', 'Week', 'Month'
  String _selectedTag = 'All'; // 'All', 'Tasks', 'Deadlines', 'Meetings', 'Task Breakdown'
  Employee? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    _selectedEmployee = widget.employee;
  }



  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _focusedMonth = DateTime(now.year, now.month, 1);
    });
  }

  Employee _resolveActiveEmployee(ErpProvider erp) {
    if (_selectedEmployee != null) return _selectedEmployee!;
    if (widget.employeeId != null) {
      try {
        return erp.allEmployees.firstWhere((e) => e.id == widget.employeeId);
      } catch (_) {}
    }
    final curr = erp.currentEmployee;
    if (curr != null) return curr;
    if (erp.allEmployees.isNotEmpty) return erp.allEmployees.first;
    return Employee(
      id: erp.currentUserId,
      name: erp.currentUserName,
      email: erp.currentUserEmail,
      phone: '+91 99999 00000',
      role: erp.currentRole.label,
      category: RoleCategory.technical,
      department: 'Technical',
      team: 'Engineering',
      isActive: true,
    );
  }

  Color _getDepartmentColor(String department) {
    final d = department.toLowerCase();
    if (d.contains('tech') || d.contains('eng')) return const Color(0xFF0284C7);
    if (d.contains('sales')) return const Color(0xFF10B981);
    if (d.contains('finance')) return const Color(0xFF6366F1);
    if (d.contains('hr')) return const Color(0xFF8B5CF6);
    if (d.contains('market')) return const Color(0xFFF59E0B);
    return const Color(0xFF64748B);
  }

  void _showEmployeePickerSheet(BuildContext context, ErpProvider erp, Employee currentEmp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String deptFilter = 'All';
        String searchQuery = '';

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final departments = ['All', 'Technical', 'Sales', 'Finance', 'HR', 'Marketing'];
            final filtered = erp.allEmployees.where((emp) {
              if (deptFilter != 'All' && !emp.department.toLowerCase().contains(deptFilter.toLowerCase())) {
                return false;
              }
              if (searchQuery.isNotEmpty) {
                final q = searchQuery.toLowerCase();
                return emp.name.toLowerCase().contains(q) ||
                    emp.role.toLowerCase().contains(q) ||
                    emp.department.toLowerCase().contains(q) ||
                    emp.id.toLowerCase().contains(q);
              }
              return true;
            }).toList();

            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Employee Calendar',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF212529),
                              ),
                            ),
                            Text(
                              'View individual schedule, tasks & meetings',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search employee by name, role or ID...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      onChanged: (val) => setModalState(() => searchQuery = val),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Department Filter Chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: departments.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final dept = departments[idx];
                        final isSel = deptFilter == dept;
                        return InkWell(
                          onTap: () => setModalState(() => deptFilter = dept),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF212529) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dept,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                color: isSel ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  // Employee List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: filtered.length,
                      separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, idx) {
                        final emp = filtered[idx];
                        final isCurrent = emp.id == currentEmp.id;
                        final deptColor = _getDepartmentColor(emp.department);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: deptColor.withValues(alpha: 0.12),
                            child: Text(
                              emp.name.substring(0, 1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: deptColor,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  emp.name,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                                    color: const Color(0xFF212529),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: deptColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  emp.department,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: deptColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${emp.id} • ${emp.role}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                          trailing: isCurrent
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0284C7), size: 20)
                              : const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
                          onTap: () {
                            setState(() {
                              _selectedEmployee = emp;
                            });
                            Navigator.pop(modalCtx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final activeEmp = _resolveActiveEmployee(erp);

    final empTasks = erp.tasksForEmployee(activeEmp.id, activeEmp.name);
    final empMeetings = erp.meetingsForEmployee(activeEmp.name, activeEmp.department);
    final empCalls = activeEmp.department.toLowerCase().contains('sales')
        ? erp.callsForEmployee(activeEmp.id, activeEmp.name)
        : <SalesCall>[];

    // Filter tasks, meetings and calls for selected date
    final selectedDayTasks = empTasks.where((t) {
      return t.dueDate.year == _selectedDate.year &&
          t.dueDate.month == _selectedDate.month &&
          t.dueDate.day == _selectedDate.day;
    }).toList();

    final selectedDayMeetings = empMeetings.where((m) {
      return m.date.year == _selectedDate.year &&
          m.date.month == _selectedDate.month &&
          m.date.day == _selectedDate.day;
    }).toList();

    final selectedDayCalls = empCalls.where((c) {
      if (c.nextFollowUpDate == null) return false;
      return c.nextFollowUpDate!.year == _selectedDate.year &&
          c.nextFollowUpDate!.month == _selectedDate.month &&
          c.nextFollowUpDate!.day == _selectedDate.day;
    }).toList();

    final selectedDayDeadlines = selectedDayTasks.where((t) => t.isOverdue || t.isDueToday).toList();

    List<CompanyTask> displayedTasks = selectedDayTasks;
    List<Meeting> displayedMeetings = selectedDayMeetings;
    List<SalesCall> displayedCalls = selectedDayCalls;

    if (_selectedTag == 'Tasks') {
      displayedMeetings = [];
      displayedCalls = [];
    } else if (_selectedTag == 'Deadlines') {
      displayedTasks = selectedDayDeadlines;
      displayedMeetings = [];
      displayedCalls = [];
    } else if (_selectedTag == 'Meetings') {
      displayedTasks = [];
      displayedCalls = [];
    }

    final totalDisplayedEvents = displayedTasks.length + displayedMeetings.length + displayedCalls.length;
    final monthHeaderFormat = DateFormat('MMMM yyyy');
    final selectedDayHeaderFormat = DateFormat('EEEE, MMM d, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF212529)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${activeEmp.name}'s Calendar",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                  ),
                  Text(
                    '${activeEmp.department} • ${activeEmp.role}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              actions: [
                if (widget.allowEmployeeSwitching)
                  IconButton(
                    icon: const Icon(Icons.people_alt_outlined, color: Color(0xFF212529)),
                    tooltip: 'Switch Employee',
                    onPressed: () => _showEmployeePickerSheet(context, erp, activeEmp),
                  ),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CreateTaskDialog(
              initialDate: _selectedDate,
              assignedEmployeeId: activeEmp.id,
              assignedEmployeeName: activeEmp.name,
            ),
          );
        },
        backgroundColor: const Color(0xFF212529),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 18),
        label: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Controls Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Month / Year Title
                      Row(
                        children: [
                          Text(
                            _viewMode == 'Day'
                                ? DateFormat('MMM d, yyyy').format(_selectedDate)
                                : monthHeaderFormat.format(_viewMode == 'Week' ? _selectedDate : _focusedMonth),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF212529),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Today button
                          InkWell(
                            onTap: _goToToday,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Controls: Segregated Daily / Weekly / Monthly Switch & Navigation
                      Row(
                        children: [
                          // 3-way Segregated Toggle: Day / Week / Month
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                _buildViewToggleBtn('Day', _viewMode == 'Day', () => setState(() => _viewMode = 'Day')),
                                _buildViewToggleBtn('Week', _viewMode == 'Week', () => setState(() => _viewMode = 'Week')),
                                _buildViewToggleBtn('Month', _viewMode == 'Month', () => setState(() => _viewMode = 'Month')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Calendar View Body depending on segregation mode
                  if (_viewMode == 'Day')
                    _buildDailyStripBar()
                  else if (_viewMode == 'Week')
                    _buildWeeklyStrip(empTasks, empMeetings, empCalls)
                  else
                    _buildMonthlyGrid(empTasks, empMeetings, empCalls),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Interactive Filter Tags Row: Tasks / Deadlines / Meetings / Task Breakdown
            _buildTagsFilterBar(selectedDayTasks, selectedDayDeadlines, selectedDayMeetings, empTasks),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // View Content Body: Daily Schedule Agenda, Day Schedule List, or Task Breakdown View
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
              child: _selectedTag == 'Task Breakdown'
                  ? _buildTaskBreakdownView(context, erp, empTasks)
                  : (_viewMode == 'Day'
                      ? _buildDailyTimelineAgenda(context, erp, displayedTasks, displayedMeetings, displayedCalls, selectedDayHeaderFormat)
                      : _buildSelectedDayScheduleSection(context, erp, displayedTasks, displayedMeetings, displayedCalls, selectedDayHeaderFormat, totalDisplayedEvents)),
            ),
          ],
        ),
      ),
    );
  }

  // Interactive Schedule Filter Tags Bar
  Widget _buildTagsFilterBar(
    List<CompanyTask> dayTasks,
    List<CompanyTask> dayDeadlines,
    List<Meeting> dayMeetings,
    List<CompanyTask> allTasks,
  ) {
    final tags = [
      {'id': 'All', 'label': 'All Events', 'count': dayTasks.length + dayMeetings.length},
      {'id': 'Tasks', 'label': 'Tasks', 'count': dayTasks.length},
      {'id': 'Deadlines', 'label': 'Deadlines', 'count': dayDeadlines.length},
      {'id': 'Meetings', 'label': 'Meetings', 'count': dayMeetings.length},
      {'id': 'Task Breakdown', 'label': 'Tasks Breakdown', 'count': allTasks.length},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: tags.map((t) {
            final id = t['id'] as String;
            final label = t['label'] as String;
            final count = t['count'] as int;
            final isSel = _selectedTag == id;
            final isDeadline = id == 'Deadlines';

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedTag = id),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel
                        ? const Color(0xFF212529)
                        : (isDeadline && count > 0 ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel
                          ? const Color(0xFF212529)
                          : (isDeadline && count > 0 ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isDeadline && count > 0 && !isSel)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE11D48),
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        '$label ($count)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel
                              ? Colors.white
                              : (isDeadline && count > 0 ? const Color(0xFFE11D48) : const Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Tasks Breakdown & Planner Section
  Widget _buildTaskBreakdownView(BuildContext context, ErpProvider erp, List<CompanyTask> allTasks) {
    final completedTasks = allTasks.where((t) => t.isCompleted).toList();
    final inProgressTasks = allTasks.where((t) => !t.isCompleted && t.status == TaskStatus.inProgress).toList();
    final deadlineTasks = allTasks.where((t) => !t.isCompleted && (t.isOverdue || t.isDueToday)).toList();
    final completionRate = allTasks.isNotEmpty ? (completedTasks.length / allTasks.length) : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breakdown Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Breakdown & Planner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF212529),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${allTasks.length} Assigned Tasks • ${(completionRate * 100).toInt()}% Met',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add_task_rounded, size: 20, color: Color(0xFF212529)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const CreateTaskDialog(),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 4 KPI Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildBreakdownKpiTile('Total', '${allTasks.length}', const Color(0xFF212529), const Color(0xFFF1F5F9)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBreakdownKpiTile('Ongoing', '${inProgressTasks.length}', const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBreakdownKpiTile('Deadlines', '${deadlineTasks.length}', const Color(0xFFE11D48), const Color(0xFFFFF1F2)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBreakdownKpiTile('Completed', '${completedTasks.length}', const Color(0xFF059669), const Color(0xFFECFDF5)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Progress Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Delivery Progress',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  Text(
                    '${(completionRate * 100).toInt()}% Done',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionRate,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF212529)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Task List
        const Text(
          'ASSIGNED TASKS & ACTION ITEMS',
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.6),
        ),
        const SizedBox(height: 10),

        if (allTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            child: const Center(
              child: Text('No assigned tasks available', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          )
        else
          ...allTasks.map((t) => _buildTaskCard(context, t, erp)),
      ],
    );
  }

  Widget _buildBreakdownKpiTile(String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 3, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF212529) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
      ],
    );
  }

  // Daily View Date Selector Strip
  Widget _buildDailyStripBar() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(_selectedDate),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212529),
                ),
              ),
            ],
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'TODAY',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
              ),
            ),
        ],
      ),
    );
  }

  // Weekly Calendar Strip
  Widget _buildWeeklyStrip(List<CompanyTask> tasks, List<Meeting> meetings, List<SalesCall> calls) {
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = monday.add(Duration(days: index));
        final isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;
        final isSelected = date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;

        final hasMeetings = meetings.any((m) =>
            m.date.year == date.year && m.date.month == date.month && m.date.day == date.day);
        final hasTasks = tasks.any((t) =>
            t.dueDate.year == date.year && t.dueDate.month == date.month && t.dueDate.day == date.day);
        final hasCalls = calls.any((c) =>
            c.nextFollowUpDate != null &&
            c.nextFollowUpDate!.year == date.year &&
            c.nextFollowUpDate!.month == date.month &&
            c.nextFollowUpDate!.day == date.day);

        return InkWell(
          onTap: () => setState(() => _selectedDate = date),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF212529)
                  : (isToday ? const Color(0xFFE0F2FE) : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  weekdays[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : (isToday ? const Color(0xFF0284C7) : const Color(0xFF2B3035)),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasMeetings)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (hasTasks)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white70 : const Color(0xFF0284C7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (hasCalls)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF34D399) : const Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Monthly Calendar Grid
  Widget _buildMonthlyGrid(List<CompanyTask> tasks, List<Meeting> meetings, List<SalesCall> calls) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOfWeek = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        // Weekday header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((day) {
            return SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),

        // Grid of dates
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42, // 6 weeks * 7 days
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
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final isToday = date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day;
            final isSelected = date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;

            final hasMeetings = meetings.any((m) =>
                m.date.year == date.year && m.date.month == date.month && m.date.day == date.day);
            final dayTasks = tasks.where((t) =>
                t.dueDate.year == date.year && t.dueDate.month == date.month && t.dueDate.day == date.day).toList();
            final hasTasks = dayTasks.isNotEmpty;
            final hasOverdue = dayTasks.any((t) => t.isOverdue);
            final hasCalls = calls.any((c) =>
                c.nextFollowUpDate != null &&
                c.nextFollowUpDate!.year == date.year &&
                c.nextFollowUpDate!.month == date.month &&
                c.nextFollowUpDate!.day == date.day);

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: (isToday || isSelected) ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isToday ? const Color(0xFF0284C7) : const Color(0xFF2B3035)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasMeetings)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasTasks)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white70
                                  : (hasOverdue ? const Color(0xFFEF4444) : const Color(0xFF0284C7)),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasCalls)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF34D399) : const Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Daily View Hourly Schedule Timeline Agenda
  Widget _buildDailyTimelineAgenda(
    BuildContext context,
    ErpProvider erp,
    List<CompanyTask> tasks,
    List<Meeting> meetings,
    List<SalesCall> calls,
    DateFormat headerFormat,
  ) {
    final totalEvents = tasks.length + meetings.length + calls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Summary Header Banner
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerFormat.format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF212529),
                  ),
                ),
                Text(
                  '$totalEvents scheduled (${meetings.length} meetings • ${tasks.length} tasks${calls.isNotEmpty ? ' • ${calls.length} calls' : ''})',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Row(
              children: [
                _buildLegendDot('Meetings', const Color(0xFF6366F1)),
                const SizedBox(width: 8),
                _buildLegendDot('Tasks', const Color(0xFF0284C7)),
                if (calls.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildLegendDot('Calls', const Color(0xFF10B981)),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // All Day / Day Deliverables Section if any tasks
        if (tasks.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment_turned_in_rounded, size: 15, color: Color(0xFF0284C7)),
                        SizedBox(width: 6),
                        Text(
                          'DAY DELIVERABLES & TASKS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0284C7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${tasks.where((t) => t.isCompleted).length}/${tasks.length} Done',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...tasks.map((t) => _buildTaskCard(context, t, erp)),
              ],
            ),
          ),
        ],

        // Hourly Timeline Agenda (08:00 AM to 08:00 PM)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 15, color: Color(0xFF212529)),
                  SizedBox(width: 6),
                  Text(
                    'HOURLY AGENDA TIMELINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF212529),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hourly Slots 08:00 to 20:00
              ...List.generate(13, (hourIdx) {
                final hour = 8 + hourIdx;
                final hourStr = hour < 12
                    ? '${hour.toString().padLeft(2, '0')}:00 AM'
                    : hour == 12
                        ? '12:00 PM'
                        : '${(hour - 12).toString().padLeft(2, '0')}:00 PM';

                // Find events matching this hour
                final hourMeetings = meetings.where((m) {
                  return _isTimeInHour(m.startTime, hour);
                }).toList();

                final hourCalls = calls.where((c) {
                  if (c.nextFollowUpDate == null) return false;
                  return c.nextFollowUpDate!.hour == hour;
                }).toList();

                final hasEvents = hourMeetings.isNotEmpty || hourCalls.isNotEmpty;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Label column
                      SizedBox(
                        width: 62,
                        child: Text(
                          hourStr,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: hasEvents ? FontWeight.w800 : FontWeight.w600,
                            color: hasEvents ? const Color(0xFF212529) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      // Timeline vertical connector
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 2,
                        height: hasEvents ? 60 : 24,
                        color: hasEvents ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                      ),
                      // Event slot content
                      Expanded(
                        child: hasEvents
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...hourMeetings.map((m) => _buildMeetingCard(context, m)),
                                  ...hourCalls.map((c) => _buildCallCard(context, c)),
                                ],
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: const Text(
                                  'Available Slot',
                                  style: TextStyle(fontSize: 10.5, color: Color(0xFFCBD5E1), fontStyle: FontStyle.italic),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  bool _isTimeInHour(String timeString, int targetHour) {
    try {
      final clean = timeString.toUpperCase().trim();
      final isPM = clean.contains('PM');
      final isAM = clean.contains('AM');
      final parts = clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      var hour = int.parse(parts[0]);
      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      return hour == targetHour;
    } catch (_) {
      return false;
    }
  }

  // Selected Day's Schedule List (for Weekly and Monthly views)
  Widget _buildSelectedDayScheduleSection(
    BuildContext context,
    ErpProvider erp,
    List<CompanyTask> tasks,
    List<Meeting> meetings,
    List<SalesCall> calls,
    DateFormat headerFormat,
    int totalEvents,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerFormat.format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF212529),
                  ),
                ),
                Text(
                  '$totalEvents scheduled (${meetings.length} meetings • ${tasks.length} tasks${calls.isNotEmpty ? ' • ${calls.length} calls' : ''})',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Row(
              children: [
                _buildLegendDot('Meetings', const Color(0xFF6366F1)),
                const SizedBox(width: 8),
                _buildLegendDot('Tasks', const Color(0xFF0284C7)),
                if (calls.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildLegendDot('Calls', const Color(0xFF10B981)),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (totalEvents == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.event_busy_rounded, size: 36, color: Color(0xFF94A3B8)),
                const SizedBox(height: 8),
                const Text(
                  'No Tasks or Meetings Scheduled',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Tap "+ Add Task" below to schedule work or select another date.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          // Scheduled Meetings section
          if (meetings.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.videocam_rounded, size: 14, color: Color(0xFF4F46E5)),
                SizedBox(width: 4),
                Text(
                  'SCHEDULED MEETINGS',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5), letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...meetings.map((m) => _buildMeetingCard(context, m)),
            const SizedBox(height: 14),
          ],

          // Sales Calls section (if any)
          if (calls.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.phone_in_talk_rounded, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 4),
                Text(
                  'SCHEDULED SALES CALLS & FOLLOW-UPS',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981), letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...calls.map((c) => _buildCallCard(context, c)),
            const SizedBox(height: 14),
          ],

          // Scheduled Tasks section
          if (tasks.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.task_alt_rounded, size: 14, color: Color(0xFF0284C7)),
                SizedBox(width: 4),
                Text(
                  'SCHEDULED TASKS & DELIVERABLES',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7), letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...tasks.map((t) => _buildTaskCard(context, t, erp)),
          ],
        ],
      ],
    );
  }

  // Meeting Card in Schedule
  Widget _buildMeetingCard(BuildContext context, Meeting meeting) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => MeetingDetailsDialog(meeting: meeting),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC7D2FE)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.05),
              blurRadius: 6,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${meeting.startTime} – ${meeting.endTime}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const Text(
                        'Tap for Details',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meeting.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meeting.locationOrLink,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sales Call Card in Schedule
  Widget _buildCallCard(BuildContext context, SalesCall call) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.05),
            blurRadius: 6,
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
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF059669), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        call.nextFollowUpDate != null
                            ? DateFormat('hh:mm a').format(call.nextFollowUpDate!)
                            : 'Follow-up Call',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                      ),
                    ),
                    Text(
                      call.outcome.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: call.outcome.color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${call.customerName} (${call.companyName})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                ),
                const SizedBox(height: 2),
                Text(
                  call.notes.isNotEmpty ? call.notes : call.phone,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Task Card in Schedule
  Widget _buildTaskCard(BuildContext context, CompanyTask task, ErpProvider erp) {
    return InkWell(
      onTap: () => EmployeeTaskDetailModal.show(context, task),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.isCompleted
                ? const Color(0xFF86EFAC)
                : (task.isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => erp.toggleTaskCompletion(task.id),
              child: Container(
                margin: const EdgeInsets.only(top: 2, right: 10),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: task.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    width: 1.8,
                  ),
                ),
                child: task.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: task.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF212529),
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      _buildPriorityTag(task.priority),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.deadlineCountdownText,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.projectName ?? 'General Planner',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityTag(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.urgent:
        color = const Color(0xFFEF4444);
        break;
      case TaskPriority.high:
        color = const Color(0xFFF59E0B);
        break;
      case TaskPriority.medium:
        color = const Color(0xFF0284C7);
        break;
      case TaskPriority.low:
        color = const Color(0xFF64748B);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}
