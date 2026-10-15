import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/user_role.dart';
import '../screens/auth/login_screen.dart';

/// Digital Inertia ERP — Universal App Navigation Drawer / Desktop Sidebar
/// Supports both modal slide-out drawer mode and persistent desktop sidebar mode.
/// Follows ultra-clean monochrome branding with Instrument Sans.
class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onOpenAdmin;
  final VoidCallback onOpenAlerts;
  final bool isDrawer;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required this.onOpenAdmin,
    required this.onOpenAlerts,
    this.isDrawer = true,
  });

  void _handleItemTap(BuildContext context, int tabIndex) {
    if (isDrawer) {
      Navigator.of(context).pop();
    }
    onSelectTab(tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final userInitial = erp.currentUserName.isNotEmpty ? erp.currentUserName[0].toUpperCase() : 'D';

    return Container(
      width: 270,
      color: const Color(0xFF212529),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BRANDING HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: Text(
                            'DI',
                            style: GoogleFonts.instrumentSans(
                              color: const Color(0xFF212529),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
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
                              'Digital Inertia',
                              style: GoogleFonts.instrumentSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'STRATEGIC CONSULTING',
                              style: GoogleFonts.instrumentSans(
                                color: const Color(0xFFADB5BD),
                                fontWeight: FontWeight.w700,
                                fontSize: 8.5,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // User Dossier Card
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Text(
                            userInitial,
                            style: GoogleFonts.instrumentSans(
                              color: const Color(0xFF212529),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                erp.currentUserName,
                                style: GoogleFonts.instrumentSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                erp.currentRole.label.split(' / ').first,
                                style: GoogleFonts.instrumentSans(
                                  color: const Color(0xFFADB5BD),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF343A40), height: 1),

            // 2. DEMO PERSONA SWITCHER RIBBON
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SWITCH DEMO ROLE',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 9,
                      color: const Color(0xFFADB5BD),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildQuickRoleChip('CEO', UserRole.ceo, erp),
                      _buildQuickRoleChip('Tech Lead', UserRole.technical, erp),
                      _buildQuickRoleChip('Sales BD', UserRole.sales, erp),
                      _buildQuickRoleChip('Finance', UserRole.finance, erp),
                      _buildQuickRoleChip('HR', UserRole.hr, erp),
                      _buildQuickRoleChip('Intern', UserRole.intern, erp),
                    ],
                  ),
                ],
              ),
            ),

            // 3. NAVIGATION MODULES (All Connected Modules)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  _buildDrawerItem(
                    label: 'Executive Home',
                    icon: Icons.dashboard_rounded,
                    isSelected: currentIndex == 0,
                    onTap: () => _handleItemTap(context, 0),
                  ),
                  _buildDrawerItem(
                    label: 'Employees Directory',
                    icon: Icons.people_outline_rounded,
                    isSelected: currentIndex == 1,
                    onTap: () => _handleItemTap(context, 1),
                  ),
                  _buildDrawerItem(
                    label: 'Interns & Recruitment',
                    icon: Icons.school_outlined,
                    isSelected: currentIndex == 2,
                    badgeCount: erp.activeInternsCount,
                    onTap: () => _handleItemTap(context, 2),
                  ),
                  _buildDrawerItem(
                    label: 'Tasks & Agile',
                    icon: Icons.check_circle_outline_rounded,
                    isSelected: currentIndex == 3,
                    badgeCount: erp.allTasks.any((t) => !t.isCompleted) ? erp.allTasks.where((t) => !t.isCompleted).length : null,
                    onTap: () => _handleItemTap(context, 3),
                  ),
                  _buildDrawerItem(
                    label: 'Sales & 12-Stage Pipeline',
                    icon: Icons.trending_up_rounded,
                    isSelected: currentIndex == 4,
                    badgeCount: erp.followUpsDueTodayCount > 0 ? erp.followUpsDueTodayCount : null,
                    onTap: () => _handleItemTap(context, 4),
                  ),
                  _buildDrawerItem(
                    label: 'Projects Portfolio',
                    icon: Icons.folder_open_rounded,
                    isSelected: currentIndex == 5,
                    badgeCount: erp.overbudgetProjects.isNotEmpty ? erp.overbudgetProjects.length : null,
                    onTap: () => _handleItemTap(context, 5),
                  ),
                  _buildDrawerItem(
                    label: 'Executive Approvals',
                    icon: Icons.verified_user_outlined,
                    isSelected: currentIndex == 7,
                    badgeCount: erp.pendingApprovals.isNotEmpty ? erp.pendingApprovals.length : null,
                    onTap: () => _handleItemTap(context, 7),
                  ),
                  _buildDrawerItem(
                    label: 'Calendar & Meetings',
                    icon: Icons.calendar_month_outlined,
                    isSelected: currentIndex == 8,
                    onTap: () => _handleItemTap(context, 8),
                  ),
                  _buildDrawerItem(
                    label: 'Departments Hub',
                    icon: Icons.domain_rounded,
                    isSelected: currentIndex == 9,
                    onTap: () => _handleItemTap(context, 9),
                  ),
                  _buildDrawerItem(
                    label: 'Task Widget Studio',
                    icon: Icons.widgets_outlined,
                    isSelected: currentIndex == 10,
                    onTap: () => _handleItemTap(context, 10),
                  ),
                  _buildDrawerItem(
                    label: 'Threshold Alerts',
                    icon: Icons.notifications_none_rounded,
                    badgeCount: erp.thresholdAlerts.isNotEmpty ? erp.thresholdAlerts.length : null,
                    isSelected: false,
                    onTap: () {
                      if (isDrawer) Navigator.of(context).pop();
                      onOpenAlerts();
                    },
                  ),
                  _buildDrawerItem(
                    label: 'Admin Control Centre',
                    icon: Icons.admin_panel_settings_outlined,
                    isSelected: currentIndex == 6,
                    onTap: () => _handleItemTap(context, 6),
                  ),
                ],
              ),
            ),

            // 4. BOTTOM SIGN OUT
            const Divider(color: Color(0xFF343A40), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.instrumentSans(
                          color: Colors.white,
                          fontSize: 13,
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
    return GestureDetector(
      onTap: () {
        erp.switchToDemoMode();
        erp.setRole(role);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.instrumentSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? const Color(0xFF212529) : Colors.white,
          ),
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
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF212529) : const Color(0xFFADB5BD),
          size: 18,
        ),
        title: Text(
          label,
          style: GoogleFonts.instrumentSans(
            color: isSelected ? const Color(0xFF212529) : const Color(0xFFCED4DA),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: badgeCount != null && badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF212529) : const Color(0xFFE03131),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.instrumentSans(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
