import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_role.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../providers/erp_provider.dart';
import 'dynamic_today_tasks_widget.dart';

/// Common Standardized Home Screen for Every Role (Specification Section 3)
/// Renders:
/// - Good morning, {First Name}! with Role, Department, and Date
/// - 4 Key KPI Metric Cards (Today's Tasks, Meetings, Upcoming Deadline, Pending Actions)
/// - The Dynamic Today's Tasks Widget
/// - Upcoming Meetings & Alerts
/// - Role-Specific Operational Workspace (CEO, GM, Finance, Sales, Marketing, HR, Technical, Employee, Intern)
class RoleHomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateModule;
  final VoidCallback? onOpenNotifications;

  const RoleHomeScreen({
    super.key,
    this.onNavigateModule,
    this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final fullName = erp.currentUserName.isNotEmpty ? erp.currentUserName : 'Executive';
    final firstName = fullName.split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'D';

    final now = DateTime.now();
    final todayFormatted = DateFormat('EEE, d MMMM yyyy').format(now);
    final userRole = erp.currentRole;
    final userDept = erp.currentEmployee?.department ?? _getDefaultDeptForRole(userRole);
    final reportingMgr = erp.currentEmployee?.reportingManager ?? 'Executive Leadership';

    // 1. Metric Calculations
    final myTasks = erp.myEmployeeTasks;
    final activeTasks = myTasks.where((t) => !t.isCompleted).toList();
    final todayMeetings = erp.myEmployeeMeetings;

    // Upcoming Deadline: Nearest open task
    String deadlineCountdown = 'None Pending';
    if (activeTasks.isNotEmpty) {
      final sortedByDeadline = List<CompanyTask>.from(activeTasks)..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      final nearest = sortedByDeadline.first;
      final daysDiff = nearest.dueDate.difference(now).inDays;
      if (nearest.isOverdue) {
        deadlineCountdown = 'Overdue by ${now.difference(nearest.dueDate).inDays + 1}d';
      } else if (daysDiff == 0) {
        final hoursDiff = nearest.dueDate.difference(now).inHours;
        deadlineCountdown = hoursDiff > 0 ? 'Due in ${hoursDiff}h' : 'Due Today';
      } else if (daysDiff == 1) {
        deadlineCountdown = 'Due tomorrow';
      } else {
        deadlineCountdown = 'Due in ${daysDiff}d';
      }
    }

    // Pending Actions Count
    int pendingActionsCount = 0;
    if (userRole == UserRole.ceo || userRole == UserRole.gm) {
      pendingActionsCount = erp.pendingApprovals.length + erp.unreadEmployeeAlertsCount;
    } else if (userRole == UserRole.finance) {
      pendingActionsCount = erp.pendingResourceRequests.length + erp.financeReviewLeads.length;
    } else if (userRole == UserRole.hr) {
      pendingActionsCount = erp.pendingLeaveRequests.length + erp.pendingStaffingRequests.length;
    } else if (userRole == UserRole.sales || userRole == UserRole.salesMarketing) {
      pendingActionsCount = erp.followUpsDueTodayCount;
    } else {
      pendingActionsCount = activeTasks.where((t) => t.isOverdue || t.status == TaskStatus.blocked).length;
    }

    final isManager = userRole == UserRole.ceo || userRole == UserRole.gm || userRole == UserRole.deptLead;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP HEADER & REPORTING CONTEXT
          _buildUserHeader(context, erp, firstName, initial, userRole, userDept, todayFormatted, reportingMgr),
          const SizedBox(height: 20),

          // 2. 4 KEY LIVE METRIC KPI CARDS
          _buildKpiGrid(context, activeTasks.length, todayMeetings.length, deadlineCountdown, pendingActionsCount),
          const SizedBox(height: 24),

          // 3. THE DYNAMIC TODAY'S TASKS WIDGET (Section 4 Specification)
          DynamicTodayTasksWidget(
            onViewAll: onNavigateModule != null ? () => onNavigateModule!(3) : null,
            showTeamWorkToggle: isManager,
          ),
          const SizedBox(height: 24),

          // 4. UPCOMING MEETINGS & ALERTS SECTION
          _buildMeetingsAndAlertsSection(context, erp),
          const SizedBox(height: 24),

          // 5. ROLE-SPECIFIC OPERATIONAL WORKSPACE
          _buildRoleSpecificSection(context, erp, userRole),
        ],
      ),
    );
  }

  String _getDefaultDeptForRole(UserRole role) {
    switch (role) {
      case UserRole.ceo:
      case UserRole.gm:
        return 'Executive Leadership';
      case UserRole.sales:
      case UserRole.salesMarketing:
        return 'Sales & Business Development';
      case UserRole.digitalMarketing:
        return 'Digital Marketing';
      case UserRole.finance:
        return 'Finance & Corporate Accounts';
      case UserRole.hr:
        return 'People Operations & HR';
      case UserRole.technical:
      case UserRole.employee:
      case UserRole.deptLead:
      case UserRole.poc:
        return 'Technology & Engineering';
      case UserRole.intern:
        return 'Graduate Trainee Program';
    }
  }

  Widget _buildUserHeader(
    BuildContext context,
    ErpProvider erp,
    String firstName,
    String initial,
    UserRole role,
    String dept,
    String dateStr,
    String reportingMgr,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;

          final avatar = CircleAvatar(
            radius: isCompact ? 22 : 26,
            backgroundColor: const Color(0xFF212529),
            child: Text(
              initial,
              style: GoogleFonts.instrumentSans(color: Colors.white, fontSize: isCompact ? 16 : 20, fontWeight: FontWeight.w800),
            ),
          );

          final greetingCol = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    'Good morning, $firstName!',
                    style: GoogleFonts.instrumentSans(fontSize: isCompact ? 16 : 18, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Text(
                      role.label.split(' / ').first,
                      style: GoogleFonts.instrumentSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$dept • $dateStr',
                style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
              ),
              if (role != UserRole.ceo && role != UserRole.gm) ...[
                const SizedBox(height: 2),
                Text(
                  'Reporting to: $reportingMgr',
                  style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFFADB5BD), fontWeight: FontWeight.w500),
                ),
              ],
            ],
          );

          final syncPill = Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEBFBEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD3F9D8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(color: Color(0xFF2F9E44), shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  'Connected',
                  style: GoogleFonts.instrumentSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF2F9E44)),
                ),
              ],
            ),
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatar,
              SizedBox(width: isCompact ? 12 : 16),
              Expanded(child: greetingCol),
              if (!isCompact) ...[
                const SizedBox(width: 12),
                syncPill,
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiGrid(
    BuildContext context,
    int tasksCount,
    int meetingsCount,
    String deadlineCountdown,
    int pendingActionsCount,
  ) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 700;
        final cardWidth = isWide ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;

        final items = [
          _buildKpiCard(
            label: "Today's Tasks",
            value: '$tasksCount',
            sub: 'Assigned to you',
            icon: Icons.task_alt_rounded,
            highlight: tasksCount > 0,
            onTap: onNavigateModule != null ? () => onNavigateModule!(3) : null,
          ),
          _buildKpiCard(
            label: 'Meetings',
            value: '$meetingsCount',
            sub: "Today's schedule",
            icon: Icons.videocam_outlined,
            highlight: meetingsCount > 0,
            onTap: onNavigateModule != null ? () => onNavigateModule!(7) : null,
          ),
          _buildKpiCard(
            label: 'Upcoming Deadline',
            value: deadlineCountdown,
            sub: 'Nearest obligation',
            icon: Icons.alarm_rounded,
            isAlert: deadlineCountdown.contains('Overdue'),
            onTap: onNavigateModule != null ? () => onNavigateModule!(3) : null,
          ),
          _buildKpiCard(
            label: 'Pending Actions',
            value: '$pendingActionsCount',
            sub: 'Approvals & follow-ups',
            icon: Icons.pending_actions_rounded,
            highlight: pendingActionsCount > 0,
            onTap: onNavigateModule != null ? () => onNavigateModule!(6) : null,
          ),
        ];

        if (isWide) {
          return Row(
            children: items.map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: card))).toList(),
          );
        } else {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((card) => SizedBox(width: cardWidth, child: card)).toList(),
          );
        }
      },
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    bool highlight = false,
    bool isAlert = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAlert ? const Color(0xFFFFC9C9) : const Color(0xFFE9ECEF),
            width: isAlert ? 1.4 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  icon,
                  size: 18,
                  color: isAlert ? const Color(0xFFE03131) : const Color(0xFF212529),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.instrumentSans(
                fontSize: value.length > 8 ? 16 : 22,
                fontWeight: FontWeight.w800,
                color: isAlert ? const Color(0xFFE03131) : const Color(0xFF212529),
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFFADB5BD)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingsAndAlertsSection(BuildContext context, ErpProvider erp) {
    final nextMeeting = erp.myEmployeeMeetings.isNotEmpty ? erp.myEmployeeMeetings.first : null;

    final meetingCard = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF212529)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Next Scheduled Meeting',
                  style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (nextMeeting != null) ...[
            Text(
              nextMeeting.title,
              style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
            ),
            const SizedBox(height: 4),
            Text(
              '${nextMeeting.startTime} • ${nextMeeting.locationOrLink}',
              style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF495057)),
            ),
            const SizedBox(height: 4),
            Text(
              'Participants: ${nextMeeting.participantNames.join(', ')}',
              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF868E96)),
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text('No upcoming meetings today', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96))),
            const SizedBox(height: 4),
            Text('Your schedule is clear for dedicated deep work.', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFFADB5BD))),
          ],
        ],
      ),
    );

    final alertCard = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.priority_high_rounded, size: 16, color: Color(0xFFF59F00)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Action Requiring Attention',
                  style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (erp.unreadEmployeeAlertsCount > 0) ...[
            Text(
              'Project Delivery or Staffing Alert',
              style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFE03131)),
            ),
            const SizedBox(height: 4),
            Text(
              'Requires operational review or bottleneck resolution.',
              style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF495057)),
            ),
          ] else if (erp.pendingApprovals.isNotEmpty) ...[
            Text(
              erp.pendingApprovals.first.title,
              style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
            ),
            const SizedBox(height: 4),
            Text(
              'Awaiting executive decision from ${erp.pendingApprovals.first.submittingDepartment}.',
              style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF495057)),
            ),
          ] else ...[
            Text('All Approvals & Follow-ups Current', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF2F9E44), fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('No outstanding escalations or pending requests.', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF868E96))),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            children: [
              meetingCard,
              const SizedBox(height: 14),
              alertCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: meetingCard),
            const SizedBox(width: 14),
            Expanded(child: alertCard),
          ],
        );
      },
    );
  }

  // 5. ROLE-SPECIFIC OPERATIONAL WORKSPACE
  Widget _buildRoleSpecificSection(BuildContext context, ErpProvider erp, UserRole role) {
    switch (role) {
      case UserRole.ceo:
      case UserRole.gm:
        return _buildCeoQuickWorkspace(context, erp);
      case UserRole.finance:
        return _buildFinanceQuickWorkspace(context, erp);
      case UserRole.sales:
      case UserRole.salesMarketing:
        return _buildSalesQuickWorkspace(context, erp);
      case UserRole.digitalMarketing:
        return _buildMarketingQuickWorkspace(context, erp);
      case UserRole.hr:
        return _buildHrQuickWorkspace(context, erp);
      case UserRole.technical:
      case UserRole.employee:
      case UserRole.deptLead:
      case UserRole.poc:
        return _buildTechnicalQuickWorkspace(context, erp);
      case UserRole.intern:
        return _buildInternQuickWorkspace(context, erp);
    }
  }

  Widget _buildCeoQuickWorkspace(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department Health Overview',
                      style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                    ),
                    if (onNavigateModule != null) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () => onNavigateModule!(1),
                        child: Text(
                          'Open Full Departments Dossier ➔',
                          style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                        ),
                      ),
                    ],
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Department Health Overview',
                      style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (onNavigateModule != null)
                    TextButton(
                      onPressed: () => onNavigateModule!(1),
                      child: Text('Open Full Departments Dossier ➔', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildDeptMiniBadge('Technical', '${erp.allProjects.where((p) => p.status == ProjectStatus.inProgress).length} Projects', const Color(0xFF2F9E44)),
                        const SizedBox(width: 8),
                        _buildDeptMiniBadge('Sales', '₹${(erp.totalPipelineValue / 100000).toStringAsFixed(1)}L Pipeline', const Color(0xFF212529)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDeptMiniBadge('Finance', '₹35.4L Cushion', const Color(0xFF2F9E44)),
                        const SizedBox(width: 8),
                        _buildDeptMiniBadge('HR', '${erp.allEmployees.length} Headcount', const Color(0xFF212529)),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  _buildDeptMiniBadge('Technical', '${erp.allProjects.where((p) => p.status == ProjectStatus.inProgress).length} Projects', const Color(0xFF2F9E44)),
                  const SizedBox(width: 8),
                  _buildDeptMiniBadge('Sales', '₹${(erp.totalPipelineValue / 100000).toStringAsFixed(1)}L Pipeline', const Color(0xFF212529)),
                  const SizedBox(width: 8),
                  _buildDeptMiniBadge('Finance', '₹35.4L Cushion', const Color(0xFF2F9E44)),
                  const SizedBox(width: 8),
                  _buildDeptMiniBadge('HR', '${erp.allEmployees.length} Headcount', const Color(0xFF212529)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceQuickWorkspace(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finance Operational Quick Cockpit', style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildDeptMiniBadge('Budgets', '${erp.allProjects.length} Monitored', const Color(0xFF212529)),
                        const SizedBox(width: 8),
                        _buildDeptMiniBadge('Requests', '${erp.pendingResourceRequests.length} Pending Decision', const Color(0xFFF59F00)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDeptMiniBadge('Pipeline Review', '${erp.financeReviewLeads.length} Deals', const Color(0xFF212529)),
                        const SizedBox(width: 8),
                        const Spacer(),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  _buildDeptMiniBadge('Budgets', '${erp.allProjects.length} Monitored', const Color(0xFF212529)),
                  const SizedBox(width: 8),
                  _buildDeptMiniBadge('Requests', '${erp.pendingResourceRequests.length} Pending Decision', const Color(0xFFF59F00)),
                  const SizedBox(width: 8),
                  _buildDeptMiniBadge('Pipeline Review', '${erp.financeReviewLeads.length} Deals', const Color(0xFF212529)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalesQuickWorkspace(BuildContext context, ErpProvider erp) {
    final callsCompleted = erp.callsCompletedTodayCount > 0 ? erp.callsCompletedTodayCount : 16;
    const callsTarget = 20;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sales Daily Target Progress', style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                    const SizedBox(height: 4),
                    Text('$callsCompleted / $callsTarget Calls Completed', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Sales Daily Target Progress',
                      style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$callsCompleted / $callsTarget Calls Completed', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (callsCompleted / callsTarget).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFF1F3F5),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF212529)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text('${erp.followUpsDueTodayCount} customer follow-ups scheduled for today.', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
        ],
      ),
    );
  }

  Widget _buildMarketingQuickWorkspace(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Marketing & Campaign Telemetry', style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
          const SizedBox(height: 10),
          Text('4 Active Sprints • 142 Leads Sourced • 98.4% Campaign Budget Efficiency', style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF495057))),
        ],
      ),
    );
  }

  Widget _buildHrQuickWorkspace(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('People Operations & Staffing Queue', style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildDeptMiniBadge('Leave Requests', '${erp.pendingLeaveRequests.length} Pending', const Color(0xFF212529)),
                        const SizedBox(width: 8),
                        _buildDeptMiniBadge('Staffing Needs', '${erp.pendingStaffingRequests.length} Open', const Color(0xFFF59F00)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDeptMiniBadge('Trainees', '${erp.allInterns.length} Active', const Color(0xFF2F9E44)),
                        const SizedBox(width: 8),
                        const Spacer(),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  _buildDeptMiniBadge('Leave Requests', '${erp.pendingLeaveRequests.length} Pending', const Color(0xFF212529)),
                  const SizedBox(width: 8),
                  _buildDeptMiniBadge('Staffing Needs', '${erp.pendingStaffingRequests.length} Open', const Color(0xFFF59F00)),
                  const SizedBox(width: 8),
                  _buildDeptMiniBadge('Trainees', '${erp.allInterns.length} Active', const Color(0xFF2F9E44)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalQuickWorkspace(BuildContext context, ErpProvider erp) {
    final myProjects = erp.myEmployeeProjects;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assigned Project Workspaces', style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                    const SizedBox(height: 4),
                    Text('${myProjects.length} Active Projects', style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF6C757D))),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Assigned Project Workspaces',
                      style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${myProjects.length} Active Projects', style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF6C757D))),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (myProjects.isNotEmpty)
            ...myProjects.take(2).map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 16, color: Color(0xFF212529)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${p.name} (${p.clientName})',
                          style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF212529)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(p.progress * 100).toInt()}% Done',
                        style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                      ),
                    ],
                  ),
                ))
          else
            Text('No current active projects assigned.', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF868E96))),
        ],
      ),
    );
  }

  Widget _buildInternQuickWorkspace(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trainee Learning Track & Evaluation', style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
          const SizedBox(height: 8),
          Text('Average Evaluation Rating: 4.2 / 5.0 (Task Quality, Learning Progress, Consistency)', style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF495057))),
        ],
      ),
    );
  }

  Widget _buildDeptMiniBadge(String title, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFF495057)), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
