import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import 'pages/employee_dashboard_page.dart';
import 'pages/employee_projects_page.dart';
import 'pages/employee_calendar_page.dart';
import 'pages/employee_profile_page.dart';
import 'widgets/employee_notifications_sheet.dart';

/// Screen Container: Dedicated Technical Employee Mobile App Shell
/// Provides sticky, responsive 4-destination bottom navigation bar:
/// 0. Home: Main sketch overview dashboard (Quick metrics, Today's tasks, Projects, Meetings)
/// 1. Projects: Filtered view of all assigned project cards with live progress bars
/// 2. Calendar: Interactive Day / Week / Month schedule along with different tags & tasks breakdown
/// 3. Profile: User account, leave request management, settings, and personal target
class EmployeeNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const EmployeeNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<EmployeeNavigationScreen> createState() => _EmployeeNavigationScreenState();
}

class _EmployeeNavigationScreenState extends State<EmployeeNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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
    final unreadCount = erp.unreadEmployeeAlertsCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      // Sleek top AppBar for secondary tabs (Home has its own custom sketch header)
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF212529)),
                onPressed: () => setState(() => _currentIndex = 0),
                tooltip: 'Back to Home',
              ),
              title: Text(
                _getAppBarTitle(_currentIndex),
                style: TextStyle(
                  fontFamily: GoogleFonts.instrumentSans().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF212529),
                  letterSpacing: -0.3,
                ),
              ),
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF212529), size: 24),
                      tooltip: 'Alerts & Reminders',
                      onPressed: _openNotificationsSheet,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE11D48),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: TextStyle(
                                fontFamily: GoogleFonts.instrumentSans().fontFamily,
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: Home (Main Sketch Dashboard)
          EmployeeDashboardPage(
            onNavigateToProjects: () => setState(() => _currentIndex = 1),
            onNavigateToCalendar: () => setState(() => _currentIndex = 2),
            onNavigateToTasks: () => setState(() => _currentIndex = 2),
            onNavigateToProfile: () => setState(() => _currentIndex = 3),
          ),
          // 1: Projects (Filtered view of all assigned project cards)
          const EmployeeProjectsPage(),
          // 2: Calendar (Interactive Day / Week / Month schedule with tags and tasks breakdown)
          const EmployeeCalendarPage(),
          // 3: Profile (User account, leave request management, and settings)
          const EmployeeProfilePage(),
        ],
      ),
      // Sticky 4-Destination Bottom Navigation Bar matching design specification
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE9ECEF), width: 1.2),
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
          unselectedItemColor: const Color(0xFF868E96),
          selectedLabelStyle: TextStyle(
            fontFamily: GoogleFonts.instrumentSans().fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: GoogleFonts.instrumentSans().fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Projects',
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

  String _getAppBarTitle(int index) {
    switch (index) {
      case 1:
        return 'Assigned Projects';
      case 2:
        return 'Work Calendar & Schedule';
      case 3:
        return 'Profile & Account';
      default:
        return 'Dashboard';
    }
  }
}
