import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import 'pages/finance_dashboard_page.dart';
import 'pages/finance_budgets_page.dart';
import 'pages/finance_resource_requests_page.dart';
import 'pages/finance_leads_pipeline_page.dart';
import 'pages/finance_tasks_calendar_page.dart';
import 'pages/finance_profile_page.dart';
import 'widgets/finance_notifications_sheet.dart';

/// Main navigation shell for the dedicated Finance Mobile App
/// Implements 5-item bottom nav (Home, Budgets, Requests, Calendar, Profile),
/// Top bar brand, Leads Pipeline shortcut, and unified Notifications Bell system.
class FinanceNavigationScreen extends StatefulWidget {
  const FinanceNavigationScreen({super.key});

  @override
  State<FinanceNavigationScreen> createState() => _FinanceNavigationScreenState();
}

class _FinanceNavigationScreenState extends State<FinanceNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final overbudgetCount = erp.overbudgetProjects.length;
    final thresholdCount = erp.thresholdAlertProjects.length;
    final pendingRequestsCount = erp.pendingResourceRequests.length;
    final unreadAlertsCount = overbudgetCount + thresholdCount + (pendingRequestsCount > 0 ? 1 : 0);

    final pages = [
      FinanceDashboardPage(
        onNavigateToBudgets: () => setState(() => _currentIndex = 1),
        onNavigateToRequests: () => setState(() => _currentIndex = 2),
        onNavigateToCalendar: () => setState(() => _currentIndex = 3),
      ),
      const FinanceBudgetsPage(),
      const FinanceResourceRequestsPage(),
      const FinanceTasksCalendarPage(),
      const FinanceProfilePage(),
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
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DI Finance',
                  style: TextStyle(
                    color: Color(0xFF212529),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Financial Operations & Budgets',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Leads Pipeline Shortcut in Top Bar
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.trending_up_rounded, color: Color(0xFF212529), size: 21),
                if (erp.financeReviewLeads.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${erp.financeReviewLeads.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Shared Leads Pipeline',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FinanceLeadsPipelinePage()),
              );
            },
          ),

          // Notification Bell with urgent badges
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
            tooltip: 'Finance Alerts',
            onPressed: () => FinanceNotificationsSheet.show(context),
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
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF212529)),
              label: 'Budgets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded, color: Color(0xFF212529)),
              label: 'Requests',
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
