import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../providers/erp_provider.dart';
import '../../employee/pages/employee_calendar_page.dart';

/// Page 6 — Tasks & Calendar: Plan HR work, deadlines, and meetings
/// Implements Daily, Weekly, Monthly calendar views and highlights overdue items.
class HrTasksCalendarPage extends StatefulWidget {
  const HrTasksCalendarPage({super.key});

  @override
  State<HrTasksCalendarPage> createState() => _HrTasksCalendarPageState();
}

class _HrTasksCalendarPageState extends State<HrTasksCalendarPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _taskFilter = 'All'; // 'All', 'Today', 'Next 7 Days', 'Overdue', 'Done'

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return const Color(0xFFEF4444);
      case TaskPriority.high:
        return const Color(0xFFF97316);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.low:
        return const Color(0xFF10B981);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allHrTasks = erp.hrTasks;
    final allHrMeetings = erp.hrMeetings;

    final todayTasks = allHrTasks.where((t) => t.isDueToday).toList();
    final overdueTasks = allHrTasks.where((t) => t.isOverdue).toList();
    final next7DaysTasks = allHrTasks.where((t) => !t.isDueToday && !t.isOverdue && t.status != TaskStatus.done).toList();
    final completedTasks = allHrTasks.where((t) => t.status == TaskStatus.done).toList();

    List<CompanyTask> displayedTasks;
    switch (_taskFilter) {
      case 'Today':
        displayedTasks = todayTasks;
        break;
      case 'Next 7 Days':
        displayedTasks = next7DaysTasks;
        break;
      case 'Overdue':
        displayedTasks = overdueTasks;
        break;
      case 'Done':
        displayedTasks = completedTasks;
        break;
      default:
        displayedTasks = allHrTasks;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Tasks & Calendar',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF38BDF8),
          labelColor: const Color(0xFF38BDF8),
          unselectedLabelColor: const Color(0xFF64748B),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text('Tasks (${allHrTasks.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text('Calendar (${allHrMeetings.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddTaskDialog(context, erp),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Tasks View
          _buildTasksTab(context, erp, displayedTasks, todayTasks.length, next7DaysTasks.length, overdueTasks.length, completedTasks.length),

          // Tab 2: Calendar View (Unified with Technical Employee Portal UI)
          EmployeeCalendarPage(
            employeeId: erp.currentUserId.isNotEmpty ? erp.currentUserId : 'EMP-401',
            showAppBar: false,
            allowEmployeeSwitching: true,
          ),
        ],
      ),
    );
  }

  // Tasks Tab View
  Widget _buildTasksTab(
    BuildContext context,
    ErpProvider erp,
    List<CompanyTask> tasks,
    int todayCount,
    int next7Count,
    int overdueCount,
    int doneCount,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', erp.hrTasks.length, const Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                _buildFilterChip('Today', todayCount, const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _buildFilterChip('Next 7 Days', next7Count, const Color(0xFF10B981)),
                const SizedBox(width: 8),
                _buildFilterChip('Overdue', overdueCount, const Color(0xFFEF4444)),
                const SizedBox(width: 8),
                _buildFilterChip('Done', doneCount, const Color(0xFF64748B)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Overdue Warning Banner
          if (overdueCount > 0 && _taskFilter != 'Done') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Attention: $overdueCount HR task(s) are overdue. Please complete or reschedule.',
                      style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          if (tasks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.task_alt_rounded, color: Color(0xFF475569), size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No $_taskFilter tasks found',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ...tasks.map((task) => _buildTaskItem(context, erp, task)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, Color color) {
    final isSelected = _taskFilter == label;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _taskFilter = label);
      },
      selectedColor: color.withValues(alpha: 0.2),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? color : const Color(0xFF64748B),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? color : const Color(0xFF334155)),
    );
  }

  Widget _buildTaskItem(BuildContext context, ErpProvider erp, CompanyTask task) {
    final isDone = task.status == TaskStatus.done;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isOverdue && !isDone
              ? const Color(0xFFEF4444).withValues(alpha: 0.5)
              : const Color(0xFF334155),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => erp.toggleHrTask(task.id),
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
                size: 22,
              ),
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
                          color: isDone ? const Color(0xFF64748B) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (task.isOverdue && !isDone)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('OVERDUE', style: TextStyle(color: Color(0xFFEF4444), fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    task.description,
                    style: TextStyle(color: isDone ? const Color(0xFF475569) : const Color(0xFF64748B), fontSize: 11),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: task.isOverdue && !isDone ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                      style: TextStyle(
                        color: task.isOverdue && !isDone ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority.label,
                        style: TextStyle(color: _getPriorityColor(task.priority), fontSize: 9.5, fontWeight: FontWeight.bold),
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
  void _showAddTaskDialog(BuildContext context, ErpProvider erp) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime dueDate = DateTime.now().add(const Duration(days: 2));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Add Personal HR Task', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Task Title...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F7),
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Description or notes...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F7),
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Due Date:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) setDialogState(() => dueDate = picked);
                        },
                        child: Text('${dueDate.day}/${dueDate.month}/${dueDate.year}', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Priority:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      DropdownButton<TaskPriority>(
                        value: selectedPriority,
                        dropdownColor: Colors.white,
                        items: TaskPriority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.label, style: TextStyle(color: _getPriorityColor(p), fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedPriority = v);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  erp.addHrPersonalTask(
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    priority: selectedPriority,
                    dueDate: dueDate,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Personal task created')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212529),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
