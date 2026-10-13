import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';

/// Page 5 — Performance & Targets (Measure individual sales performance)
class SalesPerformancePage extends StatelessWidget {
  const SalesPerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final achievedLakhs = (erp.monthlySalesAchieved / 100000).toStringAsFixed(1);
    final targetLakhs = (erp.monthlySalesTarget / 100000).toStringAsFixed(0);
    final remainingLakhs = (erp.monthlySalesRemaining / 100000).toStringAsFixed(1);
    final monthlyRatio = erp.monthlySalesAchievedRatio;
    final dailyRatio = (erp.callsCompletedTodayCount / erp.dailyColdCallTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Performance & Targets',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // -------------------------------------------------------------
            // SECTION 1: Monthly Sales Target Card
            // -------------------------------------------------------------
            _buildMonthlyTargetSection(
              achievedLakhs: achievedLakhs,
              targetLakhs: targetLakhs,
              remainingLakhs: remainingLakhs,
              ratio: monthlyRatio,
            ),
            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // SECTION 2: Daily Cold Calls Target Card
            // -------------------------------------------------------------
            _buildDailyCallsSection(
              completed: erp.callsCompletedTodayCount,
              target: erp.dailyColdCallTarget,
              pending: erp.pendingColdCallsTodayCount,
              ratio: dailyRatio,
            ),
            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // SECTION 3: Weekly Performance & Comparison
            // -------------------------------------------------------------
            _buildWeeklyComparisonSection(
              totals: erp.weeklyCallTotals,
              highestWeek: erp.highestPerformingWeek,
              highestCalls: erp.highestPerformingWeekCalls,
            ),
            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // SECTION 4: Conversion & Volume Metrics (2x2 Grid)
            // -------------------------------------------------------------
            const Text(
              'Sales Conversion & Efficiency',
              style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Monthly Calls',
                    value: '${erp.monthlyCallsTotal}',
                    subtitle: 'Total outreach made',
                    icon: Icons.ring_volume_rounded,
                    color: const Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Closed vs Lost',
                    value: '${erp.dealsClosedCount} Won / ${erp.dealsLostCount} Lost',
                    subtitle: '80% Win Ratio',
                    icon: Icons.handshake_rounded,
                    color: const Color(0xFF34D399),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Conversion Rate',
                    value: '${erp.callConversionRate}%',
                    subtitle: 'Call-to-deal closed',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFFFBBF24),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Follow-up Rate',
                    value: '${(erp.followUpCompletionRate * 100).toInt()}%',
                    subtitle: 'On-time completion',
                    icon: Icons.task_alt_rounded,
                    color: const Color(0xFFA78BFA),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // SECTION 5: Sales SLA & Quality Rating Card
            // -------------------------------------------------------------
            _buildQualityCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTargetSection({
    required String achievedLakhs,
    required String targetLakhs,
    required String remainingLakhs,
    required double ratio,
  }) {
    final pct = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
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
                  Icon(Icons.flag_rounded, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Monthly Sales Target',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pct% Achieved',
                  style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Achieved Amount', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '₹$achievedLakhs Lakhs',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Remaining Amount', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '₹$remainingLakhs Lakhs',
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Target Amount', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '₹$targetLakhs Lakhs',
                    style: const TextStyle(color: Color(0xFF212529), fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCallsSection({
    required int completed,
    required int target,
    required int pending,
    required double ratio,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  Icon(Icons.phone_in_talk_rounded, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Daily Cold Calls Target',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Text(
                '$completed / $target Calls',
                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pending > 0
                ? '$pending more calls required today to hit your 20-call minimum quota.'
                : 'Congratulations! You have completed today\'s minimum cold-call target.',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(
                ratio >= 1.0 ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparisonSection({
    required List<int> totals,
    required int highestWeek,
    required int highestCalls,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  Icon(Icons.bar_chart_rounded, color: Color(0xFFA78BFA), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Weekly Call Comparison',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Highest: Wk $highestWeek',
                  style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(totals.length, (idx) {
              final wk = idx + 1;
              final count = totals[idx];
              final isHighest = wk == highestWeek;
              final barRatio = count / 60.0;

              return Column(
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      color: isHighest ? const Color(0xFFA78BFA) : Colors.white,
                      fontSize: 12,
                      fontWeight: isHighest ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 34,
                    height: 60,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      width: 34,
                      height: 60 * barRatio,
                      decoration: BoxDecoration(
                        color: isHighest ? const Color(0xFF8B5CF6) : const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wk $wk',
                    style: TextStyle(
                      color: isHighest ? const Color(0xFFA78BFA) : const Color(0xFF64748B),
                      fontSize: 11,
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

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
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
            style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_rounded, color: Color(0xFF34D399), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales Outreach Quality Score: 94%',
                  style: TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Avg response time < 2 hours • 4.8 / 5.0 client feedback score.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
