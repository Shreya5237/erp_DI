import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/sales_call.dart';
import '../../../models/meeting.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/log_call_dialog.dart';
import '../widgets/sales_notifications_sheet.dart';

/// Page 4 — Calendar: Follow-ups & Schedule
/// Combines follow-up management and calendar scheduling in one dedicated workspace:
/// - Calendar views: Month, Week, and Day
/// - Overdue follow-ups prominently highlighted with immediate reschedule/complete actions
/// - Follow-ups due today and over next 7 days
/// - Sales meetings, deal deadlines, and priority reminders
/// - Distinct but restrained visual indicators for calls, meetings, and deadlines
class SalesCalendarPage extends StatefulWidget {
  const SalesCalendarPage({super.key});

  @override
  State<SalesCalendarPage> createState() => _SalesCalendarPageState();
}

class _SalesCalendarPageState extends State<SalesCalendarPage> {
  String _activeView = 'Week'; // 'Month', 'Week', 'Day'
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final overdueFollowUps = erp.overdueFollowUps;
    final todayFollowUps = erp.followUpsDueToday;
    final upcomingSevenDays = erp.upcomingFollowUpsSevenDays;
    final salesMeetings = erp.salesMeetings;

    final unreadAlerts = erp.overdueFollowUpsCount + (erp.pendingColdCallsTodayCount > 0 ? 1 : 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: 'Calendar & Schedule' + Notification Bell
              _buildTopBar(context, unreadAlerts),
              const SizedBox(height: 12),

              // Calendar View Switcher (Month, Week, Day) + Today button
              _buildCalendarHeaderControls(),
              const SizedBox(height: 14),

              // Interactive Calendar Strip for Current View
              _buildCalendarStrip(),
              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // 1. OVERDUE FOLLOW-UPS (Immediate action needed)
              // -------------------------------------------------------------
              if (overdueFollowUps.isNotEmpty) ...[
                _buildOverdueSection(context, overdueFollowUps, erp),
                const SizedBox(height: 18),
              ],

              // -------------------------------------------------------------
              // 2. FOLLOW-UPS DUE TODAY
              // -------------------------------------------------------------
              _buildSectionHeader('Due Today', todayFollowUps.length, const Color(0xFF212529)),
              const SizedBox(height: 8),
              if (todayFollowUps.isEmpty)
                _buildEmptyCard('No follow-up calls due today.')
              else
                ...todayFollowUps.map((call) => _buildFollowUpCard(context, call, erp)),
              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // 3. UPCOMING IN NEXT 7 DAYS
              // -------------------------------------------------------------
              _buildSectionHeader('Next 7 Days', upcomingSevenDays.length, const Color(0xFF495057)),
              const SizedBox(height: 8),
              if (upcomingSevenDays.isEmpty)
                _buildEmptyCard('No follow-ups scheduled for the next 7 days.')
              else
                ...upcomingSevenDays.map((call) => _buildFollowUpCard(context, call, erp)),
              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // 4. UPCOMING SALES MEETINGS
              // -------------------------------------------------------------
              _buildSectionHeader('Sales Meetings', salesMeetings.length, const Color(0xFF212529)),
              const SizedBox(height: 8),
              if (salesMeetings.isEmpty)
                _buildEmptyCard('No meetings scheduled for this period.')
              else
                ...salesMeetings.map((mtg) => _buildMeetingCard(context, mtg)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const LogCallDialog(),
          );
        },
        backgroundColor: const Color(0xFF212529),
        elevation: 2,
        icon: const Icon(Icons.add_call, color: Colors.white, size: 18),
        label: Text(
          'Log Call',
          style: GoogleFonts.instrumentSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// Top Bar with Page Title and Notification Bell
  Widget _buildTopBar(BuildContext context, int unreadAlerts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Calendar & Schedule',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF212529),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        InkWell(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const SalesNotificationsSheet(),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Color(0xFF212529), size: 20),
                if (unreadAlerts > 0)
                  Positioned(
                    top: 8,
                    right: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF212529),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Segment switcher for Month, Week, Day + Today action button
  Widget _buildCalendarHeaderControls() {
    final views = ['Month', 'Week', 'Day'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final monthStr = '${months[_selectedDate.month - 1]} ${_selectedDate.year}';

    return Column(
      children: [
        // Controls Row: View Toggles on left, Today button on right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Month, Week, Day Segment Toggles
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: views.map((v) {
                  final isSelected = _activeView == v;
                  return InkWell(
                    onTap: () => setState(() => _activeView = v),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        v,
                        style: GoogleFonts.instrumentSans(
                          color: isSelected ? const Color(0xFF212529) : const Color(0xFF6C757D),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // 'Today' quick-jump button
            InkWell(
              onTap: () => setState(() => _selectedDate = DateTime.now()),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.today_rounded, size: 14, color: Color(0xFF212529)),
                    const SizedBox(width: 4),
                    Text(
                      'Today',
                      style: GoogleFonts.instrumentSans(
                        color: const Color(0xFF212529),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Date Title + Navigation Arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              monthStr,
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF212529),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 22, color: Color(0xFF212529)),
                  onPressed: () {
                    setState(() {
                      if (_activeView == 'Month') {
                        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                      } else if (_activeView == 'Week') {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                      } else {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFF212529)),
                  onPressed: () {
                    setState(() {
                      if (_activeView == 'Month') {
                        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                      } else if (_activeView == 'Week') {
                        _selectedDate = _selectedDate.add(const Duration(days: 7));
                      } else {
                        _selectedDate = _selectedDate.add(const Duration(days: 1));
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Weekly interactive date selector strip
  Widget _buildCalendarStrip() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final dayDate = startOfWeek.add(Duration(days: index));
          final isSelected = dayDate.day == _selectedDate.day &&
              dayDate.month == _selectedDate.month &&
              dayDate.year == _selectedDate.year;
          final isToday = dayDate.day == DateTime.now().day &&
              dayDate.month == DateTime.now().month &&
              dayDate.year == DateTime.now().year;

          return InkWell(
            onTap: () => setState(() => _selectedDate = dayDate),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 38,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF212529) : (isToday ? const Color(0xFFF1F3F5) : Colors.transparent),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    dayLabels[index],
                    style: GoogleFonts.instrumentSans(
                      color: isSelected ? const Color(0xFFADB5BD) : const Color(0xFF868E96),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dayDate.day}',
                    style: GoogleFonts.instrumentSans(
                      color: isSelected ? Colors.white : const Color(0xFF212529),
                      fontSize: 14,
                      fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Overdue follow-ups section header and cards
  Widget _buildOverdueSection(BuildContext context, List<SalesCall> overdueFollowUps, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD8D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE03131), size: 18),
              const SizedBox(width: 8),
              Text(
                'Overdue Follow-ups (${overdueFollowUps.length})',
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFFE03131),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...overdueFollowUps.map((call) => _buildFollowUpCard(context, call, erp, isOverdue: true)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color accent) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF212529),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE9ECEF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF495057),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowUpCard(BuildContext context, SalesCall call, ErpProvider erp, {bool isOverdue = false}) {
    final timeStr = call.nextFollowUpDate != null
        ? '${call.nextFollowUpDate!.hour}:${call.nextFollowUpDate!.minute.toString().padLeft(2, '0')}'
        : '14:00';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? const Color(0xFFFFD8D8) : const Color(0xFFE9ECEF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  call.customerName,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOverdue ? const Color(0xFFFFF5F5) : const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOverdue ? '${call.daysOverdue}d overdue' : timeStr,
                  style: GoogleFonts.instrumentSans(
                    color: isOverdue ? const Color(0xFFE03131) : const Color(0xFF495057),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${call.companyName} · Follow-up Call',
            style: GoogleFonts.instrumentSans(
              color: const Color(0xFF868E96),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (call.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              call.notes,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontSize: 11),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 2)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    erp.rescheduleFollowUp(call.id, picked);
                  }
                },
                child: Text(
                  'Reschedule',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF6C757D),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              InkWell(
                onTap: () => erp.markFollowUpCompleted(call.id),
                child: Text(
                  'Mark Complete',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, Meeting mtg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.videocam_outlined, color: Color(0xFF212529), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mtg.title,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${mtg.startTime} - ${mtg.endTime} · ${mtg.participantNames.length} Attendees',
                  style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 11.5),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  content: Text('Launching meeting session for ${mtg.title}'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Join',
              style: GoogleFonts.instrumentSans(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Text(
        message,
        style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
