import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import 'ceo_modals.dart';

class CeoSidebarItem {
  final int index;
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final int? badgeCount;

  const CeoSidebarItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.activeIcon,
    this.badgeCount,
  });
}

/// Persistent executive sidebar navigation supporting desktop full/collapsed rail
/// and mobile slide-out drawer behavior.
class CeoSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectModule;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final bool isDrawer;

  const CeoSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectModule,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.isDrawer = false,
  });

  List<CeoSidebarItem> _getItems(ErpProvider erp) {
    final pendingApprovals = erp.pendingApprovals.length + erp.pendingResourceRequests.length;
    final overdueTasks = erp.allTasks.where((t) => t.isOverdue && !t.isCompleted).length;
    final todayMeetings = erp.todayMeetings.length;

    return [
      const CeoSidebarItem(
        index: 0,
        title: 'Executive Overview',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
      ),
      const CeoSidebarItem(
        index: 1,
        title: 'People & Departments',
        icon: Icons.groups_outlined,
        activeIcon: Icons.groups_rounded,
      ),
      CeoSidebarItem(
        index: 2,
        title: 'Projects & Tasks',
        icon: Icons.folder_open_outlined,
        activeIcon: Icons.folder_rounded,
        badgeCount: overdueTasks > 0 ? overdueTasks : null,
      ),
      const CeoSidebarItem(
        index: 3,
        title: 'Clients & Business',
        icon: Icons.trending_up_rounded,
        activeIcon: Icons.trending_up_rounded,
      ),
      CeoSidebarItem(
        index: 4,
        title: 'Finance & Approvals',
        icon: Icons.account_balance_outlined,
        activeIcon: Icons.account_balance_rounded,
        badgeCount: pendingApprovals > 0 ? pendingApprovals : null,
      ),
      CeoSidebarItem(
        index: 5,
        title: 'Calendar & Notifications',
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        badgeCount: todayMeetings > 0 ? todayMeetings : null,
      ),
      const CeoSidebarItem(
        index: 6,
        title: 'Reports & Control Centre',
        icon: Icons.tune_outlined,
        activeIcon: Icons.tune_rounded,
      ),
      const CeoSidebarItem(
        index: 11,
        title: 'Profile & Security',
        icon: Icons.manage_accounts_outlined,
        activeIcon: Icons.manage_accounts_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final items = _getItems(erp);
    final width = isCollapsed ? 74.0 : 260.0;

    return Container(
      width: isDrawer ? 280.0 : width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE9ECEF), width: 1.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Branding Area
            _buildBrandingHeader(context),
            const Divider(color: Color(0xFFE9ECEF), height: 1.0),

            // Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                children: items.map((item) => _buildNavItem(context, item)).toList(),
              ),
            ),

            const Divider(color: Color(0xFFE9ECEF), height: 1.0),

            // Bottom Profile / Session Area
            _buildBottomFooter(context, erp),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingHeader(BuildContext context) {
    if (isCollapsed && !isDrawer) {
      return Container(
        height: 72,
        alignment: Alignment.center,
        child: InkWell(
          onTap: onToggleCollapse,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'DI',
                style: GoogleFonts.instrumentSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // DI Monogram
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'DI',
                style: GoogleFonts.instrumentSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Digital Inertia',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212529),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFDEE2E6)),
                  ),
                  child: Text(
                    'STRATEGIC CONSULTING',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF212529),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Collapse Button (Desktop)
          if (!isDrawer && onToggleCollapse != null)
            IconButton(
              icon: const Icon(Icons.menu_open_rounded, size: 20, color: Color(0xFF6C757D)),
              tooltip: 'Collapse sidebar',
              onPressed: onToggleCollapse,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, CeoSidebarItem item) {
    final isSelected = currentIndex == item.index;

    if (isCollapsed && !isDrawer) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Tooltip(
          message: item.title,
          preferBelow: false,
          child: InkWell(
            onTap: () => onSelectModule(item.index),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF212529) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 20,
                    color: isSelected ? Colors.white : const Color(0xFF495057),
                  ),
                  if (item.badgeCount != null)
                    Positioned(
                      top: 6,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE03131),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            onSelectModule(item.index);
            if (isDrawer) Navigator.of(context).maybePop();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF212529) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 19,
                  color: isSelected ? Colors.white : const Color(0xFF495057),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF212529),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.badgeCount != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFE03131),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item.badgeCount}',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFooter(BuildContext context, ErpProvider erp) {
    if (isCollapsed && !isDrawer) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFE03131)),
          tooltip: 'Sign Out',
          onPressed: () => CeoModals.showLogoutConfirmation(context),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    erp.currentUserName.isNotEmpty ? erp.currentUserName[0] : 'C',
                    style: GoogleFonts.instrumentSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'CEO / MD Workspace',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 10.5,
                        color: const Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF6C757D)),
                tooltip: 'Sign Out',
                onPressed: () => CeoModals.showLogoutConfirmation(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '“COZ’ EVERYONE NEEDS A PUSH”',
            textAlign: TextAlign.center,
            style: GoogleFonts.instrumentSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFADB5BD),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
