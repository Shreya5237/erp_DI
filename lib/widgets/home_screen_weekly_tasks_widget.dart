import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../providers/erp_provider.dart';
import '../screens/tasks/task_detail_dialog.dart';
import '../screens/tasks/task_list_screen.dart';
import '../services/native_home_widget_service.dart';

/// Deadline categories for precise calendar-day calculations
enum DeadlineCategory {
  completed,
  dueToday,
  dueTomorrow,
  upcoming,
  overdue,
}

/// Calculated deadline information using local calendar dates
class TaskDeadlineInfo {
  final DeadlineCategory category;
  final String label;
  final int days;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final Color badgeBorderColor;
  final IconData icon;

  const TaskDeadlineInfo({
    required this.category,
    required this.label,
    required this.days,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
    required this.badgeBorderColor,
    required this.icon,
  });

  /// Calculates deadline countdown using local calendar dates (year, month, day)
  /// rather than raw timestamps to avoid timezone or hour-boundary distortions.
  static TaskDeadlineInfo calculate(CompanyTask task, [DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final target = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);

    // 1. Completed tasks: no outstanding obligation
    if (task.isCompleted) {
      return const TaskDeadlineInfo(
        category: DeadlineCategory.completed,
        label: 'Completed',
        days: 0,
        badgeBackgroundColor: Color(0xFFECFDF5),
        badgeTextColor: Color(0xFF059669),
        badgeBorderColor: Color(0xFFA7F3D0),
        icon: Icons.check_circle_outline_rounded,
      );
    }

    // 2. Due today
    if (target.isAtSameMomentAs(today)) {
      return const TaskDeadlineInfo(
        category: DeadlineCategory.dueToday,
        label: 'Due Today',
        days: 0,
        badgeBackgroundColor: Color(0xFFFEF3C7),
        badgeTextColor: Color(0xFFD97706),
        badgeBorderColor: Color(0xFFFDE68A),
        icon: Icons.today_rounded,
      );
    }

    // 3. Due tomorrow
    if (target.isAtSameMomentAs(tomorrow)) {
      return const TaskDeadlineInfo(
        category: DeadlineCategory.dueTomorrow,
        label: 'Due Tomorrow',
        days: 1,
        badgeBackgroundColor: Color(0xFFE0F2FE),
        badgeTextColor: Color(0xFF0284C7),
        badgeBorderColor: Color(0xFFBAE6FD),
        icon: Icons.upcoming_rounded,
      );
    }

    // 4. Overdue tasks
    if (target.isBefore(today)) {
      final daysPast = today.difference(target).inDays;
      final daysPastClamped = daysPast <= 0 ? 1 : daysPast;
      return TaskDeadlineInfo(
        category: DeadlineCategory.overdue,
        label: daysPastClamped == 1 ? 'Overdue by 1 day' : 'Overdue by $daysPastClamped days',
        days: daysPastClamped,
        badgeBackgroundColor: const Color(0xFFFEF2F2),
        badgeTextColor: const Color(0xFFDC2626),
        badgeBorderColor: const Color(0xFFFECACA),
        icon: Icons.warning_amber_rounded,
      );
    }

    // 5. Future deadlines
    final daysRemaining = target.difference(today).inDays;
    return TaskDeadlineInfo(
      category: DeadlineCategory.upcoming,
      label: daysRemaining == 1 ? '1 day remaining' : '$daysRemaining days remaining',
      days: daysRemaining,
      badgeBackgroundColor: const Color(0xFFF1F5F9),
      badgeTextColor: const Color(0xFF475569),
      badgeBorderColor: const Color(0xFFCBD5E1),
      icon: Icons.schedule_rounded,
    );
  }
}

/// Home Screen Weekly Tasks Widget
/// Displays tasks scheduled for current Monday-to-Sunday week, highlights upcoming deadlines,
/// shows countdowns, provides completion toggles, and syncs with ERP provider state.
class HomeScreenWeeklyTasksWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onViewAll;
  final VoidCallback? onRefresh;
  final VoidCallback? onAddTask;
  final bool isCompact;
  final int? maxTasksToShow;

  const HomeScreenWeeklyTasksWidget({
    super.key,
    this.title = 'Weekly Tasks',
    this.onViewAll,
    this.onRefresh,
    this.onAddTask,
    this.isCompact = false,
    this.maxTasksToShow,
  });

  @override
  State<HomeScreenWeeklyTasksWidget> createState() => _HomeScreenWeeklyTasksWidgetState();
}

class _HomeScreenWeeklyTasksWidgetState extends State<HomeScreenWeeklyTasksWidget> {
  String _selectedFilter = 'All';
  bool _isRefreshing = false;

  Future<void> _handleRefresh(ErpProvider erp) async {
    setState(() => _isRefreshing = true);
    widget.onRefresh?.call();
    await NativeHomeWidgetService.syncToNativeWidgets(erp);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _openTaskDetails(BuildContext context, CompanyTask task, ErpProvider erp) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: erp,
        child: TaskDetailDialog(task: task),
      ),
    );
  }

  void _openFullWeeklyList(BuildContext context) {
    if (widget.onViewAll != null) {
      widget.onViewAll!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: TaskListScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allPrioritized = erp.currentWeekTasksPrioritized;
    final totalDue = erp.currentWeekTasksTotalCount;
    final completedCount = erp.currentWeekTasksCompletedCount;
    final completionRate = erp.currentWeekTaskCompletionRate;

    final monday = erp.currentWeekMonday;
    final sunday = erp.currentWeekSundayEnd;
    final rangeFormat = DateFormat('MMM d');
    final weekDateRangeLabel = '${rangeFormat.format(monday)} – ${rangeFormat.format(sunday)}';

    // Apply filter if selected
    List<CompanyTask> displayedTasks = allPrioritized;
    if (_selectedFilter == 'Today & Tomorrow') {
      displayedTasks = allPrioritized.where((t) {
        final info = TaskDeadlineInfo.calculate(t);
        return info.category == DeadlineCategory.dueToday ||
            info.category == DeadlineCategory.dueTomorrow;
      }).toList();
    } else if (_selectedFilter == 'Upcoming') {
      displayedTasks = allPrioritized.where((t) {
        final info = TaskDeadlineInfo.calculate(t);
        return info.category == DeadlineCategory.upcoming;
      }).toList();
    } else if (_selectedFilter == 'Overdue') {
      displayedTasks = allPrioritized.where((t) {
        final info = TaskDeadlineInfo.calculate(t);
        return info.category == DeadlineCategory.overdue;
      }).toList();
    } else if (_selectedFilter == 'Completed') {
      displayedTasks = allPrioritized.where((t) => t.isCompleted).toList();
    }

    if (widget.maxTasksToShow != null && widget.maxTasksToShow! > 0) {
      displayedTasks = displayedTasks.take(widget.maxTasksToShow!).toList();
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header: Weekly Progress Summary
          _buildWeeklyHeader(
            context,
            erp,
            weekDateRangeLabel,
            totalDue,
            completedCount,
            completionRate,
          ),
          const SizedBox(height: 16),

          // 2. Filter Pills
          _buildFilterTabs(allPrioritized),
          const SizedBox(height: 16),

          // 3. Task List or Empty State
          if (displayedTasks.isEmpty)
            _buildEmptyState(context, erp)
          else
            _buildTaskList(context, erp, displayedTasks),

          // 4. Footer link if more tasks exist
          if (allPrioritized.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildFooterActions(context, allPrioritized.length),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyHeader(
    BuildContext context,
    ErpProvider erp,
    String weekRange,
    int totalDue,
    int completedCount,
    double completionRate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 450;
            final titleWidget = Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_view_week_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF212529),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        weekRange,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );

            final actionsWidget = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onAddTask != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF212529), size: 20),
                    tooltip: 'Add Task',
                    onPressed: widget.onAddTask,
                  ),
                IconButton(
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF212529)),
                        )
                      : const Icon(Icons.refresh_rounded, color: Color(0xFF212529), size: 20),
                  tooltip: 'Refresh & Sync Widget',
                  onPressed: _isRefreshing ? null : () => _handleRefresh(erp),
                ),
                TextButton(
                  onPressed: () => _openFullWeeklyList(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF212529)),
                    ],
                  ),
                ),
              ],
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget,
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: actionsWidget),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: titleWidget),
                const SizedBox(width: 8),
                actionsWidget,
              ],
            );
          },
        ),
        const SizedBox(height: 14),

        // Progress bar card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 295;
                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEEKLY PROGRESS',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount of $totalDue completed (${completionRate.toStringAsFixed(0)}%)',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212529),
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'WEEKLY PROGRESS',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$completedCount of $totalDue completed (${completionRate.toStringAsFixed(0)}%)',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212529),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalDue > 0 ? (completedCount / totalDue).clamp(0.0, 1.0) : 1.0,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF212529)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(List<CompanyTask> tasks) {
    final todayAndTomorrowCount = tasks.where((t) {
      final info = TaskDeadlineInfo.calculate(t);
      return info.category == DeadlineCategory.dueToday ||
          info.category == DeadlineCategory.dueTomorrow;
    }).length;
    final overdueCount = tasks.where((t) => TaskDeadlineInfo.calculate(t).category == DeadlineCategory.overdue).length;
    final completedCount = tasks.where((t) => t.isCompleted).length;

    final filters = [
      {'label': 'All', 'count': tasks.length},
      {'label': 'Today & Tomorrow', 'count': todayAndTomorrowCount},
      {'label': 'Overdue', 'count': overdueCount},
      {'label': 'Completed', 'count': completedCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final label = f['label'] as String;
          final count = f['count'] as int;
          final isSelected = _selectedFilter == label;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _selectedFilter = label),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF212529) : const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF212529) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, ErpProvider erp, List<CompanyTask> tasks) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskRow(context, erp, task);
      },
    );
  }

  Widget _buildTaskRow(BuildContext context, ErpProvider erp, CompanyTask task) {
    final deadlineInfo = TaskDeadlineInfo.calculate(task);
    final dateFmt = DateFormat('EEE, MMM d');

    return InkWell(
      key: ValueKey('task-card-${task.id}'),
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openTaskDetails(context, task, erp),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF212529),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.isCompleted
                ? const Color(0xFF2F9E44)
                : (deadlineInfo.category == DeadlineCategory.overdue
                    ? const Color(0xFFE03131)
                    : const Color(0xFF343A40)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular toggle completion button
            InkWell(
              key: ValueKey('task-checkbox-${task.id}'),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                erp.toggleTaskCompletion(task.id);
                NativeHomeWidgetService.syncToNativeWidgets(erp);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 2, right: 10),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFFADB5BD),
                    width: 1.8,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),

            // Task content & badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Priority Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: task.isCompleted ? const Color(0xFF868E96) : Colors.white,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: const Color(0xFFADB5BD),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildPriorityChip(task.priority),
                    ],
                  ),

                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11.5,
                        color: const Color(0xFFCED4DA),
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Deadline, Countdown Badge, and Status
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Prominent Deadline Date
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14171A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF343A40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFFCED4DA)),
                            const SizedBox(width: 4),
                            Text(
                              dateFmt.format(task.dueDate),
                              style: GoogleFonts.instrumentSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Countdown / Obligation Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: deadlineInfo.badgeBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: deadlineInfo.badgeBorderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(deadlineInfo.icon, size: 11, color: deadlineInfo.badgeTextColor),
                            const SizedBox(width: 4),
                            Text(
                              deadlineInfo.label,
                              style: GoogleFonts.instrumentSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: deadlineInfo.badgeTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14171A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF343A40)),
                        ),
                        child: Text(
                          task.status.label,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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

  Widget _buildPriorityChip(TaskPriority priority) {
    Color bg;
    Color text;
    Color border;

    switch (priority) {
      case TaskPriority.urgent:
        bg = const Color(0xFFFEF2F2);
        text = const Color(0xFFDC2626);
        border = const Color(0xFFFECACA);
        break;
      case TaskPriority.high:
        bg = const Color(0xFFFFF7ED);
        text = const Color(0xFFEA580C);
        border = const Color(0xFFFED7AA);
        break;
      case TaskPriority.medium:
        bg = const Color(0xFFF0F9FF);
        text = const Color(0xFF0284C7);
        border = const Color(0xFFBAE6FD);
        break;
      case TaskPriority.low:
        bg = const Color(0xFFF8FAFC);
        text = const Color(0xFF64748B);
        border = const Color(0xFFE2E8F0);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        priority.label,
        style: GoogleFonts.instrumentSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ErpProvider erp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const Icon(
              Icons.done_all_rounded,
              color: Color(0xFF10B981),
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 'All'
                ? 'No Tasks Scheduled for This Week'
                : 'No $_selectedFilter Tasks Found',
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF212529),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedFilter == 'All'
                ? 'You are all caught up for Monday through Sunday.'
                : 'Try selecting a different filter tab or check back later.',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, int totalCount) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Text(
          'Showing tasks for current active week',
          style: GoogleFonts.instrumentSans(
            fontSize: 11,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _openFullWeeklyList(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Text(
              'Open Full Schedule ($totalCount)',
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF212529),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
