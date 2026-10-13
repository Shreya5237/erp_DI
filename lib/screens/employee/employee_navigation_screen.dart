import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import 'pages/employee_dashboard_page.dart';
import 'pages/employee_projects_page.dart';
import 'pages/employee_tasks_page.dart';
import 'pages/employee_calendar_page.dart';
import 'pages/employee_profile_page.dart';
import 'widgets/employee_notifications_sheet.dart';

/// Screen Container: Dedicated Employee Mobile App Shell
/// Provides fixed bottom navigation across 5 specialized pages:
/// 1. Home (Dashboard)
/// 2. Projects
/// 3. Tasks & Schedule
/// 4. Calendar
/// 5. Profile
///
/// Top bar includes company branding, mode telemetry, and notification bell.
/// Fully isolated from CEO and Sales portals: accessible through login only.
class EmployeeNavigationScreen extends StatefulWidget {
  const EmployeeNavigationScreen({super.key});

  @override
  State<EmployeeNavigationScreen> createState() => _EmployeeNavigationScreenState();
}

class _EmployeeNavigationScreenState extends State<EmployeeNavigationScreen> {
  int _currentIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _openNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EmployeeNotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    // Calculate active alerts count for notification badge
    final overdueCount = erp.myEmployeeTasks.where((t) => t.isOverdue).length;
    final meetingsCount = erp.myEmployeeMeetings.length;
    final totalAlerts = overdueCount + meetingsCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF212529),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'Di',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 8,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Text(
                      'Digital Inertia',
                      style: TextStyle(
                        color: Color(0xFF212529),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Employee Workspace • ${erp.currentUserName.split(" ").first}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Distinct Mode Badge (Live API vs Demo Mode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: erp.isLiveMode ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: erp.isLiveMode ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  width: 0.8,
                ),
              ),
              child: Text(
                erp.isLiveMode ? 'LIVE' : 'DEMO',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: erp.isLiveMode ? const Color(0xFF065F46) : const Color(0xFF92400E),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Notification Bell with dynamic unread count
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF212529), size: 24),
                  tooltip: 'Alerts & Reminders',
                  onPressed: _openNotificationsSheet,
                ),
                if (totalAlerts > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$totalAlerts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: Home (Dashboard)
          EmployeeDashboardPage(
            onNavigateToTasks: () => setState(() => _currentIndex = 2),
            onNavigateToCalendar: () => setState(() => _currentIndex = 3),
          ),
          // 1: Projects
          const EmployeeProjectsPage(),
          // 2: Tasks & Schedule
          const EmployeeTasksPage(),
          // 3: Calendar
          const EmployeeCalendarPage(),
          // 4: Profile
          const EmployeeProfilePage(),
        ],
      ),
      // Fixed 5-tab Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE9ECEF), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF212529).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF212529),
          unselectedItemColor: const Color(0xFF6C757D),
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              activeIcon: Icon(Icons.task_alt_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
