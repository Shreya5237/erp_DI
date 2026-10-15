import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/lead.dart';
import '../../../models/sales_call.dart';
import '../../../providers/erp_provider.dart';
import 'log_call_dialog.dart';

/// Modal bottom sheet displaying comprehensive deal/lead details and approval workflows
class DealDetailSheet extends StatelessWidget {
  final Lead lead;

  const DealDetailSheet({super.key, required this.lead});

  static void show(BuildContext context, Lead lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DealDetailSheet(lead: lead),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final currentLead = erp.allLeads.firstWhere((l) => l.id == lead.id, orElse: () => lead);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF64748B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              currentLead.companyName,
                              style: const TextStyle(
                                color: Color(0xFF212529),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE9ECEF)),
                            ),
                            child: Text(
                              currentLead.id,
                              style: const TextStyle(color: Color(0xFF495057), fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currentLead.clientName} • ${currentLead.domain}',
                        style: const TextStyle(color: Color(0xFF6C757D), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹${_formatCurrency(currentLead.dealValue)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE9ECEF), height: 16),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Current Stage & Approval Banner
                _buildStageBanner(currentLead),
                const SizedBox(height: 16),

                // Quick Contact Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.phone_rounded,
                        label: 'Call Client',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => LogCallDialog(
                              prefilledCompanyName: currentLead.companyName,
                              prefilledCustomerName: currentLead.clientName,
                              prefilledPhone: currentLead.phone,
                              leadId: currentLead.id,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.calendar_today_rounded,
                        label: 'Schedule Follow-up',
                        onTap: () => _showScheduleDialog(context, currentLead),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Feasibility & Internal Approval Status (HR & Finance)
                _buildFeasibilitySection(context, currentLead),
                const SizedBox(height: 18),

                // Deal Details & Requirements Scope
                _buildDetailsCard(currentLead),
                const SizedBox(height: 18),

                // Approval History / Activity Timeline
                if (currentLead.approvalHistory.isNotEmpty) ...[
                  const Text(
                    'Approval & Workflow History',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...currentLead.approvalHistory.map((item) => _buildHistoryTile(item)),
                  const SizedBox(height: 18),
                ],

                // Action Buttons to Forward
                _buildForwardingActions(context, currentLead),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageBanner(Lead lead) {
    Color stageColor;
    Color stageBg;
    switch (lead.status) {
      case LeadStatus.won:
        stageColor = const Color(0xFF10B981);
        stageBg = const Color(0xFFECFDF5);
        break;
      case LeadStatus.lost:
        stageColor = const Color(0xFFEF4444);
        stageBg = const Color(0xFFFEF2F2);
        break;
      default:
        stageColor = const Color(0xFF212529);
        stageBg = const Color(0xFFF1F3F5);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stageBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stageColor == const Color(0xFF212529) ? const Color(0xFFE9ECEF) : stageColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.timeline_rounded, color: stageColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pipeline Stage: ${lead.status.label}',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: stageColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Approval Status: ${lead.internalApprovalStage}',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: const Color(0xFF6C757D),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF212529), size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                color: const Color(0xFF212529),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeasibilitySection(BuildContext context, Lead lead) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: Color(0xFF212529), size: 16),
              const SizedBox(width: 8),
              Text(
                'Department Feasibility Checks',
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  color: const Color(0xFF212529),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Text(
                  lead.internalApprovalStage,
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: const Color(0xFF212529),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // HR Feasibility
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  'HR Review:',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: const Color(0xFF6C757D),
                    fontSize: 11.5,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lead.hrFeasibility.status.label} (${lead.hrFeasibility.estimatedEffortHours}h effort)',
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: const Color(0xFF212529),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      lead.hrFeasibility.resourceAvailabilityNotes,
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: const Color(0xFF6C757D),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Finance Feasibility
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  'Finance Check:',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: const Color(0xFF6C757D),
                    fontSize: 11.5,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lead.financeFeasibility.status.label} (${lead.financeFeasibility.expectedMarginPercent}% margin)',
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: const Color(0xFF212529),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      lead.financeFeasibility.budgetFeasibilityNotes,
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: const Color(0xFF6C757D),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Lead lead) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements & Contact Info',
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              color: const Color(0xFF212529),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Contact Phone', lead.phone),
          _buildInfoRow('Work Email', lead.email),
          _buildInfoRow('Lead Source', lead.source),
          _buildInfoRow('Assigned POC', lead.assignedEmployeeName),
          _buildInfoRow(
            'Next Follow-up',
            '${lead.nextFollowUpDate.day}/${lead.nextFollowUpDate.month}/${lead.nextFollowUpDate.year}',
          ),
          const SizedBox(height: 8),
          Text(
            'Requirements Scope:',
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              color: const Color(0xFF6C757D),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            lead.requirementsScope,
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              color: const Color(0xFF212529),
              fontSize: 11.5,
            ),
          ),
          if (lead.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes:',
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                color: const Color(0xFF6C757D),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              lead.notes,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                color: const Color(0xFF212529),
                fontSize: 11.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                color: const Color(0xFF6C757D),
                fontSize: 11.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                color: const Color(0xFF212529),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(LeadApprovalAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF212529)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      action.action,
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: const Color(0xFF212529),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${action.timestamp.day}/${action.timestamp.month} ${action.timestamp.hour}:${action.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: const Color(0xFF868E96),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${action.authorName} (${action.authorRole}): ${action.comments}',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: const Color(0xFF495057),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForwardingActions(BuildContext context, Lead lead) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Workflow Actions',
          style: TextStyle(
            fontFamily: GoogleFonts.instrumentSans().fontFamily,
            color: const Color(0xFF212529),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Forward to Manager
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmForwardToManager(context, lead),
                icon: const Icon(Icons.supervisor_account_rounded, size: 16),
                label: Text(
                  'Forward to Manager',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212529),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Forward to HR & Finance
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _confirmForwardToHrFinance(context, lead),
                icon: const Icon(Icons.hub_rounded, size: 16, color: Color(0xFF212529)),
                label: Text(
                  'Forward HR/Finance',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212529),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F3F5),
                  foregroundColor: const Color(0xFF212529),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFE9ECEF)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Update Stage Dropdown
        OutlinedButton.icon(
          onPressed: () => _showStageUpdateDialog(context, lead),
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          label: Text(
            'Move Pipeline Stage',
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF212529),
            side: const BorderSide(color: Color(0xFF212529)),
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  void _confirmForwardToManager(BuildContext context, Lead lead) {
    final commentCtrl = TextEditingController(
      text: 'Commercial feasibility ready. Requesting review for ${lead.companyName} deal.',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Forward to Manager', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit ${lead.companyName} (₹${_formatCurrency(lead.dealValue)}) for manager evaluation and approval.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                maxLines: 2,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add notes for manager...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<ErpProvider>().forwardLeadToManager(lead.id, comments: commentCtrl.text.trim());
              Navigator.pop(ctx);
              Navigator.pop(context); // close sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF10B981),
                  content: Text('Deal ${lead.companyName} forwarded to Manager!'),
                ),
              );
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmForwardToHrFinance(BuildContext context, Lead lead) {
    final commentCtrl = TextEditingController(
      text: 'Requesting HR technical capacity check (120h) & Finance gross margin check.',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Forward to HR & Finance', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Initiate dual-department feasibility review for ${lead.companyName}.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                maxLines: 2,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add feasibility notes...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<ErpProvider>().forwardLeadToHrFinance(lead.id, comments: commentCtrl.text.trim());
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  content: Text('Deal ${lead.companyName} forwarded to HR & Finance!'),
                ),
              );
            },
            child: const Text('Forward', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showStageUpdateDialog(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Lead Stage', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: LeadStatus.values.map((stage) {
              final isCurrent = lead.status == stage;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFF5F6F7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(
                    stage.label,
                    style: TextStyle(
                      color: isCurrent ? const Color(0xFF212529) : const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isCurrent ? const Icon(Icons.check_rounded, color: Color(0xFF212529), size: 18) : null,
                  onTap: () {
                    context.read<ErpProvider>().updateLeadStatus(lead.id, stage);
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, Lead lead) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (pickedDate != null && context.mounted) {
      context.read<ErpProvider>().logColdCall(
            customerName: lead.clientName,
            companyName: lead.companyName,
            phone: lead.phone,
            outcome: CallOutcome.followUpRequired,
            notes: 'Follow-up call rescheduled from deal card.',
            nextFollowUpDate: pickedDate,
            leadId: lead.id,
            dealValue: lead.dealValue,
          );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          content: Text('Follow-up scheduled for ${pickedDate.day}/${pickedDate.month}/${pickedDate.year}'),
        ),
      );
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
