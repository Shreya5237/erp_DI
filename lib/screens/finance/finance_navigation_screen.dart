import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        titleSpacing: 16,
        title: Row(
          children: [
            // Branding Icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'DI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DI Finance',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Financial Operations & Budgets',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF868E96),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
                      padding: const EdgeInsets.all(3.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF212529),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${erp.financeReviewLeads.length}',
                        style: GoogleFonts.instrumentSans(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
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

          // Notification Bell with unread badges
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
                        color: Color(0xFF212529),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Finance Alerts',
            onPressed: () => FinanceNotificationsSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE9ECEF), width: 1)),
        ),
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Row(
          children: [
            Expanded(child: _buildNavItem(index: 0, label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home_rounded)),
            Expanded(child: _buildNavItem(index: 1, label: 'Budgets', icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded)),
            Expanded(child: _buildNavItem(index: 2, label: 'Requests', icon: Icons.description_outlined, activeIcon: Icons.description_rounded)),
            Expanded(child: _buildNavItem(index: 3, label: 'Calendar', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded)),
            Expanded(child: _buildNavItem(index: 4, label: 'Profile', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF212529) : const Color(0xFF868E96),
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                color: isSelected ? const Color(0xFF212529) : const Color(0xFF868E96),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            // Dot indicator matching inspiration mockup
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF212529) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
