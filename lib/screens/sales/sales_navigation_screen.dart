import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/sales_dashboard_page.dart';
import 'pages/sales_cold_calls_page.dart';
import 'pages/sales_deals_pipeline_page.dart';
import 'pages/sales_calendar_page.dart';
import 'pages/sales_performance_page.dart';
import 'pages/sales_profile_page.dart';

/// Main navigation shell for the dedicated Sales Workspace Mobile Portal
/// Implements the 5 bottom navigation tabs matching the official specification:
/// 1. Home (SalesDashboardPage)
/// 2. Calls (SalesColdCallsPage)
/// 3. Deals (SalesDealsPipelinePage)
/// 4. Calendar (SalesCalendarPage)
/// 5. Profile (SalesProfilePage)
///
/// Additional views (Follow-ups, Schedule, Performance) are accessible through
/// relevant pages (e.g. Quick Actions, overview cards, and profile links).
class SalesNavigationScreen extends StatefulWidget {
  const SalesNavigationScreen({super.key});

  @override
  State<SalesNavigationScreen> createState() => _SalesNavigationScreenState();
}

class _SalesNavigationScreenState extends State<SalesNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      SalesDashboardPage(
        onNavigateToCalls: () => setState(() => _currentIndex = 1),
        onNavigateToDeals: () => setState(() => _currentIndex = 2),
        onNavigateToCalendar: () => setState(() => _currentIndex = 3),
        onNavigateToMetrics: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SalesPerformancePage()),
          );
        },
        onNavigateToProfile: () => setState(() => _currentIndex = 4),
      ),
      const SalesColdCallsPage(),
      const SalesDealsPipelinePage(),
      const SalesCalendarPage(),
      const SalesProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE9ECEF))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF212529),
          unselectedItemColor: const Color(0xFF868E96),
          selectedLabelStyle: GoogleFonts.instrumentSans(
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
          ),
          unselectedLabelStyle: GoogleFonts.instrumentSans(
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
          ),
          selectedFontSize: 10.5,
          unselectedFontSize: 10.5,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded, color: Color(0xFF212529)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_outlined),
              activeIcon: Icon(Icons.phone_rounded, color: Color(0xFF212529)),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center_outlined),
              activeIcon: Icon(Icons.business_center_rounded, color: Color(0xFF212529)),
              label: 'Deals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
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
