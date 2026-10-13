import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/compact_filter_bar.dart';
import 'task_detail_dialog.dart';

/// Screen 6: Task Management Screen organized by Department with Dropdown Filter Bar
class TaskListScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TaskListScreen({super.key, this.onBack});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TextEditingController _searchController;
  final Set<String> _collapsedDepartments = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<ErpProvider>().taskSearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateTaskDialog(BuildContext context) {
    final erp = context.read<ErpProvider>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String domain = 'Frontend';
    String department = 'Engineering';
    String assignedToId = erp.allEmployees.first.id;
    String assignedToName = erp.allEmployees.first.name;
    AssigneeType assigneeType = AssigneeType.employee;
    TaskPriority priority = TaskPriority.high;
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Assign Task',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Task Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: department,
                        decoration: const InputDecoration(labelText: 'Department'),
                        items: ['Engineering', 'Applied AI', 'UI/UX Design', 'Digital Marketing', 'Sales & BD', 'Operations & Finance', 'Human Resources']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => department = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: domain,
                        decoration: const InputDecoration(labelText: 'Domain'),
                        items: ['Frontend', 'Backend', 'Full Stack', 'Mobile App', 'AI / ML', 'DevOps / Cloud', 'UI/UX Engineering', 'SEO / Marketing', 'Sales Outreach']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => domain = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: assignedToId,
                        decoration: const InputDecoration(labelText: 'Assignee'),
                        items: erp.allEmployees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final emp = erp.allEmployees.firstWhere((e) => e.id == val);
                            setDialogState(() {
                              assignedToId = val;
                              assignedToName = emp.name;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty) return;
                            erp.createTask(
                              title: titleController.text.trim(),
                              description: descController.text.trim().isEmpty ? 'Sprint assignment' : descController.text.trim(),
                              domain: domain,
                              department: department,
                              assignedToId: assignedToId,
                              assignedToName: assignedToName,
                              assigneeType: assigneeType,
                              dueDate: dueDate,
                              priority: priority,
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF212529)),
                          child: const Text('Confirm Task Assignment', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
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
    final tasks = erp.filteredTasks;
    final tasksByDept = erp.tasksByDepartment;

    final availableDepartments = erp.availableTaskDepartments;
    final activeDept = erp.taskDepartmentFilter ?? 'All Departments';
    final activeStatus = erp.taskStatusFilter;
    final activeScope = erp.taskScopeFilter;

    // Quick metrics for top status tabs
    final allCount = erp.allTasks.length;
    final ongoingAndOverdueCount = erp.allTasks.where((t) => t.isOngoing || t.isOverdue).length;
    final upcomingCount = erp.allTasks.where((t) => t.isUpcoming).length;
    final completedCount = erp.allTasks.where((t) => t.isCompleted).length;

    final hasActiveFilters = (erp.taskDepartmentFilter != null && erp.taskDepartmentFilter != 'All Departments') ||
        activeStatus != 'Ongoing & Overdue' ||
        activeScope != 'All' ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF212529)),
                onPressed: widget.onBack,
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Management',
              style: TextStyle(
                color: Color(0xFF212529),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${tasks.length} tasks shown • ${tasksByDept.keys.length} departments',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _showCreateTaskDialog(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF212529),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {});
                  erp.setTaskSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search task by title, assignee, domain...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            erp.setTaskSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Space-Saving Compact Filter Dropdown Bar
          CompactFilterBar(
            hasActiveFilters: hasActiveFilters,
            onReset: () {
              _searchController.clear();
              erp.setTaskSearchQuery('');
              erp.setTaskDepartmentFilter(null);
              erp.setTaskStatusFilter('Ongoing & Overdue');
              erp.setTaskScopeFilter('All');
              setState(() {});
            },
            items: [
              // 1. Department Dropdown
              FilterDropdownItem<String>(
                label: 'Department',
                icon: Icons.corporate_fare_rounded,
                value: activeDept,
                options: availableDepartments.map((dept) {
                  return FilterOption<String>(
                    label: dept,
                    value: dept,
                    icon: _getDepartmentIcon(dept),
                  );
                }).toList(),
                onChanged: (val) {
                  erp.setTaskDepartmentFilter(val == 'All Departments' ? null : val);
                },
              ),

              // 2. Status Dropdown (Default: Ongoing & Overdue)
              FilterDropdownItem<String>(
                label: 'Status',
                icon: Icons.tune_rounded,
                value: activeStatus,
                options: const [
                  FilterOption<String>(label: '⚡ Ongoing & Overdue', value: 'Ongoing & Overdue', color: Color(0xFFE11D48)),
                  FilterOption<String>(label: '🔄 Ongoing (Active)', value: 'Ongoing', color: Color(0xFF2563EB)),
                  FilterOption<String>(label: '⚠️ Overdue Tasks', value: 'Overdue', color: Color(0xFFDC2626)),
                  FilterOption<String>(label: '📅 Upcoming / To-Be', value: 'Upcoming', color: Color(0xFFD97706)),
                  FilterOption<String>(label: '✅ Completed', value: 'Completed', color: Color(0xFF16A34A)),
                  FilterOption<String>(label: '📋 All Tasks', value: 'All'),
                ],
                onChanged: (val) {
                  if (val != null) erp.setTaskStatusFilter(val);
                },
              ),

              // 3. Scope Dropdown
              FilterDropdownItem<String>(
                label: 'Scope',
                icon: Icons.filter_list_rounded,
                value: activeScope,
                options: const [
                  FilterOption<String>(label: 'All Scope', value: 'All'),
                  FilterOption<String>(label: 'My Tasks', value: 'My Tasks', icon: Icons.person_outline),
                  FilterOption<String>(label: 'Project Tasks', value: 'Projects • Domain', icon: Icons.folder_open),
                ],
                onChanged: (val) {
                  if (val != null) erp.setTaskScopeFilter(val);
                },
              ),
            ],
          ),

          // Quick Action Status Navigation Tabs (Options to visit upcoming & completed tasks)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickStatusChip(
                    '⚡ Ongoing & Overdue ($ongoingAndOverdueCount)',
                    activeStatus == 'Ongoing & Overdue',
                    const Color(0xFFE11D48),
                    () => erp.setTaskStatusFilter('Ongoing & Overdue'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickStatusChip(
                    '📅 Upcoming ($upcomingCount)',
                    activeStatus == 'Upcoming',
                    const Color(0xFFD97706),
                    () => erp.setTaskStatusFilter('Upcoming'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickStatusChip(
                    '✅ Completed ($completedCount)',
                    activeStatus == 'Completed',
                    const Color(0xFF16A34A),
                    () => erp.setTaskStatusFilter('Completed'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickStatusChip(
                    'All ($allCount)',
                    activeStatus == 'All',
                    const Color(0xFF475569),
                    () => erp.setTaskStatusFilter('All'),
                  ),
                ],
              ),
            ),
          ),

          // Tasks List (Grouped by Department)
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.task_alt_rounded, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 10),
                        Text(
                          'No tasks found for "$activeStatus".',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            erp.setTaskStatusFilter('All');
                            erp.setTaskDepartmentFilter(null);
                          },
                          child: const Text('View All Tasks'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasksByDept.keys.length,
                    itemBuilder: (context, index) {
                      final deptName = tasksByDept.keys.elementAt(index);
                      final deptTasks = tasksByDept[deptName]!;
                      final isCollapsed = _collapsedDepartments.contains(deptName);

                      final deptOngoing = deptTasks.where((t) => t.isOngoing).length;
                      final deptOverdue = deptTasks.where((t) => t.isOverdue).length;
                      final deptUpcoming = deptTasks.where((t) => t.isUpcoming).length;
                      final deptDone = deptTasks.where((t) => t.isCompleted).length;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Department Header Card
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (isCollapsed) {
                                    _collapsedDepartments.remove(deptName);
                                  } else {
                                    _collapsedDepartments.add(deptName);
                                  }
                                });
                              },
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9).withOpacity(0.6),
                                  borderRadius: isCollapsed
                                      ? BorderRadius.circular(16)
                                      : const BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF212529),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getDepartmentIcon(deptName),
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            deptName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF212529),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Wrap(
                                            spacing: 6,
                                            children: [
                                              _buildDeptCountTag('Ongoing: $deptOngoing', const Color(0xFF2563EB)),
                                              if (deptOverdue > 0)
                                                _buildDeptCountTag('Overdue: $deptOverdue', const Color(0xFFDC2626)),
                                              _buildDeptCountTag('To-Be: $deptUpcoming', const Color(0xFFD97706)),
                                              _buildDeptCountTag('Done: $deptDone', const Color(0xFF16A34A)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isCollapsed ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                                      size: 20,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (!isCollapsed) ...[
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              ...deptTasks.map((task) => _buildTaskCard(task)),
                              const SizedBox(height: 6),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatusChip(String label, bool isSelected, Color activeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildDeptCountTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildTaskCard(CompanyTask task) {
    final isOverdue = task.isOverdue;
    final isDone = task.isCompleted;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => TaskDetailDialog(task: task),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOverdue ? const Color(0xFFFEF2F2).withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFF1F5F9),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFFDCFCE7)
                        : (isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDone
                        ? Icons.check_circle_outline_rounded
                        : (isOverdue ? Icons.warning_amber_rounded : Icons.pending_actions_rounded),
                    size: 16,
                    color: isDone
                        ? const Color(0xFF16A34A)
                        : (isOverdue ? const Color(0xFFDC2626) : const Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212529),
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${task.domain} • Assigned to ${task.assignedToName}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                // Priority / Status Pill
                _buildTaskStatusBadge(task),
              ],
            ),
            const SizedBox(height: 8),
            // Progress Bar & Due Date
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.progressPercent / 100.0,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone
                            ? const Color(0xFF16A34A)
                            : (isOverdue ? const Color(0xFFDC2626) : const Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${task.progressPercent}%',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  isOverdue ? '${task.daysOverdue}d overdue' : 'Due ${_formatDate(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isOverdue ? FontWeight.w800 : FontWeight.w500,
                    color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusBadge(CompanyTask task) {
    if (task.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Done', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
      );
    }
    if (task.isOverdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Overdue', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
      );
    }
    if (task.isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Ongoing', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('To-Be', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}';
  }

  IconData _getDepartmentIcon(String dept) {
    final d = dept.toLowerCase();
    if (d.contains('eng') || d.contains('tech')) return Icons.code_rounded;
    if (d.contains('ai') || d.contains('intell')) return Icons.psychology_rounded;
    if (d.contains('design') || d.contains('ui')) return Icons.palette_rounded;
    if (d.contains('market') || d.contains('growth')) return Icons.campaign_rounded;
    if (d.contains('sales') || d.contains('biz')) return Icons.trending_up_rounded;
    if (d.contains('people') || d.contains('hr')) return Icons.groups_rounded;
    if (d.contains('finance') || d.contains('account')) return Icons.account_balance_rounded;
    if (d.contains('ops') || d.contains('operat')) return Icons.settings_suggest_rounded;
    return Icons.business_rounded;
  }
}
