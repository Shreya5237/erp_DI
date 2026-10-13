import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/task.dart';
import '../../../models/meeting.dart';
import '../widgets/meeting_details_dialog.dart';
import '../widgets/create_task_dialog.dart';
import '../../../widgets/home_screen_weekly_tasks_widget.dart';

/// Screen 1: Employee Dashboard (Home Screen)
/// Adhering strictly to the finalized concept:
/// - Leave balance: Number of leaves available
/// - Progress overview: Tasks completed versus pending
/// - Upcoming meetings: Next meeting, time, and a quick join or details option
/// - Upcoming deadlines: Deadline date and countdown in days, with overdue tasks highlighted
/// - This week's tasks in priority order: Today's urgent tasks first, followed by tomorrow's tasks and the remaining week
class EmployeeDashboardPage extends StatelessWidget {
  final VoidCallback? onNavigateToTasks;
  final VoidCallback? onNavigateToCalendar;

  const EmployeeDashboardPage({
    super.key,
    this.onNavigateToTasks,
    this.onNavigateToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final employee = erp.currentEmployee;
    final myTasks = erp.myEmployeeTasks;
    final nextMeeting = erp.nextMyMeeting;

    // Task counts
    final completedCount = myTasks.where((t) => t.isCompleted).length;
    final pendingCount = myTasks.where((t) => !t.isCompleted).length;
    final overdueCount = myTasks.where((t) => t.isOverdue).length;
    final totalCount = myTasks.length;
    final progressPercent = totalCount > 0 ? (completedCount / totalCount) : 1.0;

    // Upcoming deadlines: tasks not completed sorted by deadline
    final upcomingDeadlineTasks = myTasks
        .where((t) => !t.isCompleted)
        .toList()
      ..sort((a, b) {
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
        return a.dueDate.compareTo(b.dueDate);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 400)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Welcome Bar
              _buildWelcomeHeader(erp, employee),
              const SizedBox(height: 16),

              // 1. Leave Balance Card
              _buildLeaveBalanceCard(context, employee),
              const SizedBox(height: 16),

              // 2. Progress Overview: Tasks Completed vs Pending
              _buildProgressOverviewCard(completedCount, pendingCount, overdueCount, progressPercent),
              const SizedBox(height: 16),

              // 3. Upcoming Meeting: Next meeting, time, quick join or details
              _buildUpcomingMeetingCard(context, nextMeeting),
              const SizedBox(height: 20),

              // 4. Upcoming Deadlines with Countdown in Days & Overdue Highlight
              _buildUpcomingDeadlinesSection(context, upcomingDeadlineTasks),
              const SizedBox(height: 20),

              // 5. This Week's Tasks Widget in Priority Order
              HomeScreenWeeklyTasksWidget(
                title: "This Week's Tasks",
                onViewAll: onNavigateToTasks,
                onAddTask: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CreateTaskDialog(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ErpProvider erp, dynamic employee) {
    final dateFormat = DateFormat('EEEE, MMMM d');
    final firstName = erp.currentUserName.split(' ').first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hello, $firstName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF212529),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('👋', style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              employee?.role ?? 'Technical Specialist',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.today_rounded, size: 14, color: Color(0xFF0284C7)),
              const SizedBox(width: 5),
              Text(
                dateFormat.format(DateTime.now()),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2B3035)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 1. Leave Balance Card
  Widget _buildLeaveBalanceCard(BuildContext context, dynamic employee) {
    final totalAvailable = employee?.leaveBalance ?? 14;
    final casual = employee?.casualLeaves ?? 6;
    final sick = employee?.sickLeaves ?? 5;
    final paid = employee?.paidLeaves ?? 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.beach_access_rounded, color: Color(0xFF059669), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Leave Balance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212529),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF059669), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '$totalAvailable Days Available',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Leave Breakdown Chips
          Row(
            children: [
              _buildLeaveSubtypeCard('Casual', '$casual', const Color(0xFF0284C7)),
              const SizedBox(width: 8),
              _buildLeaveSubtypeCard('Sick', '$sick', const Color(0xFFEF4444)),
              const SizedBox(width: 8),
              _buildLeaveSubtypeCard('Paid / Privilege', '$paid', const Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveSubtypeCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 2. Progress Overview Card
  Widget _buildProgressOverviewCard(int completed, int pending, int overdue, double progress) {
    final percentInt = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.analytics_outlined, color: Color(0xFF0284C7), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Progress Overview',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212529),
                    ),
                  ),
                ],
              ),
              Text(
                '$percentInt% Completed',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // 3 Metric Badges: Completed, Pending, Overdue
          Row(
            children: [
              _buildProgressMetric(
                label: 'Completed',
                count: '$completed',
                color: const Color(0xFF10B981),
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: 8),
              _buildProgressMetric(
                label: 'Pending',
                count: '$pending',
                color: const Color(0xFFF59E0B),
                icon: Icons.hourglass_top_rounded,
              ),
              const SizedBox(width: 8),
              _buildProgressMetric(
                label: 'Overdue',
                count: '$overdue',
                color: const Color(0xFFEF4444),
                icon: Icons.error_outline_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric({
    required String label,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 3. Upcoming Meeting Card
  Widget _buildUpcomingMeetingCard(BuildContext context, Meeting? meeting) {
    if (meeting == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.event_available_rounded, color: Color(0xFF10B981), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No Meetings Scheduled', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529))),
                  Text('You have a clear schedule for the moment.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF212529).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Color(0xFF818CF8), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'NEXT MEETING',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC7D2FE),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meeting.startTime,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            meeting.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Location / Platform
          Row(
            children: [
              const Icon(Icons.link_rounded, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  meeting.locationOrLink,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action buttons: Quick Join or Details
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => MeetingDetailsDialog(meeting: meeting),
                    );
                  },
                  icon: const Icon(Icons.videocam_rounded, size: 15, color: Colors.white),
                  label: const Text('Quick Join', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => MeetingDetailsDialog(meeting: meeting),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Upcoming Deadlines with Countdown & Overdue Highlight
  Widget _buildUpcomingDeadlinesSection(BuildContext context, List<CompanyTask> deadlineTasks) {
    final dateFormat = DateFormat('MMM d');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.timer_outlined, size: 18, color: Color(0xFF212529)),
                SizedBox(width: 6),
                Text(
                  'Upcoming Deadlines',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212529),
                  ),
                ),
              ],
            ),
            if (onNavigateToTasks != null)
              GestureDetector(
                onTap: onNavigateToTasks,
                child: const Text(
                  'View All Tasks',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (deadlineTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text('No pending deadlines!', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: deadlineTasks.take(5).map((task) {
                final isOverdue = task.isOverdue;
                final isDueToday = task.isDueToday;
                final badgeColor = isOverdue
                    ? const Color(0xFFEF4444)
                    : (isDueToday ? const Color(0xFFF59E0B) : const Color(0xFF0284C7));

                return Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                      width: isOverdue ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.deadlineCountdownText,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateFormat.format(task.dueDate),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212529),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.projectName ?? 'Engineering Core',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

}

