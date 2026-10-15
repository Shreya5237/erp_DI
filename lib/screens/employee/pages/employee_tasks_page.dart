import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/task.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/employee_task_detail_modal.dart';

/// Screen 4: Tasks & Schedule (Daily Work Planner)
/// Time-sequenced list of all assigned tasks categorized by status:
/// - Ongoing
/// - Upcoming
/// - Completed
/// Tapping any task card opens the detailed card overlay modal
class EmployeeTasksPage extends StatefulWidget {
  const EmployeeTasksPage({super.key});

  @override
  State<EmployeeTasksPage> createState() => _EmployeeTasksPageState();
}

class _EmployeeTasksPageState extends State<EmployeeTasksPage> {
  String _activeTab = 'All'; // 'All', 'Ongoing', 'Upcoming', 'Completed', 'Overdue'
  String _sortBy = 'Deadline'; // 'Deadline', 'Priority', 'Status'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final myTasks = erp.myEmployeeTasks;

    // Filter tasks based on status category
    List<CompanyTask> filtered = myTasks.where((t) {
      if (_activeTab == 'Ongoing') {
        return !t.isCompleted && (t.status == TaskStatus.inProgress || t.status == TaskStatus.todo);
      } else if (_activeTab == 'Upcoming') {
        return !t.isCompleted && t.dueDate.isAfter(DateTime.now());
      } else if (_activeTab == 'Completed') {
        return t.isCompleted;
      } else if (_activeTab == 'Overdue') {
        return t.isOverdue;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            (t.projectName ?? '').toLowerCase().contains(q);
      }

      return true;
    }).toList();

    // Sort tasks
    filtered.sort((a, b) {
      if (_sortBy == 'Deadline') {
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
        return a.dueDate.compareTo(b.dueDate);
      } else if (_sortBy == 'Priority') {
        return b.priority.index.compareTo(a.priority.index);
      } else {
        // Status: Ongoing first, then Todo, then Done
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        return a.status.index.compareTo(b.status.index);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const CreateTaskDialog(),
          );
        },
        backgroundColor: const Color(0xFF212529),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 18),
        label: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Daily Work Planner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Work Planner',
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212529),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Today: ${DateFormat('MMM d').format(DateTime.now())} • Tomorrow: ${DateFormat('MMM d').format(DateTime.now().add(const Duration(days: 1)))}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search & Sort bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search tasks by keyword...',
                          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF5F6F7),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sort By Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          icon: const Icon(Icons.sort_rounded, size: 18, color: Color(0xFF212529)),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                          items: ['Deadline', 'Priority', 'Status'].map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text('Sort: $opt'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _sortBy = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Status & Timeline Filter Tabs: All, Ongoing, Upcoming, Completed, Overdue
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimelineTab('All', myTasks.length),
                      const SizedBox(width: 6),
                      _buildTimelineTab('Ongoing', myTasks.where((t) => !t.isCompleted && (t.status == TaskStatus.inProgress || t.status == TaskStatus.todo)).length),
                      const SizedBox(width: 6),
                      _buildTimelineTab('Upcoming', myTasks.where((t) => !t.isCompleted && t.dueDate.isAfter(DateTime.now())).length),
                      const SizedBox(width: 6),
                      _buildTimelineTab('Completed', myTasks.where((t) => t.isCompleted).length),
                      const SizedBox(width: 6),
                      _buildTimelineTab('Overdue', myTasks.where((t) => t.isOverdue).length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tasks List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.task_alt_rounded, size: 40, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 10),
                        Text('No tasks in "$_activeTab"', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                        const SizedBox(height: 4),
                        const Text('Tap "+ Add Task" to schedule a personal task or reminder.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 80),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final task = filtered[idx];
                      return _buildTaskCard(context, task, erp);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(String label, int count) {
    final isSelected = _activeTab == label;
    final isOverdueTab = label == 'Overdue';

    return InkWell(
      onTap: () => setState(() => _activeTab = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isOverdueTab ? const Color(0xFFEF4444) : const Color(0xFF212529))
              : (isOverdueTab && count > 0 ? const Color(0xFFFFF5F5) : const Color(0xFFF1F3F5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isOverdueTab ? const Color(0xFFEF4444) : const Color(0xFF212529))
                : const Color(0xFFE9ECEF),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontFamily: GoogleFonts.instrumentSans().fontFamily,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isOverdueTab && count > 0 ? const Color(0xFFE03131) : const Color(0xFF6C757D)),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, CompanyTask task, ErpProvider erp) {
    final dateFormat = DateFormat('EEE, MMM d');
    final isManagerAssigned = !task.isPersonalTask;

    return InkWell(
      onTap: () => EmployeeTaskDetailModal.show(context, task),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? const Color(0xFF86EFAC)
              : (task.isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
          width: task.isOverdue ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1-Tap Toggle Circle
          InkWell(
            onTap: () => erp.toggleTaskCompletion(task.id),
            child: Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
          ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority pill, Countdown, Due Date
                Row(
                  children: [
                    _buildPriorityPill(task.priority),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.isOverdue
                            ? const Color(0xFFFEF2F2)
                            : (task.isDueToday ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.deadlineCountdownText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: task.isOverdue
                              ? const Color(0xFFEF4444)
                              : (task.isDueToday ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(task.dueDate),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: task.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF212529),
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),

                // Description
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Footer: Project tag & Assigned by info
                Row(
                  children: [
                    if (task.projectName != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.projectName!,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isManagerAssigned ? Icons.person_outline_rounded : Icons.person_pin_rounded,
                            size: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              isManagerAssigned ? 'Assigned by: ${task.assignedByName}' : 'Personal Task',
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  Widget _buildPriorityPill(TaskPriority priority) {
    Color bg;
    Color fg;
    switch (priority) {
      case TaskPriority.urgent:
        bg = const Color(0xFFFFF5F5);
        fg = const Color(0xFFE03131);
        break;
      case TaskPriority.high:
        bg = const Color(0xFFFFF9DB);
        fg = const Color(0xFFF59F00);
        break;
      case TaskPriority.medium:
        bg = const Color(0xFFF1F3F5);
        fg = const Color(0xFF495057);
        break;
      case TaskPriority.low:
        bg = const Color(0xFFF8F9FA);
        fg = const Color(0xFF6C757D);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontFamily: GoogleFonts.instrumentSans().fontFamily,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
