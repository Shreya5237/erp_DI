import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/approval.dart';

/// Executive Approvals Management Screen adhering to Section 4.5 & 9.5 of the ERP PRD
class ApprovalsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ApprovalsScreen({super.key, this.onBack});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allRequests = erp.allApprovalRequests;
    final filtered = allRequests.where((a) {
      if (_statusFilter == 'All') return true;
      if (_statusFilter == 'Pending' && a.isAwaitingExecutiveAction) return true;
      if (_statusFilter == 'Approved' && a.status == ApprovalStatus.approved) return true;
      if (_statusFilter == 'Changes' && a.status == ApprovalStatus.changesRequested) return true;
      if (_statusFilter == 'Rejected' && a.status == ApprovalStatus.rejected) return true;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF212529), size: 18),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: const Text(
          'Internal Approval Hub',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workflow Indicator Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Multi-Tier Approval Cycle',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Sales Submission ➔ GM / MD Feasibility Review ➔ CEO Final Decision ➔ Sales Confirmation',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Approved', 'Changes', 'Rejected'].map((status) {
                  final isSelected = _statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: const Color(0xFF212529),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _statusFilter = status),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            if (filtered.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No approval requests in this category.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ),
              ),
            ] else ...[
              ...filtered.map((req) => _buildApprovalDetailCard(context, erp, req)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalDetailCard(BuildContext context, ErpProvider erp, CompanyApprovalRequest req) {
    Color statusColor;
    switch (req.status) {
      case ApprovalStatus.approved:
        statusColor = const Color(0xFF16A34A);
        break;
      case ApprovalStatus.rejected:
        statusColor = const Color(0xFFDC2626);
        break;
      case ApprovalStatus.changesRequested:
        statusColor = const Color(0xFFD97706);
        break;
      default:
        statusColor = const Color(0xFF2563EB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  req.status.label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
              Text(
                '₹${req.dealValueOrBudget.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            req.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
          ),
          const SizedBox(height: 4),
          Text(
            'Dept: ${req.submittingDepartment} • Submitted by ${req.submittedByName} (${req.submittedByRole})',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Text(
            req.summary,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
          ),
          if (req.reviewNotes != null && req.reviewNotes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.comment_outlined, size: 14, color: Color(0xFF475569)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Review Notes: ${req.reviewNotes}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (req.isAwaitingExecutiveAction) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDecisionDialog(context, erp, req.id, isRework: true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Request Changes', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      erp.approveApprovalRequest(req.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Proposal "${req.title}" officially approved!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: const Color(0xFF212529),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Approve Proposal', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showDecisionDialog(BuildContext context, ErpProvider erp, String reqId, {required bool isRework}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isRework ? 'Request Modifications' : 'Reject Deal',
          style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter specific feedback for the sales/proposal team...',
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
}
