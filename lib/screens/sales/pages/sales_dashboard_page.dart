import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/log_call_dialog.dart';
import 'sales_follow_ups_page.dart';
import 'sales_performance_page.dart';

/// Page 1 — Dashboard (Daily sales overview)
class SalesDashboardPage extends StatelessWidget {
  final VoidCallback? onNavigateToCalls;
  final VoidCallback? onNavigateToDeals;

  const SalesDashboardPage({
    super.key,
    this.onNavigateToCalls,
    this.onNavigateToDeals,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final overdueFollowUps = erp.overdueFollowUps;
    final todayFollowUps = erp.followUpsDueToday;
    final urgentFollowUps = [...overdueFollowUps, ...todayFollowUps];
    final salesMeetings = erp.salesMeetings;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome & Date Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sales Overview',
                        style: TextStyle(
                          color: Color(0xFF212529),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Welcome back, ${erp.currentUserName}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                      ),
                    ],
                  ),
                  // Log Call Quick Button
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const LogCallDialog(),
                      );
                    },
                    icon: const Icon(Icons.add_call, size: 15, color: Colors.white),
                    label: const Text(
                      'Log Call',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // TOP PRIORITY: Urgent Follow-ups & Upcoming Meetings Banner
              // -------------------------------------------------------------
              if (urgentFollowUps.isNotEmpty || salesMeetings.isNotEmpty) ...[
                _buildUrgentAttentionSection(context, erp, urgentFollowUps, salesMeetings),
                const SizedBox(height: 16),
              ],

              // -------------------------------------------------------------
              // Leave Balance & Daily Target Row
              // -------------------------------------------------------------
              Row(
                children: [
                  // Leave Balance Card
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.beach_access_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      title: 'Leave Balance',
                      value: '20 Days',
                      subtitle: '14 Annual • 4 Sick • 2 Casual',
                      bgColor: const Color(0xFF0369A1).withValues(alpha: 0.12),
                      borderColor: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Daily Cold-Call Target vs Actual
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.phone_in_talk_rounded,
                      iconColor: const Color(0xFF34D399),
                      title: 'Daily Call Target',
                      value: '${erp.callsCompletedTodayCount} / ${erp.dailyColdCallTarget}',
                      subtitle: erp.pendingColdCallsTodayCount > 0
                          ? '${erp.pendingColdCallsTodayCount} calls remaining'
                          : 'Daily target reached!',
                      bgColor: const Color(0xFF059669).withValues(alpha: 0.12),
                      borderColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                      progress: (erp.callsCompletedTodayCount / erp.dailyColdCallTarget).clamp(0.0, 1.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // -------------------------------------------------------------
              // Monthly Target vs Achieved Card
              // -------------------------------------------------------------
              _buildMonthlyTargetCard(context, erp),
              const SizedBox(height: 12),

              // -------------------------------------------------------------
              // Weekly Performance Card
              // -------------------------------------------------------------
              _buildWeeklyPerformanceCard(context, erp),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // Quick Nav Shortcuts to Secondary Pages (Follow-ups & Performance)
              // -------------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: _buildQuickNavButton(
                      icon: Icons.schedule_rounded,
                      label: 'Follow-ups & Schedule',
                      badge: '${erp.followUpsDueTodayCount + erp.overdueFollowUpsCount}',
                      badgeColor: const Color(0xFFEF4444),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SalesFollowUpsPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickNavButton(
                      icon: Icons.insights_rounded,
                      label: 'Performance & Targets',
                      badge: '77%',
                      badgeColor: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SalesPerformancePage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // Today's Follow-up Calls List
              // -------------------------------------------------------------
              _buildSectionHeader(
                title: 'Follow-up Calls Due Today',
                count: todayFollowUps.length,
                onSeeAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SalesFollowUpsPage()),
                  );
                },
              ),
              const SizedBox(height: 8),
              if (todayFollowUps.isEmpty)
                _buildEmptyState('No follow-up calls due today.')
              else
                ...todayFollowUps.map((call) => _buildCallCard(context, call, erp)),

              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // Upcoming Sales Meetings
              // -------------------------------------------------------------
              _buildSectionHeader(
                title: 'Upcoming Meetings',
                count: salesMeetings.length,
              ),
              const SizedBox(height: 8),
              if (salesMeetings.isEmpty)
                _buildEmptyState('No upcoming meetings.')
              else
                ...salesMeetings.take(3).map((mtg) => _buildMeetingCard(context, mtg)),

              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // Upcoming Planned Calls & Due Dates
              // -------------------------------------------------------------
              _buildSectionHeader(
                title: 'Upcoming Planned Calls',
                count: erp.upcomingFollowUpsSevenDays.length,
                onSeeAll: onNavigateToCalls,
              ),
              const SizedBox(height: 8),
              if (erp.upcomingFollowUpsSevenDays.isEmpty)
                _buildEmptyState('No upcoming calls scheduled for next 7 days.')
              else
                ...erp.upcomingFollowUpsSevenDays.take(4).map((call) => _buildCallCard(context, call, erp)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentAttentionSection(
    BuildContext context,
    ErpProvider erp,
    List urgentFollowUps,
    List salesMeetings,
  ) {
    final overdueCount = erp.overdueFollowUps.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            overdueCount > 0
                ? const Color(0xFFEF4444).withValues(alpha: 0.18)
                : const Color(0xFF3B82F6).withValues(alpha: 0.15),
            const Color(0xFF2B3035),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: overdueCount > 0
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : const Color(0xFF3B82F6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                overdueCount > 0 ? Icons.warning_amber_rounded : Icons.priority_high_rounded,
                color: overdueCount > 0 ? const Color(0xFFF87171) : const Color(0xFF60A5FA),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                overdueCount > 0 ? 'Urgent Attention Needed' : 'Today\'s Urgent Schedule',
                style: TextStyle(
                  color: overdueCount > 0 ? const Color(0xFFF87171) : const Color(0xFF60A5FA),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (overdueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$overdueCount Overdue',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            overdueCount > 0
                ? 'You have $overdueCount overdue follow-up calls requiring immediate action.'
                : 'Next meeting: ${salesMeetings.isNotEmpty ? salesMeetings.first.title : "No meetings today."}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SalesFollowUpsPage()),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'View Urgent Follow-ups',
                      style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: Color(0xFF60A5FA), size: 13),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color bgColor,
    required Color borderColor,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF212529), fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation(iconColor),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthlyTargetCard(BuildContext context, ErpProvider erp) {
    final achievedLakhs = (erp.monthlySalesAchieved / 100000).toStringAsFixed(1);
    final targetLakhs = (erp.monthlySalesTarget / 100000).toStringAsFixed(0);
    final remainingLakhs = (erp.monthlySalesRemaining / 100000).toStringAsFixed(1);
    final percentage = (erp.monthlySalesAchievedRatio * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(14),
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
              const Row(
                children: [
                  Icon(Icons.track_changes_rounded, color: Color(0xFFF59E0B), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Monthly Target vs Achieved',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage% Achieved',
                  style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Achieved', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                  Text('₹$achievedLakhs Lakhs', style: const TextStyle(color: Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Remaining', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                  Text('₹$remainingLakhs Lakhs', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Target', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
                  Text('₹$targetLakhs Lakhs', style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: erp.monthlySalesAchievedRatio,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPerformanceCard(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: Color(0xFF8B5CF6), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Weekly Performance',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Highest: Wk ${erp.highestPerformingWeek} (${erp.highestPerformingWeekCalls} calls)',
                  style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(erp.weeklyCallTotals.length, (idx) {
              final weekNum = idx + 1;
              final calls = erp.weeklyCallTotals[idx];
              final isHighest = weekNum == erp.highestPerformingWeek;
              final ratio = calls / 60.0;

              return Column(
                children: [
                  Text(
                    '$calls',
                    style: TextStyle(
                      color: isHighest ? const Color(0xFFA78BFA) : Colors.white70,
                      fontSize: 11,
                      fontWeight: isHighest ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 48,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Container(
                      width: 28,
                      height: 48 * ratio,
                      decoration: BoxDecoration(
                        color: isHighest ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wk $weekNum',
                    style: TextStyle(
                      color: isHighest ? const Color(0xFFA78BFA) : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: isHighest ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavButton({
    required IconData icon,
    required String label,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF60A5FA), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    int? count,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildCallCard(BuildContext context, dynamic call, ErpProvider erp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: call.isFollowUpOverdue
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: call.outcome.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.phone_rounded, color: call.outcome.color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        call.customerName,
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: call.outcome.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        call.outcome.label,
                        style: TextStyle(color: call.outcome.color, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${call.companyName} • ${call.phone}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
                if (call.notes.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    call.notes,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, dynamic mtg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.video_call_rounded, color: Color(0xFFA78BFA), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mtg.title,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${mtg.startTime} - ${mtg.endTime} • ${mtg.locationOrLink}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ),
    );
  }
}
