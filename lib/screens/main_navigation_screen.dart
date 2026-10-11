import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/erp_provider.dart';
import '../widgets/app_drawer.dart';
import 'dashboard/ceo_dashboard_screen.dart';
import 'employees/employee_list_screen.dart';
import 'interns/intern_list_screen.dart';
import 'tasks/task_list_screen.dart';
import 'projects/project_list_screen.dart';
import 'leads/lead_list_screen.dart';
import 'alerts/alerts_screen.dart';
import 'admin/admin_screen.dart';

/// Main Navigation Container matching the bottom bar and drawer in screenshots
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  // 0: Home (Dashboard)
  // 1: Employees
  // 2: Interns
  // 3: Tasks
  // 4: Leads
  // 5: Projects
  // 6: Admin

  int _bottomNavIndex = 0;
  // 0: Home
  // 1: People (toggle between Employees / Interns)
  // 2: Tasks
  // 3: Projects
  // 4: More (Leads / Drawer)

  bool _isShowingInternsInPeople = false;

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      if (index == 0) {
        _currentIndex = 0; // Home
      } else if (index == 1) {
        _currentIndex = _isShowingInternsInPeople ? 2 : 1; // People
      } else if (index == 2) {
        _currentIndex = 3; // Tasks
      } else if (index == 3) {
        _currentIndex = 5; // Projects
      } else if (index == 4) {
        _currentIndex = 4; // Leads (or More)
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
        bodyWidget = CeoDashboardScreen(
          onNavigateTab: (tabIdx) {
            _onDrawerSelect(tabIdx);
          },
        );
        break;
      case 1:
        bodyWidget = Column(
          children: [
            // Top toggle between Employees and Interns in People tab
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
      default:
        bodyWidget = const CeoDashboardScreen();
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onSelectTab: _onDrawerSelect,
        onOpenAdmin: () {
          setState(() {
            _currentIndex = 6;
          });
        },
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
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A), size: 24),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Circular "Di" logo badge matching Screen 2
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
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
            const SizedBox(width: 8),
            const Text(
              'Digital Inertia',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Notification bell with red badge for alerts
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0F172A), size: 22),
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
          // User avatar circle
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'L',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
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
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: _onBottomNavTapped,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF0F172A),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'People',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline_rounded),
              activeIcon: Icon(Icons.check_circle_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'More',
            ),
          ],
        ),
      ),
    );
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
                  color: !_isShowingInternsInPeople ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
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
                  color: _isShowingInternsInPeople ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Interns',
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
