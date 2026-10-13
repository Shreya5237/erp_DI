import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/lead.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/badge_chip.dart';

/// Lead Inspection, Feasibility Assessment, Approval & Project Conversion Dialog
/// Adheres directly to Section 4.4, 4.5 & 4.6 of the ERP PRD
class LeadDetailDialog extends StatefulWidget {
  final Lead lead;

  const LeadDetailDialog({super.key, required this.lead});

  @override
  State<LeadDetailDialog> createState() => _LeadDetailDialogState();
}

class _LeadDetailDialogState extends State<LeadDetailDialog> {
  final _notesController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _projectDescController = TextEditingController();
  final _projectBudgetController = TextEditingController();
  bool _isConvertingToProject = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.lead.notes;
    _projectNameController.text = '${widget.lead.companyName} Solution';
    _projectDescController.text = widget.lead.requirementsScope;
    _projectBudgetController.text = widget.lead.dealValue.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _projectNameController.dispose();
    _projectDescController.dispose();
    _projectBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final lead = erp.allLeads.firstWhere((l) => l.id == widget.lead.id, orElse: () => widget.lead);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BadgeChip(
                    label: lead.status.label,
                    backgroundColor: AppColors.electricBlue.withOpacity(0.12),
                    textColor: AppColors.electricBlue,
                  ),
                  Text(
                    '₹${lead.dealValue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                lead.companyName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Contact: ${lead.clientName} • ${lead.email}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Details Meta Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildMeta('Business Dev Owner', lead.assignedEmployeeName),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildMeta('Source', lead.source),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildMeta('Phone', lead.phone),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildMeta(
                      'Next Follow-Up',
                      dateFormat.format(lead.nextFollowUpDate),
                      color: lead.needsAttentionToday ? AppColors.statusOverdue : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // SECTION 4.4: FEASIBILITY ASSESSMENT (HR & FINANCE)
              _buildFeasibilitySection(context, erp, lead),
              const SizedBox(height: 18),

              // SECTION 4.5: MULTI-TIER INTERNAL APPROVAL
              _buildApprovalWorkflowSection(context, erp, lead),
              const SizedBox(height: 18),

              // 12-Stage Pipeline Stage Selector
              const Text(
                'Update Pipeline Stage (12 Stages)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: LeadStatus.values.map((s) {
                  final isSelected = lead.status == s;
                  return ChoiceChip(
                    label: Text(s.label),
                    selected: isSelected,
                    selectedColor: const Color(0xFF212529),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                    onSelected: (val) async {
                      if (val) {
                        try {
                          await erp.updateLeadStatus(lead.id, s);
                          if (context.mounted && erp.isLiveMode) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF059669),
                                content: Text('Live DB: Stage updated to ${s.label}'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFFDC2626),
                                content: Text(
                                  'Stage update failed: ${e.toString().replaceFirst("ApiException (HTTP 403): ", "").replaceFirst("Exception: ", "")}',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Notes & Interactions
              const Text(
                'Meeting Notes & Requirements',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Add conversation notes, client requirements...',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 18),

              // SECTION 4.6: CLIENT CONFIRMATION & SPIN UP PROJECT
              if ((lead.status == LeadStatus.won || lead.status == LeadStatus.clientDecision) &&
                  lead.convertedProjectId == null) ...[
                if (!_isConvertingToProject) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rocket_launch_rounded, size: 18, color: Colors.white),
                      label: const Text('Confirm Deal & Spin Up Project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(() => _isConvertingToProject = true),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spin Up Confirmed Project',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _projectNameController,
                          decoration: const InputDecoration(labelText: 'Project Name'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _projectBudgetController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Approved Budget (₹)'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _isConvertingToProject = false),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final budget = double.tryParse(_projectBudgetController.text.trim()) ?? lead.dealValue;
                                  erp.convertLeadToProject(
                                    leadId: lead.id,
                                    projectName: _projectNameController.text.trim(),
                                    description: _projectDescController.text.trim(),
                                    budget: budget,
                                    ownerEmployeeId: 'EMP-101', // Arjun Sharma (Tech Lead)
                                    deadline: DateTime.now().add(const Duration(days: 45)),
                                  );
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Project "${_projectNameController.text}" initialized!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF212529)),
                                child: const Text('Create Project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ] else if (lead.convertedProjectId != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Text(
                        'Active Client Project #${lead.convertedProjectId}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeasibilitySection(BuildContext context, ErpProvider erp, Lead lead) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Department Feasibility Report',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: lead.isFeasibilityPending ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  lead.isFeasibilityPending ? 'Reviews Pending' : 'Feasibility Approved',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: lead.isFeasibilityPending ? const Color(0xFFB45309) : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // HR Assessment Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_outline_rounded, size: 16, color: Color(0xFF0284C7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HR Feasibility: ${lead.hrFeasibility.status.label}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                      ),
                      Text(
                        '${lead.hrFeasibility.estimatedEffortHours}h effort • ${lead.hrFeasibility.resourceAvailabilityNotes}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (lead.hrFeasibility.status != FeasibilityStatus.completed)
                  TextButton(
                    onPressed: () {
                      erp.submitHrFeasibility(
                        lead.id,
                        skills: ['Flutter', 'Spring Boot', 'UI/UX'],
                        hours: 120,
                        notes: 'Engineering capacity verified.',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('HR Feasibility approved!')));
                    },
                    child: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Finance Assessment Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFF16A34A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finance Feasibility: ${lead.financeFeasibility.status.label}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                      ),
                      Text(
                        'Margin: ${lead.financeFeasibility.expectedMarginPercent.toStringAsFixed(0)}% • ${lead.financeFeasibility.paymentTerms}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (lead.financeFeasibility.status != FeasibilityStatus.completed)
                  TextButton(
                    onPressed: () {
                      erp.submitFinanceFeasibility(
                        lead.id,
                        cost: lead.dealValue * 0.6,
                        price: lead.dealValue,
                        margin: 40.0,
                        paymentTerms: '30% Advance, 70% Delivery',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Finance Feasibility approved!')));
                    },
                    child: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalWorkflowSection(BuildContext context, ErpProvider erp, Lead lead) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Internal Approval Flow',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  lead.internalApprovalStage,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Sales ➔ GM / MD Review ➔ CEO Final Decision ➔ Sales Confirmation',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          if (lead.internalApprovalStage == 'Draft')
            ElevatedButton(
              onPressed: () {
                erp.submitLeadForInternalApproval(lead.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Submitted proposal for GM & CEO review!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212529),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Submit for Executive Approval', style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _buildMeta(String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
