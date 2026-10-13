import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/intern.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/trainee_mentor_dialog.dart';

/// Page 4 — Onboarding & Trainees: Manage new joiners and their trainers
/// Tracks onboarding progress, flags missed milestones, and schedules reviews.
class HrOnboardingTraineesPage extends StatefulWidget {
  const HrOnboardingTraineesPage({super.key});

  @override
  State<HrOnboardingTraineesPage> createState() => _HrOnboardingTraineesPageState();
}

class _HrOnboardingTraineesPageState extends State<HrOnboardingTraineesPage> {
  String _selectedTab = 'All'; // 'All', 'In Training', 'Review Due', 'Completed', 'Flagged'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allInterns = erp.allInterns;
    final attentionTrainees = erp.traineesNeedingAttention;

    final filteredList = allInterns.where((i) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = i.name.toLowerCase().contains(q) ||
            i.college.toLowerCase().contains(q) ||
            i.domain.toLowerCase().contains(q) ||
            (i.assignedPocName?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }

      switch (_selectedTab) {
        case 'In Training':
          return i.status == InternStatus.internshipActive || i.status == InternStatus.taskAssigned;
        case 'Review Due':
          return i.status == InternStatus.underEvaluation;
        case 'Completed':
          return i.status == InternStatus.completed ||
              i.status == InternStatus.recommendedForHiring ||
              i.status == InternStatus.hired;
        case 'Flagged':
          return i.missedUpdatesDays > 0 || i.status == InternStatus.needsImprovement;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Onboarding & Trainees',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            Row(
              children: [
                _buildSummaryStat('Active', '${erp.activeInternsCount}', const Color(0xFF10B981)),
                const SizedBox(width: 8),
                _buildSummaryStat('Review Due', '${erp.internsAwaitingEvaluationCount}', const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _buildSummaryStat('Flagged', '${attentionTrainees.length}', const Color(0xFFEF4444)),
                const SizedBox(width: 8),
                _buildSummaryStat('Completed', '${erp.internsConvertedCount}', const Color(0xFF8B5CF6)),
              ],
            ),
            const SizedBox(height: 14),

            // Search Bar
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search trainee by name, domain, or trainer...',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                filled: true,
                fillColor: const Color(0xFF2B3035),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            // Tab Switcher
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip('All', allInterns.length),
                  const SizedBox(width: 8),
                  _buildTabChip('In Training', allInterns.where((i) => i.status == InternStatus.internshipActive).length),
                  const SizedBox(width: 8),
                  _buildTabChip('Review Due', erp.internsAwaitingEvaluationCount),
                  const SizedBox(width: 8),
                  _buildTabChip('Completed', erp.internsConvertedCount),
                  const SizedBox(width: 8),
                  _buildTabChip('Flagged', attentionTrainees.length, isWarning: true),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Trainees list
            if (filteredList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.school_outlined, color: Color(0xFF475569), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No trainees found in $_selectedTab',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ...filteredList.map((intern) => _buildTraineeCard(context, intern)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int count, {bool isWarning = false}) {
    final isSelected = _selectedTab == label;
    final color = isWarning ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedTab = label);
      },
      selectedColor: color.withValues(alpha: 0.2),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? color : const Color(0xFF64748B),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? color : const Color(0xFF334155)),
    );
  }

  Widget _buildTraineeCard(BuildContext context, Intern intern) {
    final bool isFlagged = intern.missedUpdatesDays > 0 || intern.status == InternStatus.needsImprovement;
    final totalTasks = intern.totalTasks;
    final progress = totalTasks > 0 ? (intern.completedTasks / totalTasks).clamp(0.0, 1.0) : 0.4;
    final rubricAvg = intern.evaluationRubric.averageScore;

    // Display status badge mapping as per prompt:
    // Not started, In training, Review due, Completed
    String displayStatusLabel;
    Color statusColor;
    if (intern.status == InternStatus.selected || intern.status == InternStatus.applied) {
      displayStatusLabel = 'Not started';
      statusColor = const Color(0xFF64748B);
    } else if (intern.status == InternStatus.underEvaluation) {
      displayStatusLabel = 'Review due';
      statusColor = const Color(0xFFF59E0B);
    } else if (intern.status == InternStatus.completed ||
        intern.status == InternStatus.recommendedForHiring ||
        intern.status == InternStatus.hired) {
      displayStatusLabel = 'Completed';
      statusColor = const Color(0xFF10B981);
    } else {
      displayStatusLabel = 'In training';
      statusColor = const Color(0xFF38BDF8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFlagged ? const Color(0xFFEF4444).withValues(alpha: 0.4) : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, domain, status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intern.name,
                      style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${intern.college} (${intern.domain}) • Batch: ${intern.batchId}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  displayStatusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Details & Mentorship info
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
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 6),
                        Text(
                          'Trainer / Mentor: ${intern.assignedPocName ?? "Not Assigned"}',
                          style: const TextStyle(color: Color(0xFFDDD6FE), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Score: ${rubricAvg.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Training progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Onboarding Progress', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),

          // Missed milestone alert flag
          if (isFlagged) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, color: Color(0xFFEF4444), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      intern.missedUpdatesDays > 0
                          ? 'Flagged: Missed daily updates for ${intern.missedUpdatesDays} days'
                          : 'Flagged: Performance requires improvement review',
                      style: const TextStyle(color: Color(0xFFF87171), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Latest Trainer / Review notes
          if (intern.latestFeedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Trainer Feedback: "${intern.latestFeedback}"',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],

          const SizedBox(height: 12),
          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: () => _notifyTrainer(context, intern),
                icon: const Icon(Icons.notifications_active_outlined, size: 13, color: Color(0xFF38BDF8)),
                label: const Text('Notify Trainer', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _scheduleReviewMeeting(context, intern),
                icon: const Icon(Icons.event_available_rounded, size: 13, color: Color(0xFFF59E0B)),
                label: const Text('Schedule Review', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => TraineeMentorDialog.show(context, intern),
                icon: const Icon(Icons.rate_review_rounded, size: 13, color: Colors.white),
                label: const Text('Evaluate', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _notifyTrainer(BuildContext context, Intern intern) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF38BDF8),
        content: Text('Sent review & milestone reminder to ${intern.assignedPocName ?? "Department Lead"}'),
      ),
    );
  }

  void _scheduleReviewMeeting(BuildContext context, Intern intern) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Color(0xFF212529), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Review Meeting: ${intern.name}', style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trainee: ${intern.name}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 4),
              Text('Trainer / Mentor: ${intern.assignedPocName ?? "Unassigned"}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Weekly milestone sync scheduled with HR and technical POC for upcoming Friday batch review.',
                  style: TextStyle(color: Color(0xFF334155), fontSize: 12, height: 1.4),
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
            child: const Text('Confirm Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
