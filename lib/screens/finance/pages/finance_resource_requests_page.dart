import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/finance_models.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/finance_formatters.dart';
import '../widgets/finance_lead_review_sheet.dart';
import 'finance_leads_pipeline_page.dart';

/// Page 3: Resource & Deal Reviews
/// Clean, minimalist procurement review and deal feasibility sign-off
/// Charcoal #212529, soft gray #F5F6F7, and white #FFFFFF.
class FinanceResourceRequestsPage extends StatefulWidget {
  const FinanceResourceRequestsPage({super.key});

  @override
  State<FinanceResourceRequestsPage> createState() => _FinanceResourceRequestsPageState();
}

class _FinanceResourceRequestsPageState extends State<FinanceResourceRequestsPage> {
  int _activeTabIndex = 0; // 0 = Resource Requests, 1 = Deal Reviews
  String _selectedFilter = 'All'; // 'All', 'Pending', 'Approved', 'Clarification', 'Rejected', 'Fulfilled'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allRequests = erp.allResourceRequests;
    final allLeads = erp.financeReviewLeads;

    final filteredRequests = allRequests.where((r) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesResource = r.requestedResource.toLowerCase().contains(q);
        final matchesDept = r.requestingDepartment.toLowerCase().contains(q);
        final matchesRequester = r.requesterName.toLowerCase().contains(q);
        final matchesProject = (r.projectName ?? '').toLowerCase().contains(q);
        if (!matchesResource && !matchesDept && !matchesRequester && !matchesProject) return false;
      }
      if (_selectedFilter == 'Pending') return r.isPending;
      if (_selectedFilter == 'Approved') return r.isApproved;
      if (_selectedFilter == 'Clarification') return r.isClarificationRequested;
      if (_selectedFilter == 'Rejected') return r.isRejected;
      if (_selectedFilter == 'Fulfilled') return r.status == ResourceRequestStatus.fulfilled;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Banner with title and pipeline shortcut
            _buildHeaderBanner(context, erp),

            // Tab bar: Resource Requests vs Deal Reviews
            _buildTabs(),

            // Search Bar & Filter Chips
            if (_activeTabIndex == 0) ...[
              _buildSearchBar(),
              _buildFilterChips(allRequests, erp),
            ],

            const Divider(color: Color(0xFFE9ECEF), height: 1),

            // Main List View
            Expanded(
              child: _activeTabIndex == 0
                  ? _buildResourceRequestsList(context, filteredRequests, erp)
                  : _buildDealReviewsList(context, allLeads, erp),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Header Banner
  Widget _buildHeaderBanner(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
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
                      'Department Resource Requests',
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF212529),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Procurement, cloud instances & deal sign-offs',
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF868E96),
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${erp.pendingResourceRequests.length} Pending',
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Shortcut to Leads Pipeline (required by tests)
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceLeadsPipelinePage()));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: Color(0xFF212529), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Access Shared Leads Pipeline for Deal Feasibility',
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF212529),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212529),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${erp.financeReviewLeads.length} Deals',
                      style: GoogleFonts.instrumentSans(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF212529), size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tabs separating Resource Requests and Deal Reviews
  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                index: 0,
                label: 'Resource Requests',
              ),
            ),
            Expanded(
              child: _buildTabButton(
                index: 1,
                label: 'Deal Reviews',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({required int index, required String label}) {
    final isSelected = _activeTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _activeTabIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSans(
            color: isSelected ? const Color(0xFF212529) : const Color(0xFF868E96),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Container(
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
                  hintText: 'Search by resource, department, or project...',
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
    );
  }

  /// Filter chips
  Widget _buildFilterChips(List<ResourceRequest> allRequests, ErpProvider erp) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          _buildFilterChip('All', allRequests.length),
          _buildFilterChip('Pending', erp.pendingResourceRequests.length),
          _buildFilterChip('Approved', erp.approvedResourceRequests.length),
          _buildFilterChip('Clarification', allRequests.where((r) => r.isClarificationRequested).length),
          _buildFilterChip('Rejected', erp.rejectedResourceRequests.length),
          _buildFilterChip('Fulfilled', allRequests.where((r) => r.status == ResourceRequestStatus.fulfilled).length),
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

  /// Resource Requests List
  Widget _buildResourceRequestsList(BuildContext context, List<ResourceRequest> requests, ErpProvider erp) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No resource requests found for "$_selectedFilter"',
          style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return _buildRequestCard(context, req, erp);
      },
    );
  }

  /// Request Card with Clean Charcoal & White styling
  Widget _buildRequestCard(BuildContext context, ResourceRequest req, ErpProvider erp) {
    ProjectBudget? linkedBudget;
    if (req.projectId != null) {
      linkedBudget = erp.allProjectBudgets.firstWhere(
        (b) => b.projectId == req.projectId,
        orElse: () => ProjectBudget(
          projectId: req.projectId!,
          projectName: req.projectName ?? 'Project',
          clientName: 'Client',
          approvedBudget: 0,
          spentAmount: 0,
        ),
      );
    }

    final hasBudgetAvailable = linkedBudget == null || (linkedBudget.remainingBalance >= req.estimatedCost);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: req.isPending ? const Color(0xFF212529) : const Color(0xFFE9ECEF),
          width: req.isPending ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department pill & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    req.requestingDepartment,
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF495057),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: req.isPending ? const Color(0xFF212529) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Text(
                  req.status.label,
                  style: GoogleFonts.instrumentSans(
                    color: req.isPending ? Colors.white : const Color(0xFF495057),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Requested Resource Title (e.g. AWS GPU Cluster (p4d.24xlarge))
          Text(
            req.requestedResource,
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF212529),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Purpose
          Text(
            req.purpose,
            style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontSize: 12),
          ),
          const SizedBox(height: 14),

          // Specs Box
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated Cost', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            FinanceFormatters.formatFullInr(req.estimatedCost),
                            style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Units', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            '${req.quantity}',
                            style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Requester', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            req.requesterName,
                            style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 12.5, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (req.projectName != null) ...[
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE9ECEF), height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Project: ${req.projectName}',
                          style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasBudgetAvailable ? 'Budget Available' : 'Overbudget',
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF212529),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Finance comments if reviewed
          if (req.financeComments != null && req.financeComments!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.comment_rounded, color: Color(0xFF212529), size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Decision: ${req.financeComments} (by ${req.reviewedBy ?? "Finance"})',
                      style: GoogleFonts.instrumentSans(color: const Color(0xFF495057), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Workflow Action Buttons (Approve & Allocate, Reject, Clarify)
          if (req.isPending || req.isClarificationRequested) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _showClarifyDialog(context, req, erp),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF212529),
                    side: const BorderSide(color: Color(0xFFCED4DA)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Clarify', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                OutlinedButton(
                  onPressed: () => _showRejectDialog(context, req, erp),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF212529),
                    side: const BorderSide(color: Color(0xFFCED4DA)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Reject', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                  onPressed: () => _showApproveDialog(context, req, erp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Approve & Allocate', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Deal Reviews List (Deals forwarded by Sales)
  Widget _buildDealReviewsList(BuildContext context, List leads, ErpProvider erp) {
    if (leads.isEmpty) {
      return Center(
        child: Text(
          'No deals currently awaiting financial review.',
          style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      FinanceFormatters.formatFullInr(lead.dealValue),
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF212529),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Contact: ${lead.contactPerson} • Rep: ${lead.assignedEmployeeName}',
                style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => FinanceLeadReviewSheet.show(context, lead),
                  icon: const Icon(Icons.rate_review_rounded, size: 16),
                  label: Text(
                    'Review & Sign Off Financials',
                    style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700),
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
      },
    );
  }

  void _showApproveDialog(BuildContext context, ResourceRequest req, ErpProvider erp) {
    final commentController = TextEditingController(text: 'Approved within verified operational and project budget.');
    final amountController = TextEditingController(text: req.estimatedCost.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Approve Resource Request',
          style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm allocation for ${req.requestedResource} (${req.requestingDepartment}).',
              style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF495057)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.instrumentSans(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Approved Allocation Amount (₹)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 2,
              style: GoogleFonts.instrumentSans(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Finance Comments',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96))),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text.trim()) ?? req.estimatedCost;
              erp.approveResourceRequest(
                req.id,
                comments: commentController.text.trim(),
                allocatedBudget: amt,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirm Approval', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, ResourceRequest req, ErpProvider erp) {
    final reasonController = TextEditingController(text: 'Out of scope for current quarter allocation.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reject Resource Request',
          style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide reason for declining ${req.requestedResource}:',
              style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF495057)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
              style: GoogleFonts.instrumentSans(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96))),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                erp.rejectResourceRequest(req.id, reason: reasonController.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Decline Request', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showClarifyDialog(BuildContext context, ResourceRequest req, ErpProvider erp) {
    final questionsController = TextEditingController(text: 'Is this spot instance or on-demand?');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Request Clarification',
          style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit questions to ${req.requesterName} (${req.requestingDepartment}):',
              style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF495057)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: questionsController,
              maxLines: 2,
              style: GoogleFonts.instrumentSans(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Clarification Questions',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96))),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionsController.text.trim().isNotEmpty) {
                erp.requestResourceClarification(req.id, questions: questionsController.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Send Inquiry', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
