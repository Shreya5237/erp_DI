import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/finance_models.dart';
import '../../../models/task.dart';
import '../widgets/finance_lead_review_sheet.dart';
import 'finance_leads_pipeline_page.dart';

/// Page 1: Finance Dashboard
/// Finance team's daily overview prioritizing pending approvals and urgent tasks at the top
class FinanceDashboardPage extends StatelessWidget {
  final VoidCallback? onNavigateToBudgets;
  final VoidCallback? onNavigateToRequests;
  final VoidCallback? onNavigateToCalendar;

  const FinanceDashboardPage({
    super.key,
    this.onNavigateToBudgets,
    this.onNavigateToRequests,
    this.onNavigateToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    // Urgent Alerts Data
    final overbudgetList = erp.overbudgetProjects;
    final thresholdList = erp.thresholdAlertProjects;
    final pendingRequests = erp.pendingResourceRequests;
    final reviewLeads = erp.financeReviewLeads;
    final myTasks = erp.financeTasks;
    final pendingTasks = myTasks.where((t) => !t.isCompleted).toList();
    final meetings = erp.financeMeetings;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF38BDF8),
          backgroundColor: Colors.white,
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 400)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Persona
                _buildHeader(context, erp),
                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // TOP PRIORITY: Pending Approvals & Urgent Financial Tasks
                // -----------------------------------------------------------
                _buildPriorityAlertsSection(context, erp, overbudgetList, thresholdList, pendingRequests),
                const SizedBox(height: 18),

                // -----------------------------------------------------------
                // Key Financial Overview & Leave Balance Row
                // -----------------------------------------------------------
                _buildKeyMetricsOverview(context, erp),
                const SizedBox(height: 18),

                // -----------------------------------------------------------
                // Project Budgets Overview (Allocated, Spent, Remaining)
                // -----------------------------------------------------------
                _buildProjectBudgetsOverviewCard(context, erp),
                const SizedBox(height: 18),

                // -----------------------------------------------------------
                // Leads Pipeline Requiring Finance Review
                // -----------------------------------------------------------
                _buildLeadsPipelineSection(context, erp, reviewLeads),
                const SizedBox(height: 18),

                // -----------------------------------------------------------
                // Resource Requests Status (Pending, Approved, Rejected)
                // -----------------------------------------------------------
                _buildResourceRequestsSummaryCard(context, erp),
                const SizedBox(height: 18),

                // -----------------------------------------------------------
                // Today's Tasks & Deadlines
                // -----------------------------------------------------------
                _buildTodayTasksSection(context, erp, pendingTasks),
                const SizedBox(height: 18),

                // -----------------------------------------------------------
                // Upcoming Meetings
                // -----------------------------------------------------------
                _buildUpcomingMeetingsSection(context, erp, meetings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header Banner with greeting and leave balance badge
  Widget _buildHeader(BuildContext context, ErpProvider erp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hello, ${erp.currentUserName.split(' ').first}',
                  style: const TextStyle(
                    color: Color(0xFF212529),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Finance Lead',
                    style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            const Text(
              'Digital Inertia • Financial & Business Ops',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
        // Leave balance pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.beach_access_rounded, color: Color(0xFF10B981), size: 14),
                  SizedBox(width: 5),
                  Text(
                    '18 Days',
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Text(
                'Leave Balance (HR Synced)',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Priority Section: Pending approvals & urgent financial tasks at the top
  Widget _buildPriorityAlertsSection(
    BuildContext context,
    ErpProvider erp,
    List<ProjectBudget> overbudget,
    List<ProjectBudget> threshold,
    List<ResourceRequest> pendingRequests,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (overbudget.isNotEmpty || pendingRequests.isNotEmpty)
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded, color: Color(0xFFEF4444), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Action Required: Urgent Approvals & Alerts',
                style: TextStyle(
                  color: Color(0xFF212529),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${overbudget.length + threshold.length + pendingRequests.length} Urgent',
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Overbudget alert card
          if (overbudget.isNotEmpty)
            ...overbudget.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget Exceeded: ${p.projectName}',
                            style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Spent ₹${p.spentAmount.toStringAsFixed(0)} / ₹${p.approvedBudget.toStringAsFixed(0)} (${(p.utilizationPercentage * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToBudgets,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Review', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),

          // Threshold warning
          if (threshold.isNotEmpty)
            ...threshold.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Threshold Warning: ${p.projectName}',
                            style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Approaching limit: ${(p.utilizationPercentage * 100).toStringAsFixed(1)}% spent (₹${p.spentAmount.toStringAsFixed(0)} / ₹${p.approvedBudget.toStringAsFixed(0)})',
                            style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToBudgets,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),

          // Pending Resource Requests quick approval banner
          if (pendingRequests.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pending_actions_rounded, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pendingRequests.length} Pending Resource Requests',
                          style: const TextStyle(color: Color(0xFFBAE6FD), fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Latest: ${pendingRequests.first.requestedResource} (${pendingRequests.first.requestingDepartment})',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToRequests,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Review', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Key Metrics Overview Grid
  Widget _buildKeyMetricsOverview(BuildContext context, ErpProvider erp) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'Total Budget',
            value: '₹${(erp.totalAllocatedBudget / 1000).toStringAsFixed(0)}k',
            sublabel: 'Allocated across ${erp.allProjectBudgets.length} prjs',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF38BDF8),
            onTap: onNavigateToBudgets,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            label: 'Total Spent',
            value: '₹${(erp.totalSpentBudget / 1000).toStringAsFixed(0)}k',
            sublabel: '${(erp.overallBudgetUtilization * 100).toStringAsFixed(1)}% utilized',
            icon: Icons.pie_chart_rounded,
            color: const Color(0xFFF59E0B),
            onTap: onNavigateToBudgets,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            label: 'Remaining',
            value: '₹${(erp.totalRemainingBudget / 1000).toStringAsFixed(0)}k',
            sublabel: 'Available liquidity',
            icon: Icons.savings_rounded,
            color: const Color(0xFF10B981),
            onTap: onNavigateToBudgets,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String sublabel,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(sublabel, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // Project Budgets Overview Card
  Widget _buildProjectBudgetsOverviewCard(BuildContext context, ErpProvider erp) {
    final utilization = erp.overallBudgetUtilization;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Budgets Health',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Approved expenses vs allocated capital',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              TextButton(
                onPressed: onNavigateToBudgets,
                child: const Text('Manage', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Utilization Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: utilization.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFF212529),
              valueColor: AlwaysStoppedAnimation<Color>(
                utilization >= 1.0
                    ? const Color(0xFFEF4444)
                    : utilization >= 0.85
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Breakdown stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBudgetStatItem('Approved', '₹${erp.totalAllocatedBudget.toStringAsFixed(0)}', const Color(0xFF38BDF8)),
              _buildBudgetStatItem('Spent', '₹${erp.totalSpentBudget.toStringAsFixed(0)}', const Color(0xFFF59E0B)),
              _buildBudgetStatItem('Remaining', '₹${erp.totalRemainingBudget.toStringAsFixed(0)}', const Color(0xFF10B981)),
              _buildBudgetStatItem('Utilization', '${(utilization * 100).toStringAsFixed(1)}%', const Color(0xFFA78BFA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // Leads Pipeline Section
  Widget _buildLeadsPipelineSection(BuildContext context, ErpProvider erp, List reviewLeads) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leads Pipeline Review',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${reviewLeads.length} deals forwarded by Sales for finance action',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceLeadsPipelinePage()));
                },
                child: const Text('View All', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (reviewLeads.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No deals currently awaiting finance review.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            )
          else
            ...reviewLeads.take(2).map((lead) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.business_rounded, color: Color(0xFFA78BFA), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead.companyName,
                            style: const TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Target: ₹${lead.dealValue.toStringAsFixed(0)} • Rep: ${lead.assignedEmployeeName}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => FinanceLeadReviewSheet.show(context, lead),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Review', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // Resource Requests Summary Card
  Widget _buildResourceRequestsSummaryCard(BuildContext context, ErpProvider erp) {
    final pending = erp.pendingResourceRequests.length;
    final approved = erp.approvedResourceRequests.length;
    final rejected = erp.rejectedResourceRequests.length;
    final total = erp.allResourceRequests.length;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resource Requests Status',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Departmental procurement & toolings',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              TextButton(
                onPressed: onNavigateToRequests,
                child: const Text('All Requests', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatusPill('Pending', '$pending', const Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusPill('Approved', '$approved', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusPill('Rejected', '$rejected', const Color(0xFFEF4444)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusPill('Total Log', '$total', const Color(0xFF38BDF8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Today's Tasks & Deadlines Section
  Widget _buildTodayTasksSection(BuildContext context, ErpProvider erp, List<CompanyTask> tasks) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Tasks & Deadlines",
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${tasks.length} active tasks assigned to Siddharth Roy',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              TextButton(
                onPressed: onNavigateToCalendar,
                child: const Text('View All', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('All tasks completed for today!', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
            )
          else
            ...tasks.take(3).map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF64748B),
                        size: 20,
                      ),
                      onPressed: () => erp.toggleFinanceTask(task.id),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              color: task.isCompleted ? const Color(0xFF64748B) : Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: task.priority == TaskPriority.urgent
                                      ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                      : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.priority.label,
                                  style: TextStyle(
                                    color: task.priority == TaskPriority.urgent ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Due ${task.dueDate.day}/${task.dueDate.month}',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                              ),
                            ],
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

  // Upcoming Meetings Section
  Widget _buildUpcomingMeetingsSection(BuildContext context, ErpProvider erp, List meetings) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Meetings',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Budget reviews with Executive & Sales',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF38BDF8), size: 18),
                onPressed: onNavigateToCalendar,
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (meetings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No upcoming meetings scheduled for today.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            )
          else
            ...meetings.take(2).map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.video_camera_front_rounded, color: Color(0xFF38BDF8), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.date.day}/${m.date.month} • ${m.startTime} - ${m.endTime} (${m.locationOrLink})',
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
