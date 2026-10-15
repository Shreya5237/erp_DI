import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/hr_models.dart';
import '../../../models/task.dart';
import '../../../models/project.dart';
import '../../../models/intern.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/hr_target_config_dialog.dart';
import 'hr_leave_management_page.dart';
import 'hr_pipeline_coordination_page.dart';

/// Page 1 — Dashboard: HR's daily overview
/// Prioritizes pending leave approvals, urgent staffing, and project coordination at the top.
class HrDashboardPage extends StatelessWidget {
  final VoidCallback? onNavigateToStaffing;
  final VoidCallback? onNavigateToTrainees;
  final VoidCallback? onNavigateToCalendar;

  const HrDashboardPage({
    super.key,
    this.onNavigateToStaffing,
    this.onNavigateToTrainees,
    this.onNavigateToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final pendingLeaves = erp.pendingLeaveRequests;
    final pendingStaffing = erp.pendingStaffingRequests;
    final attentionTrainees = erp.traineesNeedingAttention;
    final newJoiners = erp.newJoiners;
    final attentionProjects = erp.projectsNeedingAttention;
    final hrTasks = erp.hrTasks;
    final hrMeetings = erp.hrMeetings;
    final targets = erp.hrMonthlyTargets;

    final todayTasks = hrTasks.where((t) => t.isDueToday || t.isOverdue).toList();
    final weekTasks = hrTasks.where((t) => !t.isDueToday && !t.isOverdue).take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 300)),
        color: const Color(0xFF8B5CF6),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome & Greeting banner
              _buildWelcomeBanner(context, erp),
              const SizedBox(height: 16),

              // ==========================================
              // TOP PRIORITY: Urgent Approvals & Staffing
              // ==========================================
              if (pendingLeaves.isNotEmpty || pendingStaffing.isNotEmpty || attentionProjects.isNotEmpty) ...[
                _buildSectionHeader('Urgent Action Required', Icons.warning_amber_rounded, const Color(0xFFEF4444)),
                const SizedBox(height: 8),

                // Pending Leave Approvals Card
                if (pendingLeaves.isNotEmpty)
                  _buildPendingLeavesCard(context, pendingLeaves),
                if (pendingLeaves.isNotEmpty) const SizedBox(height: 10),

                // Urgent Team Member Staffing Requests Card
                if (pendingStaffing.isNotEmpty)
                  _buildPendingStaffingCard(context, pendingStaffing),
                if (pendingStaffing.isNotEmpty) const SizedBox(height: 10),

                // Projects Needing Staffing / Attention Card
                if (attentionProjects.isNotEmpty)
                  _buildProjectsNeedingAttentionCard(context, attentionProjects),
                const SizedBox(height: 20),
              ],

              // ==========================================
              // SECTION 2: HR Monthly Targets & Deadlines
              // ==========================================
              _buildSectionHeader('HR Monthly Targets & KPI', Icons.military_tech_rounded, const Color(0xFFA855F7),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFFA855F7)),
                  label: const Text('Configure', style: TextStyle(color: Color(0xFFA855F7), fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => HrTargetConfigDialog.show(context),
                ),
              ),
              const SizedBox(height: 8),
              _buildMonthlyTargetsCard(context, erp, targets),
              const SizedBox(height: 12),

              // Next Important Deadline Countdown Card
              _buildNextDeadlineCard(),
              const SizedBox(height: 20),

              // ==========================================
              // SECTION 3: Onboarding & Trainees Overview
              // ==========================================
              _buildSectionHeader('Onboarding & Trainees', Icons.school_rounded, const Color(0xFF10B981)),
              const SizedBox(height: 8),
              _buildTraineesOverviewCard(context, newJoiners, attentionTrainees),
              const SizedBox(height: 20),

              // ==========================================
              // SECTION 4: Weekly Tasks & Priorities
              // ==========================================
              _buildSectionHeader('Weekly Tasks & Priorities', Icons.task_alt_rounded, const Color(0xFF38BDF8),
                trailing: TextButton(
                  onPressed: onNavigateToCalendar,
                  child: const Text('View All', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              _buildWeeklyTasksCard(context, erp, todayTasks, weekTasks),
              const SizedBox(height: 20),

              // ==========================================
              // SECTION 5: Upcoming Meetings
              // ==========================================
              _buildSectionHeader('Upcoming Meetings', Icons.calendar_month_rounded, const Color(0xFFF59E0B)),
              const SizedBox(height: 8),
              _buildUpcomingMeetingsCard(context, hrMeetings),
            ],
          ),
        ),
      ),
    );
  }

  // Welcome Greeting
  Widget _buildWelcomeBanner(BuildContext context, ErpProvider erp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF212529), Color(0xFF2B3035)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF212529).withValues(alpha: 0.12),
            blurRadius: 16,
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 1.5),
                      ),
                      child: const Center(
                        child: Text('MJ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meera Joshi',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Head of HR & People Operations • EMP-111',
                            style: TextStyle(color: Color(0xFFDDD6FE), fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('HR Lead', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.beach_access_rounded, color: Color(0xFF38BDF8), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Own Leaves: 18 days',
                        style: const TextStyle(color: Color(0xFFE0F2FE), fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_rounded, color: Color(0xFF34D399), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Total Staff: ${erp.allEmployees.length}',
                        style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Header Helper
  Widget _buildSectionHeader(String title, IconData icon, Color color, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Color(0xFF212529), fontSize: 14.5, fontWeight: FontWeight.w800, letterSpacing: -0.2),
          ),
        ),
        ?trailing,
      ],
    );
  }

  // Card 1: Pending Leave Approvals
  Widget _buildPendingLeavesCard(BuildContext context, List<EmployeeLeaveRequest> leaves) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.event_busy_rounded, color: Color(0xFFF59E0B), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pending Leave Approvals (${leaves.length})',
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HrLeaveManagementPage()));
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Review All', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFF38BDF8), size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...leaves.take(2).map((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(req.employeeName, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: req.leaveType.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(req.leaveType.label, style: TextStyle(color: req.leaveType.color, fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${req.department} • ${req.daysCount} days (${req.startDate.day}/${req.startDate.month} - ${req.endDate.day}/${req.endDate.month})',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                        if (req.hasOverlappingTeamAbsence)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 12),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Overlapping: ${req.overlappingEmployeeNames.join(", ")}',
                                    style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HrLeaveManagementPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Review', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Card 2: Team Member Staffing Requests
  Widget _buildPendingStaffingCard(BuildContext context, List<StaffingRequest> requests) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.group_add_rounded, color: Color(0xFFA78BFA), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Team Staffing Requests (${requests.length})',
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onNavigateToStaffing,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Manage', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFF38BDF8), size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...requests.take(2).map((stf) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stf.requiredRole} • Needed: ${stf.headcount}',
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${stf.requestingDepartment} • Req by ${stf.requesterName}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: stf.requiredSkills.take(3).map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(s, style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 9.5)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onNavigateToStaffing,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Assign', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Card 3: Projects Needing Attention & Staffing Gaps
  Widget _buildProjectsNeedingAttentionCard(BuildContext context, List<Project> projects) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.handshake_rounded, color: Color(0xFFF87171), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Projects Needing Attention (${projects.length})',
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HrPipelineCoordinationPage()));
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pipeline Sync', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFF38BDF8), size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...projects.take(2).map((prj) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prj.name, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          '${prj.domain} • Team Size: ${prj.teamMemberNames.length} • Progress: ${(prj.progress * 100).toInt()}%',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (prj.hasResourceConflict)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Staffing Gap', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Section 2: Monthly Targets Overview (Section 2 in Prompt)
  Widget _buildMonthlyTargetsCard(BuildContext context, ErpProvider erp, HrMonthlyTargets targets) {
    final leaveReviewed = erp.hrLeaveReviewedThisMonthCount;
    final leaveTarget = targets.leaveRequestsTarget;

    final staffingFulfilled = erp.hrStaffingFulfilledThisMonthCount;
    final staffingTarget = targets.staffingRequestsTarget;

    final traineeReviews = erp.hrTraineeReviewsCompletedThisMonthCount;
    final traineeTarget = targets.traineeReviewsTarget;

    final followUps = erp.hrCustomerFollowUpsCompletedThisMonthCount;
    final followUpTarget = targets.customerFollowUpsTarget;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Target Overview',
            style: TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Actual performance tracked from central ERP records',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Leave requests',
                  current: leaveReviewed,
                  target: leaveTarget,
                  subLabel: 'Reviewed this month',
                  color: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'Staffing requests',
                  current: staffingFulfilled,
                  target: staffingTarget,
                  subLabel: 'Fulfilled this month',
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Trainee reviews',
                  current: traineeReviews,
                  target: traineeTarget,
                  subLabel: 'Completed this month',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'Customer follow-ups',
                  current: followUps,
                  target: followUpTarget,
                  subLabel: 'Completed this month',
                  color: const Color(0xFFA855F7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required int current,
    required int target,
    required String subLabel,
    required Color color,
  }) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '$current',
                style: const TextStyle(color: Color(0xFF212529), fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Text(
                ' / $target',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 6),
          Text(subLabel, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
        ],
      ),
    );
  }

  // Next Important Deadline Countdown
  Widget _buildNextDeadlineCard() {
    // Exact spec from section 2: Trainee evaluation: 2 days Remaining
    const int daysRemaining = 2;
    final bool isOverdue = daysRemaining < 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2B3035),
            isOverdue ? const Color(0xFF450A0A) : const Color(0xFF14243A),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF38BDF8).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isOverdue ? const Color(0xFFEF4444) : const Color(0xFF38BDF8)).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.timer_outlined,
              color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Important Deadline',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Trainee Evaluation Review Batch',
                  style: TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Friday Technical Trainee Rubric Assessment',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF0284C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  isOverdue ? 'OVERDUE' : '$daysRemaining days',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                ),
                if (!isOverdue)
                  const Text('Remaining', style: TextStyle(color: Colors.white70, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section 3: Onboarding & Trainees Overview
  Widget _buildTraineesOverviewCard(BuildContext context, List<Intern> newJoiners, List<Intern> attentionTrainees) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Expanded(
                child: Text(
                  'Trainees Needing Attention (${attentionTrainees.length})',
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onNavigateToTrainees,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFF38BDF8), size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...attentionTrainees.take(2).map((trn) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(trn.name, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                trn.missedUpdatesDays > 0 ? '${trn.missedUpdatesDays}d Missed' : 'Review Due',
                                style: const TextStyle(color: Color(0xFFF87171), fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${trn.college} (${trn.domain}) • Mentor: ${trn.assignedPocName ?? "Unassigned"}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onNavigateToTrainees,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Evaluate', style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Section 4: Weekly Tasks & Priorities
  Widget _buildWeeklyTasksCard(
    BuildContext context,
    ErpProvider erp,
    List<CompanyTask> todayTasks,
    List<CompanyTask> weekTasks,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Today\'s Urgent (${todayTasks.length})',
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Next 7 Days (${weekTasks.length})',
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (todayTasks.isEmpty && weekTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('All tasks completed for the week!', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ),
          ...todayTasks.take(3).map((task) {
            final isDone = task.status == TaskStatus.done;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: task.isOverdue ? const Color(0xFFEF4444).withValues(alpha: 0.4) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => erp.toggleHrTask(task.id),
                    child: Icon(
                      isDone ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isDone ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      size: 20,
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
                            color: isDone ? const Color(0xFF64748B) : Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (task.isOverdue)
                          const Text('Overdue priority', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Section 5: Upcoming Meetings
  Widget _buildUpcomingMeetingsCard(BuildContext context, List<dynamic> meetings) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meetings.isEmpty)
            const Text('No upcoming meetings scheduled.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ...meetings.take(3).map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.videocam_rounded, color: Color(0xFFFBBF24), size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${m.date.day}/${m.date.month} at ${m.startTime} • ${m.departmentOrProject}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
