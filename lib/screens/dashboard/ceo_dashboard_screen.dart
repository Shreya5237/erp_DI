import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/project.dart';
import '../../models/task.dart';
import '../../widgets/compact_filter_bar.dart';
import '../../widgets/tasks_donut_chart.dart';
import '../alerts/alerts_screen.dart';
import '../tasks/task_detail_dialog.dart';

/// Comprehensive CEO Executive Dashboard adhering to Section 9 of the ERP PRD
class CeoDashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const CeoDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<CeoDashboardScreen> createState() => _CeoDashboardScreenState();
}

class _CeoDashboardScreenState extends State<CeoDashboardScreen> {
  String _selectedTaskStatus = 'Ongoing & Overdue';
  String _selectedTaskDepartment = 'All Departments';
  final Set<String> _collapsedDepartments = {};

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final activeProjects = erp.allProjects.where((p) => p.status == ProjectStatus.inProgress).length;
    final totalPipelineLakhs = (erp.totalPipelineValue / 100000).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Executive Header & Persona Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Good morning, ${erp.currentUserName.split(" ")[0]}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF212529),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF212529),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'CEO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Youth Employment Mission Banner (PRD Section 1)
            _buildYouthEmploymentBanner(erp),
            const SizedBox(height: 16),

            // Threshold Alerts Banner (if active)
            if (erp.thresholdAlerts.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 20, color: Color(0xFFEF4444)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${erp.thresholdAlerts.length} operational exceptions require attention',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                            const Text(
                              'Overdue follow-ups, pending reviews and delayed milestones',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFB91C1C)),
                    ],
                  ),
                ),
              ),
            ],

            // 4 Core Executive Metric Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.people_outline_rounded,
                    title: 'Active Team',
                    value: '${erp.allEmployees.length}',
                    subtext: '21 present today',
                    onTap: () => widget.onNavigateTab?.call(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.school_outlined,
                    title: 'Friday Interns',
                    value: '${erp.activeInternsCount}',
                    subtext: '1-week eval active',
                    onTap: () => widget.onNavigateTab?.call(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.folder_open_rounded,
                    title: 'Active Projects',
                    value: '$activeProjects',
                    subtext: '${erp.allProjects.length} total received',
                    onTap: () => widget.onNavigateTab?.call(5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Pipeline Value',
                    value: '₹${totalPipelineLakhs}L',
                    subtext: '${erp.allLeads.length} active leads',
                    onTap: () => widget.onNavigateTab?.call(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SECTION 9.5: TODAY'S APPROVALS (CEO Attention Required)
            _buildTodaysApprovalsSection(context, erp),
            const SizedBox(height: 20),

            // SECTION 9.1: 5 DEPARTMENTS ATTENDANCE BREAKDOWN
            _buildDepartmentAttendanceSection(erp),
            const SizedBox(height: 20),

            // SECTION 9.4: SALES PERFORMANCE
            _buildSalesPerformanceSection(erp),
            const SizedBox(height: 20),

            // SECTION 10: TODAY'S MEETINGS
            _buildScheduledMeetingsSection(erp),
            const SizedBox(height: 20),

            // Department Tasks Overview Section organized by Department with Dropdown Filter Bar
            _buildCeoTasksSection(context, erp),
          ],
        ),
      ),
    );
  }

  Widget _buildYouthEmploymentBanner(ErpProvider erp) {
    final progress = erp.youthEmploymentPlaced / erp.youthEmploymentGoal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF212529), Color(0xFF2B3035)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Youth Employment Mission 2026',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              const Spacer(),
              Text(
                '${erp.youthEmploymentPlaced} / ${erp.youthEmploymentGoal}',
                style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Friday Batch: 25 interns in 1-week eval',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% of annual target',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysApprovalsSection(BuildContext context, ErpProvider erp) {
    final pending = erp.pendingApprovals;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              const Text(
                "Today's Approvals",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF212529),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${pending.length} Actionable',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (pending.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No proposals currently awaiting CEO decision.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ),
            ),
          ] else ...[
            ...pending.map((req) => _buildApprovalCard(context, erp, req)),
          ],
        ],
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, ErpProvider erp, dynamic req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
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
                  req.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212529),
                  ),
                ),
              ),
              Text(
                '₹${(req.dealValueOrBudget / 1000).toStringAsFixed(0)}k',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'From: ${req.submittingDepartment} • Submitted by ${req.submittedByName}',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          Text(
            req.summary,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.35),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showReviewDialog(context, erp, req.id, isReject: false, isRework: true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Request Changes',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    erp.approveApprovalRequest(req.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Approved "${req.title}"!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: const Color(0xFF212529),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Approve Deal',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, ErpProvider erp, String reqId, {required bool isReject, required bool isRework}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isRework ? 'Request Modifications' : 'Reject Proposal',
          style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter feedback and required changes...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              filled: true,
              fillColor: const Color(0xFFF5F6F7),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
            maxLines: 3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isRework ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (isRework) {
                erp.requestChangesApprovalRequest(reqId, notes: controller.text.trim());
              } else {
                erp.rejectApprovalRequest(reqId, notes: controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Submit Decision', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentAttendanceSection(ErpProvider erp) {
    final metrics = erp.departmentMetrics;
    return Container(
      padding: const EdgeInsets.all(18),
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
            children: const [
              Expanded(
                child: Text(
                  'Department Attendance Today',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '21 / 24 Present (88%)',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...metrics.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m.department.title,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                      Text(
                        '${m.presentToday} / ${m.totalEmployees} present',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: m.presentToday / m.totalEmployees,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        (m.presentToday / m.totalEmployees) >= 0.85
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFF59E0B),
                      ),
                      minHeight: 5,
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

  Widget _buildSalesPerformanceSection(ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.phone_in_talk_rounded, size: 18, color: Color(0xFF212529)),
              SizedBox(width: 8),
              Text(
                'Sales & Outbound Outreach',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSmallKpi(
                  'Calls Made',
                  '${erp.contactsCompletedThisWeek} / ${erp.weeklyContactTarget}',
                  sub: 'Weekly Target',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallKpi(
                  'Follow-ups Due',
                  '${erp.followUpsDueTodayCount}',
                  sub: '${erp.overdueFollowUpsCount} Overdue',
                  isWarning: erp.overdueFollowUpsCount > 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallKpi(
                  'Deals Closed',
                  '${erp.dealsWonCount} Won',
                  sub: '${erp.dealsLostCount} Lost',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallKpi(String label, String value, {String? sub, bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFEF2F2) : const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isWarning ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isWarning ? const Color(0xFFB91C1C) : const Color(0xFF212529),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 10, color: isWarning ? const Color(0xFFEF4444) : const Color(0xFF94A3B8))),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduledMeetingsSection(ErpProvider erp) {
    final meetings = erp.todayMeetings;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_rounded, size: 18, color: Color(0xFF212529)),
              const SizedBox(width: 8),
              const Text(
                "Today's Executive Meetings",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
              ),
              const Spacer(),
              Text(
                '${meetings.length} Sessions',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (meetings.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No meetings scheduled today.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ),
          ] else ...[
            ...meetings.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212529),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m.startTime,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                          ),
                          Text(
                            '${m.locationOrLink} • ${m.participantNames.length} participants',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtext,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF212529)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF212529),
              ),
            ),
            if (subtext != null) ...[
              const SizedBox(height: 2),
              Text(
                subtext,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCeoTasksSection(BuildContext context, ErpProvider erp) {
    final allTasks = erp.allTasks;
    final completedCount = allTasks.where((t) => t.isCompleted).length;
    final inProgressCount = allTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final todoCount = allTasks.where((t) => t.status == TaskStatus.todo || t.status == TaskStatus.backlog).length;
    final overdueCount = allTasks.where((t) => t.isOverdue).length;
    final reworkCount = allTasks.where((t) => t.status == TaskStatus.inReview || t.status == TaskStatus.needsRework).length;
    final upcomingCount = allTasks.where((t) => t.isUpcoming).length;
    final ongoingAndOverdueCount = allTasks.where((t) => t.isOngoing || t.isOverdue).length;

    // Available departments from tasks and ERP standard departments
    const knownDepts = [
      'Engineering',
      'Applied AI',
      'UI/UX Design',
      'Digital Marketing',
      'Sales & BD',
      'Operations & Finance',
      'Human Resources',
    ];
    final allDepartments = <String>{
      ...knownDepts,
      ...allTasks.map((t) => t.effectiveDepartment),
    }.where((d) => d.isNotEmpty).toList()..sort();

    // Filter departments to display
    final departmentsToShow = _selectedTaskDepartment == 'All Departments'
        ? allDepartments
        : [_selectedTaskDepartment];

    final hasActiveFilter = _selectedTaskStatus != 'Ongoing & Overdue' ||
        _selectedTaskDepartment != 'All Departments';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.hub_rounded, size: 18, color: Color(0xFF212529)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Department Task Operations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF212529),
                      ),
                    ),
                    Text(
                      'Showing ${_selectedTaskStatus.toLowerCase()} items ($ongoingAndOverdueCount active)',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  erp.setTaskStatusFilter(_selectedTaskStatus);
                  if (_selectedTaskDepartment != 'All Departments') {
                    erp.setTaskDepartmentFilter(_selectedTaskDepartment);
                  }
                  widget.onNavigateTab?.call(3);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Sprint Board',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Real Donut Chart Overview
          TasksDonutChart(
            completed: completedCount,
            inProgress: inProgressCount,
            todo: todoCount,
            overdue: overdueCount,
            needsRework: reworkCount,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // Dropdown Filter Bar (Department & Status Dropdowns)
          CompactFilterBar(
            hasActiveFilters: hasActiveFilter,
            onReset: () {
              setState(() {
                _selectedTaskStatus = 'Ongoing & Overdue';
                _selectedTaskDepartment = 'All Departments';
              });
            },
            items: [
              FilterDropdownItem<String>(
                label: 'Department',
                icon: Icons.corporate_fare_rounded,
                value: _selectedTaskDepartment,
                options: [
                  const FilterOption<String>(label: 'All Departments', value: 'All Departments'),
                  ...allDepartments.map((dept) => FilterOption<String>(
                        label: dept,
                        value: dept,
                        icon: _getDepartmentIcon(dept),
                      )),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTaskDepartment = val);
                },
              ),
              FilterDropdownItem<String>(
                label: 'Task Filter',
                icon: Icons.tune_rounded,
                value: _selectedTaskStatus,
                options: const [
                  FilterOption<String>(label: '⚡ Ongoing & Overdue', value: 'Ongoing & Overdue', color: Color(0xFFE11D48)),
                  FilterOption<String>(label: '🔄 Ongoing (Active)', value: 'Ongoing', color: Color(0xFF2563EB)),
                  FilterOption<String>(label: '⚠️ Overdue Tasks', value: 'Overdue', color: Color(0xFFDC2626)),
                  FilterOption<String>(label: '📅 Upcoming / To-Be', value: 'Upcoming', color: Color(0xFFD97706)),
                  FilterOption<String>(label: '✅ Completed', value: 'Completed', color: Color(0xFF16A34A)),
                  FilterOption<String>(label: '📋 All Tasks', value: 'All'),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTaskStatus = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Filter Switcher Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildQuickStatusChip(
                  '⚡ Ongoing & Overdue ($ongoingAndOverdueCount)',
                  _selectedTaskStatus == 'Ongoing & Overdue',
                  const Color(0xFFE11D48),
                  () => setState(() => _selectedTaskStatus = 'Ongoing & Overdue'),
                ),
                const SizedBox(width: 8),
                _buildQuickStatusChip(
                  '📅 Upcoming ($upcomingCount)',
                  _selectedTaskStatus == 'Upcoming',
                  const Color(0xFFD97706),
                  () => setState(() => _selectedTaskStatus = 'Upcoming'),
                ),
                const SizedBox(width: 8),
                _buildQuickStatusChip(
                  '✅ Completed ($completedCount)',
                  _selectedTaskStatus == 'Completed',
                  const Color(0xFF16A34A),
                  () => setState(() => _selectedTaskStatus = 'Completed'),
                ),
                const SizedBox(width: 8),
                _buildQuickStatusChip(
                  'All (${allTasks.length})',
                  _selectedTaskStatus == 'All',
                  const Color(0xFF64748B),
                  () => setState(() => _selectedTaskStatus = 'All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Department Task Groups
          ...departmentsToShow.map((dept) {
            return _buildDepartmentTaskCard(context, erp, dept, allTasks);
          }),
        ],
      ),
    );
  }

  Widget _buildDepartmentTaskCard(
    BuildContext context,
    ErpProvider erp,
    String department,
    List<CompanyTask> allTasks,
  ) {
    final deptAll = allTasks.where((t) => t.effectiveDepartment == department).toList();
    final deptOngoing = deptAll.where((t) => t.isOngoing).toList();
    final deptOverdue = deptAll.where((t) => t.isOverdue).toList();
    final deptUpcoming = deptAll.where((t) => t.isUpcoming).toList();
    final deptCompleted = deptAll.where((t) => t.isCompleted).toList();
    final deptOngoingAndOverdue = deptAll.where((t) => t.isOngoing || t.isOverdue).toList();

    // Determine list to show according to current filter
    List<CompanyTask> displayTasks;
    switch (_selectedTaskStatus) {
      case 'Ongoing':
        displayTasks = deptOngoing;
        break;
      case 'Overdue':
        displayTasks = deptOverdue;
        break;
      case 'Upcoming':
        displayTasks = deptUpcoming;
        break;
      case 'Completed':
        displayTasks = deptCompleted;
        break;
      case 'All':
        displayTasks = deptAll;
        break;
      case 'Ongoing & Overdue':
      default:
        // By default, strictly ongoing and overdue on the list!
        displayTasks = deptOngoingAndOverdue;
        break;
    }

    final isCollapsed = _collapsedDepartments.contains(department);
    final completionRatio = deptAll.isNotEmpty ? deptCompleted.length / deptAll.length : 0.0;
    final deptColor = _getDepartmentColor(department);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: deptOverdue.isNotEmpty ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
          width: deptOverdue.isNotEmpty ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department Header (Tappable to toggle collapse)
          InkWell(
            onTap: () {
              setState(() {
                if (isCollapsed) {
                  _collapsedDepartments.remove(department);
                } else {
                  _collapsedDepartments.add(department);
                }
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: deptColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getDepartmentIcon(department), size: 16, color: deptColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              department,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF212529),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${deptAll.length} tasks',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isCollapsed ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Department Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: completionRatio,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(deptColor),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Department Counts Tags Row (Ongoing, Overdue, To-Be, Completed)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDeptCountBadge('⚡ Ongoing: ${deptOngoing.length}', const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                        const SizedBox(width: 6),
                        if (deptOverdue.isNotEmpty) ...[
                          _buildDeptCountBadge('⚠️ Overdue: ${deptOverdue.length}', const Color(0xFFDC2626), const Color(0xFFFEF2F2), isBold: true),
                          const SizedBox(width: 6),
                        ],
                        _buildDeptCountBadge('📅 To-Be: ${deptUpcoming.length}', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                        const SizedBox(width: 6),
                        _buildDeptCountBadge('✅ Done: ${deptCompleted.length}', const Color(0xFF16A34A), const Color(0xFFF0FDF4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Department Tasks List (If not collapsed)
          if (!isCollapsed) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (displayTasks.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 24, color: Colors.green.shade400),
                          const SizedBox(height: 6),
                          Text(
                            _selectedTaskStatus == 'Ongoing & Overdue'
                                ? 'No ongoing or overdue tasks in $department'
                                : 'No ${_selectedTaskStatus.toLowerCase()} tasks in $department',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() => _selectedTaskStatus = 'Upcoming');
                                },
                                icon: const Icon(Icons.calendar_today_rounded, size: 12),
                                label: Text('View Upcoming (${deptUpcoming.length})', style: const TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: const Color(0xFFD97706),
                                  side: const BorderSide(color: Color(0xFFFDE68A)),
                                  backgroundColor: const Color(0xFFFFFBEB),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() => _selectedTaskStatus = 'Completed');
                                },
                                icon: const Icon(Icons.check_rounded, size: 12),
                                label: Text('View Completed (${deptCompleted.length})', style: const TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: const Color(0xFF16A34A),
                                  side: const BorderSide(color: Color(0xFFBBF7D0)),
                                  backgroundColor: const Color(0xFFF0FDF4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...displayTasks.map((task) => _buildCeoTaskTile(context, erp, task)),
                  ],

                  const SizedBox(height: 10),
                  // Bottom Department Options Bar: options to visit upcoming and completed tasks
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Option: Visit Upcoming Tasks
                        InkWell(
                          onTap: () {
                            setState(() => _selectedTaskStatus = 'Upcoming');
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.upcoming_rounded, size: 13, color: Color(0xFFD97706)),
                                const SizedBox(width: 4),
                                Text(
                                  'Upcoming (${deptUpcoming.length})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Option: Visit Completed Tasks
                        InkWell(
                          onTap: () {
                            setState(() => _selectedTaskStatus = 'Completed');
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16A34A)),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed (${deptCompleted.length})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Option: Visit In Tasks Tab
                        InkWell(
                          onTap: () {
                            erp.setTaskDepartmentFilter(department);
                            erp.setTaskStatusFilter(_selectedTaskStatus);
                            widget.onNavigateTab?.call(3);
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Open All',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFF2563EB)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCeoTaskTile(BuildContext context, ErpProvider erp, CompanyTask task) {
    Color priorityColor = const Color(0xFF64748B);
    Color priorityBg = const Color(0xFFF1F5F9);
    if (task.priority == TaskPriority.urgent) {
      priorityColor = const Color(0xFFDC2626);
      priorityBg = const Color(0xFFFEF2F2);
    } else if (task.priority == TaskPriority.high) {
      priorityColor = const Color(0xFFEA580C);
      priorityBg = const Color(0xFFFFF7ED);
    } else if (task.priority == TaskPriority.medium) {
      priorityColor = const Color(0xFF2563EB);
      priorityBg = const Color(0xFFEFF6FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: task.isOverdue ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => TaskDetailDialog(task: task),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priority.label.toUpperCase(),
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: priorityColor),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    task.status.label,
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                  ),
                ),
                const Spacer(),
                if (task.isOverdue) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      '⚠️ ${task.daysOverdue}d Overdue',
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Due ${task.dueDate.day}/${task.dueDate.month}',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212529),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                CircleAvatar(
                  radius: 9,
                  backgroundColor: const Color(0xFF212529),
                  child: Text(
                    task.assignedToName.isNotEmpty ? task.assignedToName[0] : 'U',
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${task.assignedToName} • ${task.domain}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptCountBadge(String label, Color color, Color bg, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQuickStatusChip(String label, bool isSelected, Color activeColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  IconData _getDepartmentIcon(String dept) {
    final d = dept.toLowerCase();
    if (d.contains('eng') || d.contains('tech')) return Icons.code_rounded;
    if (d.contains('ai') || d.contains('intel')) return Icons.psychology_rounded;
    if (d.contains('design') || d.contains('ui') || d.contains('ux')) return Icons.palette_rounded;
    if (d.contains('market') || d.contains('seo') || d.contains('content')) return Icons.campaign_rounded;
    if (d.contains('sales') || d.contains('biz')) return Icons.trending_up_rounded;
    if (d.contains('hr') || d.contains('human')) return Icons.people_alt_rounded;
    if (d.contains('ops') || d.contains('finance')) return Icons.account_balance_wallet_rounded;
    return Icons.business_center_rounded;
  }

  Color _getDepartmentColor(String dept) {
    final d = dept.toLowerCase();
    if (d.contains('eng') || d.contains('tech')) return const Color(0xFF2563EB);
    if (d.contains('ai') || d.contains('intel')) return const Color(0xFF7C3AED);
    if (d.contains('design') || d.contains('ui') || d.contains('ux')) return const Color(0xFFEA580C);
    if (d.contains('market') || d.contains('seo')) return const Color(0xFFD97706);
    if (d.contains('sales') || d.contains('biz')) return const Color(0xFF16A34A);
    if (d.contains('hr') || d.contains('human')) return const Color(0xFF0D9488);
    if (d.contains('ops') || d.contains('finance')) return const Color(0xFF0284C7);
    return const Color(0xFF212529);
  }
}
