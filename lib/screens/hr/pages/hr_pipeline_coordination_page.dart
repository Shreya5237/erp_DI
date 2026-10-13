import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/hr_models.dart';
import '../../../models/lead.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/customer_change_request_dialog.dart';

/// Page 5 — Leads Pipeline & Project Coordination
/// HR's involvement in deals, customer feedback, and post-deal coordination.
class HrPipelineCoordinationPage extends StatefulWidget {
  const HrPipelineCoordinationPage({super.key});

  @override
  State<HrPipelineCoordinationPage> createState() => _HrPipelineCoordinationPageState();
}

class _HrPipelineCoordinationPageState extends State<HrPipelineCoordinationPage> {
  int _currentTabIndex = 0; // 0: Finalized Deals & Staffing, 1: Change Requests & Customer Feedback

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final leads = erp.allLeads;
    final finalizedDeals = leads.where((l) => l.status == LeadStatus.won || l.status == LeadStatus.proposalPrepared || l.dealValue > 200000).toList();
    final allChangeRequests = erp.allCustomerChangeRequests;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Pipeline & Project Coordination',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, color: Color(0xFFF97316)),
            tooltip: 'Record Customer Feedback',
            onPressed: () => CustomerChangeRequestDialog.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Important Notice Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF06B6D4), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Once a deal is finalized, HR coordinates people and communication. Technical feasibility, project scope, delivery commitments, and budget changes must be reviewed by the appropriate PM or Finance.',
                      style: TextStyle(color: Color(0xFFBAE6FD), fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab Buttons
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentTabIndex = 0),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _currentTabIndex == 0 ? const Color(0xFF8B5CF6) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Deals & Staffing (${finalizedDeals.length})',
                          style: TextStyle(
                            color: _currentTabIndex == 0 ? Colors.white : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentTabIndex = 1),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _currentTabIndex == 1 ? const Color(0xFFF97316) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Customer Changes (${allChangeRequests.length})',
                          style: TextStyle(
                            color: _currentTabIndex == 1 ? Colors.white : const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (_currentTabIndex == 0) ...[
              // Section 1: Finalized Deals & Staffing Requirements
              ...finalizedDeals.map((lead) => _buildDealCoordinationCard(context, erp, lead)),
            ] else ...[
              // Section 2: Customer Change Requests & Feedback Tracker
              ...allChangeRequests.map((req) => _buildChangeRequestCard(context, erp, req)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDealCoordinationCard(BuildContext context, ErpProvider erp, Lead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Company, Value, Deal Stage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.companyName,
                      style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Scope: ${lead.requirementsScope.isNotEmpty ? lead.requirementsScope : lead.domain} • Client: ${lead.clientName}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Finalized Deal',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Details grid
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deal Value: ₹${(lead.dealValue / 100000).toStringAsFixed(1)}L',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Contact: ${lead.phone}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, size: 14, color: Color(0xFFA78BFA)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'HR Staffing Requirement: 2 Mobile Devs, 1 QA Engineer',
                        style: const TextStyle(color: Color(0xFFDDD6FE), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Coordination Actions
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  CustomerChangeRequestDialog.show(context, lead: lead);
                },
                icon: const Icon(Icons.feedback_outlined, size: 14, color: Color(0xFFF97316)),
                label: const Text('Record Customer Request', style: TextStyle(color: Color(0xFFF97316), fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF97316)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showStaffingCoordination(context, lead),
                icon: const Icon(Icons.assignment_ind_rounded, size: 14, color: Colors.white),
                label: const Text('Staffing Status', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeRequestCard(BuildContext context, ErpProvider erp, CustomerChangeRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: req.isEscalated ? const Color(0xFFEF4444).withValues(alpha: 0.5) : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Company, feedback type, status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        req.companyName,
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      if (req.isEscalated) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Escalated', style: TextStyle(color: Color(0xFFEF4444), fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Client: ${req.clientName} • Forwarded to: ${req.forwardedToRole}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: req.status.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  req.status.label,
                  style: TextStyle(color: req.status.color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Request Description & Communication History
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requirement / Feedback: "${req.description}"',
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Follow-up: ${req.followUpDate.day}/${req.followUpDate.month}/${req.followUpDate.year}',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Logged: ${req.createdDate.day}/${req.createdDate.month}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                    ),
                  ],
                ),
                if (req.resolutionNotes != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Lead Response: ${req.resolutionNotes}',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Status & Resolution buttons
          Row(
            children: [
              if (!req.isEscalated && req.status != CustomerRequestStatus.completed)
                OutlinedButton(
                  onPressed: () {
                    erp.resolveCustomerChangeRequest(
                      req.id,
                      resolutionNotes: 'Escalated by HR to executive leadership for expedited customer resolution.',
                      status: CustomerRequestStatus.escalated,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: const Color(0xFFEF4444), content: Text('Escalated request ${req.id}')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text('Escalate', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
                ),
              const Spacer(),
              if (req.status != CustomerRequestStatus.completed) ...[
                OutlinedButton(
                  onPressed: () => _forwardRequestDialog(context, erp, req),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text('Forward', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _resolveRequestDialog(context, erp, req),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Mark Resolved', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showStaffingCoordination(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Staffing Sync: ${lead.companyName}', style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Domain: ${lead.domain}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'HR staffing checklist:\n• Lead Architect confirmed\n• 2 Developers assigned from Bench\n• Onboarding sync with customer team planned.',
                  style: TextStyle(color: Color(0xFF334155), fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _forwardRequestDialog(BuildContext context, ErpProvider erp, CustomerChangeRequest req) {
    String selectedRole = req.forwardedToRole;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Forward Request ${req.id}', style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Forward To:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: 'Project Manager', child: Text('Project Manager', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                  DropdownMenuItem(value: 'Tech Lead', child: Text('Tech Lead', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                  DropdownMenuItem(value: 'Finance Lead', child: Text('Finance Lead', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                ],
                onChanged: (v) {
                  if (v != null) selectedRole = v;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Notes for recipient...',
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () {
              erp.forwardCustomerChangeRequest(
                req.id,
                forwardedToRole: selectedRole,
                notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : 'Forwarded for technical/financial review.',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: const Color(0xFF212529), content: Text('Forwarded to $selectedRole')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Forward', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _resolveRequestDialog(BuildContext context, ErpProvider erp, CustomerChangeRequest req) {
    final notesController = TextEditingController(text: 'Customer changes reviewed and incorporated into project backlog.');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Resolve Request ${req.id}', style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Resolution Notes:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                maxLines: 2,
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () {
              erp.resolveCustomerChangeRequest(
                req.id,
                resolutionNotes: notesController.text.trim(),
                status: CustomerRequestStatus.completed,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Change request marked as Completed')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Mark Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
