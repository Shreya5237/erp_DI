import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/lead.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/badge_chip.dart';

/// Lead Inspection, Follow-Up & Project Conversion Dialog
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
    _projectNameController.text = '${widget.lead.companyName} Custom Solution';
    _projectDescController.text = 'Client deliverables for ${widget.lead.companyName}';
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
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BadgeChip.status(lead.status.label),
                  Text(
                    currencyFormat.format(lead.dealValue),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.statusCompleted,
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
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Contact: ${lead.clientName} • ${lead.email}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Details Card
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
              const SizedBox(height: 16),

              // Pipeline Stage Selector
              const Text(
                'Update Pipeline Stage',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LeadStatus.values.map((s) {
                  final isSelected = lead.status == s;
                  return ChoiceChip(
                    label: Text(s.label),
                    selected: isSelected,
                    selectedColor: s == LeadStatus.won
                        ? AppColors.statusCompletedLight
                        : (s == LeadStatus.lost ? AppColors.statusOverdueLight : AppColors.electricBlueLight),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                    onSelected: (val) {
                      if (val) {
                        erp.updateLeadStatus(lead.id, s);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Notes
              const Text(
                'Meeting Notes & Activity',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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

              // Convert Won Lead to Project Action
              if (lead.status == LeadStatus.won && lead.convertedProjectId == null) ...[
                if (!_isConvertingToProject) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                      label: const Text('Convert Lead to Active Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusCompleted,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _isConvertingToProject = true);
                      },
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompletedLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusCompleted.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spin Up Client Project',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.statusCompleted,
                          ),
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
                          decoration: const InputDecoration(labelText: 'Allocated Budget (\$)'),
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
                                    ownerEmployeeId: lead.assignedEmployeeId,
                                    deadline: DateTime.now().add(const Duration(days: 30)),
                                  );
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Project "${_projectNameController.text}" initialized!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCompleted),
                                child: const Text('Create Project'),
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
                    color: AppColors.statusCompletedLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: AppColors.statusCompleted),
                      SizedBox(width: 8),
                      Text(
                        'Converted to Active Client Project',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.statusCompleted),
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
