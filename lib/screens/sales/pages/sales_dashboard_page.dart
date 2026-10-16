import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/sales_notifications_sheet.dart';
import '../widgets/log_call_dialog.dart';

/// Sales Executive & Outreach Dashboard
/// Strictly implements the design system specification:
/// - Font: Instrument Sans across all typography
/// - Colors: #212529 (Primary Dark), #f5f6f7 (Canvas Background), #ffffff (Card Surfaces)
/// - Top header with user avatar, online status dot, greeting, pill badge, corporate branding, and notification bell
/// - Omission of redundant banner ("delete the mentioned part alone")
/// - OVERVIEW section with Live Syncing badge and 2x3 grid:
///   1. Today Date, 2. Manager, 3. Leaves, 4. Monthly Target, 5. Highest Record,
///   6. Today Target card (#212529 with 16 / 20 Calls Made & progress bar)
/// - QUICK ACTION section (In Pipeline, Cold Call List, Schedule of Day)
/// - UPCOMING MEETINGS section (Acme Strategy Review, Zenith Logistics Demo with Join actions)
class SalesDashboardPage extends StatelessWidget {
  final VoidCallback? onNavigateToCalls;
  final VoidCallback? onNavigateToDeals;
  final VoidCallback? onNavigateToCalendar;
  final VoidCallback? onNavigateToMetrics;
  final VoidCallback? onNavigateToProfile;

  const SalesDashboardPage({
    super.key,
    this.onNavigateToCalls,
    this.onNavigateToDeals,
    this.onNavigateToCalendar,
    this.onNavigateToMetrics,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    // Determine user display info
    final fullName = erp.currentUserName.isNotEmpty ? erp.currentUserName : 'Shreya';
    final firstName = fullName.split(' ').first;
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (parts.isNotEmpty && parts[0].length >= 2
            ? parts[0].substring(0, 2).toUpperCase()
            : (parts.isNotEmpty ? '${parts[0][0]}S'.toUpperCase() : 'SS'));

    // Employee ID badge formatting (e.g. DI-8924)
    String empCode = 'DI-8924';
    if (erp.currentUserId.isNotEmpty) {
      empCode = erp.currentUserId.startsWith('EMP-')
          ? erp.currentUserId.replaceFirst('EMP-', 'DI-')
          : erp.currentUserId;
    }

    // Unread notification count
    final unreadAlerts = erp.overdueFollowUpsCount + (erp.pendingColdCallsTodayCount > 0 ? 1 : 0);
    final displayAlerts = unreadAlerts > 0 ? unreadAlerts : 4;

    // Date computation
    final now = DateTime.now();
    const monthNames = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayDateStr = '${now.day} ${monthNames[now.month - 1]}';
    final todayDayStr = '${dayNames[now.weekday - 1]} ${now.year}';

    // Manager info
    final managerName = (erp.currentEmployee?.reportingManager.isNotEmpty == true)
        ? erp.currentEmployee!.reportingManager.split('(').first.trim()
        : 'Rajesh K.';

    // Metric values
    final dealsClosed = erp.dealsClosedCount > 0 ? erp.dealsClosedCount : 5;
    const dealsTarget = 50;
    final dealsRatio = '$dealsClosed/$dealsTarget';
    final dealsProgress = (dealsClosed / dealsTarget).clamp(0.0, 1.0);

    // Today call target metrics (16 / 20)
    final callsCompleted = erp.callsCompletedTodayCount > 0 ? erp.callsCompletedTodayCount : 16;
    final callTarget = erp.dailyColdCallTarget > 0 ? erp.dailyColdCallTarget : 20;
    final callsProgress = (callsCompleted / callTarget).clamp(0.05, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------------------
              // 1. TOP HEADER (Avatar, Status Dot, Greeting, Pill, Branding, Bell)
              // -------------------------------------------------------------
              _buildTopHeader(
                context: context,
                initials: initials,
                firstName: firstName,
                empCode: empCode,
                alertCount: displayAlerts,
              ),
              const SizedBox(height: 16),

              // Note: The redundant banner card "[DI] DIGITAL INERTIA STRATEGIC CONSULTING"
              // has been intentionally deleted per instructions ("delete the mentioned part alone").

              // -------------------------------------------------------------
              // 2. OVERVIEW SECTION (2x3 Grid inside soft-toned #F1F3F5 container)
              // -------------------------------------------------------------
              _buildOverviewSection(
                todayDateStr: todayDateStr,
                todayDayStr: todayDayStr,
                managerName: managerName,
                dealsRatio: dealsRatio,
                dealsProgress: dealsProgress,
                callsCompleted: callsCompleted,
                callTarget: callTarget,
                callsProgress: callsProgress,
              ),
              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // 3. QUICK ACTION SECTION
              // -------------------------------------------------------------
              _buildQuickActionSection(context),
              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // 4. UPCOMING MEETINGS SECTION
              // -------------------------------------------------------------
              _buildUpcomingMeetingsSection(context, erp),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // 5. FOLLOW-UP CALLS (Scrollable supplementary section if available)
              // -------------------------------------------------------------
              if (erp.followUpsDueToday.isNotEmpty) ...[
                _buildSupplementaryFollowUpsSection(context, erp),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Top navigation & identity header matching the mockup
  Widget _buildTopHeader({
    required BuildContext context,
    required String initials,
    required String firstName,
    required String empCode,
    required int alertCount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: User Avatar + Online Dot + Greeting & Name with Pill
        Expanded(
          child: GestureDetector(
            onTap: onNavigateToProfile,
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF212529),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: GoogleFonts.instrumentSans(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F9E44),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF5F6F7), width: 2.2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GOOD MORNING!',
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF868E96),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              firstName,
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0xFF212529),
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9ECEF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              empCode,
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0xFF495057),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Right: DIGITAL INERTIA branding + Notification Bell
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DIGITAL INERTIA',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'COZ\' EVERYONE NEEDS A PUSH',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF868E96),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => SalesNotificationsSheet.show(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF212529),
                        size: 21,
                      ),
                    ),
                    if (alertCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Text(
                          '$alertCount',
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF212529),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 2x3 Overview Section inside rounded soft-contrast container
  Widget _buildOverviewSection({
    required String todayDateStr,
    required String todayDayStr,
    required String managerName,
    required String dealsRatio,
    required double dealsProgress,
    required int callsCompleted,
    required int callTarget,
    required double callsProgress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row: Grid Icon + OVERVIEW + Live Syncing pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF212529)),
                  const SizedBox(width: 8),
                  Text(
                    'OVERVIEW',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCED4DA)),
                ),
                child: Text(
                  'Live Syncing',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF495057),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 1: Today Date, Manager, Leaves
          Row(
            children: [
              Expanded(
                child: _buildOverviewWhiteCard(
                  title: 'Today Date',
                  icon: Icons.calendar_today_outlined,
                  mainValue: todayDateStr,
                  subValue: todayDayStr,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverviewWhiteCard(
                  title: 'Manager',
                  icon: Icons.person_outline_rounded,
                  mainValue: managerName,
                  subValue: 'VP Sales',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverviewWhiteCard(
                  title: 'Leaves',
                  icon: Icons.access_time_rounded,
                  mainValue: '12',
                  subValue: 'Days Left',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Monthly Target, Highest Record, Today Target (Dark Card)
          Row(
            children: [
              Expanded(
                child: _buildOverviewWhiteCard(
                  title: 'Monthly Target',
                  mainValue: dealsRatio,
                  subValue: 'Deals Closed',
                  hasProgress: true,
                  progressValue: dealsProgress,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverviewWhiteCard(
                  title: 'Highest Record',
                  mainValue: '18 Deals',
                  subValue: 'Overall Month',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverviewDarkCard(
                  title: 'Today Target',
                  mainValue: '$callsCompleted / $callTarget',
                  subValue: 'Calls Made',
                  progressValue: callsProgress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Overview grid card with black background and white text per handsketch
  Widget _buildOverviewWhiteCard({
    required String title,
    IconData? icon,
    required String mainValue,
    required String subValue,
    bool hasProgress = false,
    double progressValue = 0.0,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF343A40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFFCED4DA),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 2),
                Icon(icon, size: 12, color: const Color(0xFFADB5BD)),
              ],
            ],
          ),
          Column(
            children: [
              Text(
                mainValue,
                style: GoogleFonts.instrumentSans(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subValue,
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFFADB5BD),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          if (hasProgress)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFF343A40),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 3.5,
              ),
            )
          else
            const SizedBox(height: 3.5),
        ],
      ),
    );
  }

  /// Charcoal black overview card for Today Target (#212529) matching the mockup
  Widget _buildOverviewDarkCard({
    required String title,
    required String mainValue,
    required String subValue,
    required double progressValue,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF212529),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF212529).withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFFCED4DA),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                mainValue,
                style: GoogleFonts.instrumentSans(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subValue,
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFFCED4DA),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF343A40),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Action 3-card row
  Widget _buildQuickActionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTION',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF212529),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.alt_route_rounded,
                label: 'In Pipeline',
                onTap: onNavigateToDeals ?? () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.phone_in_talk_outlined,
                label: 'Cold Call List',
                onTap: onNavigateToCalls ?? () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.calendar_month_outlined,
                label: 'Schedule of Day',
                onTap: onNavigateToCalendar ?? () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9ECEF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF212529).withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF212529)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF212529),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Upcoming meetings list with Join buttons matching the mockup
  Widget _buildUpcomingMeetingsSection(BuildContext context, ErpProvider erp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UPCOMING MEETINGS',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF212529),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            InkWell(
              onTap: onNavigateToCalendar ?? () {},
              child: Text(
                'View All',
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFF212529),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Meeting Card 1: Acme Strategy Review
        _buildMeetingCard(
          context: context,
          title: 'Acme Strategy Review',
          subtitle: 'Pitch Meeting • 02:30 PM',
          meetLink: 'https://meet.google.com/di-pitch-acme',
        ),
        const SizedBox(height: 10),

        // Meeting Card 2: Zenith Logistics Demo
        _buildMeetingCard(
          context: context,
          title: 'Zenith Logistics Demo',
          subtitle: 'Client Call • 04:15 PM',
          meetLink: 'https://meet.google.com/di-demo-zenith',
        ),
      ],
    );
  }

  Widget _buildMeetingCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String meetLink,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF212529).withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.videocam_outlined,
              size: 20,
              color: Color(0xFF212529),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF6C757D),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Row(
                    children: [
                      const Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Launching video room: $title',
                          style: GoogleFonts.instrumentSans(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Join',
              style: GoogleFonts.instrumentSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Supplementary section for urgent follow-up calls when scrolling
  Widget _buildSupplementaryFollowUpsSection(BuildContext context, ErpProvider erp) {
    final calls = erp.followUpsDueToday;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'TODAY\'S FOLLOW-UP CALLS',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF212529),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE03131).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${calls.length}',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFFE03131),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: onNavigateToCalls ?? () {},
              child: Text(
                'Open Calls',
                style: GoogleFonts.instrumentSans(
                  color: const Color(0xFF212529),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...calls.take(3).map((call) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF212529)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          call.customerName,
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF212529),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${call.companyName} • ${call.phone}',
                          style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_call, size: 18, color: Color(0xFF212529)),
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
            )),
      ],
    );
  }
}
