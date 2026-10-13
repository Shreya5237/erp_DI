import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/hierarchy.dart';
import '../../models/intern.dart';
import '../../models/task.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/badge_chip.dart';
import '../tasks/task_detail_dialog.dart';

/// Intern Profile, Mentorship & Final Hiring Decision Dialog
class InternDetailDialog extends StatefulWidget {
  final Intern intern;

  const InternDetailDialog({super.key, required this.intern});

  @override
  State<InternDetailDialog> createState() => _InternDetailDialogState();
}

class _InternDetailDialogState extends State<InternDetailDialog> {
  late double _rating;
  final _feedbackController = TextEditingController();
  final _quickTaskTitleController = TextEditingController();
  bool _isAssigningTask = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.intern.performanceRating;
    _feedbackController.text = widget.intern.latestFeedback;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _quickTaskTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final intern = erp.allInterns.firstWhere(
      (i) => i.id == widget.intern.id,
      orElse: () => widget.intern,
    );
    final pocs = erp.allEmployees.where((e) => e.isPOC).toList();
    final internTasks = erp.allTasks.where((t) => t.assignedToId == intern.id).toList();
    final dateFormat = DateFormat('MMM d, yyyy');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.electricBlueLight,
                    child: Text(
                      intern.name.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          intern.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${intern.domain} • ${intern.college}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BadgeChip.status(intern.finalDecision.label),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Batch & Selection Details Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Weekly Intake Batch', intern.batchName),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildInfoRow(
                      'Interview Score',
                      '${intern.interviewScore} / 10.0',
                      highlightColor: AppColors.electricBlue,
                    ),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildInfoRow(
                      'Selection Date',
                      dateFormat.format(intern.selectionDate),
                    ),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildInfoRow(
                      'Tasks Completed',
                      '${intern.completedTasks} of ${intern.totalTasks} Done',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Mentor / POC Assignment Dropdown
              const Text(
                'Assigned Mentor / POC',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: intern.assignedPocId,
                    hint: const Text('Assign Point of Contact (POC)'),
                    items: pocs.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.id,
                        child: Text('${e.name} (${e.role})'),
                      );
                    }).toList(),
                    onChanged: (newPocId) {
                      if (newPocId != null) {
                        erp.updateInternPoc(intern.id, newPocId);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Performance Rating & Feedback (CEO or Mentor updates)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Performance & Evaluation',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${_rating.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: _rating,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                activeColor: _rating < 3.0 ? AppColors.statusOverdue : AppColors.statusCompleted,
                onChanged: (val) {
                  setState(() => _rating = val);
                },
              ),
              TextField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  hintText: 'Enter observation, code quality, or discipline notes...',
                  isDense: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.save_outlined, size: 15),
                  label: const Text('Save Feedback', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    erp.addInternFeedback(
                      intern.id,
                      _rating,
                      _feedbackController.text.trim(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Performance feedback saved.')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Final Decision Selector (CEO Executive Power)
              const Text(
                'Final Hiring / Retention Decision',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: InternFinalDecision.values.map((decision) {
                  final isSelected = intern.finalDecision == decision;
                  return ChoiceChip(
                    label: Text(decision.label),
                    selected: isSelected,
                    selectedColor: decision == InternFinalDecision.retain
                        ? AppColors.statusCompletedLight
                        : (decision == InternFinalDecision.reject
                            ? AppColors.statusOverdueLight
                            : AppColors.backgroundLight),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (decision == InternFinalDecision.retain
                              ? AppColors.statusCompleted
                              : (decision == InternFinalDecision.reject
                                  ? AppColors.statusOverdue
                                  : AppColors.textPrimary))
                          : AppColors.textSecondary,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        erp.updateInternDecision(intern.id, decision);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              if (intern.status != InternStatus.hired && intern.finalDecision != InternFinalDecision.hired) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16, color: Colors.white),
                    label: const Text('Convert to Permanent Employee', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212529),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      erp.convertInternToEmployee(
                        intern.id,
                        role: '${intern.domain} Developer',
                        department: intern.category == RoleCategory.technical ? 'Technology and Engineering' : 'Sales and Business Development',
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('🎉 Congratulations! ${intern.name} successfully appointed as employee!')),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Assigned Tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assigned Tasks (${internTasks.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isAssigningTask ? Icons.close : Icons.add_circle_outline,
                      size: 20,
                      color: AppColors.electricBlue,
                    ),
                    onPressed: () {
                      setState(() => _isAssigningTask = !_isAssigningTask);
                    },
                  ),
                ],
              ),
              if (_isAssigningTask) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlueLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _quickTaskTitleController,
                        decoration: const InputDecoration(
                          hintText: 'Task Title (e.g. Build API test suite)',
                          isDense: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_quickTaskTitleController.text.trim().isEmpty) return;
                            erp.createTask(
                              title: _quickTaskTitleController.text.trim(),
                              description: 'Assignment assigned to intern ${intern.name}',
                              domain: intern.domain,
                              assignedToId: intern.id,
                              assignedToName: intern.name,
                              assigneeType: AssigneeType.intern,
                              dueDate: DateTime.now().add(const Duration(days: 3)),
                              priority: TaskPriority.high,
                            );
                            _quickTaskTitleController.clear();
                            setState(() => _isAssigningTask = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text('Assign to Intern', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              ...internTasks.map((t) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('Due: ${dateFormat.format(t.dueDate)} • ${t.progressPercent}%', style: const TextStyle(fontSize: 11)),
                    trailing: BadgeChip.status(t.status.label),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => TaskDetailDialog(task: t),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: highlightColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
