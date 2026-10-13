import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/finance_models.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/adjust_budget_dialog.dart';

/// Page 2: Project Budgets
/// Manage and monitor project finances, allocations, spending, and adjustment records
class FinanceBudgetsPage extends StatefulWidget {
  const FinanceBudgetsPage({super.key});

  @override
  State<FinanceBudgetsPage> createState() => _FinanceBudgetsPageState();
}

class _FinanceBudgetsPageState extends State<FinanceBudgetsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Overbudget', 'Approaching Limit', 'Healthy'
  final Set<String> _expandedProjectIds = {};

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allBudgets = erp.allProjectBudgets;

    final filtered = allBudgets.where((b) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = b.projectName.toLowerCase().contains(q);
        final matchesClient = b.clientName.toLowerCase().contains(q);
        final matchesDomain = b.domain.toLowerCase().contains(q);
        if (!matchesName && !matchesClient && !matchesDomain) return false;
      }
      if (_selectedFilter == 'Overbudget') return b.isExceeded;
      if (_selectedFilter == 'Approaching Limit') return b.isApproachingLimit;
      if (_selectedFilter == 'Healthy') return !b.isExceeded && !b.isApproachingLimit;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary KPIs Bar
            _buildSummaryKPIBanner(erp),

            // Search Bar & Filters
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by project name, client, or domain...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                      filled: true,
                      fillColor: const Color(0xFF2B3035),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', allBudgets.length),
                        _buildFilterChip('Overbudget', erp.overbudgetProjects.length, const Color(0xFFEF4444)),
                        _buildFilterChip('Approaching Limit', erp.thresholdAlertProjects.length, const Color(0xFFF59E0B)),
                        _buildFilterChip(
                          'Healthy',
                          allBudgets.where((b) => !b.isExceeded && !b.isApproachingLimit).length,
                          const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white, height: 1),

            // Projects List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, color: Color(0xFF64748B), size: 40),
                          const SizedBox(height: 10),
                          Text(
                            'No project budgets match "$_selectedFilter"',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final project = filtered[index];
                        final isExpanded = _expandedProjectIds.contains(project.projectId);
                        return _buildProjectBudgetCard(context, project, isExpanded);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryKPIBanner(ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
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
                    'Finance Project Budgets',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Approved expenses vs live commitments',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${erp.allProjectBudgets.length} Projects',
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBannerStat(
                  'Total Approved',
                  '₹${(erp.totalAllocatedBudget / 1000).toStringAsFixed(0)}k',
                  const Color(0xFF38BDF8),
                ),
              ),
              Expanded(
                child: _buildBannerStat(
                  'Total Spent',
                  '₹${(erp.totalSpentBudget / 1000).toStringAsFixed(0)}k',
                  erp.overallBudgetUtilization > 1.0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildBannerStat(
                  'Remaining Balance',
                  '₹${(erp.totalRemainingBudget / 1000).toStringAsFixed(0)}k',
                  const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildBannerStat(
                  'Utilization',
                  '${(erp.overallBudgetUtilization * 100).toStringAsFixed(1)}%',
                  const Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildFilterChip(String label, int count, [Color? color]) {
    final isSelected = _selectedFilter == label;
    final activeColor = color ?? const Color(0xFF0284C7);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: activeColor.withValues(alpha: 0.25),
        side: BorderSide(color: isSelected ? activeColor : const Color(0xFF334155)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        label: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onSelected: (_) => setState(() => _selectedFilter = label),
      ),
    );
  }

  Widget _buildProjectBudgetCard(BuildContext context, ProjectBudget project, bool isExpanded) {
    final utilization = project.utilizationPercentage;
    final color = project.isExceeded
        ? const Color(0xFFEF4444)
        : project.isApproachingLimit
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: project.isExceeded
              ? const Color(0xFFEF4444).withValues(alpha: 0.5)
              : project.isApproachingLimit
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                  : const Color(0xFF334155),
          width: (project.isExceeded || project.isApproachingLimit) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Top Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.projectName,
                            style: const TextStyle(
                              color: Color(0xFF212529),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Client: ${project.clientName} • ${project.domain}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            project.isExceeded
                                ? Icons.report_problem_rounded
                                : project.isApproachingLimit
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_rounded,
                            color: color,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            project.isExceeded
                                ? 'Overbudget'
                                : project.isApproachingLimit
                                    ? 'Approaching Limit'
                                    : 'Healthy',
                            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Financial Overview 3-column stats
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Approved Budget', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                          const SizedBox(height: 3),
                          Text(
                            '₹${project.approvedBudget.toStringAsFixed(0)}',
                            style: const TextStyle(color: Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount Spent', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                          const SizedBox(height: 3),
                          Text(
                            '₹${project.spentAmount.toStringAsFixed(0)}',
                            style: TextStyle(color: color, fontSize: 13.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Remaining Balance', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                          const SizedBox(height: 3),
                          Text(
                            '₹${project.remainingBalance.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: project.remainingBalance < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Utilization Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Utilization: ${(utilization * 100).toStringAsFixed(1)}%',
                      style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      project.isExceeded
                          ? '+${((utilization - 1.0) * 100).toStringAsFixed(1)}% Over Limit'
                          : '${((1.0 - utilization) * 100).toStringAsFixed(1)}% Available',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: utilization.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFF212529),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 14),

                // Action buttons: Adjust Budget & Toggle Details
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => AdjustBudgetDialog.show(context, project),
                      icon: const Icon(Icons.tune_rounded, size: 14),
                      label: const Text('Adjust Budget', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedProjectIds.remove(project.projectId);
                          } else {
                            _expandedProjectIds.add(project.projectId);
                          }
                        });
                      },
                      icon: Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                      ),
                      label: Text(
                        isExpanded ? 'Hide Details' : 'Allocations (${project.allocations.length})',
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable Allocations & Adjustment History
          if (isExpanded) ...[
            const Divider(color: Color(0xFF334155), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Allocations Section
                  const Text(
                    'Resource & Expense Allocations Breakdown',
                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (project.allocations.isEmpty)
                    const Text('No departmental allocations recorded.', style: TextStyle(color: Color(0xFF64748B), fontSize: 11))
                  else
                    ...project.allocations.map((alc) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212529),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  alc.category,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '₹${alc.spentAmount.toStringAsFixed(0)} / ₹${alc.allocatedAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: alc.isOverspent ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (alc.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(alc.description, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                            ],
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: alc.utilizationRatio.clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor: Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  alc.isOverspent ? const Color(0xFFEF4444) : const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 12),

                  // Budget Adjustment History Section
                  const Text(
                    'Budget Adjustment & Audit History',
                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (project.adjustmentHistory.isEmpty)
                    const Text('No prior budget adjustments recorded.', style: TextStyle(color: Color(0xFF64748B), fontSize: 11))
                  else
                    ...project.adjustmentHistory.map((adj) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212529),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              adj.adjustmentAmount >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: adj.adjustmentAmount >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${adj.adjustmentAmount >= 0 ? '+' : ''}₹${adj.adjustmentAmount.toStringAsFixed(0)} (New: ₹${adj.newBudget.toStringAsFixed(0)})',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        '${adj.timestamp.day}/${adj.timestamp.month}/${adj.timestamp.year}',
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Reason: ${adj.reason} • By: ${adj.approvedBy}',
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
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
            ),
          ],
        ],
      ),
    );
  }
}
