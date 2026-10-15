import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/project.dart';
import '../widgets/project_details_sheet.dart';

/// Screen 3: Projects (Assigned Projects to Employee)
/// Adhering strictly to the finalized concept:
/// - List of assigned projects
/// - Project name and short description
/// - Project manager and team members
/// - Overall project progress
/// - Employee's assigned tasks and individual progress
/// - Project status: Not started, In progress, or Completed
/// - Selecting a project opens its details and the employee's responsibilities within it
class EmployeeProjectsPage extends StatefulWidget {
  const EmployeeProjectsPage({super.key});

  @override
  State<EmployeeProjectsPage> createState() => _EmployeeProjectsPageState();
}

class _EmployeeProjectsPageState extends State<EmployeeProjectsPage> {
  String _selectedStatusFilter = 'All'; // 'All', 'In Progress', 'Completed', 'Planning'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final myProjects = erp.myEmployeeProjects;

    // Filter by search and status
    final filtered = myProjects.where((p) {
      if (_selectedStatusFilter != 'All') {
        if (_selectedStatusFilter == 'In Progress' && p.status != ProjectStatus.inProgress) return false;
        if (_selectedStatusFilter == 'Completed' && p.status != ProjectStatus.completed) return false;
        if (_selectedStatusFilter == 'Planning' && p.status != ProjectStatus.planning) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.clientName.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 13,
                    color: const Color(0xFF212529),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search assigned projects...',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 13,
                      color: const Color(0xFFADB5BD),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF6C757D)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF212529), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterChip('All', myProjects.length),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip('In Progress', myProjects.where((p) => p.status == ProjectStatus.inProgress).length),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip('Planning', myProjects.where((p) => p.status == ProjectStatus.planning).length),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip('Completed', myProjects.where((p) => p.status == ProjectStatus.completed).length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE9ECEF)),

          // Projects List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_open_rounded, size: 40, color: Color(0xFFADB5BD)),
                        const SizedBox(height: 10),
                        Text(
                          'No projects found',
                          style: TextStyle(
                            fontFamily: GoogleFonts.instrumentSans().fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF495057),
                          ),
                        ),
                        Text(
                          'Try clearing the search or status filter.',
                          style: TextStyle(
                            fontFamily: GoogleFonts.instrumentSans().fontFamily,
                            fontSize: 12,
                            color: const Color(0xFF868E96),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final project = filtered[idx];
                      return _buildProjectCard(context, project, erp);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, int count) {
    final isSelected = _selectedStatusFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF212529) : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF212529) : const Color(0xFFE9ECEF)),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontFamily: GoogleFonts.instrumentSans().fontFamily,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF495057),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project, ErpProvider erp) {
    // Calculate employee's individual tasks and progress for this project
    final myTasksInProject = erp.myEmployeeTasks.where((t) {
      return (t.projectId == project.id || t.projectName == project.name);
    }).toList();

    final myCompleted = myTasksInProject.where((t) => t.isCompleted).length;
    final myTaskPercent = myTasksInProject.isNotEmpty
        ? (myCompleted / myTasksInProject.length)
        : (project.progress);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ProjectDetailsSheet(project: project),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Domain pill, Status pill, Arrow icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    project.domain,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                  ),
                ),
                const SizedBox(width: 6),
                _buildStatusPill(project.status),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 10),

            // Project Name & Short Description
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF212529),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              project.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Project Manager & Team Members
            Row(
              children: [
                const Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text(
                  'PM: ${project.ownerEmployeeName.split(" ").first}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.group_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  '${project.teamMemberNames.length} Members',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Progress Rows
            // 1. Overall Project Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Overall Project Progress', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text('${(project.progress * 100).toInt()}%', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF212529))),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: project.progress,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 10),

            // 2. Employee's Assigned Tasks & Individual Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Tasks Progress', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                Text(
                  myTasksInProject.isNotEmpty
                      ? '$myCompleted/${myTasksInProject.length} Done (${(myTaskPercent * 100).toInt()}%)'
                      : 'Lead Contributor',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: myTaskPercent,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(ProjectStatus status) {
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
        fg = const Color(0xFF64748B);
        label = 'Not Started';
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
}
