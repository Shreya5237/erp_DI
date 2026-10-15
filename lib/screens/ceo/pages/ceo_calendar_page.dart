import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/meeting.dart';
import '../../../models/project.dart';
import '../widgets/ceo_modals.dart';

/// Module 6: Calendar & Notifications (Executive Workspace)
/// Design inspired by minimalist executive reference
class CeoCalendarPage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoCalendarPage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoCalendarPage> createState() => _CeoCalendarPageState();
}

class _CeoCalendarPageState extends State<CeoCalendarPage> {
  String _activeTab = 'Schedule'; // 'Schedule', 'Approvals', 'Projects', 'Clients', 'People'
  String _calendarView = 'Daily'; // 'Daily', 'Weekly'
  String _searchQuery = '';
  final Set<String> _readNotificationIds = {};

  final List<String> _tabs = ['Schedule', 'Approvals', 'Projects', 'Clients', 'People'];

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    final meetings = erp.allMeetings;
    final todayMeetings = meetings.where((m) => m.isToday).toList();
    final notifications = _getNotifications(erp);
    final unreadCount = notifications.where((n) => !_readNotificationIds.contains(n.id)).length;
    final upcomingDeadlinesCount = erp.allTasks.where((t) => t.isOverdue || t.dueDate.difference(DateTime.now()).inDays <= 7).length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 16, isMobile ? 16 : 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & "Schedule meeting ->" pill button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Calendar & Notifications',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212529),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => CeoModals.showScheduleMeetingModal(context, erp),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Schedule',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Horizontal Category Tabs (Schedule, Approvals, Projects, Clients, People)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = _activeTab == tab;
                final badgeCount = tab == 'Schedule' ? todayMeetings.length : _getNotificationsForTab(erp, tab).where((n) => !_readNotificationIds.contains(n.id)).length;

                return Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = tab),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tab,
                              style: GoogleFonts.instrumentSans(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? const Color(0xFF212529) : const Color(0xFF868E96),
                              ),
                            ),
                            if (badgeCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF212529) : const Color(0xFFE9ECEF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$badgeCount',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : const Color(0xFF495057),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 2,
                          width: isSelected ? 24 : 0,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF212529) : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Stat Cards (Today's meetings, Unread alerts, Deadlines)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard("Today's meetings", '${todayMeetings.length}', 'Leadership sync'),
                const SizedBox(width: 12),
                _buildStatCard('Unread alerts', '$unreadCount', 'Requires attention'),
                const SizedBox(width: 12),
                _buildStatCard('Deadlines', '$upcomingDeadlinesCount', 'Next 7 days'),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Active Sub-view Based on Tab
          if (_activeTab == 'Schedule')
            _buildScheduleView(context, erp)
          else
            _buildNotificationsView(context, erp, _activeTab),
        ],
      ),
    );
  }

  // --- Schedule / Meetings View ---
  Widget _buildScheduleView(BuildContext context, ErpProvider erp) {
    final allMeetings = erp.allMeetings;
    final filteredMeetings = allMeetings.where((m) {
      if (_calendarView == 'Daily' && !m.isToday) return false;
      if (_searchQuery.isNotEmpty && !m.title.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header inside card with Daily / Weekly switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Executive schedule & leadership meetings',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Live leadership calendar · Synced with Google Meet',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11.5,
                        color: const Color(0xFF868E96),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: ['Daily', 'Weekly'].map((mode) {
                      final isSel = _calendarView == mode;
                      return InkWell(
                        onTap: () => setState(() => _calendarView = mode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSel ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSel
                                ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]
                                : null,
                          ),
                          child: Text(
                            mode,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 11.5,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel ? const Color(0xFF212529) : const Color(0xFF868E96),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 18, color: Color(0xFFADB5BD)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF212529)),
                      decoration: InputDecoration(
                        hintText: 'Filter schedule records...',
                        hintStyle: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFFADB5BD)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE9ECEF)),

          // Meetings List
          if (filteredMeetings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  _calendarView == 'Daily' ? 'No meetings scheduled for today.' : 'No upcoming meetings scheduled this week.',
                  style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredMeetings.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final m = filteredMeetings[i];
                return InkWell(
                  onTap: () => _showMeetingDetailModal(context, m),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                m.startTime,
                                style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                              ),
                              Text(
                                DateFormat('dd MMM').format(m.date),
                                style: GoogleFonts.instrumentSans(fontSize: 10, color: const Color(0xFF868E96)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.title,
                                style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${m.organizerName} · ${m.departmentOrProject}',
                                style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          m.isToday ? 'TODAY' : 'UPCOMING',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: m.isToday ? const Color(0xFF2B8A3E) : const Color(0xFF495057),
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
    );
  }

  // --- Notification Center View ---
  Widget _buildNotificationsView(BuildContext context, ErpProvider erp, String category) {
    final notifs = _getNotificationsForTab(erp, category);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Mark All as Read button
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$category notifications',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Live company alerts & triggers',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11.5,
                        color: const Color(0xFF868E96),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final n in notifs) {
                        _readNotificationIds.add(n.id);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('All $category notifications marked as read.', style: GoogleFonts.instrumentSans())),
                    );
                  },
                  child: Text(
                    'Mark all as read',
                    style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE9ECEF)),

          if (notifs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No $category notifications.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96))),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifs.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final n = notifs[i];
                final isRead = _readNotificationIds.contains(n.id);

                return InkWell(
                  onTap: () {
                    setState(() => _readNotificationIds.add(n.id));
                    widget.onNavigateModule(n.targetModuleIndex);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRead ? Colors.transparent : const Color(0xFFE03131),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: GoogleFonts.instrumentSans(
                                        fontSize: 13.5,
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                                        color: const Color(0xFF212529),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    n.timeAgo,
                                    style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFFADB5BD)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                n.body,
                                style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
                              ),
                            ],
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
    );
  }

  // --- Stat Card Helper ---
  Widget _buildStatCard(String title, String val, String sub) {
    return Container(
      width: 130,
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

  // --- Meeting Detail Modal ---
  void _showMeetingDetailModal(BuildContext context, Meeting meeting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEE2E6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Organizer: ${meeting.organizerName} · ${meeting.departmentOrProject}',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12.5,
                            color: const Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: meeting.isToday ? const Color(0xFFD3F9D8) : const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      meeting.isToday ? 'TODAY' : 'UPCOMING',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: meeting.isToday ? const Color(0xFF2B8A3E) : const Color(0xFF212529),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time & Schedule', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF868E96))),
                        const SizedBox(height: 2),
                        Text(
                          '${meeting.startTime} - ${meeting.endTime}',
                          style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Date', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF868E96))),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, dd MMM').format(meeting.date),
                          style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildModalRow('Location / Link', meeting.locationOrLink),
              _buildModalRow('Participants', meeting.participantNames.join(', ')),
              _buildModalRow('Meeting Priority', 'High Executive Review'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Joined meeting: ${meeting.title}', style: GoogleFonts.instrumentSans())),
                        );
                      },
                      icon: const Icon(Icons.videocam_outlined, size: 16, color: Color(0xFF212529)),
                      label: Text('Join Call', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF212529),
                        side: const BorderSide(color: Color(0xFFDEE2E6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text('Dismiss', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF868E96)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF212529),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dynamic Notifications Generator ---
  List<_NotificationRecord> _getNotifications(ErpProvider erp) {
    final List<_NotificationRecord> list = [];

    // Approvals
    for (final a in erp.pendingApprovals) {
      list.add(
        _NotificationRecord(
          id: 'app_${a.id}',
          category: 'Approvals',
          title: 'Approval required: ${a.title}',
          body: '${a.submittingDepartment} submitted a proposal valued at ₹${(a.dealValueOrBudget / 100000).toStringAsFixed(1)}L.',
          timeAgo: '12m ago',
          targetModuleIndex: 4, // Finance & Approvals
        ),
      );
    }

    // Projects
    for (final p in erp.allProjects.where((p) => p.status == ProjectStatus.delayed || p.activeBlockers.isNotEmpty)) {
      list.add(
        _NotificationRecord(
          id: 'proj_${p.id}',
          category: 'Projects',
          title: 'Project at risk: ${p.name}',
          body: 'Milestone delivery health requires executive attention. ${(p.progress * 100).toInt()}% complete.',
          timeAgo: '45m ago',
          targetModuleIndex: 2, // Projects & Tasks
        ),
      );
    }

    // Clients
    for (final l in erp.allLeads.where((l) => l.isFollowUpMissed)) {
      list.add(
        _NotificationRecord(
          id: 'lead_${l.id}',
          category: 'Clients',
          title: 'Follow-up overdue: ${l.companyName}',
          body: 'Lead owner ${l.assignedEmployeeName} missed scheduled touchpoint.',
          timeAgo: '2h ago',
          targetModuleIndex: 3, // Clients & Business
        ),
      );
    }

    // People
    for (final r in erp.pendingResourceRequests) {
      list.add(
        _NotificationRecord(
          id: 'req_${r.id}',
          category: 'People',
          title: 'Resource requisition: ${r.requestedResource}',
          body: '${r.requesterName} requested staffing authorization for ${r.requestingDepartment}.',
          timeAgo: '3h ago',
          targetModuleIndex: 1, // People & Departments
        ),
      );
    }

    // Default notifications if empty
    if (list.isEmpty) {
      list.addAll([
        _NotificationRecord(
          id: 'app_def_1',
          category: 'Approvals',
          title: 'Budget reallocation pending signoff',
          body: 'Technical Department requested ₹4.5L cloud scaling allocation.',
          timeAgo: '10m ago',
          targetModuleIndex: 4,
        ),
        _NotificationRecord(
          id: 'proj_def_1',
          category: 'Projects',
          title: 'Atlas Platform Sprint 4 blocker',
          body: 'API dependency waiting for client integration token.',
          timeAgo: '1h ago',
          targetModuleIndex: 2,
        ),
        _NotificationRecord(
          id: 'client_def_1',
          category: 'Clients',
          title: 'High-value deal proposal ready',
          body: 'Horizon Enterprise proposal ready for CEO review (₹62.0L).',
          timeAgo: '2h ago',
          targetModuleIndex: 3,
        ),
        _NotificationRecord(
          id: 'people_def_1',
          category: 'People',
          title: 'New Senior Architect onboarding completed',
          body: 'Technical Head confirmed successful sprint allocation.',
          timeAgo: '4h ago',
          targetModuleIndex: 1,
        ),
      ]);
    }

    return list;
  }

  List<_NotificationRecord> _getNotificationsForTab(ErpProvider erp, String tab) {
    final all = _getNotifications(erp);
    if (tab == 'Approvals') return all.where((n) => n.category == 'Approvals').toList();
    if (tab == 'Projects') return all.where((n) => n.category == 'Projects').toList();
    if (tab == 'Clients') return all.where((n) => n.category == 'Clients').toList();
    if (tab == 'People') return all.where((n) => n.category == 'People').toList();
    return all;
  }
}

class _NotificationRecord {
  final String id;
  final String category;
  final String title;
  final String body;
  final String timeAgo;
  final int targetModuleIndex;

  _NotificationRecord({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.targetModuleIndex,
  });
}
