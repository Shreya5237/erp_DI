import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/project.dart';
import '../../../models/task.dart';
import '../../../models/meeting.dart';
import '../widgets/employee_task_detail_modal.dart';
import '../widgets/project_details_sheet.dart';
import '../widgets/meeting_details_dialog.dart';
import '../widgets/employee_notifications_sheet.dart';

class EmployeeDashboardPage extends StatelessWidget {
  final VoidCallback? onNavigateToProjects;
  final VoidCallback? onNavigateToCalendar;
  final VoidCallback? onNavigateToTasks;
  final VoidCallback? onNavigateToProfile;

  const EmployeeDashboardPage({
    super.key,
    this.onNavigateToProjects,
    this.onNavigateToCalendar,
    this.onNavigateToTasks,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final employee = erp.currentEmployee;

    // Determine user name and initial
    final fullName = erp.currentUserName.isNotEmpty ? erp.currentUserName : 'Shreya';
    final firstName = fullName.split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S';

    // Unread alerts count
    final unreadAlerts = erp.unreadEmployeeAlertsCount;

    // Tasks & Projects
    final myTasks = erp.myEmployeeTasks;
    final myProjects = erp.myEmployeeProjects;

    // Featured tasks for Today's Tasks
    final todayTasks = myTasks.where((t) => !t.isCompleted).take(3).toList();
    if (todayTasks.isEmpty && myTasks.isNotEmpty) {
      todayTasks.addAll(myTasks.take(3));
    }

    // Reporting manager (defaults to Rajesh Kumar matching hand-drawn sketch specification)
    final reportingMgr = (employee?.reportingManager.isNotEmpty == true &&
            !employee!.reportingManager.contains('CEO') &&
            !employee.reportingManager.contains('Laven'))
        ? employee.reportingManager
        : 'Rajesh Kumar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 28), // lowered properly
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6), // slightly lower top clearance
              // 1. TOP USER PROFILE HEADER
              _buildHeader(context, erp, firstName, initial, unreadAlerts),
              const SizedBox(height: 18),

              // 2. QUICK OVERVIEW WIDGET (2x3 Grid with black background cards & white text)
              _buildQuickOverview(context, erp, reportingMgr),
              const SizedBox(height: 22),

              // 3. TODAY'S TASKS SECTION
              _buildTodaysTasksSection(context, todayTasks, reportingMgr),
              const SizedBox(height: 22),

              // 4. PROJ ASSIGNED SECTION
              _buildProjAssignedSection(context, myProjects),
              const SizedBox(height: 22),

              // 5. UPCOMING MEETINGS SECTION
              _buildUpcomingMeetingsSection(context, erp),
              const SizedBox(height: 26),

              // 6. BRANDING ELEMENT FOOTER
              _buildBrandingFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. User Profile Header with personalized greeting & interactive notification bell
  Widget _buildHeader(BuildContext context, ErpProvider erp, String firstName, String initial, int unreadCount) {
    return Row(
      children: [
        // User Avatar Circle (Taps to navigate to Profile page)
        GestureDetector(
          onTap: onNavigateToProfile,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF212529).withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Personalized Greeting & Tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, $firstName!',
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF212529),
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'DIGITAL INERTIA',
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF868E96),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Interactive Notification Bell with Badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF212529), size: 26),
              tooltip: 'Alerts & Notifications',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const EmployeeNotificationsSheet(),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE11D48),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 2. Quick Overview Widget (2x3 Hand-Drawn Sketch Layout)
  // User Requirement: "each of this sub widgets in black bg and the text in white"
  Widget _buildQuickOverview(BuildContext context, ErpProvider erp, String reportingMgr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF212529).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF212529)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Quick Metrics Overview',
                        style: TextStyle(
                          fontFamily: GoogleFonts.instrumentSans().fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF212529),
                          letterSpacing: 0.6,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDEE2E6)),
                ),
                child: Text(
                  'Q4 Active',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF495057),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x3 Grid of Sub-Widgets in Black Background (#212529) and White Text
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              // Card 1: DATE & TIME (with shortcut jump straight to Calendar View)
              _buildBlackOverviewTile(
                title: 'DATE & TIME',
                icon: Icons.calendar_month_outlined,
                value: DateFormat('EEE, MMM d').format(DateTime.now()),
                subtitle: '${DateFormat('hh:mm a').format(DateTime.now())} IST',
                subtitleColor: const Color(0xFF34D399), // crisp emerald
                actionIcon: Icons.arrow_outward_rounded,
                onTap: onNavigateToCalendar,
              ),

              // Card 2: REPORTING MGR (Quick reference to lead Rajesh Kumar)
              _buildBlackOverviewTile(
                title: 'REPORTING MGR',
                icon: Icons.person_outline_rounded,
                value: reportingMgr,
                subtitle: 'Team Lead',
                subtitleColor: const Color(0xFFADB5BD),
              ),

              // Card 3: LEAVE BALANCE (Clean metric e.g. 14 Days)
              _buildBlackOverviewTile(
                title: 'LEAVE BALANCE',
                icon: Icons.beach_access_outlined,
                value: '${erp.currentEmployee?.leaveBalance ?? 14} Days',
                subtitle: 'Available Balance',
                subtitleColor: const Color(0xFFCED4DA),
                onTap: onNavigateToProfile,
              ),

              // Card 4: ACTIVE PROJECTS (Total involved count e.g. 04 Projs)
              _buildBlackOverviewTile(
                title: 'ACTIVE PROJECTS',
                icon: Icons.folder_open_outlined,
                value: '${erp.myEmployeeProjects.where((p) => p.status != ProjectStatus.completed).length.toString().padLeft(2, '0')} Projs',
                subtitle: 'Active Involved',
                subtitleColor: const Color(0xFFCED4DA),
                actionIcon: Icons.arrow_outward_rounded,
                onTap: onNavigateToProjects,
              ),

              // Card 5: UPCOMING DEADLINE (Prominent highlight e.g. Oct 18 with warning dot)
              Builder(
                builder: (context) {
                  final pendingTasks = erp.myEmployeeTasks.where((t) => !t.isCompleted).toList()
                    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
                  final urgentTask = pendingTasks.isNotEmpty ? pendingTasks.first : null;
                  final deadlineDate = urgentTask != null ? urgentTask.dueDate : DateTime(2026, 10, 18);
                  final projectName = urgentTask != null
                      ? (urgentTask.projectName ?? urgentTask.title.split(' ').take(2).join(' '))
                      : 'Rebrand Delivery';
                  final shortProject = projectName.length > 14 ? '${projectName.substring(0, 12)}..' : projectName;
                  final deadlineLabel = DateFormat('MMM d').format(deadlineDate);

                  return InkWell(
                    onTap: onNavigateToCalendar,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212529),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF343A40), width: 1.1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF212529).withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DEADLINE',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFDA4AF),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              // Accent Color Warning Indicator Dot
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF43F5E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deadlineLabel,
                            style: TextStyle(
                              fontFamily: GoogleFonts.instrumentSans().fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shortProject,
                            style: TextStyle(
                              fontFamily: GoogleFonts.instrumentSans().fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFDA4AF),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Card 6: TARGET (Visual completion progress e.g. 92% Met, Tap to Edit)
              InkWell(
                onTap: () => _showEditTargetDialog(context, erp),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF343A40), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF212529).withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TARGET',
                            style: TextStyle(
                              fontFamily: GoogleFonts.instrumentSans().fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFCED4DA),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 13, color: Color(0xFFADB5BD)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${erp.employeeTargetGoalPercent}% Met',
                        style: TextStyle(
                          fontFamily: GoogleFonts.instrumentSans().fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to Edit',
                        style: TextStyle(
                          fontFamily: GoogleFonts.instrumentSans().fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFADB5BD),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Black Overview Tile Helper
  Widget _buildBlackOverviewTile({
    required String title,
    IconData? icon,
    required String value,
    required String subtitle,
    Color? subtitleColor,
    IconData? actionIcon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF212529),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF343A40), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF212529).withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFCED4DA),
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (actionIcon != null)
                  Icon(actionIcon, size: 12, color: const Color(0xFFCED4DA))
                else if (icon != null)
                  Icon(icon, size: 13, color: const Color(0xFFADB5BD)),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: subtitleColor ?? const Color(0xFFADB5BD),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 3. Today's Tasks Cards with horizontal scroll and slide-up Modal
  Widget _buildTodaysTasksSection(BuildContext context, List<CompanyTask> tasks, String reportingMgr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row matching hand-drawn sketch ("Todays tasks" ... "See More")
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Todays tasks",
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF212529),
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: onNavigateToTasks ?? onNavigateToCalendar,
              child: Text(
                'See More',
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C757D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontally scrolling cards (Heading, Timing, Manager)
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (ctx, idx) {
              final task = tasks[idx];
              String timeStr = '10:30 AM';
              if (idx == 1) timeStr = '01:15 PM';
              if (idx == 2) timeStr = '03:45 PM';

              return _buildTodayTaskCard(context, task, timeStr, reportingMgr);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTaskCard(BuildContext context, CompanyTask task, String timeStr, String reportingMgr) {
    final taskLead = task.assignedByName.isNotEmpty ? task.assignedByName : reportingMgr;

    return InkWell(
      onTap: () => EmployeeTaskDetailModal.show(context, task),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 215,
        padding: const EdgeInsets.all(14),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top time chip & arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontFamily: GoogleFonts.instrumentSans().fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFADB5BD)),
              ],
            ),
            const SizedBox(height: 6),

            // Heading / Title
            Text(
              task.title,
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF212529),
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Project & Manager Subtitles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.projectName ?? 'Design System',
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C757D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Lead: ${taskLead.split(" ").first}',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF495057),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. PROJ ASSIGNED Grid Section (matching hand-drawn sketch & Image 3)
  Widget _buildProjAssignedSection(BuildContext context, List<Project> projects) {
    final displayProjects = projects.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Proj Assigned',
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF212529),
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: onNavigateToProjects,
              child: Text(
                'See more',
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C757D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Side-by-side Project Cards
        Row(
          children: displayProjects.asMap().entries.map((entry) {
            final idx = entry.key;
            final project = entry.value;
            final dateBadge = idx == 0 ? 'Oct 24' : 'Nov 12';

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(left: idx > 0 ? 10 : 0),
                child: _buildAssignedProjectCard(context, project, dateBadge),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAssignedProjectCard(BuildContext context, Project project, String dateBadge) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ProjectDetailsSheet(project: project),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
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
            // Top Row: Title & Date Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF212529),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dateBadge,
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Manager Name
            Text(
              'Mgr: ${project.ownerEmployeeName}',
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 10.5,
                color: const Color(0xFF6C757D),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Progress text row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                Text(
                  '${(project.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212529),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Linear Progress Indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: project.progress,
                backgroundColor: const Color(0xFFE9ECEF),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF212529)),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. UPCOMING MEETINGS Section with Join action
  Widget _buildUpcomingMeetingsSection(BuildContext context, ErpProvider erp) {
    final meeting = erp.myEmployeeMeetings.isNotEmpty
        ? erp.myEmployeeMeetings.first
        : Meeting(
            id: 'MTG-00A',
            title: 'Q4 Strategic Alignment',
            participantNames: ['Rajesh K.', 'Arjun S.'],
            date: DateTime(2026, 10, 14),
            startTime: '11:00 AM',
            endTime: '12:00 PM',
            locationOrLink: 'Meet: di-q4-alignment',
            agenda: 'Review goals and milestone delivery schedule.',
            organizerName: 'Rajesh K.',
            departmentOrProject: 'DI Rebrand & Strategy',
            status: 'Scheduled',
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header matching sketch ("Upcoming meeting" ... "See more")
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming meeting',
              style: TextStyle(
                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF212529),
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: onNavigateToCalendar,
              child: Text(
                'See more',
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C757D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Meeting Card
        Container(
          padding: const EdgeInsets.all(14),
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
          child: Row(
            children: [
              // Video Camera Icon Circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: Color(0xFF212529),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Meeting Title & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.title,
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212529),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Oct 14 • ${meeting.startTime} • ${meeting.organizerName.split(" ").first} K.',
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        fontSize: 11,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),

              // Black Pill Button: Join
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => MeetingDetailsDialog(meeting: meeting),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212529),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  minimumSize: const Size(60, 34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  'Join',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. Corporate Branding Elements: DI Monogram, Strategic Consulting badge, and tagline
  Widget _buildBrandingFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDEE2E6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF212529),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'Di',
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'STRATEGIC CONSULTING',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '“COZ’ EVERYONE NEEDS A PUSH”',
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C757D),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // Editable Target Goal Modal Dialog
  void _showEditTargetDialog(BuildContext context, ErpProvider erp) {
    int tempGoal = erp.employeeTargetGoalPercent;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set Personal Target Goal',
                        style: TextStyle(
                          fontFamily: GoogleFonts.instrumentSans().fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF6C757D)),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customize your target performance percentage for this quarter.',
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      fontSize: 12,
                      color: const Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '$tempGoal% Met',
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212529),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Slider(
                    value: tempGoal.toDouble(),
                    min: 50,
                    max: 100,
                    divisions: 50,
                    activeColor: const Color(0xFF212529),
                    inactiveColor: const Color(0xFFE9ECEF),
                    onChanged: (val) {
                      setModalState(() => tempGoal = val.toInt());
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        erp.setEmployeeTargetGoal(tempGoal);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF212529),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Text(
                              'Target goal updated to $tempGoal% Met!',
                              style: TextStyle(fontFamily: GoogleFonts.instrumentSans().fontFamily),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Target',
                        style: TextStyle(
                          fontFamily: GoogleFonts.instrumentSans().fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
