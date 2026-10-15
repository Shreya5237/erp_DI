import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/task.dart';
import '../../../models/project.dart';
import '../../../providers/erp_provider.dart';

/// Interactive Slide-Up Task Detail Overlay Modal (matching Image 2 & specification)
/// Contains:
/// - Project Name & Team Lead
/// - Your Role (e.g., Lead Designer, UX Strategist)
/// - Deadline Date & Time
/// - Task Description: Brief overview of requirements
/// - Submit / Complete Task Button: Marks task done and updates status instantly on dashboard
class EmployeeTaskDetailModal extends StatelessWidget {
  final CompanyTask task;

  const EmployeeTaskDetailModal({super.key, required this.task});

  static Future<void> show(BuildContext context, CompanyTask task) {
    final erp = Provider.of<ErpProvider>(context, listen: false);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider<ErpProvider>.value(
        value: erp,
        child: EmployeeTaskDetailModal(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    // Get live updated task instance from provider
    final liveTask = erp.allTasks.firstWhere((t) => t.id == task.id, orElse: () => task);
    final employee = erp.currentEmployee;

    final dateFormat = DateFormat('EEE, MMM d • h:mm a');
    final isDone = liveTask.isCompleted;

    final teamLeadName = liveTask.assignedByName.isNotEmpty
        ? liveTask.assignedByName
        : (employee?.reportingManager.isNotEmpty == true
            ? employee!.reportingManager
            : 'Nina Bose');

    final projectName = (liveTask.projectName != null && liveTask.projectName!.isNotEmpty)
        ? liveTask.projectName!
        : 'Design System';

    // Find project progress if available
    final project = erp.allProjects.firstWhere(
      (p) => p.name.toLowerCase() == projectName.toLowerCase() || p.id == liveTask.projectId,
      orElse: () => Project(
        id: 'PRJ-DS',
        name: projectName,
        description: 'A shared component library for consistent product experiences.',
        clientName: 'Digital Inertia',
        ownerEmployeeId: 'EMP-001',
        ownerEmployeeName: teamLeadName,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        deadline: DateTime.now().add(const Duration(days: 45)),
        status: ProjectStatus.inProgress,
        progress: 0.34,
        budget: 500000,
        domain: 'Design System',
      ),
    );

    final assignedRole = employee?.role.isNotEmpty == true ? employee!.role : 'Lead Designer, UX Strategist';
    final progressPercent = (project.progress * 100).toInt();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCED4DA),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Dark Hero Card (Image 2 design)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212529),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF212529).withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // White rounded folder icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.folder_outlined,
                              color: Color(0xFF212529),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Project Title
                        Text(
                          projectName,
                          style: TextStyle(
                            fontFamily: GoogleFonts.instrumentSans().fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Project Description
                        Text(
                          project.description.isNotEmpty
                              ? project.description
                              : 'A shared component library for consistent product experiences.',
                          style: TextStyle(
                            fontFamily: GoogleFonts.instrumentSans().fontFamily,
                            fontSize: 12.5,
                            color: const Color(0xFFCED4DA),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Completion Progress Text
                        Row(
                          children: [
                            Text(
                              '$progressPercent%',
                              style: TextStyle(
                                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'complete',
                              style: TextStyle(
                                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFADB5BD),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: project.progress.clamp(0.0, 1.0),
                            backgroundColor: const Color(0xFF495057),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 4.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Metadata Information Card (Image 2 style)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                    ),
                    child: Column(
                      children: [
                        // Project Manager Row
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFDEE2E6)),
                              ),
                              child: const Icon(Icons.work_outline_rounded, size: 17, color: Color(0xFF495057)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PROJECT MANAGER',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF868E96),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    teamLeadName,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF212529),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFE9ECEF)),
                        ),

                        // Team Members & Role Row
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFDEE2E6)),
                              ),
                              child: const Icon(Icons.people_outline_rounded, size: 18, color: Color(0xFF495057)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'YOUR ROLE & TEAM',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF868E96),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    assignedRole,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF212529),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Collaborator Avatars (NB, AK, VT)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMiniAvatar('NB', const Color(0xFF212529)),
                                const SizedBox(width: 3),
                                _buildMiniAvatar('AK', const Color(0xFF495057)),
                                const SizedBox(width: 3),
                                _buildMiniAvatar('VT', const Color(0xFF6C757D)),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFE9ECEF)),
                        ),

                        // Deadline Date & Time Row
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFFECDD3)),
                              ),
                              child: const Icon(Icons.alarm_rounded, size: 18, color: Color(0xFFE11D48)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DEADLINE DATE & TIME',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF868E96),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateFormat.format(liveTask.dueDate),
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: liveTask.isOverdue ? const Color(0xFFE11D48) : const Color(0xFF212529),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isDone)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: Text(
                                  'COMPLETED',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF065F46),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // "Your responsibilities" Section (Image 2 style)
                  Text(
                    'Your responsibilities',
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF212529),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Responsibility Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF212529).withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Radio/Check circle icon
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isDone ? const Color(0xFF212529) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDone ? const Color(0xFF212529) : const Color(0xFFADB5BD),
                                  width: 1.8,
                                ),
                              ),
                              child: isDone
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Task Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    liveTask.title,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF212529),
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$projectName • ${dateFormat.format(liveTask.dueDate)}',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                      fontSize: 11,
                                      color: const Color(0xFF6C757D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Priority Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFDEE2E6)),
                              ),
                              child: Text(
                                liveTask.priority.name.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF495057),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Mini progress bar for this responsibility
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: isDone ? 1.0 : (liveTask.progressPercent / 100.0).clamp(0.0, 1.0),
                            backgroundColor: const Color(0xFFE9ECEF),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF212529)),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Task Description: Brief overview of requirements
                  Text(
                    'TASK REQUIREMENTS & OVERVIEW',
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF868E96),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          liveTask.description.isNotEmpty
                              ? liveTask.description
                              : 'Review and implement guidelines for the unified executive interface according to corporate specs.',
                          style: TextStyle(
                            fontFamily: GoogleFonts.instrumentSans().fontFamily,
                            fontSize: 13,
                            color: const Color(0xFF343A40),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildBulletPoint('Strict adherence to Instrument Sans and monochrome aesthetic.'),
                        _buildBulletPoint('Ensure instant real-time synchronization with ERP backend state.'),
                        _buildBulletPoint('Verify milestone handoff with lead $teamLeadName.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Submit / Complete Task Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE9ECEF), width: 1.2),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Mark task complete and dispatch instant alert to manager
                  erp.dispatchTaskCompletedAlert(liveTask);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF212529),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Task Completed! Status updated and alert sent to $teamLeadName.',
                              style: TextStyle(
                                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: Icon(
                  isDone ? Icons.done_all_rounded : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  isDone ? 'Update & Re-dispatch Alert' : 'Submit / Complete Task',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212529),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String text, Color bg) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5, right: 8),
            width: 4.5,
            height: 4.5,
            decoration: const BoxDecoration(
              color: Color(0xFF212529),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 12,
                color: const Color(0xFF495057),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
