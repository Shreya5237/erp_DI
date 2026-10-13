import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import 'pages/sales_dashboard_page.dart';
import 'pages/sales_cold_calls_page.dart';
import 'pages/sales_deals_pipeline_page.dart';
import 'pages/sales_calendar_page.dart';
import 'pages/sales_profile_page.dart';
import 'pages/sales_follow_ups_page.dart';
import 'pages/sales_performance_page.dart';
import 'widgets/sales_notifications_sheet.dart';

/// Main navigation shell for the dedicated Sales Mobile App
/// Implements Section 4 (Home, Calls, Deals, Calendar, Profile)
/// and Section 2 (Top bar notification bell & alert system).
class SalesNavigationScreen extends StatefulWidget {
  const SalesNavigationScreen({super.key});

  @override
  State<SalesNavigationScreen> createState() => _SalesNavigationScreenState();
}

class _SalesNavigationScreenState extends State<SalesNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final unreadAlertsCount = erp.overdueFollowUpsCount + (erp.pendingColdCallsTodayCount > 0 ? 1 : 0);

    final pages = [
      SalesDashboardPage(
        onNavigateToCalls: () => setState(() => _currentIndex = 1),
        onNavigateToDeals: () => setState(() => _currentIndex = 2),
      ),
      const SalesColdCallsPage(),
      const SalesDealsPipelinePage(),
      const SalesCalendarPage(),
      const SalesProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 14,
        title: Row(
          children: [
            // Branding Icon
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DI Sales',
                  style: TextStyle(
                    color: Color(0xFF212529),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Growth & Outreach Portal',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Follow-ups Quick Shortcut
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.schedule_rounded, color: Color(0xFF212529), size: 21),
                if (erp.overdueFollowUpsCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${erp.overdueFollowUpsCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Follow-ups & Schedule',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SalesFollowUpsPage()),
              );
            },
          ),

          // Performance Quick Shortcut
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: Color(0xFF212529), size: 21),
            tooltip: 'Performance & Targets',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SalesPerformancePage()),
              );
            },
          ),

          // Notification Bell
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Color(0xFF212529), size: 22),
                if (unreadAlertsCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Sales Alerts',
            onPressed: () => SalesNotificationsSheet.show(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF212529),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF212529)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_in_talk_outlined),
              activeIcon: Icon(Icons.phone_in_talk_rounded, color: Color(0xFF212529)),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded),
              activeIcon: Icon(Icons.pie_chart_rounded, color: Color(0xFF212529)),
              label: 'Deals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded, color: Color(0xFF212529)),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded, color: Color(0xFF212529)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
