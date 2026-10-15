import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/user_role.dart';
import 'widgets/ceo_header.dart';
import 'widgets/ceo_sidebar.dart';
import 'pages/ceo_overview_page.dart';
import 'pages/ceo_departments_page.dart';
import 'pages/ceo_people_page.dart';
import 'pages/ceo_projects_page.dart';
import 'pages/ceo_pipeline_page.dart';
import 'pages/ceo_finance_page.dart';
import 'pages/ceo_approvals_page.dart';
import 'pages/ceo_calendar_page.dart';
import 'pages/ceo_tasks_page.dart';
import 'pages/ceo_daily_reports_page.dart';
import 'pages/ceo_control_centre_page.dart';
import 'pages/ceo_profile_settings_page.dart';

/// Executive Application Shell & Navigation Shell (Specification Section 3 & 14)
/// Provides:
/// - Persistent sidebar on desktop (expandable/collapsible) & slide-out drawer on mobile
/// - Top executive header with live alerts, sync status, search, and actions
/// - 12 authorized executive modules
class CeoExecutiveShellScreen extends StatefulWidget {
  final int initialModuleIndex;

  const CeoExecutiveShellScreen({
    super.key,
    this.initialModuleIndex = 0,
  });

  @override
  State<CeoExecutiveShellScreen> createState() => _CeoExecutiveShellScreenState();
}

class _CeoExecutiveShellScreenState extends State<CeoExecutiveShellScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentModuleIndex;
  bool _isSidebarCollapsed = false;

  final List<String> _moduleTitles = [
    'Executive Overview', // 0
    'People & Departments', // 1
    'Projects & Tasks', // 2
    'Clients & Business', // 3
    'Finance & Approvals', // 4
    'Calendar & Notifications', // 5
    'Reports & Control Centre', // 6
    'Approvals & Requests', // 7
    'Tasks & Deadlines', // 8
    'Daily Reports & Analytics', // 9
    'Departments Directory', // 10
    'My Profile & Settings', // 11
  ];

  @override
  void initState() {
    super.initState();
    _currentModuleIndex = widget.initialModuleIndex;
  }

  void _onSelectModule(int index) {
    setState(() => _currentModuleIndex = index);
  }

  int _getBottomNavIndex() {
    if (_currentModuleIndex == 0) return 0;
    if (_currentModuleIndex == 2 || _currentModuleIndex == 8) return 1;
    if (_currentModuleIndex == 4) return 2;
    if (_currentModuleIndex == 7 || _currentModuleIndex == 6) return 3;
    return 4; // Menu for other modules
  }

  void _onBottomNavTapped(int navIndex) {
    switch (navIndex) {
      case 0:
        _onSelectModule(0); // Overview
        break;
      case 1:
        _onSelectModule(2); // Projects & Tasks
        break;
      case 2:
        _onSelectModule(4); // Finance & Approvals
        break;
      case 3:
        _onSelectModule(7); // Approvals
        break;
      case 4:
        _scaffoldKey.currentState?.openDrawer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    // Security Gate: Verify CEO or GM role
    if (erp.currentRole != UserRole.ceo && erp.currentRole != UserRole.gm) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6F7),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 48, color: Color(0xFFE03131)),
                const SizedBox(height: 16),
                const Text(
                  'Access Restricted',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your authenticated identity (${erp.currentUserName} • ${erp.currentRole.label}) is not authorized for executive CEO workspace administration.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pendingApprovalsCount = erp.pendingApprovals.length + erp.pendingResourceRequests.length;

    // 7 Core Workspaces + Deep Navigation mapping
    Widget activePage;
    switch (_currentModuleIndex) {
      case 0:
        activePage = CeoOverviewPage(onNavigateModule: _onSelectModule);
        break;
      case 1:
        activePage = CeoPeoplePage(onNavigateModule: _onSelectModule);
        break;
      case 2:
        activePage = CeoProjectsPage(onNavigateModule: _onSelectModule);
        break;
      case 3:
        activePage = CeoPipelinePage(onNavigateModule: _onSelectModule);
        break;
      case 4:
        activePage = CeoFinancePage(onNavigateModule: _onSelectModule);
        break;
      case 5:
        activePage = CeoCalendarPage(onNavigateModule: _onSelectModule);
        break;
      case 6:
        activePage = CeoControlCentrePage(onNavigateModule: _onSelectModule);
        break;
      case 7:
        activePage = CeoApprovalsPage(onNavigateModule: _onSelectModule);
        break;
      case 8:
        activePage = CeoTasksPage(onNavigateModule: _onSelectModule);
        break;
      case 9:
        activePage = CeoDailyReportsPage(onNavigateModule: _onSelectModule);
        break;
      case 10:
        activePage = CeoDepartmentsPage(onNavigateModule: _onSelectModule);
        break;
      case 11:
        activePage = CeoProfileSettingsPage(onNavigateModule: _onSelectModule);
        break;
      default:
        activePage = CeoOverviewPage(onNavigateModule: _onSelectModule);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6F7),
      drawer: isDesktop
          ? null
          : CeoSidebar(
              currentIndex: _currentModuleIndex,
              onSelectModule: _onSelectModule,
              isDrawer: true,
            ),
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE9ECEF), width: 1.0),
                ),
              ),
              child: SafeArea(
                child: BottomNavigationBar(
                  currentIndex: _getBottomNavIndex(),
                  onTap: _onBottomNavTapped,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF212529),
                  unselectedItemColor: const Color(0xFF868E96),
                  selectedFontSize: 11,
                  unselectedFontSize: 11,
                  elevation: 0,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined),
                      activeIcon: Icon(Icons.dashboard_rounded),
                      label: 'Overview',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.folder_open_outlined),
                      activeIcon: Icon(Icons.folder_rounded),
                      label: 'Projects',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_outlined),
                      activeIcon: Icon(Icons.account_balance_rounded),
                      label: 'Finance',
                    ),
                    BottomNavigationBarItem(
                      icon: Badge(
                        isLabelVisible: pendingApprovalsCount > 0,
                        label: Text(
                          '$pendingApprovalsCount',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFFE03131),
                        child: const Icon(Icons.fact_check_outlined),
                      ),
                      activeIcon: Badge(
                        isLabelVisible: pendingApprovalsCount > 0,
                        label: Text(
                          '$pendingApprovalsCount',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFFE03131),
                        child: const Icon(Icons.fact_check_rounded),
                      ),
                      label: 'Approvals',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.menu_rounded),
                      activeIcon: Icon(Icons.menu_open_rounded),
                      label: 'Menu',
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        children: [
          // Persistent Sidebar for Desktop
          if (isDesktop)
            CeoSidebar(
              currentIndex: _currentModuleIndex,
              onSelectModule: _onSelectModule,
              isCollapsed: _isSidebarCollapsed,
              onToggleCollapse: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            ),

          // Main Workspace Area
          Expanded(
            child: Column(
              children: [
                // Executive Header
                CeoHeader(
                  currentModuleName: _currentModuleIndex < _moduleTitles.length
                      ? _moduleTitles[_currentModuleIndex]
                      : 'Executive Workspace',
                  onToggleSidebar: () => _scaffoldKey.currentState?.openDrawer(),
                  onNavigateModule: _onSelectModule,
                ),

                // Active Module Content
                Expanded(
                  child: activePage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
