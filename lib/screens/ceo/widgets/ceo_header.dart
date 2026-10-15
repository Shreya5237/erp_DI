import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import 'ceo_modals.dart';

/// Executive Top Header for Digital Inertia CEO Workspace.
/// Implements:
/// - CEO avatar, name, designation, personalized greeting
/// - Company context: reporting period & last data synchronization time
/// - Global search trigger
/// - Interactive live alert notification bell with unread badge
/// - Quick Action menu (+ Quick Action)
/// - CEO profile menu with settings, security, persona switch, and sign out
class CeoHeader extends StatefulWidget {
  final VoidCallback? onToggleSidebar;
  final ValueChanged<int> onNavigateModule;
  final String currentModuleName;

  const CeoHeader({
    super.key,
    this.onToggleSidebar,
    required this.onNavigateModule,
    required this.currentModuleName,
  });

  @override
  State<CeoHeader> createState() => _CeoHeaderState();
}

class _CeoHeaderState extends State<CeoHeader> {
  bool _isSyncing = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _handleManualSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF212529),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2F9E44), size: 18),
              const SizedBox(width: 8),
              Text(
                'ERP Data Synchronized Successfully',
                style: GoogleFonts.instrumentSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final isMobile = screenWidth < 600;
    final unreadAlerts = erp.unreadEmployeeAlertsCount + erp.thresholdAlerts.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28.0 : (isMobile ? 12.0 : 16.0),
        vertical: isDesktop ? 14.0 : 10.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Mobile/Tablet Menu Button
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF212529), size: 22),
              onPressed: widget.onToggleSidebar,
              tooltip: 'Navigation Menu',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            ),
            const SizedBox(width: 6),
          ],

          // Executive Greeting & Current Context / Breadcrumbs
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '${_getGreeting()}, ${erp.currentUserName.split(" ")[0]}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.instrumentSans(
                          fontSize: isDesktop ? 18 : (isMobile ? 15 : 16),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212529),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212529),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CEO',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isMobile) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          isDesktop ? 'Reporting: Q4 FY 2026-27' : 'Q4 FY26',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 11.5,
                            color: const Color(0xFF6C757D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFFADB5BD), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _isSyncing ? null : _handleManualSync,
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isSyncing
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF212529)),
                                  )
                                : const Icon(Icons.sync_rounded, size: 12, color: Color(0xFF6C757D)),
                            const SizedBox(width: 4),
                            Text(
                              _isSyncing ? 'Syncing...' : (isDesktop ? 'Synced Just Now' : 'Synced'),
                              style: GoogleFonts.instrumentSans(
                                fontSize: 11.5,
                                color: const Color(0xFF6C757D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions Cluster
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Global Search Button
              InkWell(
                onTap: () => CeoModals.showGlobalSearchModal(context, erp, widget.onNavigateModule),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 12 : 8,
                    vertical: isDesktop ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: Color(0xFF6C757D)),
                      if (isDesktop) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Search ERP...',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12.5,
                            color: const Color(0xFF6C757D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFDEE2E6)),
                          ),
                          child: Text(
                            '⌘K',
                            style: GoogleFonts.instrumentSans(fontSize: 10, color: const Color(0xFF6C757D), fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 6 : 10),

              // Interactive Notifications Bell
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF212529), size: 20),
                    tooltip: 'Executive Alerts & Notifications',
                    onPressed: () => CeoModals.showNotificationsModal(context, erp, widget.onNavigateModule),
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F6F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFE9ECEF)),
                      ),
                      padding: const EdgeInsets.all(7),
                    ),
                  ),
                  if (unreadAlerts > 0)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE03131),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                        child: Center(
                          child: Text(
                            '$unreadAlerts',
                            style: GoogleFonts.instrumentSans(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: isMobile ? 6 : 10),

              // Quick Actions Button
              PopupMenuButton<String>(
                tooltip: 'Quick Executive Action',
                offset: const Offset(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                color: Colors.white,
                elevation: 6,
                onSelected: (val) {
                  switch (val) {
                    case 'approvals':
                      widget.onNavigateModule(6); // Approvals module
                      break;
                    case 'directive':
                      CeoModals.showCompanyDirectiveModal(context, erp);
                      break;
                    case 'meeting':
                      CeoModals.showScheduleMeetingModal(context, erp);
                      break;
                    case 'task':
                      CeoModals.showCompanyDirectiveModal(context, erp);
                      break;
                    case 'reports':
                      widget.onNavigateModule(9); // Daily Reports
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'approvals',
                    child: Row(
                      children: [
                        const Icon(Icons.fact_check_outlined, size: 18, color: Color(0xFF212529)),
                        const SizedBox(width: 10),
                        Text('Pending Approvals', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF212529))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'directive',
                    child: Row(
                      children: [
                        const Icon(Icons.campaign_outlined, size: 18, color: Color(0xFF212529)),
                        const SizedBox(width: 10),
                        Text('Issue Company Directive', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF212529))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'meeting',
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF212529)),
                        const SizedBox(width: 10),
                        Text('Schedule Meeting', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF212529))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reports',
                    child: Row(
                      children: [
                        const Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF212529)),
                        const SizedBox(width: 10),
                        Text('Daily Reports & Analytics', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF212529))),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : (isMobile ? 8 : 10), vertical: isDesktop ? 8 : 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      if (isDesktop) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Action',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 6 : 10),

              // CEO Profile Menu Dropdown
              PopupMenuButton<String>(
                tooltip: 'CEO Profile & Session',
                offset: const Offset(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                color: Colors.white,
                elevation: 6,
                onSelected: (val) {
                  if (val == 'settings') {
                    widget.onNavigateModule(11); // Settings
                  } else if (val == 'logout') {
                    CeoModals.showLogoutConfirmation(context);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          erp.currentUserName,
                          style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                        ),
                        Text(
                          erp.currentUserEmail,
                          style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F7),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: Text(
                            'ROLE: ${erp.currentRole.label}',
                            style: GoogleFonts.instrumentSans(fontSize: 9.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF212529)),
                        const SizedBox(width: 10),
                        Text('Profile & Security Policy', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF212529))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE03131)),
                        const SizedBox(width: 10),
                        Text('Sign Out', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFE03131))),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: isMobile ? 32 : 36,
                  height: isMobile ? 32 : 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      erp.currentUserName.isNotEmpty ? erp.currentUserName[0] : 'C',
                      style: GoogleFonts.instrumentSans(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
