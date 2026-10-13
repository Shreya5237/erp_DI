import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/task.dart';
import '../../models/user_role.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/badge_chip.dart';

/// Interactive Task Inspector and CEO Review Dialog
class TaskDetailDialog extends StatefulWidget {
  final CompanyTask task;

  const TaskDetailDialog({super.key, required this.task});

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final _reviewNotesController = TextEditingController();
  final _submissionNotesController = TextEditingController();
  final _proofUrlController = TextEditingController();

  @override
  void dispose() {
    _reviewNotesController.dispose();
    _submissionNotesController.dispose();
    _proofUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final task = erp.allTasks.firstWhere((t) => t.id == widget.task.id, orElse: () => widget.task);
    final isCeo = erp.currentRole == UserRole.ceo;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Status and Priority
              Row(
                children: [
                  BadgeChip.status(task.status.label),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Priority: ${task.priority.label}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Metadata Grid
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildMetaRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Assignee',
                      value: '${task.assignedToName} (${task.assigneeType.label})',
                    ),
                    const Divider(height: 14, color: AppColors.borderLight),
                    _buildMetaRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Deadline',
                      value: dateFormat.format(task.dueDate),
                      valueColor: task.isOverdue ? AppColors.statusOverdue : AppColors.textPrimary,
                    ),
                    if (task.projectName != null) ...[
                      const Divider(height: 14, color: AppColors.borderLight),
                      _buildMetaRow(
                        icon: Icons.folder_open_outlined,
                        label: 'Project',
                        value: task.projectName!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Completion Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${task.progressPercent}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.electricBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: task.progressPercent / 100,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  task.progressPercent == 100
                      ? AppColors.statusCompleted
                      : AppColors.electricBlue,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 18),

              // Submission Details if Available
              if (task.submissionNotes.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.statusReviewLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.statusReview.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assignment_turned_in, size: 16, color: AppColors.statusReview),
                          SizedBox(width: 6),
                          Text(
                            'Submission Details (Ready for Review)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.statusReview,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.submissionNotes,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                      if (task.submissionProofUrl != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Deliverable URL: ${task.submissionProofUrl}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.electricBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // CEO Review Decision Section (if CEO and status is submitted or needing review)
              if (isCeo && (task.status == TaskStatus.submitted || task.status == TaskStatus.inProgress || task.isOverdue)) ...[
                const Text(
                  'CEO Executive Decision',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewNotesController,
                  decoration: const InputDecoration(
                    hintText: 'Enter feedback note or review comments...',
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.statusOverdue),
                        label: const Text('Request Rework', style: TextStyle(color: AppColors.statusOverdue, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.statusOverdue),
                        ),
                        onPressed: () {
                          erp.reviewTask(
                            taskId: task.id,
                            approve: false,
                            ceoNotes: _reviewNotesController.text.trim().isEmpty
                                ? 'Needs correction based on CEO review.'
                                : _reviewNotesController.text.trim(),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Approve & Sign-Off', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusCompleted,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          erp.reviewTask(
                            taskId: task.id,
                            approve: true,
                            ceoNotes: _reviewNotesController.text.trim().isEmpty
                                ? 'Approved by CEO Laven Lokesh'
                                : _reviewNotesController.text.trim(),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],

              // Worker / Intern Submission Option (if not approved and user is assigned or POC)
              if (!isCeo && task.status != TaskStatus.approved) ...[
                const Text(
                  'Submit Deliverable for Review',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _submissionNotesController,
                  decoration: const InputDecoration(
                    hintText: 'Describe work completed...',
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _proofUrlController,
                  decoration: const InputDecoration(
                    hintText: 'GitHub PR or Figma link (optional)',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_submissionNotesController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please describe the work completed.')),
                        );
                        return;
                      }
                      erp.submitTaskForReview(
                        task.id,
                        _submissionNotesController.text.trim(),
                        _proofUrlController.text.trim().isEmpty ? null : _proofUrlController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                    ),
                    child: const Text('Submit to POC / CEO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
