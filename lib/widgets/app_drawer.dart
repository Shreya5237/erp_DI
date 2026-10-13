import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/user_role.dart';
import '../screens/auth/login_screen.dart';
import '../screens/employee/pages/employee_calendar_page.dart';

/// Dark modern drawer navigation with full modular coverage and Persona Switcher
class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onOpenAdmin;
  final VoidCallback onOpenAlerts;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required this.onOpenAdmin,
    required this.onOpenAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    return Drawer(
      backgroundColor: const Color(0xFF212529),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _getRoleColor(erp.currentRole),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            erp.currentUserName[0],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              erp.currentUserName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              erp.currentRole.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: _getRoleColor(erp.currentRole),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.corporate_fare_rounded, size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      const Text(
                        'Digital Inertia • Enterprise ERP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF262C33), height: 1),

            // Demo Account Switcher Ribbon
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SWITCH DEMO PERSONA',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildQuickRoleChip('CEO', UserRole.ceo, erp),
                      const SizedBox(width: 6),
                      _buildQuickRoleChip('Sales', UserRole.sales, erp),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                children: [
                  _buildDrawerItem(
                    label: 'Dashboard',
                    icon: Icons.dashboard_outlined,
                    isSelected: currentIndex == 0,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(0);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Employees',
                    icon: Icons.people_outline,
                    isSelected: currentIndex == 1,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(1);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Interns & Recruitment',
                    icon: Icons.school_outlined,
                    isSelected: currentIndex == 2,
                    badgeCount: erp.activeInternsCount,
                    isSelectedBadge: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(2);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Tasks & Agile',
                    icon: Icons.check_circle_outline,
                    isSelected: currentIndex == 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(3);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Sales & 12-Stage Pipeline',
                    icon: Icons.trending_up,
                    isSelected: currentIndex == 4,
                    badgeCount: erp.followUpsDueTodayCount,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(4);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Projects',
                    icon: Icons.folder_open_outlined,
                    isSelected: currentIndex == 5,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(5);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Departments',
                    icon: Icons.domain_rounded,
                    isSelected: currentIndex == 9,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(9);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Approvals Hub',
                    icon: Icons.assignment_turned_in_outlined,
                    isSelected: currentIndex == 7,
                    badgeCount: erp.pendingApprovals.length,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(7);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Meetings & Sync',
                    icon: Icons.event_available_outlined,
                    isSelected: currentIndex == 8,
                    badgeCount: erp.todayMeetings.length,
                    isSelectedBadge: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(8);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Employee Calendar',
                    icon: Icons.calendar_month_outlined,
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EmployeeCalendarPage(
                            showAppBar: true,
                            allowEmployeeSwitching: true,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    label: 'iPhone Task Widget',
                    icon: Icons.widgets_outlined,
                    isSelected: currentIndex == 10,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(10);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Threshold Alerts',
                    icon: Icons.notifications_none_rounded,
                    badgeCount: erp.thresholdAlerts.length,
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      onOpenAlerts();
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Admin & Settings',
                    icon: Icons.settings_outlined,
                    isSelected: currentIndex == 6,
                    onTap: () {
                      Navigator.of(context).pop();
                      onOpenAdmin();
                    },
                  ),
                ],
              ),
            ),

            // Bottom Logout
            const Divider(color: Color(0xFF262C33), height: 1),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  erp.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRoleChip(String label, UserRole role, ErpProvider erp) {
    final isSelected = erp.currentRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          erp.switchToDemoMode();
          erp.setRole(role);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFF212529) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.ceo:
        return const Color(0xFFF59E0B);
      case UserRole.sales:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF0284C7);
    }
  }

  Widget _buildDrawerItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
    bool isSelectedBadge = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF212529) : const Color(0xFFADB5BD),
          size: 19,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF212529) : const Color(0xFFCED4DA),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: badgeCount != null && badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelectedBadge ? const Color(0xFF0284C7) : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
