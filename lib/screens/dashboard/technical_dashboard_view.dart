import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/task.dart';
import '../../models/project.dart';

/// Focused Dashboard Cockpit for Technical Employee (Arjun Sharma)
class TechnicalDashboardView extends StatefulWidget {
  final VoidCallback? onOpenWidget;

  const TechnicalDashboardView({super.key, this.onOpenWidget});

  @override
  State<TechnicalDashboardView> createState() => _TechnicalDashboardViewState();
}

class _TechnicalDashboardViewState extends State<TechnicalDashboardView> {
  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final myTasks = erp.allTasks.where((t) =>
        t.assignedToId == erp.currentUserId || t.assignedToName == erp.currentUserName).toList();
    final myProjects = erp.allProjects.where((p) =>
        p.ownerEmployeeId == erp.currentUserId || p.teamMemberNames.contains(erp.currentUserName)).toList();
    final completionRate = erp.personalTaskCompletionRate;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Technical Lead Persona Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Welcome, ${erp.currentUserName.split(" ")[0]}',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF212529),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TECH LEAD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Technology & Engineering • Agile Sprint Cockpit',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (widget.onOpenWidget != null)
                  IconButton(
                    icon: const Icon(Icons.widgets_outlined, color: Color(0xFF212529)),
                    tooltip: 'Open iOS Task Widget Simulator',
                    onPressed: widget.onOpenWidget,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 3 Quick Metrics: Assigned Projects, Sprint Tasks, Completion Rate
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.code_rounded,
                    title: 'My Projects',
                    value: '${myProjects.length}',
                    subtext: 'Engineering Lead',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.checklist_rounded,
                    title: 'Active Tasks',
                    value: '${myTasks.length}',
                    subtext: '${myTasks.where((t) => t.isCompleted).length} Completed',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.speed_rounded,
                    title: 'Completion',
                    value: '${completionRate.toStringAsFixed(0)}%',
                    subtext: 'Formula Verified',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Agile Sprint Board Container
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: const [
                            Icon(Icons.view_kanban_rounded, size: 18, color: Color(0xFF212529)),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Sprint 1 — Active Board',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF212529),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Sprint Velocity: 24 pts',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0369A1)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (myTasks.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No technical tasks currently assigned.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ] else ...[
                    ...myTasks.map((task) => _buildAgileTaskItem(context, erp, task)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Assigned Projects Details
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assigned Engineering Projects',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                  ),
                  const SizedBox(height: 12),
                  ...myProjects.map((p) => _buildProjectCard(p)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgileTaskItem(BuildContext context, ErpProvider erp, CompanyTask task) {
    Color statusColor;
    switch (task.status) {
      case TaskStatus.done:
      case TaskStatus.approved:
        statusColor = const Color(0xFF16A34A);
        break;
      case TaskStatus.inProgress:
        statusColor = const Color(0xFF0284C7);
        break;
      case TaskStatus.inReview:
      case TaskStatus.submitted:
        statusColor = const Color(0xFF8B5CF6);
        break;
      case TaskStatus.blocked:
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFF64748B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.status.label,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${task.storyPoints} pts • ${task.sprintName ?? "Sprint 1"}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const Spacer(),
              PopupMenuButton<TaskStatus>(
                icon: const Icon(Icons.more_horiz, size: 18, color: Color(0xFF64748B)),
                onSelected: (newStatus) {
                  if (newStatus == TaskStatus.blocked) {
                    _showBlockerDialog(context, erp, task.id);
                  } else {
                    erp.updateAgileTaskStatus(task.id, newStatus);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: TaskStatus.todo, child: Text('Move to To Do')),
                  const PopupMenuItem(value: TaskStatus.inProgress, child: Text('Move to In Progress')),
                  const PopupMenuItem(value: TaskStatus.inReview, child: Text('Move to In Review')),
                  const PopupMenuItem(value: TaskStatus.blocked, child: Text('Report Blocker')),
                  const PopupMenuItem(value: TaskStatus.done, child: Text('Mark as Done')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
          ),
          const SizedBox(height: 3),
          Text(
            task.description,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (task.blockerReason != null && task.blockerReason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.block, size: 12, color: Color(0xFFEF4444)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Blocker: ${task.blockerReason}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBlockerDialog(BuildContext context, ErpProvider erp, String taskId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report Task Blocker', style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe dependency or technical bottleneck...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              filled: true,
              fillColor: const Color(0xFFF5F6F7),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              erp.updateAgileTaskStatus(taskId, TaskStatus.blocked, blockerReason: controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Report Blocker', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
              ),
              Text(
                '${(p.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Client: ${p.clientName} • ${p.teamMemberNames.length} team members',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: p.progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0284C7)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(subtext, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
          ],
        ],
      ),
    );
  }
}
