import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/sales_call.dart';
import '../../../models/meeting.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/deal_detail_sheet.dart';
import '../widgets/log_call_dialog.dart';

/// Page 4 — Follow-ups & Schedule (Manage the next actions for every lead)
class SalesFollowUpsPage extends StatelessWidget {
  const SalesFollowUpsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final overdueFollowUps = erp.overdueFollowUps;
    final todayFollowUps = erp.followUpsDueToday;
    final upcomingSevenDays = erp.upcomingFollowUpsSevenDays;
    final salesMeetings = erp.salesMeetings;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Follow-ups & Schedule',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_call, color: Color(0xFF212529)),
            tooltip: 'Schedule New Call',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LogCallDialog(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // -------------------------------------------------------------
            // SECTION 1: Overdue Follow-ups (PROMINENTLY HIGHLIGHTED)
            // -------------------------------------------------------------
            if (overdueFollowUps.isNotEmpty) ...[
              _buildOverdueSectionHeader(overdueFollowUps.length),
              const SizedBox(height: 8),
              ...overdueFollowUps.map((call) => _buildFollowUpCard(context, call, erp, isOverdue: true)),
              const SizedBox(height: 20),
            ],

            // -------------------------------------------------------------
            // SECTION 2: Due Today
            // -------------------------------------------------------------
            _buildSectionHeader('Due Today', todayFollowUps.length, const Color(0xFF38BDF8)),
            const SizedBox(height: 8),
            if (todayFollowUps.isEmpty)
              _buildEmptyCard('No follow-up calls scheduled for today.')
            else
              ...todayFollowUps.map((call) => _buildFollowUpCard(context, call, erp)),
            const SizedBox(height: 20),

            // -------------------------------------------------------------
            // SECTION 3: Next 7 Days
            // -------------------------------------------------------------
            _buildSectionHeader('Next 7 Days', upcomingSevenDays.length, const Color(0xFFA78BFA)),
            const SizedBox(height: 8),
            if (upcomingSevenDays.isEmpty)
              _buildEmptyCard('No follow-up calls in the next 7 days.')
            else
              ...upcomingSevenDays.map((call) => _buildFollowUpCard(context, call, erp)),
            const SizedBox(height: 20),

            // -------------------------------------------------------------
            // SECTION 4: Upcoming Sales Meetings
            // -------------------------------------------------------------
            _buildSectionHeader('Upcoming Sales Meetings', salesMeetings.length, const Color(0xFF10B981)),
            const SizedBox(height: 8),
            if (salesMeetings.isEmpty)
              _buildEmptyCard('No upcoming meetings scheduled.')
            else
              ...salesMeetings.map((mtg) => _buildMeetingCard(context, mtg)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueSectionHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF87171), size: 18),
          const SizedBox(width: 8),
          const Text(
            'Overdue Follow-ups (Immediate Action)',
            style: TextStyle(color: Color(0xFFF87171), fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count Overdue',
              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(width: 3.5, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count',
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowUpCard(
    BuildContext context,
    SalesCall call,
    ErpProvider erp, {
    bool isOverdue = false,
  }) {
    Color priorityColor;
    switch (call.priority) {
      case 'Urgent':
        priorityColor = const Color(0xFFEF4444);
        break;
      case 'High':
        priorityColor = const Color(0xFFF59E0B);
        break;
      case 'Low':
        priorityColor = const Color(0xFF64748B);
        break;
      default:
        priorityColor = const Color(0xFF3B82F6);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue
              ? const Color(0xFFEF4444).withValues(alpha: 0.6)
              : const Color(0xFFE9ECEF),
          width: isOverdue ? 1.5 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client & Priority Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.customerName,
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: const Color(0xFF212529),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${call.companyName} • ${call.phone}',
                      style: TextStyle(
                        fontFamily: GoogleFonts.instrumentSans().fontFamily,
                        color: const Color(0xFF6C757D),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${call.priority} Priority',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: priorityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date & Time & Deal info
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF6C757D),
              ),
              const SizedBox(width: 5),
              Text(
                call.nextFollowUpDate != null
                    ? '${call.nextFollowUpDate!.day}/${call.nextFollowUpDate!.month}/${call.nextFollowUpDate!.year} at ${call.nextFollowUpDate!.hour}:${call.nextFollowUpDate!.minute.toString().padLeft(2, '0')}'
                    : 'Unscheduled',
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF495057),
                  fontSize: 11.5,
                  fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (isOverdue) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${call.daysOverdue}d overdue',
                    style: TextStyle(
                      fontFamily: GoogleFonts.instrumentSans().fontFamily,
                      color: const Color(0xFFEF4444),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (call.dealValue != null) ...[
                const Spacer(),
                Text(
                  '₹${_formatCurrency(call.dealValue!)} Deal',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: const Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),

          if (call.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Text(
                call.notes,
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  color: const Color(0xFF495057),
                  fontSize: 11,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Action Buttons: Complete, Reschedule, Call, Link Deal
          Row(
            children: [
              // Mark Completed Action
              ElevatedButton.icon(
                onPressed: () {
                  erp.markFollowUpCompleted(call.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF212529),
                      content: Text(
                        'Follow-up with ${call.customerName} marked as completed!',
                        style: TextStyle(fontFamily: GoogleFonts.instrumentSans().fontFamily),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                label: Text(
                  'Complete',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212529),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 8),

              // Reschedule Action
              OutlinedButton.icon(
                onPressed: () => _rescheduleCall(context, call, erp),
                icon: const Icon(Icons.edit_calendar_rounded, size: 14, color: Color(0xFF212529)),
                label: Text(
                  'Reschedule',
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: const Color(0xFF212529),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE9ECEF)),
                  backgroundColor: const Color(0xFFF1F3F5),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const Spacer(),

              // Linked Deal button (if lead exists)
              if (call.leadId != null)
                IconButton(
                  tooltip: 'View Linked Deal',
                  icon: const Icon(Icons.launch_rounded, color: Color(0xFF6C757D), size: 18),
                  onPressed: () {
                    final lead = erp.allLeads.firstWhere((l) => l.id == call.leadId, orElse: () => erp.allLeads.first);
                    DealDetailSheet.show(context, lead);
                  },
                ),

              // Phone call quick trigger
              IconButton(
                tooltip: 'Call Customer',
                icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF212529), size: 18),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => LogCallDialog(
                      prefilledCustomerName: call.customerName,
                      prefilledCompanyName: call.companyName,
                      prefilledPhone: call.phone,
                      leadId: call.leadId,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _rescheduleCall(BuildContext context, SalesCall call, ErpProvider erp) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 15, minute: 0),
      );
      final finalDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 15,
        pickedTime?.minute ?? 0,
      );
      erp.rescheduleFollowUp(call.id, finalDate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF212529),
            content: Text(
              'Follow-up rescheduled to ${finalDate.day}/${finalDate.month}/${finalDate.year}',
              style: TextStyle(fontFamily: GoogleFonts.instrumentSans().fontFamily),
            ),
          ),
        );
      }
    }
  }

  Widget _buildMeetingCard(BuildContext context, Meeting mtg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: const Icon(Icons.video_call_rounded, color: Color(0xFF212529), size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mtg.title,
                  style: TextStyle(
                    fontFamily: GoogleFonts.instrumentSans().fontFamily,
                    color: const Color(0xFF212529),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${mtg.startTime} - ${mtg.endTime} • ${mtg.locationOrLink}',
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              color: const Color(0xFF495057),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mtg.agenda,
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              color: const Color(0xFF6C757D),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Participants: ${mtg.participantNames.join(", ")}',
            style: TextStyle(
              fontFamily: GoogleFonts.instrumentSans().fontFamily,
              color: const Color(0xFF868E96),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
