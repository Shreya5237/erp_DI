import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/lead.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/finance_lead_review_sheet.dart';

/// Page 4: Leads Pipeline
/// Finance participation in deal progression, reviewing pricing, costs, margins, and approving financials
class FinanceLeadsPipelinePage extends StatefulWidget {
  const FinanceLeadsPipelinePage({super.key});

  @override
  State<FinanceLeadsPipelinePage> createState() => _FinanceLeadsPipelinePageState();
}

class _FinanceLeadsPipelinePageState extends State<FinanceLeadsPipelinePage> {
  String _selectedFilter = 'Needs Review'; // 'Needs Review', 'All Deals', 'Feasibility Approved', 'Returned'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allLeads = erp.allLeads;

    final filtered = allLeads.where((l) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesCompany = l.companyName.toLowerCase().contains(q);
        final matchesClient = l.clientName.toLowerCase().contains(q);
        final matchesDomain = l.domain.toLowerCase().contains(q);
        if (!matchesCompany && !matchesClient && !matchesDomain) return false;
      }
      if (_selectedFilter == 'Needs Review') {
        return l.status == LeadStatus.feasibilityAssessment ||
            l.internalApprovalStage.contains('HR & Finance') ||
            l.financeFeasibility.status == FeasibilityStatus.pending ||
            l.financeFeasibility.status == FeasibilityStatus.inReview;
      }
      if (_selectedFilter == 'Feasibility Approved') {
        return l.financeFeasibility.status == FeasibilityStatus.completed;
      }
      if (_selectedFilter == 'Returned') {
        return l.financeFeasibility.status == FeasibilityStatus.changesRequested;
      }
      return true;
    }).toList();

    final pendingCount = allLeads.where((l) =>
        l.status == LeadStatus.feasibilityAssessment ||
        l.financeFeasibility.status == FeasibilityStatus.pending ||
        l.financeFeasibility.status == FeasibilityStatus.inReview).length;

    final approvedCount = allLeads.where((l) => l.financeFeasibility.status == FeasibilityStatus.completed).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shared Leads Pipeline',
              style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Finance deal progression & commercial review',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // KPI Summary Row
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFF334155))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildKpiCard('Needs Review', '$pendingCount', const Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard('Approved', '$approvedCount', const Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Pipeline Value',
                      '₹${(erp.totalPipelineValue / 100000).toStringAsFixed(1)}L',
                      const Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search deals by company, client, or domain...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                      filled: true,
                      fillColor: const Color(0xFF2B3035),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Needs Review', pendingCount, const Color(0xFFF59E0B)),
                        _buildFilterChip('All Deals', allLeads.length),
                        _buildFilterChip('Feasibility Approved', approvedCount, const Color(0xFF10B981)),
                        _buildFilterChip(
                          'Returned',
                          allLeads.where((l) => l.financeFeasibility.status == FeasibilityStatus.changesRequested).length,
                          const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white, height: 1),

            // Leads List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF64748B), size: 40),
                          const SizedBox(height: 10),
                          Text(
                            'No deals match "$_selectedFilter"',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final lead = filtered[index];
                        return _buildLeadCard(context, lead);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
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

  Widget _buildLeadCard(BuildContext context, Lead lead) {
    final f = lead.financeFeasibility;
    final isApproved = f.status == FeasibilityStatus.completed;
    final isReturned = f.status == FeasibilityStatus.changesRequested;
    final badgeColor = isApproved
        ? const Color(0xFF10B981)
        : isReturned
            ? const Color(0xFFEF4444)
            : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (!isApproved && !isReturned)
              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
              : const Color(0xFF334155),
          width: (!isApproved && !isReturned) ? 1.5 : 1,
        ),
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
                      lead.companyName,
                      style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Client: ${lead.clientName} • Stage: ${lead.status.label}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Finance: ${f.status.label}',
                  style: TextStyle(color: badgeColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Deal Financial Details Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deal Target Value', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          '₹${lead.dealValue.toStringAsFixed(0)}',
                          style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimated Cost', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          '₹${f.estimatedCost.toStringAsFixed(0)}',
                          style: const TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Expected Margin', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          '${f.expectedMarginPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: f.expectedMarginPercent >= 30.0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white, height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.payment_rounded, color: Color(0xFF64748B), size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Terms: ${f.paymentTerms}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Scope & Sales notes
          Text(
            'Requirements: ${lead.requirementsScope}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Finance Feasibility Notes if present
          if (f.budgetFeasibilityNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, color: badgeColor, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Finance Notes: ${f.budgetFeasibilityNotes}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => FinanceLeadReviewSheet.show(context, lead),
              icon: const Icon(Icons.rate_review_rounded, size: 16),
              label: Text(
                isApproved ? 'Update Financial Evaluation' : 'Review & Sign Off Financials',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isApproved ? const Color(0xFF2B3035) : const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                side: isApproved ? const BorderSide(color: Color(0xFF334155)) : null,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
