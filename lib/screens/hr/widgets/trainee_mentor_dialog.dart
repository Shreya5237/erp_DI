import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/intern.dart';
import '../../../providers/erp_provider.dart';

/// Modal dialog for assigning trainer/mentor to a trainee and recording evaluation rubric
class TraineeMentorDialog extends StatefulWidget {
  final Intern intern;

  const TraineeMentorDialog({super.key, required this.intern});

  static Future<void> show(BuildContext context, Intern intern) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TraineeMentorDialog(intern: intern),
    );
  }

  @override
  State<TraineeMentorDialog> createState() => _TraineeMentorDialogState();
}

class _TraineeMentorDialogState extends State<TraineeMentorDialog> {
  late String? _selectedMentorId;
  late String? _selectedMentorName;
  late double _taskQuality;
  late double _consistency;
  late double _interest;
  late double _learningProgress;
  late double _communication;
  late InternStatus _selectedStatus;
  late TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    _selectedMentorId = widget.intern.assignedPocId;
    _selectedMentorName = widget.intern.assignedPocName;
    _taskQuality = widget.intern.evaluationRubric.taskQuality;
    _consistency = widget.intern.evaluationRubric.consistency;
    _interest = widget.intern.evaluationRubric.interest;
    _learningProgress = widget.intern.evaluationRubric.learningProgress;
    _communication = widget.intern.evaluationRubric.communication;
    _selectedStatus = widget.intern.status;
    _feedbackController = TextEditingController(text: widget.intern.latestFeedback);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  double get _currentAverage =>
      (_taskQuality + _consistency + _interest + _learningProgress + _communication) / 5.0;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allEmployees = erp.allEmployees;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school_rounded, color: Color(0xFF212529), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trainee Mentorship & Evaluation',
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.intern.name} • ${widget.intern.college} (${widget.intern.domain})',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Color(0xFFE2E8F0), height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Assigned Mentor / Trainer
                    const Text(
                      'Assigned Trainer / POC Mentor',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMentorId,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          hint: const Text('Select mentor from technical team', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                          items: allEmployees.map((emp) {
                            return DropdownMenuItem<String>(
                              value: emp.id,
                              child: Text(
                                '${emp.name} (${emp.role} - ${emp.department})',
                                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (empId) {
                            if (empId != null) {
                              final emp = allEmployees.firstWhere((e) => e.id == empId);
                              setState(() {
                                _selectedMentorId = emp.id;
                                _selectedMentorName = emp.name;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Status
                    const Text(
                      'Trainee Training Status',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<InternStatus>(
                          value: _selectedStatus,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(value: InternStatus.selected, child: Text('Not Started / Selected', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: InternStatus.internshipActive, child: Text('In Training (Active)', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: InternStatus.underEvaluation, child: Text('Review Due (Under Evaluation)', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: InternStatus.goodPerformance, child: Text('Good Performance', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: InternStatus.needsImprovement, child: Text('Needs Improvement (Flagged)', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: InternStatus.recommendedForHiring, child: Text('Completed (Recommended for Hire)', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: InternStatus.completed, child: Text('Completed Training', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 3: Evaluation Rubric Scores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Evaluation Rubric (1.0 to 5.0)',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Text(
                            'Avg: ${_currentAverage.toStringAsFixed(1)} / 5.0',
                            style: const TextStyle(color: Color(0xFF10B981), fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _buildScoreSlider('Task Quality', _taskQuality, (v) => setState(() => _taskQuality = v)),
                    _buildScoreSlider('Consistency', _consistency, (v) => setState(() => _consistency = v)),
                    _buildScoreSlider('Interest / Passion', _interest, (v) => setState(() => _interest = v)),
                    _buildScoreSlider('Learning Progress', _learningProgress, (v) => setState(() => _learningProgress = v)),
                    _buildScoreSlider('Communication', _communication, (v) => setState(() => _communication = v)),
                    const SizedBox(height: 14),

                    // Section 4: Trainer / HR Feedback Notes
                    const Text(
                      'Milestone Feedback & Notes',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _feedbackController,
                      style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Record trainee evaluation comments, milestone remarks...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFFF5F6F7),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF212529))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedMentorId != null && _selectedMentorName != null) {
                        erp.assignTraineeMentor(
                          widget.intern.id,
                          mentorId: _selectedMentorId!,
                          mentorName: _selectedMentorName!,
                        );
                      }
                      final rubric = InternEvaluationRubric(
                        taskQuality: _taskQuality,
                        consistency: _consistency,
                        interest: _interest,
                        learningProgress: _learningProgress,
                        communication: _communication,
                      );
                      erp.updateTraineeEvaluation(
                        widget.intern.id,
                        rubric: rubric,
                        feedback: _feedbackController.text.trim(),
                        status: _selectedStatus,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text('Updated evaluation and mentorship for ${widget.intern.name}'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212529),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Save & Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSlider(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF212529),
                inactiveTrackColor: const Color(0xFFE2E8F0),
                thumbColor: const Color(0xFF212529),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
