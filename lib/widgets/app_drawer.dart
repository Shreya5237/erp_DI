import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/erp_provider.dart';
import '../screens/auth/login_screen.dart';

/// Dark modern drawer navigation matching Screen 3
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
      backgroundColor: const Color(0xFF14171A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'L',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF14171A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            erp.currentUserName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            erp.currentRole.label.split(' ')[0],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.corporate_fare_rounded, size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      const Text(
                        'Digital Inertia',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF262C33), height: 1),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    label: 'Interns',
                    icon: Icons.school_outlined,
                    isSelected: currentIndex == 2,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(2);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Tasks',
                    icon: Icons.check_circle_outline,
                    isSelected: currentIndex == 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTab(3);
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Leads',
                    icon: Icons.trending_up,
                    isSelected: currentIndex == 4,
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
                    label: 'Alerts',
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
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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

  Widget _buildDrawerItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF14171A) : const Color(0xFFCBD5E1),
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF14171A) : const Color(0xFFCBD5E1),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: badgeCount != null && badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
