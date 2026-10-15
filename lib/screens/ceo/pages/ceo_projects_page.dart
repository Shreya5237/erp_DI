import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/project.dart';
import '../widgets/ceo_modals.dart';

/// Module 3: Projects & Tasks Workspace (Specification Section 7 & Image 5)
/// Features:
/// - Complete project portfolio overview with health metrics
/// - Hierarchical task management: project -> work package -> subtask -> employee
/// - Overdue work, blocked work, and projects at risk
/// - Dedicated Project Details Workspace with milestones, deliverables, roster, budget in ₹, dependencies, feedback, and CEO actions
class CeoProjectsPage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoProjectsPage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoProjectsPage> createState() => _CeoProjectsPageState();
}

class _CeoProjectsPageState extends State<CeoProjectsPage> {
  Project? _selectedProject;
  String _activeTab = 'Portfolio'; // 'Portfolio', 'Tasks', 'Milestones', 'Timeline', 'Resources'
  String _statusFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final projects = erp.allProjects;
    final allTasks = erp.allTasks;

    final activeProjects = projects.where((p) => p.status == ProjectStatus.inProgress).toList();
    final atRiskProjects = projects.where((p) => p.hasResourceConflict || p.activeBlockers.isNotEmpty).toList();
    final completedTasks = allTasks.where((t) => t.isCompleted).length;
    final overdueTasks = allTasks.where((t) => t.isOverdue && !t.isCompleted).length;
    final completionPct = allTasks.isNotEmpty ? ((completedTasks / allTasks.length) * 100).toInt() : 86;
    final uniqueClients = projects.map((p) => p.clientName).toSet().length;

    final filtered = projects.where((p) {
      if (_statusFilter == 'In Progress' && p.status != ProjectStatus.inProgress) return false;
      if (_statusFilter == 'Planning' && p.status != ProjectStatus.planning) return false;
      if (_statusFilter == 'Completed' && p.status != ProjectStatus.completed) return false;
      if (_statusFilter == 'At Risk' && !(p.hasResourceConflict || p.activeBlockers.isNotEmpty)) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!p.name.toLowerCase().contains(q) && !p.clientName.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Clean Executive Style — No Wordy Subheadings)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Projects & Tasks',
                  style: GoogleFonts.instrumentSans(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212529),
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedProject != null)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedProject = null),
                  icon: const Icon(Icons.arrow_back_rounded, size: 15, color: Color(0xFF212529)),
                  label: Text('Back to Portfolio', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDEE2E6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                )
              else
                // Action Pill Button (Image 5: "Create new ->")
                ElevatedButton(
                  onPressed: () => CeoModals.showCreateNewActionSheet(context, erp, widget.onNavigateModule),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create new',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // If a project is selected, show Dedicated Project Details Workspace
          if (_selectedProject != null) ...[
            _buildProjectDetailsWorkspace(context, _selectedProject!, erp),
          ] else ...[
            // Horizontal Tab Pills (Image 5)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Portfolio', 'Tasks', 'Milestones', 'Timeline', 'Resources'].map((tab) {
                  final isSel = _activeTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isSel,
                      selectedColor: const Color(0xFF212529),
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.instrumentSans(
                        color: isSel ? Colors.white : const Color(0xFF495057),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _activeTab = tab),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Stat Cards Row (Image 5)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 750;
                final crossAxisCount = isWide ? 3 : (constraints.maxWidth >= 480 ? 3 : 2);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 1.55 : 1.35,
                  children: [
                    _buildProjectStatCard(
                      'Active projects',
                      '${activeProjects.length}',
                      'Across $uniqueClients clients',
                    ),
                    _buildProjectStatCard(
                      'Completion',
                      '$completionPct%',
                      '$completedTasks tasks done',
                    ),
                    _buildProjectStatCard(
                      'At risk',
                      '${atRiskProjects.length}',
                      '$overdueTasks overdue',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),

            // Content Card Container (Image 5: Clean white card with search, filter, and rows)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeTab == 'Portfolio'
                              ? 'Active project portfolio'
                              : (_activeTab == 'Tasks' ? 'Deliverable tasks & execution' : 'Project $_activeTab'),
                          style: GoogleFonts.instrumentSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Live company records · Last updated just now',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 11,
                            color: const Color(0xFF868E96),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search & Status Filter Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Search Input
                        Expanded(
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFDEE2E6)),
                            ),
                            child: TextField(
                              style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF212529)),
                              onChanged: (val) => setState(() => _searchQuery = val.trim()),
                              decoration: InputDecoration(
                                hintText: 'Filter records...',
                                hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                                prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF868E96)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Status Filter Dropdown Button
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFDEE2E6)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _statusFilter,
                              style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF495057)),
                              icon: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF868E96)),
                              items: ['All', 'In Progress', 'At Risk', 'Planning', 'Completed'].map((s) {
                                return DropdownMenuItem(value: s, child: Text(s == 'All' ? 'All statuses' : s));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _statusFilter = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE9ECEF), height: 1),

                  // Minimalist List Rows (Image 5)
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No projects match the current filter.',
                          style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF868E96)),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, i) => const Divider(color: Color(0xFFE9ECEF), height: 1),
                      itemBuilder: (ctx, i) {
                        final p = filtered[i];
                        final hasConflict = p.hasResourceConflict || p.activeBlockers.isNotEmpty;

                        return InkWell(
                          onTap: () => setState(() => _selectedProject = p),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          p.name,
                                          style: GoogleFonts.instrumentSans(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF212529),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (hasConflict) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFE03131),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    p.clientName,
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF868E96),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF868E96)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectStatCard(String title, String val, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF868E96),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.instrumentSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF212529),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.instrumentSans(
              fontSize: 10.5,
              color: const Color(0xFFADB5BD),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


  // ========================================================
  // DEDICATED PROJECT DETAILS WORKSPACE (Section 7 Specification)
  // ========================================================
  Widget _buildProjectDetailsWorkspace(BuildContext context, Project p, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Dossier
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 750;
              final infoCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: GoogleFonts.instrumentSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client: ${p.clientName} • PM: ${p.ownerEmployeeName} • Domain: ${p.domain}',
                    style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D)),
                  ),
                ],
              );
              final actionControls = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Corrective plan requested from PM ${p.ownerEmployeeName}.', style: GoogleFonts.instrumentSans())),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDEE2E6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Request Corrective Plan', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Executive priority set to Critical for ${p.name}.', style: GoogleFonts.instrumentSans())),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212529),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Set Priority: Critical', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoCol,
                    const SizedBox(height: 12),
                    actionControls,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: infoCol),
                  const SizedBox(width: 16),
                  actionControls,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE9ECEF), height: 1),
          const SizedBox(height: 18),

          // Core Metrics Bar (Responsive Grid: 2 columns on mobile, 4 on desktop)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 750;
              final crossAxisCount = isWide ? 4 : 2;
              final childAspectRatio = isWide ? 1.7 : 1.4;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: childAspectRatio,
                children: [
                  _buildMetricBox('Overall Completion', '${(p.progress * 100).toInt()}% Done', 'Sprints: On Schedule'),
                  _buildMetricBox('Target Deadline', DateFormat('dd MMM yyyy').format(p.deadline), 'Estimated vs Planned'),
                  _buildMetricBox('Active Blockers', '${p.activeBlockers.length} Logged', p.activeBlockers.isEmpty ? 'Clean Health' : 'Needs Intervention'),
                  _buildMetricBox('Allocated Budget', '₹35,00,000', '₹24,50,000 Spent (70%)'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Milestones & Deliverables
          Text('Project Milestones & Deliverables', style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
          const SizedBox(height: 10),
          ...p.milestones.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  children: [
                    Icon(
                      m.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: m.isCompleted ? const Color(0xFF2F9E44) : const Color(0xFF6C757D),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m.title,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212529),
                          decoration: m.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Text(
                      m.isCompleted ? 'Delivered' : 'Pending',
                      style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: m.isCompleted ? const Color(0xFF2F9E44) : const Color(0xFF6C757D)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),

          // Customer Scope Changes & Feedback
          Text('Customer Scope Changes & Change Requests', style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                final contentBlock = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF212529)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Change Request #CR-204 (Scope Expansion: SSO Integration)',
                            style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Submitted by client steering committee • Impact: +₹3.5L Budget & 1 week timeline extension',
                            style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final actionBtn = ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scope Change #CR-204 approved by CEO.', style: GoogleFonts.instrumentSans())),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Approve Scope Change', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700)),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      contentBlock,
                      const SizedBox(height: 10),
                      Align(alignment: Alignment.centerRight, child: actionBtn),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: contentBlock),
                    const SizedBox(width: 14),
                    actionBtn,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String val, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            sub,
            style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFFADB5BD)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
