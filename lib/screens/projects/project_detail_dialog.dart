import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/project.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/badge_chip.dart';

/// Project Inspector with Milestones and Blocker Resolver
class ProjectDetailDialog extends StatefulWidget {
  final Project project;

  const ProjectDetailDialog({super.key, required this.project});

  @override
  State<ProjectDetailDialog> createState() => _ProjectDetailDialogState();
}

class _ProjectDetailDialogState extends State<ProjectDetailDialog> {
  final _newBlockerController = TextEditingController();
  bool _isAddingBlocker = false;

  @override
  void dispose() {
    _newBlockerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final proj = erp.allProjects.firstWhere(
      (p) => p.id == widget.project.id,
      orElse: () => widget.project,
    );
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
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
                  BadgeChip.status(proj.status.label),
                  Text(
                    'Budget: ${currencyFormat.format(proj.budget)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
                proj.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Client: ${proj.clientName} • Lead: ${proj.ownerEmployeeName}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                proj.description,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 16),

              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Overall Deliverable Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    '${(proj.progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.electricBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: proj.progress,
                minHeight: 8,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  proj.hasBlockers ? AppColors.statusOverdue : AppColors.electricBlue,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 18),

              // Timeline & Team Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMeta('Target Delivery Deadline', dateFormat.format(proj.deadline)),
                    const Divider(height: 14, color: AppColors.borderLight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Assigned Team & Lead',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                        InkWell(
                          onTap: () => _showEditTeamDialog(context, proj),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined, size: 13, color: AppColors.electricBlue),
                                SizedBox(width: 4),
                                Text(
                                  'Reassign / Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.electricBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        // Lead badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '${proj.ownerEmployeeName} (Lead)',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Other members
                        ...proj.teamMemberNames
                            .where((m) => m != proj.ownerEmployeeName)
                            .map((m) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Text(
                                    m,
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                                  ),
                                )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Active Blockers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: proj.hasBlockers ? AppColors.statusOverdue : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Project Blockers (${proj.activeBlockers.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: proj.hasBlockers ? AppColors.statusOverdue : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      _isAddingBlocker ? Icons.close : Icons.add_circle_outline,
                      size: 20,
                      color: AppColors.statusOverdue,
                    ),
                    onPressed: () {
                      setState(() => _isAddingBlocker = !_isAddingBlocker);
                    },
                  ),
                ],
              ),
              if (_isAddingBlocker) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusOverdueLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newBlockerController,
                          decoration: const InputDecoration(
                            hintText: 'Enter blocker detail...',
                            isDense: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_newBlockerController.text.trim().isEmpty) return;
                          erp.addProjectBlocker(proj.id, _newBlockerController.text.trim());
                          _newBlockerController.clear();
                          setState(() => _isAddingBlocker = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusOverdue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (proj.activeBlockers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'No active blockers reported. Development on schedule.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.statusCompleted),
                  ),
                )
              else
                ...proj.activeBlockers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final blocker = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.statusOverdueLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.statusOverdue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            blocker,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.statusOverdue),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            erp.resolveProjectBlocker(proj.id, idx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Blocker marked as resolved!')),
                            );
                          },
                          child: const Text('Resolve', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 18),

              // Milestones Checklist
              const Text(
                'Milestones & Deliverables',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...proj.milestones.map((m) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: m.isCompleted,
                  title: Text(
                    m.title,
                    style: TextStyle(
                      fontSize: 13,
                      decoration: m.isCompleted ? TextDecoration.lineThrough : null,
                      color: m.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text('Due: ${dateFormat.format(m.dueDate)}', style: const TextStyle(fontSize: 11)),
                  onChanged: (val) {
                    erp.toggleProjectMilestone(proj.id, m.id);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeta(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  void _showEditTeamDialog(BuildContext context, Project proj) {
    final erp = context.read<ErpProvider>();
    String selectedLeadId = proj.ownerEmployeeId;
    final currentMembers = List<String>.from(proj.teamMemberNames);

    final candidatePool = <String>[
      ...erp.allEmployees.map((e) => e.name),
      ...erp.allInterns.map((i) => '${i.name} (Intern)'),
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Project Team',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Reassign Team Lead
                      const Text(
                        'Project Team Lead',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: erp.allEmployees.any((e) => e.id == selectedLeadId) ? selectedLeadId : erp.allEmployees.first.id,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.star, size: 18, color: Colors.amber),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: erp.allEmployees.map((e) {
                          return DropdownMenuItem(
                            value: e.id,
                            child: Text(
                              '${e.name} • ${e.role}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final emp = erp.allEmployees.firstWhere((e) => e.id == val);
                            setDialogState(() {
                              selectedLeadId = val;
                              if (!currentMembers.contains(emp.name)) {
                                currentMembers.insert(0, emp.name);
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Manage Team Members
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assigned Members (${currentMembers.length})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Add Member',
                            icon: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_add_alt_1, size: 16, color: Color(0xFF2563EB)),
                                SizedBox(width: 4),
                                Text(
                                  '+ Add',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                            onSelected: (name) {
                              if (!currentMembers.contains(name)) {
                                setDialogState(() => currentMembers.add(name));
                              }
                            },
                            itemBuilder: (context) {
                              return candidatePool
                                  .where((c) => !currentMembers.contains(c))
                                  .map((c) => PopupMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12.5))))
                                  .toList();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: currentMembers.map((m) {
                          final isLead = erp.allEmployees.any((e) => e.id == selectedLeadId && e.name == m);
                          return Chip(
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: isLead ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            label: Text(
                              isLead ? '$m (Lead)' : m,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isLead ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                            deleteIcon: isLead ? null : const Icon(Icons.close, size: 14, color: Color(0xFF64748B)),
                            onDeleted: isLead
                                ? null
                                : () {
                                    setDialogState(() => currentMembers.remove(m));
                                  },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            erp.updateProjectTeam(
                              projectId: proj.id,
                              ownerEmployeeId: selectedLeadId,
                              teamMemberNames: currentMembers,
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                          child: const Text('Save Team Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
