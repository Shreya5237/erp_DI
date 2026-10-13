import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/project.dart';
import '../../../models/task.dart';

/// Modal sheet displaying project details and the employee's responsibilities within it
class ProjectDetailsSheet extends StatelessWidget {
  final Project project;

  const ProjectDetailsSheet({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final dateFormat = DateFormat('MMM d, yyyy');

    // Filter tasks specifically assigned to the employee for this project
    final myProjectTasks = erp.myEmployeeTasks.where((t) {
      return (t.projectId == project.id || t.projectName == project.name);
    }).toList();

    final myCompletedCount = myProjectTasks.where((t) => t.isCompleted).length;
    final myTaskProgress = myProjectTasks.isNotEmpty
        ? (myCompletedCount / myProjectTasks.length)
        : 1.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_special_rounded, color: Color(0xFF0284C7), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatusBadge(project.status),
                          const SizedBox(width: 8),
                          Text(
                            project.domain,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        project.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client & Dates Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Client: ${project.clientName}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                            ),
                            Text(
                              'Due: ${dateFormat.format(project.deadline)}',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Overall Progress', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      Text('${(project.progress * 100).toInt()}%', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF212529))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: project.progress,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(project.status)),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Project Description
                  const Text('Project Scope & Overview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // Project Manager & Team Members
                  const Text('Team & Management', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 6),
                            const Text('Project Lead / Manager: ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Expanded(
                              child: Text(
                                project.ownerEmployeeName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Team Roster:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: project.teamMemberNames.map((name) {
                            final isMe = name.contains(erp.currentUserName);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFFE0F2FE) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                                border: isMe ? Border.all(color: const Color(0xFF38BDF8)) : null,
                              ),
                              child: Text(
                                isMe ? '$name (You)' : name,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                                  color: isMe ? const Color(0xFF0369A1) : const Color(0xFF334155),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Employee's Assigned Tasks & Individual Progress Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Responsibilities & Tasks',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$myCompletedCount/${myProjectTasks.length} Completed',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Individual progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: myTaskProgress,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (myProjectTasks.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF94A3B8), size: 28),
                          SizedBox(height: 6),
                          Text('No specific sub-tasks directly assigned', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          Text('You are participating as project contributor.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    )
                  else
                    ...myProjectTasks.map((task) {
                      return _buildTaskTile(context, task, erp);
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, CompanyTask task, ErpProvider erp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: task.isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => erp.toggleTaskCompletion(task.id),
            child: Container(
              margin: const EdgeInsets.only(top: 2, right: 10),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                  width: 1.8,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: task.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF212529),
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    _buildPriorityBadge(task.priority),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.isOverdue
                            ? const Color(0xFFFEF2F2)
                            : (task.isDueToday ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.deadlineCountdownText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: task.isOverdue
                              ? const Color(0xFFEF4444)
                              : (task.isDueToday ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Assigned by: ${task.assignedByName}',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ProjectStatus status) {
    Color bg;
    Color fg;
    String label = status.label;

    switch (status) {
      case ProjectStatus.completed:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case ProjectStatus.inProgress:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        break;
      case ProjectStatus.planning:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        break;
      case ProjectStatus.delayed:
      case ProjectStatus.onHold:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return const Color(0xFF10B981);
      case ProjectStatus.inProgress:
        return const Color(0xFF0284C7);
      case ProjectStatus.delayed:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color bg;
    Color fg;
    switch (priority) {
      case TaskPriority.urgent:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFEF4444);
        break;
      case TaskPriority.high:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case TaskPriority.medium:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        break;
      case TaskPriority.low:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(priority.label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
