import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/task.dart';
import '../widgets/create_task_dialog.dart';

/// Screen 4: Tasks & Schedule (Daily Work Planner)
/// Adhering strictly to finalized concept:
/// - View tasks assigned by managers
/// - View task descriptions, priorities, and deadlines
/// - Mark tasks as completed and update progress
/// - See today's tasks, tomorrow's tasks, and next 7 days
/// - Create personal tasks and reminders
/// - Sort tasks by deadline, priority, or status
/// - Automatically reflects completion in the dashboard's progress indicators
class EmployeeTasksPage extends StatefulWidget {
  const EmployeeTasksPage({super.key});

  @override
  State<EmployeeTasksPage> createState() => _EmployeeTasksPageState();
}

class _EmployeeTasksPageState extends State<EmployeeTasksPage> {
  String _activeTab = 'All'; // 'Today', 'Tomorrow', 'Next 7 Days', 'Overdue', 'All'
  String _sortBy = 'Deadline'; // 'Deadline', 'Priority', 'Status'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final myTasks = erp.myEmployeeTasks;

    // Filter tasks based on activeTab
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextSevenDays = today.add(const Duration(days: 7));

    List<CompanyTask> filtered = myTasks.where((t) {
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);

      if (_activeTab == 'Today') {
        return tDate.isAtSameMomentAs(today);
      } else if (_activeTab == 'Tomorrow') {
        return tDate.isAtSameMomentAs(tomorrow);
      } else if (_activeTab == 'Next 7 Days') {
        return !tDate.isBefore(today) && !tDate.isAfter(nextSevenDays);
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
      body: Column(
        children: [
          // Header & Add Task Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Work Planner',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF212529),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Manager assignments & personal tasks',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const CreateTaskDialog(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text('Add Task', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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

                // Timeline Filter Tabs: Today, Tomorrow, Next 7 Days, Overdue, All
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimelineTab('All', myTasks.length),
                      const SizedBox(width: 6),
                      _buildTimelineTab('Today', myTasks.where((t) => t.isDueToday).length),
                      const SizedBox(width: 6),
                      _buildTimelineTab('Tomorrow', myTasks.where((t) => t.isDueTomorrow).length),
                      const SizedBox(width: 6),
                      _buildTimelineTab('Next 7 Days', myTasks.where((t) => !t.dueDate.isBefore(today) && !t.dueDate.isAfter(nextSevenDays)).length),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              : (isOverdueTab && count > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isOverdueTab && count > 0 ? const Color(0xFFDC2626) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, CompanyTask task, ErpProvider erp) {
    final dateFormat = DateFormat('EEE, MMM d');
    final isManagerAssigned = !task.isPersonalTask;

    return Container(
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
    );
  }

  Widget _buildPriorityPill(TaskPriority priority) {
    Color bg;
    Color fg;
    switch (priority) {
      case TaskPriority.urgent:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFEF4444);
        break;
      case TaskPriority.high:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case TaskPriority.medium:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        break;
      case TaskPriority.low:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(priority.label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
