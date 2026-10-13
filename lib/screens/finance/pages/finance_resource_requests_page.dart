import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/finance_models.dart';
import '../../../providers/erp_provider.dart';
import 'finance_leads_pipeline_page.dart';

/// Page 3: Resource Requests
/// Review requests submitted by HR, Sales, Engineering, UI/UX, and verify cost & budget availability
class FinanceResourceRequestsPage extends StatefulWidget {
  const FinanceResourceRequestsPage({super.key});

  @override
  State<FinanceResourceRequestsPage> createState() => _FinanceResourceRequestsPageState();
}

class _FinanceResourceRequestsPageState extends State<FinanceResourceRequestsPage> {
  String _selectedFilter = 'All'; // 'All', 'Pending', 'Approved', 'Clarification', 'Rejected', 'Fulfilled'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allRequests = erp.allResourceRequests;

    final filtered = allRequests.where((r) {
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
            // Header Banner & Leads Pipeline Shortcut (as required by prompt)
            _buildHeaderBanner(context, erp),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by resource, department, requester, project...',
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
                        _buildFilterChip('All', allRequests.length),
                        _buildFilterChip('Pending', erp.pendingResourceRequests.length, const Color(0xFFF59E0B)),
                        _buildFilterChip('Approved', erp.approvedResourceRequests.length, const Color(0xFF10B981)),
                        _buildFilterChip(
                          'Clarification',
                          allRequests.where((r) => r.isClarificationRequested).length,
                          const Color(0xFF8B5CF6),
                        ),
                        _buildFilterChip('Rejected', erp.rejectedResourceRequests.length, const Color(0xFFEF4444)),
                        _buildFilterChip(
                          'Fulfilled',
                          allRequests.where((r) => r.status == ResourceRequestStatus.fulfilled).length,
                          const Color(0xFF06B6D4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white, height: 1),

            // Requests List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, color: Color(0xFF64748B), size: 40),
                          const SizedBox(height: 10),
                          Text(
                            'No resource requests found for "$_selectedFilter"',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final req = filtered[index];
                        return _buildRequestCard(context, req, erp);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                    'Department Resource Requests',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'HR, Sales, Engineering & UI/UX procurement review',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${erp.pendingResourceRequests.length} Pending Review',
                  style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Shortcut to Leads Pipeline (as mandated: "The Leads Pipeline is accessible from the dashboard and Requests page")
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceLeadsPipelinePage()));
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights_rounded, color: Color(0xFFA78BFA), size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Access Shared Leads Pipeline for Deal Feasibility',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${erp.financeReviewLeads.length} Deals',
                      style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFA78BFA), size: 11),
                ],
              ),
            ),
          ),
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

  Widget _buildRequestCard(BuildContext context, ResourceRequest req, ErpProvider erp) {
    // Check project budget availability if tied to a project
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: req.isPending ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : const Color(0xFF334155),
          width: req.isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department & Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  req.requestingDepartment,
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: req.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: req.status.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  req.status.label,
                  style: TextStyle(color: req.status.color, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Requested Resource Title
          Text(
            req.requestedResource,
            style: const TextStyle(color: Color(0xFF212529), fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),

          // Purpose description
          Text(
            req.purpose,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),

          // Specs Box: Quantity, Cost, Requester, Project
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
                        const Text('Estimated Cost', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          '₹${req.estimatedCost.toStringAsFixed(0)}',
                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 13.5, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity / Units', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          '${req.quantity}',
                          style: const TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Requester', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          req.requesterName,
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                if (req.projectName != null) ...[
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Project: ${req.projectName}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                      Text(
                        hasBudgetAvailable
                            ? 'Budget Available (${linkedBudget != null ? "₹${linkedBudget.remainingBalance.toStringAsFixed(0)} rem" : "Operational"})'
                            : 'Insufficient Budget (₹${linkedBudget.remainingBalance.toStringAsFixed(0)} rem)',
                        style: TextStyle(
                          color: hasBudgetAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Finance comments & decision record if reviewed
          if (req.financeComments != null && req.financeComments!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: req.status.color.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.comment_rounded, color: req.status.color, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Finance Decision: ${req.financeComments} (by ${req.reviewedBy ?? "Finance"})',
                      style: TextStyle(color: req.status.color, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Workflow Buttons for Pending requests
          if (req.isPending || req.isClarificationRequested) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                // Clarify button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showClarifyDialog(context, req, erp),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Clarify', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),

                // Reject button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, req, erp),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),

                // Approve button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _showApproveDialog(context, req, erp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Approve & Allocate', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, ResourceRequest req, ErpProvider erp) {
    final commentController = TextEditingController(text: 'Approved within verified operational and project budget.');
    final amountController = TextEditingController(text: req.estimatedCost.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Approve Request: ${req.id}', style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Approve allocation for ${req.requestedResource} (${req.requestingDepartment})', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 12),
              const Text('Approved Amount (₹)', style: TextStyle(color: Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Approval Comments', style: TextStyle(color: Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: commentController,
                maxLines: 2,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              final approvedAmount = double.tryParse(amountController.text.trim()) ?? req.estimatedCost;
              erp.approveResourceRequest(
                req.id,
                comments: commentController.text.trim(),
                allocatedBudget: approvedAmount,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF10B981),
                  content: Text('Approved ${req.requestedResource} (₹${approvedAmount.toStringAsFixed(0)})'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm Approval', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, ResourceRequest req, ErpProvider erp) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Request: ${req.id}', style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter reason for rejecting this departmental resource request *', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Current sprint budget does not cover international flights...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              erp.rejectResourceRequest(req.id, reason: reasonController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFFEF4444),
                  content: Text('Rejected request ${req.id}'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm Rejection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showClarifyDialog(BuildContext context, ResourceRequest req, ErpProvider erp) {
    final questionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Request Clarification: ${req.id}', style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specify information required from ${req.requesterName} (${req.requestingDepartment}) *', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 10),
              TextField(
                controller: questionsController,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Please clarify if the licenses include external contractors...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionsController.text.trim().isEmpty) return;
              erp.requestResourceClarification(req.id, questions: questionsController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  content: Text('Clarification requested for ${req.id}'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Send Clarification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
