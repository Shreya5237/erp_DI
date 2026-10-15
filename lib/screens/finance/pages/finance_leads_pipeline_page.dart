import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/lead.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/finance_formatters.dart';
import '../widgets/finance_lead_review_sheet.dart';

/// Page 4: Shared Leads Pipeline
/// Finance commercial evaluation, deal feasibility signoff, margins and costs
/// Charcoal #212529, soft gray #F5F6F7, and white #FFFFFF cards.
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shared Leads Pipeline',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF212529),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Finance deal progression & commercial review',
              style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 11),
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
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _buildKpiCard('Needs Review', '$pendingCount'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard('Approved', '$approvedCount'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Pipeline Value',
                      FinanceFormatters.formatInr(erp.totalPipelineValue),
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
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF868E96), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search deals by company, client, or domain...',
                              hintStyle: GoogleFonts.instrumentSans(color: const Color(0xFFADB5BD), fontSize: 12.5),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Needs Review', pendingCount),
                        _buildFilterChip('All Deals', allLeads.length),
                        _buildFilterChip('Feasibility Approved', approvedCount),
                        _buildFilterChip(
                          'Returned',
                          allLeads.where((l) => l.financeFeasibility.status == FeasibilityStatus.changesRequested).length,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFE9ECEF), height: 1),

            // Leads List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No deals match "$_selectedFilter"',
                        style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
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

  Widget _buildKpiCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF212529) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? const Color(0xFF212529) : const Color(0xFFE9ECEF)),
          ),
          child: Text(
            '$label ($count)',
            style: GoogleFonts.instrumentSans(
              color: isSelected ? Colors.white : const Color(0xFF495057),
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, Lead lead) {
    final f = lead.financeFeasibility;
    final isApproved = f.status == FeasibilityStatus.completed;
    final isReturned = f.status == FeasibilityStatus.changesRequested;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (!isApproved && !isReturned)
              ? const Color(0xFF212529)
              : const Color(0xFFE9ECEF),
          width: (!isApproved && !isReturned) ? 1.5 : 1.0,
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
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF212529),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Client: ${lead.clientName} • Stage: ${lead.status.label}',
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Finance: ${f.status.label}',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF495057),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Deal Financial Details Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deal Value', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          FinanceFormatters.formatFullInr(lead.dealValue),
                          style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 13.5, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Est. Cost', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          FinanceFormatters.formatFullInr(f.estimatedCost),
                          style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Margin', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          '${f.expectedMarginPercent.toStringAsFixed(1)}%',
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF212529),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (f.paymentTerms.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE9ECEF), height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.payment_rounded, color: Color(0xFF868E96), size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Terms: ${f.paymentTerms}',
                          style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Scope
          Text(
            'Requirements: ${lead.requirementsScope}',
            style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontSize: 11.5, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Finance Notes if present
          if (f.budgetFeasibilityNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, color: Color(0xFF212529), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Finance Notes: ${f.budgetFeasibilityNotes}',
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF495057), fontSize: 11),
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
                style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212529),
                foregroundColor: Colors.white,
                elevation: 0,
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
