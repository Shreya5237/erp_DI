import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/erp_provider.dart';
import '../models/user_role.dart';
import '../widgets/app_drawer.dart';
import 'dashboard/ceo_dashboard_screen.dart';
import 'dashboard/technical_dashboard_view.dart';
import 'dashboard/sales_dashboard_view.dart';
import 'employees/employee_list_screen.dart';
import 'interns/intern_list_screen.dart';
import 'tasks/task_list_screen.dart';
import 'tasks/task_widget_screen.dart';
import 'projects/project_list_screen.dart';
import 'leads/lead_list_screen.dart';
import 'approvals/approvals_screen.dart';
import 'meetings/meetings_screen.dart';
import 'departments/department_hub_screen.dart';
import 'alerts/alerts_screen.dart';
import 'admin/admin_screen.dart';

/// Main Navigation Container providing role-based dynamic bottom navigation,
/// 1-tap persona switching, and complete modular access.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  // 0: Dashboard (Role-specific)
  // 1: Employees
  // 2: Interns
  // 3: Tasks
  // 4: Leads / Pipeline
  // 5: Projects
  // 6: Admin
  // 7: Approvals
  // 8: Meetings
  // 9: Departments
  // 10: iOS Task Widget

  int _bottomNavIndex = 0;
  bool _isShowingInternsInPeople = false;

  void _onBottomNavTapped(int index, UserRole role) {
    setState(() {
      _bottomNavIndex = index;
      if (role == UserRole.ceo || role == UserRole.gm) {
        if (index == 0) _currentIndex = 0;
        if (index == 1) _currentIndex = _isShowingInternsInPeople ? 2 : 1;
        if (index == 2) _currentIndex = 3;
        if (index == 3) _currentIndex = 5;
        if (index == 4) _currentIndex = 4;
      } else if (role == UserRole.sales) {
        if (index == 0) _currentIndex = 0;
        if (index == 1) _currentIndex = 4; // Leads / Pipeline
        if (index == 2) _currentIndex = 7; // Approvals
        if (index == 3) _currentIndex = 8; // Meetings
        if (index == 4) _currentIndex = 3; // Tasks
      } else {
        // Technical Employee
        if (index == 0) _currentIndex = 0;
        if (index == 1) _currentIndex = 3; // Tasks & Agile
        if (index == 2) _currentIndex = 5; // Projects
        if (index == 3) _currentIndex = 10; // iOS Task Widget
        if (index == 4) _currentIndex = 8; // Meetings
      }
    });
  }

  void _onDrawerSelect(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) _bottomNavIndex = 0;
      if (index == 1) {
        _bottomNavIndex = 1;
        _isShowingInternsInPeople = false;
      }
      if (index == 2) {
        _bottomNavIndex = 1;
        _isShowingInternsInPeople = true;
      }
      if (index == 3) _bottomNavIndex = 2;
      if (index == 4) _bottomNavIndex = 4;
      if (index == 5) _bottomNavIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final alertCount = erp.thresholdAlerts.length;

    Widget bodyWidget;
    switch (_currentIndex) {
      case 0:
        // Role-based home dashboard view
        if (erp.currentRole == UserRole.sales) {
          bodyWidget = SalesDashboardView(
            onOpenPipeline: () => setState(() => _currentIndex = 4),
          );
        } else if (erp.currentRole == UserRole.employee || erp.currentRole == UserRole.deptLead) {
          bodyWidget = TechnicalDashboardView(
            onOpenWidget: () => setState(() => _currentIndex = 10),
          );
        } else {
          bodyWidget = CeoDashboardScreen(
            onNavigateTab: (tabIdx) => _onDrawerSelect(tabIdx),
          );
        }
        break;
      case 1:
        bodyWidget = Column(
          children: [
            _buildPeopleSubTabs(),
            Expanded(
              child: EmployeeListScreen(
                onBack: () => setState(() => _currentIndex = 0),
              ),
            ),
          ],
        );
        break;
      case 2:
        bodyWidget = Column(
          children: [
            _buildPeopleSubTabs(),
            Expanded(
              child: InternListScreen(
                onBack: () => setState(() => _currentIndex = 0),
              ),
            ),
          ],
        );
        break;
      case 3:
        bodyWidget = TaskListScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
        break;
      case 4:
        bodyWidget = LeadListScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
        break;
      case 5:
        bodyWidget = ProjectListScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
        break;
      case 6:
        bodyWidget = AdminScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
        break;
      case 7:
        bodyWidget = ApprovalsScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
        break;
      case 8:
        bodyWidget = MeetingsScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
        break;
      case 9:
        bodyWidget = DepartmentHubScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
        break;
      case 10:
        bodyWidget = TaskWidgetScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
        break;
      default:
        bodyWidget = const CeoDashboardScreen();
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onSelectTab: _onDrawerSelect,
        onOpenAdmin: () => setState(() => _currentIndex = 6),
        onOpenAlerts: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AlertsScreen()),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF212529), size: 24),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF212529),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'Di',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Digital Inertia',
              style: TextStyle(
                color: Color(0xFF212529),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            // Distinct Mode Badge (Live API vs Demo Mode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: erp.isLiveMode ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: erp.isLiveMode ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: erp.isLiveMode ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    erp.isLiveMode ? 'LIVE API' : 'DEMO',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: erp.isLiveMode ? const Color(0xFF065F46) : const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // 1-Tap Persona Switcher Menu in AppBar
          PopupMenuButton<UserRole>(
            tooltip: 'Switch Persona',
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleTagColor(erp.currentRole).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getRoleTagColor(erp.currentRole).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getRoleShortTitle(erp.currentRole),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _getRoleTagColor(erp.currentRole),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down, size: 16, color: _getRoleTagColor(erp.currentRole)),
                ],
              ),
            ),
            onSelected: (role) {
              erp.setRole(role);
              setState(() => _currentIndex = 0);
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: UserRole.ceo,
                child: Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 16, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8),
                    Text('CEO (Laven Lokesh)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: UserRole.sales,
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded, size: 16, color: Color(0xFF059669)),
                    SizedBox(width: 8),
                    Text('Sales BD (Rajesh Kumar)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),

          // Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF212529), size: 21),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  );
                },
              ),
              if (alertCount > 0)
                Positioned(
                  right: 12,
                  top: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),

          // User Avatar
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5F6F7),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Center(
                  child: Text(
                    erp.currentUserName[0],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF212529),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: bodyWidget,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE9ECEF), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (idx) => _onBottomNavTapped(idx, erp.currentRole),
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF212529),
          unselectedItemColor: const Color(0xFF6C757D),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: _buildBottomNavItems(erp.currentRole),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(UserRole role) {
    if (role == UserRole.sales) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Cockpit'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), activeIcon: Icon(Icons.trending_up_rounded), label: 'Pipeline'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in_outlined), activeIcon: Icon(Icons.assignment_turned_in_rounded), label: 'Approvals'),
        BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), activeIcon: Icon(Icons.event_available_rounded), label: 'Sync'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), activeIcon: Icon(Icons.check_circle_rounded), label: 'Tasks'),
      ];
    } else if (role == UserRole.employee || role == UserRole.deptLead) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Cockpit'),
        BottomNavigationBarItem(icon: Icon(Icons.view_kanban_outlined), activeIcon: Icon(Icons.view_kanban_rounded), label: 'Sprint'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_open_outlined), activeIcon: Icon(Icons.folder_rounded), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.widgets_outlined), activeIcon: Icon(Icons.widgets_rounded), label: 'iOS Widget'),
        BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), activeIcon: Icon(Icons.event_available_rounded), label: 'Sync'),
      ];
    } else {
      // CEO / Admin
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Executive'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), activeIcon: Icon(Icons.people_rounded), label: 'People'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline_rounded), activeIcon: Icon(Icons.check_circle_rounded), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_open_outlined), activeIcon: Icon(Icons.folder_rounded), label: 'Projects'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), activeIcon: Icon(Icons.trending_up), label: 'Pipeline'),
      ];
    }
  }

  String _getRoleShortTitle(UserRole role) {
    switch (role) {
      case UserRole.ceo:
        return '👑 CEO';
      case UserRole.sales:
        return '💼 Sales';
      default:
        return '💻 Tech';
    }
  }

  Color _getRoleTagColor(UserRole role) {
    switch (role) {
      case UserRole.ceo:
        return const Color(0xFFF59E0B);
      case UserRole.sales:
        return const Color(0xFF059669);
      default:
        return const Color(0xFF0284C7);
    }
  }

  Widget _buildPeopleSubTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isShowingInternsInPeople = false;
                  _currentIndex = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_isShowingInternsInPeople ? const Color(0xFF212529) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Employees',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: !_isShowingInternsInPeople ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isShowingInternsInPeople = true;
                  _currentIndex = 2;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _isShowingInternsInPeople ? const Color(0xFF212529) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Friday Interns (25 in Eval)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _isShowingInternsInPeople ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
