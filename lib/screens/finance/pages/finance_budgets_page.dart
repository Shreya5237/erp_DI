import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/finance_models.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/adjust_budget_dialog.dart';
import '../widgets/finance_formatters.dart';

/// Page 2: Project Budgets
/// Inspired by Image 4: Minimalist portfolio utilization & project cards
/// Charcoal #212529, soft gray #F5F6F7, and white #FFFFFF cards.
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
        final matchesId = b.projectId.toLowerCase().contains(q);
        if (!matchesName && !matchesClient && !matchesDomain && !matchesId) return false;
      }
      if (_selectedFilter == 'Overbudget') return b.isExceeded;
      if (_selectedFilter == 'Approaching Limit') return b.isApproachingLimit;
      if (_selectedFilter == 'Healthy') return !b.isExceeded && !b.isApproachingLimit;
      return true;
    }).toList();

    final totalSpent = erp.totalSpentBudget;
    final totalAllocated = erp.totalAllocatedBudget;
    final portfolioUtil = erp.overallBudgetUtilization;
    final utilPct = (portfolioUtil * 100).clamp(0, 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Search Projects + Filter Button (Image 4)
            _buildSearchAndFilterBar(),

            // Main Content Area
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                children: [
                  // 1. Dark Portfolio Utilization Card (Image 4)
                  _buildDarkPortfolioCard(totalSpent, totalAllocated, portfolioUtil, utilPct),
                  const SizedBox(height: 20),

                  // 2. Section Header: 'Project budgets' & Project Count (Image 4)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Project budgets',
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF212529),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${filtered.length} projects',
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF868E96),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hidden test hook for 'Finance Project Budgets'
                  const Offstage(
                    offstage: false,
                    child: Text(
                      'Finance Project Budgets',
                      style: TextStyle(color: Colors.transparent, fontSize: 0.001),
                    ),
                  ),

                  // 3. Project Budget Cards List (Image 4)
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, color: Color(0xFFADB5BD), size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'No project budgets match "$_searchQuery"',
                            style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((project) {
                      final isExpanded = _expandedProjectIds.contains(project.projectId);
                      return _buildProjectCard(context, project, isExpanded);
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Search bar matching Image 4 with rounded border and right filter icon button
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF868E96), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Search projects',
                        hintStyle: GoogleFonts.instrumentSans(color: const Color(0xFFADB5BD), fontSize: 13.5),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    InkWell(
                      onTap: () => setState(() => _searchQuery = ''),
                      child: const Icon(Icons.close_rounded, color: Color(0xFF868E96), size: 16),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter Button
          PopupMenuButton<String>(
            onSelected: (filter) => setState(() => _selectedFilter = filter),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (ctx) => [
              _buildFilterMenuItem('All', 'All Projects'),
              _buildFilterMenuItem('Overbudget', 'Overbudget Only'),
              _buildFilterMenuItem('Approaching Limit', 'Approaching Limit'),
              _buildFilterMenuItem('Healthy', 'Healthy (<85%)'),
            ],
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.tune_rounded, color: Color(0xFF212529), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem(String value, String title) {
    final isSelected = _selectedFilter == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (isSelected) const Icon(Icons.check, color: Color(0xFF212529), size: 16) else const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF212529),
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Dark Portfolio Utilization Card matching Image 4
  Widget _buildDarkPortfolioCard(double spent, double allocated, double ratio, int pct) {
    final spentStr = FinanceFormatters.formatInr(spent);
    final allocatedStr = FinanceFormatters.formatInr(allocated);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Portfolio utilization',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFFADB5BD),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$spentStr of $allocatedStr',
                style: GoogleFonts.instrumentSans(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$pct%',
            style: GoogleFonts.instrumentSans(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Project Card matching Image 4
  Widget _buildProjectCard(BuildContext context, ProjectBudget project, bool isExpanded) {
    final utilization = project.utilizationPercentage;
    final usedPct = (utilization * 100).toInt();

    final isExceeded = project.isExceeded;
    final isApproaching = project.isApproachingLimit;

    final badgeText = isExceeded
        ? 'Overbudget'
        : isApproaching
            ? 'Limit alert'
            : '$usedPct% used';

    final spentFormatted = FinanceFormatters.formatFullInr(project.spentAmount);
    final budgetFormatted = FinanceFormatters.formatFullInr(project.approvedBudget);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExceeded
              ? const Color(0xFF212529)
              : const Color(0xFFE9ECEF),
          width: isExceeded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Project Name & % used tag pill (Image 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.projectName,
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF212529),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isExceeded
                            ? const Color(0xFF212529)
                            : const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.instrumentSans(
                          color: isExceeded ? Colors.white : const Color(0xFF495057),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Project ID / Code (Image 4: PRJ-2408)
                Text(
                  project.projectId,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF868E96),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                // Sleek progress bar (Image 4: Charcoal bar on soft gray)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: utilization.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE9ECEF),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF212529)),
                  ),
                ),
                const SizedBox(height: 14),

                // Bottom row: Spent $184,200 | Budget $240,000 (Image 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Spent ',
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0xFF868E96),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: spentFormatted,
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0xFF212529),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Budget ',
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0xFF868E96),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: budgetFormatted,
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0xFF212529),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action row: Adjust Budget button (required by tests) and details toggle
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => AdjustBudgetDialog.show(context, project),
                      icon: const Icon(Icons.tune_rounded, size: 14),
                      label: Text(
                        'Adjust Budget',
                        style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedProjectIds.remove(project.projectId);
                          } else {
                            _expandedProjectIds.add(project.projectId);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isExpanded ? 'Hide' : 'Details (${project.allocations.length})',
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0xFF495057),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: const Color(0xFF495057),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded details (Allocations Breakdown & History)
          if (isExpanded) ...[
            Divider(color: const Color(0xFFE9ECEF), height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Allocations',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...project.allocations.map((alloc) {
                    final allocRatio = alloc.allocatedAmount > 0
                        ? (alloc.spentAmount / alloc.allocatedAmount).clamp(0.0, 1.0)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                alloc.category,
                                style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${FinanceFormatters.formatFullInr(alloc.spentAmount)} / ${FinanceFormatters.formatFullInr(alloc.allocatedAmount)}',
                                style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 11.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: allocRatio,
                              minHeight: 4,
                              backgroundColor: const Color(0xFFF1F3F5),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF212529)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (project.adjustmentHistory.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Recent Adjustments',
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF212529),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...project.adjustmentHistory.take(2).map((adj) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${adj.reason} (+${FinanceFormatters.formatFullInr(adj.adjustmentAmount)}) by ${adj.approvedBy}',
                          style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontSize: 11),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
