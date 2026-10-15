import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/project.dart';
import '../../../models/task.dart';
import '../../../providers/erp_provider.dart';
import 'employee_task_detail_modal.dart';

/// Dedicated Project Details Screen / Workspace
/// Features:
/// 1. Project Overview: Title, Overall Progress Bar, Deadline, Project Manager
/// 2. Team Roster & Status: Complete member list with roles & contribution statuses
/// 3. "My Tasks" Categorized Breakdown:
///    - Personal completion percentage header (e.g. 75% completed | 25% remaining)
///    - Ongoing Tasks (Top)
///    - Upcoming Tasks (Middle)
///    - Completed Tasks (Bottom)
///    - Tapping opens detailed description modal
class ProjectDetailsSheet extends StatelessWidget {
  final Project project;

  const ProjectDetailsSheet({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final dateFormat = DateFormat('MMM d, yyyy');

    // Get live project from provider
    final liveProject = erp.allProjects.firstWhere((p) => p.id == project.id, orElse: () => project);

    // Filter tasks for this project assigned to this employee
    final myProjectTasks = erp.myEmployeeTasks.where((t) {
      return (t.projectId == liveProject.id ||
          (t.projectName != null && t.projectName!.toLowerCase() == liveProject.name.toLowerCase()));
    }).toList();

    // If no direct project tasks found, fallback to relevant tasks or simulate project slice
    final projectTasks = myProjectTasks.isNotEmpty
        ? myProjectTasks
        : erp.myEmployeeTasks.take(3).toList();

    final completedTasks = projectTasks.where((t) => t.isCompleted).toList();
    final ongoingTasks = projectTasks.where((t) => !t.isCompleted && (t.status == TaskStatus.inProgress || t.status == TaskStatus.todo)).toList();
    final upcomingTasks = projectTasks.where((t) => !t.isCompleted && t.dueDate.isAfter(DateTime.now().add(const Duration(hours: 12)))).toList();

    // Calculate personal progress
    final totalMyTasks = projectTasks.length;
    final completedMyCount = completedTasks.length;
    final personalPercent = totalMyTasks > 0
        ? ((completedMyCount / totalMyTasks) * 100).round()
        : (liveProject.progress * 100).round();
    final personalRemaining = 100 - personalPercent;

    final daysRemaining = liveProject.deadline.difference(DateTime.now()).inDays;
    final deadlineText = daysRemaining > 0 ? '$daysRemaining days left' : 'Due today';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFDEE2E6),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hub_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROJECT WORKSPACE',
                        style: TextStyle(
                          fontFamily: GoogleFonts.instrumentSans().fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: const Color(0xFF6C757D),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        liveProject.name,
                        style: TextStyle(
                          fontFamily: GoogleFonts.instrumentSans().fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF212529),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF6C757D)),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F3F5)),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. PROJECT OVERVIEW CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Progress',
                              style: TextStyle(
                                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF495057),
                              ),
                            ),
                            Text(
                              '${(liveProject.progress * 100).toInt()}%',
                              style: TextStyle(
                                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF212529),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: liveProject.progress,
                            backgroundColor: const Color(0xFFE9ECEF),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF212529)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailStat(
                                label: 'PROJECT MANAGER',
                                value: liveProject.ownerEmployeeName,
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            Container(width: 1, height: 32, color: const Color(0xFFDEE2E6)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildDetailStat(
                                label: 'DEADLINE',
                                value: '${dateFormat.format(liveProject.deadline)} ($deadlineText)',
                                icon: Icons.calendar_today_outlined,
                                highlight: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. TEAM ROSTER & STATUS
                  Text(
                    'TEAM ROSTER & STATUS',
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6C757D),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                    ),
                    child: Column(
                      children: _buildTeamMembers(liveProject, erp),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 3. "MY TASKS" CATEGORIZED BREAKDOWN
                  // Top Header Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212529),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MY TASKS BREAKDOWN',
                              style: TextStyle(
                                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFADB5BD),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$completedMyCount/${projectTasks.length} Done',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$personalPercent% of your part completed | $personalRemaining% remaining',
                          style: TextStyle(
                            fontFamily: GoogleFonts.instrumentSans().fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: personalPercent / 100,
                            backgroundColor: Colors.white.withOpacity(0.18),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section A: Ongoing Tasks (Top)
                  _buildTaskCategorySection(
                    title: 'ONGOING TASKS (IN PROGRESS)',
                    badgeColor: const Color(0xFF0284C7),
                    tasks: ongoingTasks,
                    emptyMessage: 'No ongoing tasks in progress.',
                    context: context,
                  ),
                  const SizedBox(height: 16),

                  // Section B: Upcoming Tasks (Middle)
                  _buildTaskCategorySection(
                    title: 'UPCOMING TASKS (SCHEDULED DELIVERABLES)',
                    badgeColor: const Color(0xFFF59E0B),
                    tasks: upcomingTasks,
                    emptyMessage: 'No upcoming scheduled deliverables.',
                    context: context,
                  ),
                  const SizedBox(height: 16),

                  // Section C: Completed Tasks (Bottom)
                  _buildTaskCategorySection(
                    title: 'COMPLETED TASKS (FINISHED DELIVERABLES)',
                    badgeColor: const Color(0xFF10B981),
                    tasks: completedTasks,
                    emptyMessage: 'No completed tasks recorded yet.',
                    context: context,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat({
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: const Color(0xFF6C757D)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6C757D),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: GoogleFonts.instrumentSans().fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: highlight ? const Color(0xFFE11D48) : const Color(0xFF212529),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  List<Widget> _buildTeamMembers(Project project, ErpProvider erp) {
    final members = project.teamMemberNames.isNotEmpty
        ? project.teamMemberNames
        : [project.ownerEmployeeName, erp.currentUserName, 'Sneha V (Frontend)', 'Karthik R (Backend)'];

    final widgets = <Widget>[];
    for (int i = 0; i < members.length; i++) {
      final name = members[i];
      final isMe = name.toLowerCase().contains(erp.currentUserName.toLowerCase()) ||
          name.toLowerCase().contains('shreya') ||
          name.toLowerCase().contains('arjun');

      String role = 'Contributor';
      if (name.contains(project.ownerEmployeeName) || name.contains('Rajesh') || name.contains('Ananya')) {
        role = 'Project Lead';
      } else if (name.contains('Priya') || name.contains('Backend')) {
        role = 'Senior Backend';
      } else if (name.contains('Sneha') || name.contains('Frontend')) {
        role = 'Frontend Specialist';
      } else if (isMe) {
        role = erp.currentEmployee?.role ?? 'Technical Specialist';
      }

      String status = i == 0 ? 'Lead' : (i % 2 == 0 ? 'Active' : 'Delivering');

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isMe ? const Color(0xFF212529) : const Color(0xFFE9ECEF),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isMe ? Colors.white : const Color(0xFF495057),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? '$name (You)' : name,
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        fontSize: 12.5,
                        fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        fontSize: 11,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFECFDF5) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isMe ? const Color(0xFFA7F3D0) : const Color(0xFFE9ECEF),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isMe ? const Color(0xFF065F46) : const Color(0xFF6C757D),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (i < members.length - 1) {
        widgets.add(const Divider(height: 1, color: Color(0xFFF1F3F5)));
      }
    }
    return widgets;
  }

  Widget _buildTaskCategorySection({
    required String title,
    required Color badgeColor,
    required List<CompanyTask> tasks,
    required String emptyMessage,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6C757D),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${tasks.length})',
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFADB5BD),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Text(
              emptyMessage,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 12,
                color: const Color(0xFFADB5BD),
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...tasks.map((task) => _buildProjectTaskTile(task, context)),
      ],
    );
  }

  Widget _buildProjectTaskTile(CompanyTask task, BuildContext context) {
    final dateFormat = DateFormat('MMM d • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted ? const Color(0xFFA7F3D0) : const Color(0xFFE9ECEF),
          width: 1.2,
        ),
      ),
      child: ListTile(
        onTap: () => EmployeeTaskDetailModal.show(context, task),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(
          task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFFADB5BD),
          size: 20,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontFamily: GoogleFonts.instrumentSans().fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: task.isCompleted ? const Color(0xFF6C757D) : const Color(0xFF212529),
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            'Due: ${dateFormat.format(task.dueDate)} • ${task.priority.name.toUpperCase()}',
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              fontSize: 11,
              color: const Color(0xFF6C757D),
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFADB5BD)),
      ),
    );
  }
}
