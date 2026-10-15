import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/erp_provider.dart';
import '../screens/tasks/task_detail_dialog.dart';

/// Dynamic Today's Tasks Widget (Specification Section 4)
/// Provides a live, interconnected view of personal assigned work:
/// - Selects tasks based on authenticated user ID and role assignments
/// - Strictly differentiates personal tasks from team-wide work
/// - Shows prominent Overdue Tasks alert section
/// - Shows Today's Active Tasks with priority, due time, status, and project tag
/// - Allows starting work, changing status, raising blockers with reasons, and completing tasks
/// - Updates project progress, notifies leads, and logs audit entries in real time
class DynamicTodayTasksWidget extends StatefulWidget {
  final VoidCallback? onViewAll;
  final bool showTeamWorkToggle;

  const DynamicTodayTasksWidget({
    super.key,
    this.onViewAll,
    this.showTeamWorkToggle = false,
  });

  @override
  State<DynamicTodayTasksWidget> createState() => _DynamicTodayTasksWidgetState();
}

class _DynamicTodayTasksWidgetState extends State<DynamicTodayTasksWidget> {
  bool _showCompleted = false;
  bool _viewingTeamTasks = false;

  void _showBlockerDialog(BuildContext context, CompanyTask task, ErpProvider erp) {
    final blockerController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.block_rounded, color: Color(0xFFE03131), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Report Task Blocker',
                style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specify the obstacle preventing progress on "${task.title}". The project manager and department lead will be alerted immediately.',
              style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF495057), height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: blockerController,
              maxLines: 3,
              style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF212529)),
              decoration: InputDecoration(
                hintText: 'e.g. Waiting on API credentials, missing client design assets...',
                hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                filled: true,
                fillColor: const Color(0xFFF5F6F7),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = blockerController.text.trim();
              if (reason.isEmpty) return;
              erp.updateAgileTaskStatus(task.id, TaskStatus.blocked, blockerReason: reason);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  content: Text('Blocker logged. Department lead has been notified.', style: GoogleFonts.instrumentSans()),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE03131),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Submit Blocker', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    // Select source list based on toggle if manager
    final sourceList = _viewingTeamTasks ? erp.allTasks : erp.myEmployeeTasks;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Overdue tasks: Not completed and dueDate before todayStart
    final overdueTasks = sourceList.where((t) {
      if (t.isCompleted) return false;
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return tDate.isBefore(todayStart);
    }).toList();

    // Today's tasks: Not completed and dueDate falls on today
    final todayTasks = sourceList.where((t) {
      if (t.isCompleted) return false;
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return tDate.year == todayStart.year && tDate.month == todayStart.month && tDate.day == todayStart.day;
    }).toList();

    // If no explicit today tasks exist, pull the first 3 active uncompleted tasks
    final activeDisplayTasks = todayTasks.isNotEmpty
        ? todayTasks
        : sourceList.where((t) => !t.isCompleted && !overdueTasks.contains(t)).take(4).toList();

    // Completed today
    final completedTodayTasks = sourceList.where((t) {
      if (!t.isCompleted) return false;
      if (t.completedAt != null) {
        return t.completedAt!.isAfter(todayStart.subtract(const Duration(hours: 12)));
      }
      return true;
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 460;

              final titleRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212529),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _viewingTeamTasks ? "Team Active Tasks" : "Today's Tasks",
                      style: GoogleFonts.instrumentSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Text(
                      '${activeDisplayTasks.length + overdueTasks.length}',
                      style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                    ),
                  ),
                ],
              );

              final actionsRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showTeamWorkToggle) ...[
                    InkWell(
                      onTap: () => setState(() => _viewingTeamTasks = !_viewingTeamTasks),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          _viewingTeamTasks ? (isCompact ? "My Tasks" : "Switch to My Tasks") : (isCompact ? "Team" : "Team Overview"),
                          style: GoogleFonts.instrumentSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF495057),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (widget.onViewAll != null)
                    InkWell(
                      onTap: widget.onViewAll,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              'View all',
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF212529)),
                          ],
                        ),
                      ),
                    ),
                ],
              );

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 6),
                  actionsRow,
                ],
              );
            },
          ),

          // 1. OVERDUE TASKS PROMINENT SECTION (Section 4.B Specification)
          if (overdueTasks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC9C9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFE03131)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Overdue Work Requiring Attention (${overdueTasks.length})',
                          style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFFE03131)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...overdueTasks.map((t) => _buildTaskCard(context, t, erp, isOverdue: true)),
                ],
              ),
            ),
          ],

          // 2. ACTIVE TODAY TASKS
          const SizedBox(height: 16),
          if (activeDisplayTasks.isEmpty && overdueTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.task_alt_rounded, size: 36, color: Color(0xFF2F9E44)),
                    const SizedBox(height: 8),
                    Text(
                      'No pending tasks for today',
                      style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                    ),
                    Text(
                      'You are completely caught up on scheduled deliverables.',
                      style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activeDisplayTasks.map((t) => _buildTaskCard(context, t, erp)),

          // 3. COMPLETED TODAY SUMMARY
          if (completedTodayTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => _showCompleted = !_showCompleted),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      _showCompleted ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                      size: 18,
                      color: const Color(0xFF6C757D),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed Today (${completedTodayTasks.length})',
                      style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
                    ),
                  ],
                ),
              ),
            ),
            if (_showCompleted) ...[
              const SizedBox(height: 6),
              ...completedTodayTasks.map((t) => _buildCompletedCard(context, t, erp)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, CompanyTask task, ErpProvider erp, {bool isOverdue = false}) {
    final daysDiff = task.dueDate.difference(DateTime.now()).inDays;
    final String deadlineText;
    if (isOverdue) {
      final days = DateTime.now().difference(task.dueDate).inDays;
      deadlineText = days <= 0 ? 'Overdue today' : 'Overdue by ${days + 1}d';
    } else if (daysDiff == 0) {
      deadlineText = 'Due today (${DateFormat('h:mm a').format(task.dueDate)})';
    } else if (daysDiff == 1) {
      deadlineText = 'Due tomorrow';
    } else {
      deadlineText = 'Due in $daysDiff days';
    }

    final isBlocked = task.status == TaskStatus.blocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.white : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOverdue ? const Color(0xFFFFD8D8) : const Color(0xFFE9ECEF)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => TaskDetailDialog(task: task),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox toggle
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: task.isCompleted ? const Color(0xFF2F9E44) : const Color(0xFFADB5BD),
                  ),
                  onPressed: () => erp.toggleTaskCompletion(task.id),
                ),
                const SizedBox(width: 10),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: GoogleFonts.instrumentSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF212529),
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          _buildPriorityBadge(task.priority),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Project & Department
                      Row(
                        children: [
                          Icon(Icons.folder_outlined, size: 12, color: const Color(0xFF6C757D)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${task.projectName ?? "General Task"} • ${task.department}',
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Deadline & Status (Responsive LayoutBuilder)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final statusChip = _buildStatusChip(task.status);
                          final deadlineWidget = Row(
                            children: [
                              Icon(
                                isOverdue ? Icons.alarm_on_rounded : Icons.schedule_rounded,
                                size: 12,
                                color: isOverdue ? const Color(0xFFE03131) : const Color(0xFF6C757D),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  deadlineText,
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 11.5,
                                    fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                                    color: isOverdue ? const Color(0xFFE03131) : const Color(0xFF6C757D),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );

                          if (constraints.maxWidth < 240) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                deadlineWidget,
                                const SizedBox(height: 6),
                                statusChip,
                              ],
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: deadlineWidget),
                              const SizedBox(width: 8),
                              statusChip,
                            ],
                          );
                        },
                      ),

                      if (isBlocked && task.blockerReason != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Blocker: ${task.blockerReason}',
                            style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFFE03131), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF6C757D)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 'inProgress') {
                      erp.updateAgileTaskStatus(task.id, TaskStatus.inProgress);
                    } else if (val == 'done') {
                      erp.updateAgileTaskStatus(task.id, TaskStatus.done);
                    } else if (val == 'blocker') {
                      _showBlockerDialog(context, task, erp);
                    } else if (val == 'details') {
                      showDialog(
                        context: context,
                        builder: (_) => TaskDetailDialog(task: task),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'inProgress', child: Text('Mark In Progress')),
                    const PopupMenuItem(value: 'done', child: Text('Mark Completed')),
                    const PopupMenuItem(value: 'blocker', child: Text('Report Blocker')),
                    const PopupMenuItem(value: 'details', child: Text('Open Task Dossier')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, CompanyTask task, ErpProvider erp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF2F9E44)),
            onPressed: () => erp.toggleTaskCompletion(task.id),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.instrumentSans(
                fontSize: 12.5,
                color: const Color(0xFF6C757D),
                decoration: TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              task.projectName ?? 'Task',
              style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFFADB5BD)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color bg;
    Color fg;
    String label;

    switch (priority) {
      case TaskPriority.urgent:
      case TaskPriority.high:
        bg = const Color(0xFFFFF5F5);
        fg = const Color(0xFFE03131);
        label = 'High';
        break;
      case TaskPriority.medium:
        bg = const Color(0xFFFFF9DB);
        fg = const Color(0xFFF59F00);
        label = 'Medium';
        break;
      case TaskPriority.low:
        bg = const Color(0xFFF1F3F5);
        fg = const Color(0xFF495057);
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color bg = const Color(0xFFF1F3F5);
    Color fg = const Color(0xFF495057);
    String label = status.label;

    if (status == TaskStatus.done || status == TaskStatus.approved) {
      bg = const Color(0xFFEBFBEE);
      fg = const Color(0xFF2F9E44);
    } else if (status == TaskStatus.inProgress) {
      bg = const Color(0xFFFFF9DB);
      fg = const Color(0xFFF59F00);
    } else if (status == TaskStatus.blocked) {
      bg = const Color(0xFFFFF5F5);
      fg = const Color(0xFFE03131);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
