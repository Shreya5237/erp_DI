import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import 'pages/hr_dashboard_page.dart';
import 'pages/hr_staffing_requests_page.dart';
import 'pages/hr_onboarding_trainees_page.dart';
import 'pages/hr_tasks_calendar_page.dart';
import 'pages/hr_profile_page.dart';
import 'pages/hr_pipeline_coordination_page.dart';
import 'pages/hr_leave_management_page.dart';
import 'widgets/hr_notifications_sheet.dart';

/// Main navigation shell for the dedicated HR Mobile App
/// Implements 5-item bottom nav (Home, People, Trainees, Calendar, Profile),
/// Top bar brand, Leads Pipeline shortcut, Leave Management access, and unified Notifications Bell system.
class HrNavigationScreen extends StatefulWidget {
  const HrNavigationScreen({super.key});

  @override
  State<HrNavigationScreen> createState() => _HrNavigationScreenState();
}

class _HrNavigationScreenState extends State<HrNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final pendingLeavesCount = erp.pendingLeaveRequests.length;
    final pendingStaffingCount = erp.pendingStaffingRequests.length;
    final pendingChangesCount = erp.pendingCustomerChangeRequests.length;
    final attentionTraineesCount = erp.traineesNeedingAttention.length;
    final totalAlertsCount = pendingLeavesCount + pendingStaffingCount + pendingChangesCount + (attentionTraineesCount > 0 ? 1 : 0);

    final pages = [
      HrDashboardPage(
        onNavigateToStaffing: () => setState(() => _currentIndex = 1),
        onNavigateToTrainees: () => setState(() => _currentIndex = 2),
        onNavigateToCalendar: () => setState(() => _currentIndex = 3),
      ),
      const HrStaffingRequestsPage(),
      const HrOnboardingTraineesPage(),
      const HrTasksCalendarPage(),
      const HrProfilePage(),
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
              child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DI HR',
                  style: TextStyle(
                    color: Color(0xFF212529),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'People & Talent Operations',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Leave Management Shortcut Icon
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.beach_access_rounded, color: Color(0xFF212529), size: 21),
                if (pendingLeavesCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingLeavesCount',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Leave Management',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HrLeaveManagementPage()),
              );
            },
          ),

          // Leads Pipeline & Project Coordination Shortcut
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.handshake_rounded, color: Color(0xFF212529), size: 21),
                if (pendingChangesCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingChangesCount',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Pipeline Coordination',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HrPipelineCoordinationPage()),
              );
            },
          ),

          // Unified Notification Bell
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Color(0xFF212529), size: 22),
                if (totalAlertsCount > 0)
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
            tooltip: 'HR Alerts',
            onPressed: () => HrNotificationsSheet.show(context),
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
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group_rounded, color: Color(0xFF212529)),
              label: 'People',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded, color: Color(0xFF212529)),
              label: 'Trainees',
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
