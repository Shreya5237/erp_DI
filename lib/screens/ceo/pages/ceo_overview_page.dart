import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/project.dart';
import '../widgets/ceo_modals.dart';

/// Module 1: Executive Overview Dashboard — Login Landing Page (Specification Section 5)
/// Contains:
/// A. Company performance metrics (6 clickable KPI cards)
/// B. Department health overview (Finance, Sales, Marketing, HR, Technical)
/// C. Executive attention queue ("Requires Your Attention" with Approve/Reject/Delegate actions)
/// D. Today's schedule and upcoming deadlines (countdown, overdue explicitly labelled)
/// E. Company activity feed (chronological stream)
class CeoOverviewPage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoOverviewPage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoOverviewPage> createState() => _CeoOverviewPageState();
}

class _CeoOverviewPageState extends State<CeoOverviewPage> {
  String _revenueTimeframe = '6M'; // '6M' or '1Y'

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 18 : 24,
        isMobile ? 16 : 28,
        40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Timestamp (Clean Executive Layout — No Wordy Subheadings)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Executive Overview',
                  style: GoogleFonts.instrumentSans(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212529),
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF495057)),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // A. COMPANY PERFORMANCE METRICS (6 KPI CARDS)
          _buildKpiMetricsGrid(context, erp),
          const SizedBox(height: 24),

          // Executive Charts (Image 1: Revenue Trend & Department Allocation)
          _buildExecutiveTrendsAndCharts(context, erp),
          const SizedBox(height: 28),

          // C. EXECUTIVE ATTENTION QUEUE ("Requires Your Attention")
          _buildAttentionQueue(context, erp),
          const SizedBox(height: 28),

          // B. DEPARTMENT HEALTH OVERVIEW (5 Departments)
          _buildDepartmentHealthOverview(context, erp),
          const SizedBox(height: 28),

          // Two-column layout for Desktop / Stacked for Mobile: Schedule + Activity Feed
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // D. Schedule & Upcoming Deadlines
                    Expanded(
                      flex: 5,
                      child: _buildScheduleAndDeadlines(context, erp),
                    ),
                    const SizedBox(width: 24),
                    // E. Company Activity Feed
                    Expanded(
                      flex: 4,
                      child: _buildCompanyActivityFeed(context, erp),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _buildScheduleAndDeadlines(context, erp),
                  const SizedBox(height: 24),
                  _buildCompanyActivityFeed(context, erp),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // A. COMPANY PERFORMANCE METRICS (KPIs)
  // ==========================================
  Widget _buildKpiMetricsGrid(BuildContext context, ErpProvider erp) {
    final activeProjects = erp.allProjects.where((p) => p.status == ProjectStatus.inProgress).length;
    final atRiskProjects = erp.allProjects.where((p) => p.hasResourceConflict || p.activeBlockers.isNotEmpty).length;
    final pipelineCr = (erp.totalPipelineValue / 10000000).toStringAsFixed(2);
    final totalSpentLakhs = (erp.totalSpentBudget / 100000).toStringAsFixed(1);
    final totalAllocLakhs = (erp.totalAllocatedBudget / 100000).toStringAsFixed(1);
    final utilizationPct = (erp.overallBudgetUtilization * 100).toInt();
    final completedTasks = erp.allTasks.where((t) => t.isCompleted).length;
    final overdueTasks = erp.allTasks.where((t) => t.isOverdue && !t.isCompleted).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1050
            ? 6
            : (constraints.maxWidth >= 720 ? 3 : 2);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: constraints.maxWidth >= 1050
              ? 1.25
              : (constraints.maxWidth < 600 ? 1.08 : 1.3),
          children: [
            // 1. Revenue
            _buildKpiCard(
              title: 'Revenue',
              metric: '₹38.5L',
              target: 'Target: ₹50.0L',
              subtext: '77% Monthly Achieved',
              icon: Icons.payments_outlined,
              badgeColor: const Color(0xFF2F9E44),
              onTap: () => widget.onNavigateModule(4), // Finance & Approvals
            ),
            // 2. Projects
            _buildKpiCard(
              title: 'Projects',
              metric: '$activeProjects Active',
              target: '$atRiskProjects At Risk',
              subtext: '${erp.allProjects.length} Portfolio Total',
              icon: Icons.folder_open_outlined,
              badgeColor: atRiskProjects > 0 ? const Color(0xFFF59F00) : const Color(0xFF2F9E44),
              onTap: () => widget.onNavigateModule(2), // Projects & Tasks
            ),
            // 3. Workforce
            _buildKpiCard(
              title: 'Workforce',
              metric: '${erp.allEmployees.length}',
              target: '+${erp.allInterns.length} Trainees',
              subtext: '94% Attendance Today',
              icon: Icons.people_outline_rounded,
              badgeColor: const Color(0xFF212529),
              onTap: () => widget.onNavigateModule(1), // People & Departments
            ),
            // 4. Execution
            _buildKpiCard(
              title: 'Execution',
              metric: '$completedTasks Done',
              target: '$overdueTasks Overdue',
              subtext: '${erp.allTasks.length} Total Deliverables',
              icon: Icons.task_alt_outlined,
              badgeColor: overdueTasks > 0 ? const Color(0xFFE03131) : const Color(0xFF2F9E44),
              onTap: () => widget.onNavigateModule(2), // Tasks & Projects
            ),
            // 5. Business Pipeline
            _buildKpiCard(
              title: 'Business Pipeline',
              metric: '₹${pipelineCr}Cr',
              target: '${erp.allLeads.length} Accounts',
              subtext: '${erp.dealsWonCount} Won • 4.5% Conv.',
              icon: Icons.trending_up_rounded,
              badgeColor: const Color(0xFF212529),
              onTap: () => widget.onNavigateModule(3), // Clients & Business
            ),
            // 6. Financial Health
            _buildKpiCard(
              title: 'Budget Health',
              metric: '$utilizationPct%',
              target: '₹${totalSpentLakhs}L / ₹${totalAllocLakhs}L',
              subtext: 'Optimal Burn Rate',
              icon: Icons.account_balance_outlined,
              badgeColor: utilizationPct > 85 ? const Color(0xFFE03131) : const Color(0xFF2F9E44),
              onTap: () => widget.onNavigateModule(4), // Finance & Approvals
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // IMAGE 1: REVENUE TREND & DEPARTMENT ALLOCATION
  // ==========================================
  Widget _buildExecutiveTrendsAndCharts(BuildContext context, ErpProvider erp) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _buildRevenueTrendCard(context)),
              const SizedBox(width: 16),
              Expanded(flex: 5, child: _buildDepartmentAllocationCard(context, erp)),
            ],
          );
        }
        return Column(
          children: [
            _buildRevenueTrendCard(context),
            const SizedBox(height: 16),
            _buildDepartmentAllocationCard(context, erp),
          ],
        );
      },
    );
  }

  Widget _buildRevenueTrendCard(BuildContext context) {
    final is6M = _revenueTimeframe == '6M';
    final labels = is6M ? ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'] : ['Nov', 'Jan', 'Mar', 'May', 'Jul', 'Oct'];
    final actuals = is6M ? [0.42, 0.58, 0.65, 0.60, 0.72, 0.82] : [0.35, 0.44, 0.52, 0.62, 0.70, 0.85];
    final targets = is6M ? [0.38, 0.52, 0.60, 0.64, 0.70, 0.76] : [0.32, 0.40, 0.48, 0.58, 0.66, 0.78];

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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REVENUE TREND (FY26)',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212529),
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Actual vs Target (₹ Cr)',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11.5,
                        color: const Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Timeframe Toggle Pill (6M / 1Y)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTimeframeBtn('6M', is6M),
                    _buildTimeframeBtn('1Y', !is6M),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Spline Line Chart Canvas
          SizedBox(
            height: 155,
            width: double.infinity,
            child: CustomPaint(
              painter: RevenueTrendSplinePainter(
                actualPoints: actuals,
                targetPoints: targets,
                labels: labels,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0CA678),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Actual Revenue',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF495057),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCED4DA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Target Plan',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF495057),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeBtn(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _revenueTimeframe = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.instrumentSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? const Color(0xFF212529) : const Color(0xFF868E96),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentAllocationCard(BuildContext context, ErpProvider erp) {
    // Total budget in ₹ Cr
    final totalBudgetCr = (erp.totalAllocatedBudget > 0)
        ? (erp.totalAllocatedBudget / 10000000).toStringAsFixed(0)
        : '120';

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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEPARTMENT ALLOCATION',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212529),
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Budget: ₹$totalBudgetCr Cr',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11.5,
                        color: const Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FCF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q3 Approved',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0CA678),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Donut Chart & Legend Row
          Row(
            children: [
              // Donut Chart Container
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(140, 140),
                      painter: DepartmentDonutPainter(
                        values: const [0.35, 0.28, 0.20, 0.17],
                        colors: const [
                          Color(0xFF339AF0), // Engineering / Technical
                          Color(0xFF20C997), // Sales & Mktg
                          Color(0xFFF59F00), // Operations
                          Color(0xFF845EF7), // Product R&D
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹$totalBudgetCr Cr',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'TOTAL',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFADB5BD),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),

              // Legend Column
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDonutLegendRow(const Color(0xFF339AF0), 'Engineering', '35%'),
                    const SizedBox(height: 10),
                    _buildDonutLegendRow(const Color(0xFF20C997), 'Sales & Mktg', '28%'),
                    const SizedBox(height: 10),
                    _buildDonutLegendRow(const Color(0xFFF59F00), 'Operations', '20%'),
                    const SizedBox(height: 10),
                    _buildDonutLegendRow(const Color(0xFF845EF7), 'Product R&D', '17%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonutLegendRow(Color color, String label, String percentage) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF495057),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          percentage,
          style: GoogleFonts.instrumentSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212529),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String metric,
    required String target,
    required String subtext,
    required IconData icon,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF212529).withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6C757D),
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 18, color: const Color(0xFF212529)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212529),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        target,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              subtext,
              style: GoogleFonts.instrumentSans(
                fontSize: 10,
                color: const Color(0xFFADB5BD),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // C. EXECUTIVE ATTENTION QUEUE
  // ==========================================
  Widget _buildAttentionQueue(BuildContext context, ErpProvider erp) {
    final pendingApprovals = erp.pendingApprovals;
    final pendingResource = erp.pendingResourceRequests;

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
              final isTight = constraints.maxWidth < 500;
              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE03131),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Requires Your Attention',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF212529),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFC9C9)),
                          ),
                          child: Text(
                            '${pendingApprovals.length + pendingResource.length}',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE03131),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => widget.onNavigateModule(7), // Approvals
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open Approvals Hub',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF212529),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF212529)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE03131),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Requires Your Attention',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFC9C9)),
                    ),
                    child: Text(
                      '${pendingApprovals.length + pendingResource.length} Action Items',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE03131),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => widget.onNavigateModule(7), // Approvals
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Open Approvals Hub', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF212529)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Items list
          if (pendingApprovals.isEmpty && pendingResource.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF2F9E44), size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'All executive decisions are up to date. No blocking requests.',
                        style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ...pendingApprovals.take(3).map((req) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: LayoutBuilder(
                  builder: (context, itemConstraints) {
                    final isTight = itemConstraints.maxWidth < 520;
                    if (isTight) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE9ECEF)),
                                ),
                                child: const Icon(Icons.description_outlined, size: 16, color: Color(0xFF212529)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  req.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF212529),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9DB),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFFFEEBA)),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFF59F00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dept: ${req.submittingDepartment} • Submitted by ${req.submittedByName} • ₹${req.dealValueOrBudget.toStringAsFixed(0)}',
                            style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => CeoModals.showApprovalDecisionModal(context, req, erp),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF212529),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Review & Decide', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF212529)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      req.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9DB),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFFFEEBA)),
                                    ),
                                    child: Text(
                                      'URGENT',
                                      style: GoogleFonts.instrumentSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFFF59F00)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dept: ${req.submittingDepartment} • Submitted by ${req.submittedByName} • ₹${req.dealValueOrBudget.toStringAsFixed(0)}',
                                style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => CeoModals.showApprovalDecisionModal(context, req, erp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF212529),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Review & Decide', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
            ...pendingResource.take(2).map((res) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: LayoutBuilder(
                  builder: (context, itemConstraints) {
                    final isTight = itemConstraints.maxWidth < 520;
                    if (isTight) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE9ECEF)),
                                ),
                                child: const Icon(Icons.group_add_outlined, size: 16, color: Color(0xFF212529)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Staffing: ${res.requestedResource}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF212529),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dept: ${res.requestingDepartment} • Est: ₹${res.estimatedCost.toStringAsFixed(0)} • Requester: ${res.requesterName}',
                            style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => widget.onNavigateModule(4), // Finance & Approvals
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF212529),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Authorize', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: const Icon(Icons.group_add_outlined, size: 18, color: Color(0xFF212529)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Staffing / Resource Requisition: ${res.requestedResource}',
                                style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dept: ${res.requestingDepartment} • Est: ₹${res.estimatedCost.toStringAsFixed(0)} • Requester: ${res.requesterName}',
                                style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => widget.onNavigateModule(4), // Finance & Approvals
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF212529),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Authorize', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // B. DEPARTMENT HEALTH OVERVIEW (5 Departments)
  // ==========================================
  Widget _buildDepartmentHealthOverview(BuildContext context, ErpProvider erp) {
    final depts = [
      {
        'name': 'Finance',
        'head': 'Siddharth Roy',
        'teamSize': '4 members',
        'metric1': 'Budget Utilization',
        'val1': '68%',
        'metric2': 'Pending Approvals',
        'val2': '${erp.pendingApprovals.length} requests',
        'status': 'Needs Attention',
        'statusColor': const Color(0xFFF59F00),
      },
      {
        'name': 'Sales & Marketing',
        'head': 'Rajesh Kumar',
        'teamSize': '6 members',
        'metric1': 'Target vs Achieved',
        'val1': '₹38.5L / ₹50L (77%)',
        'metric2': 'Calls Completed',
        'val2': '38 calls this week',
        'status': 'On Track',
        'statusColor': const Color(0xFF2F9E44),
      },
      {
        'name': 'Digital Marketing',
        'head': 'Ananya Sen',
        'teamSize': '3 members',
        'metric1': 'Active Campaigns',
        'val1': '4 campaigns',
        'metric2': 'Leads Generated',
        'val2': '142 leads',
        'status': 'On Track',
        'statusColor': const Color(0xFF2F9E44),
      },
      {
        'name': 'HR & Talent',
        'head': 'Sneha Kapoor',
        'teamSize': '4 members',
        'metric1': 'Workforce Attendance',
        'val1': '94% present',
        'metric2': 'Staffing Requests',
        'val2': '3 active requisitions',
        'status': 'On Track',
        'statusColor': const Color(0xFF2F9E44),
      },
      {
        'name': 'Technical / Engineering',
        'head': 'Vikram Sharma',
        'teamSize': '11 members',
        'metric1': 'Active Projects',
        'val1': '6 ongoing',
        'metric2': 'Sprint Blockers',
        'val2': '1 blocker logged',
        'status': 'Needs Attention',
        'statusColor': const Color(0xFFF59F00),
      },
    ];

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
              final isTight = constraints.maxWidth < 550;
              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department Health & Operations',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Operational health across all 5 authorized company departments.',
                      style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => widget.onNavigateModule(1), // Departments module
                      icon: const Icon(Icons.arrow_outward_rounded, size: 14, color: Color(0xFF212529)),
                      label: Text('View Department Hub', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDEE2E6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Department Health & Operations',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Operational health across all 5 authorized company departments.',
                          style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => widget.onNavigateModule(1), // Departments module
                    icon: const Icon(Icons.arrow_outward_rounded, size: 14, color: Color(0xFF212529)),
                    label: Text('View Department Hub', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDEE2E6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Department Rows
          ...depts.map((d) {
            final statusColor = d['statusColor'] as Color;

            return LayoutBuilder(
              builder: (context, itemConstraints) {
                final isNarrow = itemConstraints.maxWidth < 680;
                if (isNarrow) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                d['name'] as String,
                                style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: statusColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 5, height: 5, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  Text(
                                    d['status'] as String,
                                    style: GoogleFonts.instrumentSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: statusColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Head: ${d['head']} • ${d['teamSize']}',
                          style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d['metric1'] as String, style: GoogleFonts.instrumentSans(fontSize: 10, color: const Color(0xFF6C757D)), overflow: TextOverflow.ellipsis),
                                  Text(d['val1'] as String, style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d['metric2'] as String, style: GoogleFonts.instrumentSans(fontSize: 10, color: const Color(0xFF6C757D)), overflow: TextOverflow.ellipsis),
                                  Text(d['val2'] as String, style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF6C757D)),
                              onPressed: () => widget.onNavigateModule(1), // Jump to department workspace
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                  ),
                  child: Row(
                    children: [
                      // Department title & head
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['name'] as String,
                              style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                            ),
                            Text(
                              'Head: ${d['head']} • ${d['teamSize']}',
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                            ),
                          ],
                        ),
                      ),

                      // Metric 1
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['metric1'] as String, style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFF6C757D))),
                            Text(d['val1'] as String, style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                          ],
                        ),
                      ),

                      // Metric 2
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['metric2'] as String, style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFF6C757D))),
                            Text(d['val2'] as String, style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                          ],
                        ),
                      ),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 5, height: 5, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text(
                              d['status'] as String,
                              style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF6C757D)),
                        onPressed: () => widget.onNavigateModule(1), // Jump to department workspace
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // D. TODAY'S SCHEDULE & UPCOMING DEADLINES
  // ==========================================
  Widget _buildScheduleAndDeadlines(BuildContext context, ErpProvider erp) {
    final todayMeetings = erp.todayMeetings;
    final pendingTasks = erp.allTasks.where((t) => !t.isCompleted).take(3).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Today's Schedule & Deadlines",
                  style: GoogleFonts.instrumentSans(fontSize: 15.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => widget.onNavigateModule(5), // Calendar
                child: Text(
                  'Full Calendar',
                  style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Meetings
          Text('EXECUTIVE MEETINGS', style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF6C757D), letterSpacing: 0.5)),
          const SizedBox(height: 6),
          if (todayMeetings.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('No further executive meetings scheduled for today.', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
            )
          else ...[
            ...todayMeetings.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
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
                          style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                            Text(
                              '${m.organizerName} • ${m.locationOrLink}',
                              style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 14),

          // Deadlines Countdown
          Text('CRITICAL DELIVERABLE DEADLINES', style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF6C757D), letterSpacing: 0.5)),
          const SizedBox(height: 6),
          ...pendingTasks.map((t) {
            final isOverdue = t.isOverdue;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOverdue ? const Color(0xFFFFF5F5) : const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isOverdue ? const Color(0xFFFFC9C9) : const Color(0xFFE9ECEF)),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverdue ? Icons.error_outline_rounded : Icons.timer_outlined,
                    size: 16,
                    color: isOverdue ? const Color(0xFFE03131) : const Color(0xFF212529),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title, style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                        Text(
                          'Assigned: ${t.assignedToName} • ${t.domain}',
                          style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOverdue ? const Color(0xFFE03131) : const Color(0xFF212529),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isOverdue ? 'OVERDUE' : t.deadlineCountdownText,
                      style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
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

  // ==========================================
  // E. COMPANY ACTIVITY FEED
  // ==========================================
  Widget _buildCompanyActivityFeed(BuildContext context, ErpProvider erp) {
    final logs = erp.allAuditLogs.take(5).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Company Activity Feed',
                  style: GoogleFonts.instrumentSans(fontSize: 15.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => widget.onNavigateModule(6), // Control Centre / Audit Logs
                child: Text(
                  'Audit Trail',
                  style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No recent system activities logged.', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
              ),
            )
          else ...[
            ...logs.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF212529),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.action,
                              style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              log.details,
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF495057)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${log.module} • ${DateFormat('dd MMM, hh:mm a').format(log.timestamp)} by ${log.actorName}',
                              style: GoogleFonts.instrumentSans(fontSize: 10, color: const Color(0xFFADB5BD)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

/// Custom Spline Painter for Image 1 Revenue Trend (FY26)
class RevenueTrendSplinePainter extends CustomPainter {
  final List<double> actualPoints;
  final List<double> targetPoints;
  final List<String> labels;

  RevenueTrendSplinePainter({
    required this.actualPoints,
    required this.targetPoints,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (actualPoints.isEmpty) return;

    final graphHeight = size.height - 24; // Leave room for bottom month labels
    final graphWidth = size.width;
    final stepX = graphWidth / (actualPoints.length - 1);

    // 1. Draw horizontal subtle grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F3F5)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = graphHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(graphWidth, y), gridPaint);
    }

    // Coordinates calculation
    List<Offset> actualOffsets = [];
    List<Offset> targetOffsets = [];
    for (int i = 0; i < actualPoints.length; i++) {
      final x = i * stepX;
      final yActual = graphHeight - (actualPoints[i] * graphHeight * 0.75 + graphHeight * 0.1);
      final yTarget = graphHeight - (targetPoints[i] * graphHeight * 0.75 + graphHeight * 0.1);
      actualOffsets.add(Offset(x, yActual));
      targetOffsets.add(Offset(x, yTarget));
    }

    // 2. Draw Target Plan (Dashed grey line with dots)
    final targetPath = Path();
    targetPath.moveTo(targetOffsets.first.dx, targetOffsets.first.dy);
    for (int i = 0; i < targetOffsets.length - 1; i++) {
      final p0 = targetOffsets[i];
      final p1 = targetOffsets[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      targetPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final targetPaint = Paint()
      ..color = const Color(0xFFCED4DA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw dashed spline
    canvas.drawPath(targetPath, targetPaint);

    for (final p in targetOffsets) {
      canvas.drawCircle(p, 3.5, Paint()..color = const Color(0xFFCED4DA));
      canvas.drawCircle(p, 1.8, Paint()..color = Colors.white);
    }

    // 3. Draw Actual Revenue Gradient Area
    final fillPath = Path();
    fillPath.moveTo(actualOffsets.first.dx, actualOffsets.first.dy);
    for (int i = 0; i < actualOffsets.length - 1; i++) {
      final p0 = actualOffsets[i];
      final p1 = actualOffsets[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      fillPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }
    fillPath.lineTo(actualOffsets.last.dx, graphHeight);
    fillPath.lineTo(actualOffsets.first.dx, graphHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x2E12B886),
          Color(0x0212B886),
        ],
      ).createShader(Rect.fromLTWH(0, 0, graphWidth, graphHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw Actual Revenue Line (Green Spline)
    final actualPath = Path();
    actualPath.moveTo(actualOffsets.first.dx, actualOffsets.first.dy);
    for (int i = 0; i < actualOffsets.length - 1; i++) {
      final p0 = actualOffsets[i];
      final p1 = actualOffsets[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      actualPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final actualPaint = Paint()
      ..color = const Color(0xFF0CA678)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(actualPath, actualPaint);

    // Actual Points (White circle with green dot inside)
    for (final p in actualOffsets) {
      canvas.drawCircle(p, 4.5, Paint()..color = const Color(0xFF0CA678));
      canvas.drawCircle(p, 2.2, Paint()..color = Colors.white);
    }

    // 5. Month Labels below
    for (int i = 0; i < labels.length; i++) {
      final textSpan = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF868E96),
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      )..layout();

      final x = i * stepX - (textPainter.width / 2);
      textPainter.paint(canvas, Offset(x.clamp(0.0, graphWidth - textPainter.width), size.height - 14));
    }
  }

  @override
  bool shouldRepaint(covariant RevenueTrendSplinePainter oldDelegate) => true;
}

/// Custom Donut Chart Painter for Image 1 Department Allocation
class DepartmentDonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  DepartmentDonutPainter({
    required this.values,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 22.0;

    double startAngle = -1.570796; // Start from top (-pi / 2)
    const gapAngle = 0.045; // Small gap between segments

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] * 6.2831853) - gapAngle;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gapAngle / 2),
        sweepAngle > 0 ? sweepAngle : 0.01,
        false,
        paint,
      );

      startAngle += (values[i] * 6.2831853);
    }
  }

  @override
  bool shouldRepaint(covariant DepartmentDonutPainter oldDelegate) => false;
}
