import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/finance_models.dart';
import '../widgets/ceo_modals.dart';

/// Module 5: Finance & Approvals (Executive Workspace)
/// Design inspired by minimalist executive reference (Image 3)
class CeoFinancePage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoFinancePage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoFinancePage> createState() => _CeoFinancePageState();
}

class _CeoFinancePageState extends State<CeoFinancePage> {
  String _activeTab = 'Overview'; // 'Overview', 'Budgets', 'Approvals', 'Requests', 'Audit trail'
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Pending', 'Approved', 'Allocated'

  final List<String> _tabs = ['Overview', 'Budgets', 'Approvals', 'Requests', 'Audit trail'];

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final totalAllocCr = (erp.totalAllocatedBudget / 10000000).toStringAsFixed(2);
    final totalSpentCr = (erp.totalSpentBudget / 10000000).toStringAsFixed(2);
    final utilization = (erp.overallBudgetUtilization * 100).toInt();

    final pendingTotal = erp.pendingResourceRequests.fold<double>(0.0, (sum, r) => sum + r.estimatedCost);
    final pendingLakhs = (pendingTotal / 100000).toStringAsFixed(1);
    final pendingCount = erp.pendingResourceRequests.length;

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 16, isMobile ? 16 : 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & "Create new ->" pill button (Matching Image 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Finance & Approvals',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212529),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => CeoModals.showCreateNewActionSheet(context, erp, widget.onNavigateModule),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create new',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Horizontal Category Tabs (Overview, Budgets, Approvals, Requests, Audit trail)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = tab),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tab,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF212529) : const Color(0xFF868E96),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 2,
                          width: isSelected ? 24 : 0,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF212529) : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Stat Cards (Matching Image 3: Q2 budget, Utilized, Pending in Indian Rupees)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard('Q2 budget', '₹$totalAllocCr Cr', 'Approved allocation'),
                const SizedBox(width: 12),
                _buildStatCard('Utilized', '$utilization%', '₹$totalSpentCr Cr spent'),
                const SizedBox(width: 12),
                _buildStatCard('Pending', '₹$pendingLakhs L', '$pendingCount requests'),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Active Sub-view Based on Tab
          if (_activeTab == 'Overview') _buildMainDecisionsCard(context, erp),
          if (_activeTab == 'Budgets') _buildBudgetsSection(erp),
          if (_activeTab == 'Approvals') _buildApprovalsSection(context, erp),
          if (_activeTab == 'Requests') _buildRequestsSection(context, erp),
          if (_activeTab == 'Audit trail') _buildAuditTrailSection(erp),
        ],
      ),
    );
  }

  // --- Image 3 Main Card: "Budgets & pending decisions" ---
  Widget _buildMainDecisionsCard(BuildContext context, ErpProvider erp) {
    // Generate unified records from budget allocations + resource requests
    final List<_FinanceItem> items = [
      _FinanceItem(title: 'Technical allocation', amountStr: '₹65.0 L', category: 'Budget', isPending: false),
      _FinanceItem(title: 'Q2 media reallocation', amountStr: '₹25.0 L', category: 'Budget', isPending: false),
      _FinanceItem(title: 'Staffing cost request', amountStr: '₹6.2 L', category: 'Request', isPending: true, requester: 'HR Head'),
      _FinanceItem(title: 'Enterprise exception', amountStr: '₹3.8 L', category: 'Approval', isPending: true, requester: 'Finance Manager'),
      _FinanceItem(title: 'Sales & Marketing', amountStr: '₹40.0 L', category: 'Budget', isPending: false),
      _FinanceItem(title: 'Corporate Finance & Ops', amountStr: '₹20.0 L', category: 'Budget', isPending: false),
    ];

    // Add any live pending resource requests from erp
    for (final r in erp.allResourceRequests) {
      if (!items.any((it) => it.title == r.requestedResource)) {
        final lakhStr = (r.estimatedCost / 100000).toStringAsFixed(1);
        items.add(
          _FinanceItem(
            title: r.requestedResource,
            amountStr: '₹$lakhStr L',
            category: 'Request',
            isPending: r.isPending,
            requester: r.requesterName,
            rawRequest: r,
          ),
        );
      }
    }

    // Filter by search query & status
    final filtered = items.where((it) {
      final matchesSearch = it.title.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_statusFilter == 'Pending') return matchesSearch && it.isPending;
      if (_statusFilter == 'Approved' || _statusFilter == 'Allocated') return matchesSearch && !it.isPending;
      return matchesSearch;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budgets & pending decisions',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212529),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Live company records · Last updated just now',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11.5,
                    color: const Color(0xFF868E96),
                  ),
                ),
              ],
            ),
          ),

          // Search Box & Status Filter Dropdown (Matching Image 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 18, color: Color(0xFFADB5BD)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF212529)),
                            decoration: InputDecoration(
                              hintText: 'Filter records...',
                              hintStyle: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFFADB5BD)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _statusFilter = val),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'All',
                      child: Text('All statuses', style: GoogleFonts.instrumentSans(fontSize: 12)),
                    ),
                    PopupMenuItem(
                      value: 'Pending',
                      child: Text('Pending decisions', style: GoogleFonts.instrumentSans(fontSize: 12)),
                    ),
                    PopupMenuItem(
                      value: 'Allocated',
                      child: Text('Approved / Allocated', style: GoogleFonts.instrumentSans(fontSize: 12)),
                    ),
                  ],
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _statusFilter == 'All' ? 'All statuses' : _statusFilter,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF495057),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF868E96)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE9ECEF)),

          // List Items (Matching Image 3: Bold Title, Amount in ₹, Chevron right)
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No matching financial records.',
                  style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final it = filtered[i];
                return InkWell(
                  onTap: () => _showDecisionModal(context, erp, it),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            it.title,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF212529),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          it.amountStr,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF495057),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF868E96)),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Stat Card Helper ---
  Widget _buildStatCard(String title, String val, String sub) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF868E96),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.instrumentSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF212529),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.instrumentSans(
              fontSize: 10.5,
              color: const Color(0xFFADB5BD),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- Executive Decision Modal for tapped record ---
  void _showDecisionModal(BuildContext context, ErpProvider erp, _FinanceItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEE2E6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Category: ${item.category} · Requester: ${item.requester ?? "Executive Committee"}',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12.5,
                            color: const Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isPending ? const Color(0xFFFFF3BF) : const Color(0xFFD3F9D8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.isPending ? 'Pending Signoff' : 'Authorized',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: item.isPending ? const Color(0xFFF08C00) : const Color(0xFF2B8A3E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Value',
                          style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF868E96)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.amountStr,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Approval Authority',
                          style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF868E96)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CEO Final Signoff',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212529),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildModalRow('Justification', 'Operating necessity aligned with FY26 quarterly milestones.'),
              _buildModalRow('Financial Impact', 'Absorbed within pre-approved operational treasury reserve.'),
              _buildModalRow('Accounting Code', 'CAPEX-DI-2026-HQ'),
              const SizedBox(height: 24),

              // Decision Actions: Approve, Reject, Delegate
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Delegated review of ${item.title} to Finance Head.',
                              style: GoogleFonts.instrumentSans(),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF212529),
                        side: const BorderSide(color: Color(0xFFDEE2E6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Delegate', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Rejected ${item.title}. Notification logged.',
                              style: GoogleFonts.instrumentSans(),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE03131),
                        side: const BorderSide(color: Color(0xFFFFC9C9)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Reject', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (item.rawRequest != null) {
                          erp.approveResourceRequest(item.rawRequest!.id, allocatedBudget: item.rawRequest!.estimatedCost);
                        }
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Authorized ${item.title} (${item.amountStr}).',
                              style: GoogleFonts.instrumentSans(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text('Approve', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF868E96)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF212529),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Sub-View: Department Budgets Breakdown ---
  Widget _buildBudgetsSection(ErpProvider erp) {
    final depts = [
      {'name': 'Technical / Engineering', 'alloc': 6500000.0, 'spent': 4820000.0},
      {'name': 'Sales & Marketing', 'alloc': 4000000.0, 'spent': 2810000.0},
      {'name': 'HR & Talent Operations', 'alloc': 2500000.0, 'spent': 1800000.0},
      {'name': 'Digital Marketing', 'alloc': 2500000.0, 'spent': 1340000.0},
      {'name': 'Corporate Finance & Ops', 'alloc': 2000000.0, 'spent': 1200000.0},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Departmental Capital Utilization',
            style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
          ),
          const SizedBox(height: 16),
          ...depts.map((d) {
            final alloc = d['alloc'] as double;
            final spent = d['spent'] as double;
            final ratio = (spent / alloc).clamp(0.0, 1.0);
            final pct = (ratio * 100).toInt();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          d['name'] as String,
                          style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${(spent / 100000).toStringAsFixed(1)}L / ₹${(alloc / 100000).toStringAsFixed(1)}L ($pct%)',
                        style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: const Color(0xFFF5F6F7),
                      valueColor: AlwaysStoppedAnimation(ratio > 0.85 ? const Color(0xFFE03131) : const Color(0xFF212529)),
                      minHeight: 6,
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

  // --- Sub-View: Approvals Section ---
  Widget _buildApprovalsSection(BuildContext context, ErpProvider erp) {
    final pending = erp.allApprovalRequests;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: pending.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No approvals awaiting action.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96))),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pending.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final a = pending[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.verified_outlined, size: 18, color: Color(0xFF212529)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                            ),
                            Text(
                              '${a.submittingDepartment} · Requester: ${a.submittedByName}',
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF868E96)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => CeoModals.showApprovalDecisionModal(context, a, erp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF212529),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 0,
                        ),
                        child: Text('Review', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- Sub-View: Requests Section ---
  Widget _buildRequestsSection(BuildContext context, ErpProvider erp) {
    final requests = erp.allResourceRequests;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: requests.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No pending resource requests.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96))),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final r = requests[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.assignment_turned_in_outlined, size: 18, color: Color(0xFF212529)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.requestedResource,
                              style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                            ),
                            Text(
                              '${r.requestingDepartment} · ₹${(r.estimatedCost / 100000).toStringAsFixed(1)}L · ${r.requesterName}',
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF868E96)),
                            ),
                          ],
                        ),
                      ),
                      if (r.isPending)
                        ElevatedButton(
                          onPressed: () {
                            erp.approveResourceRequest(r.id, allocatedBudget: r.estimatedCost);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Authorized ${r.requestedResource}', style: GoogleFonts.instrumentSans())),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF212529),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 0,
                          ),
                          child: Text('Approve', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700)),
                        )
                      else
                        Text('APPROVED', style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2B8A3E))),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- Sub-View: Audit Trail Section ---
  Widget _buildAuditTrailSection(ErpProvider erp) {
    final logs = erp.allAuditLogs;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: logs.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No audit events logged.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96))),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.take(15).length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final log = logs[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.history_edu_outlined, size: 16, color: Color(0xFF212529)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.action,
                              style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                            ),
                            Text(
                              '${log.details} · By ${log.actorName}',
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF868E96)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _FinanceItem {
  final String title;
  final String amountStr;
  final String category;
  final bool isPending;
  final String? requester;
  final ResourceRequest? rawRequest;

  _FinanceItem({
    required this.title,
    required this.amountStr,
    required this.category,
    required this.isPending,
    this.requester,
    this.rawRequest,
  });
}
