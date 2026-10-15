import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/ceo_modals.dart';

/// Module 7: Reports & Control Centre (Executive Workspace)
/// Design inspired by minimalist executive reference (Image 2)
class CeoControlCentrePage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoControlCentrePage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoControlCentrePage> createState() => _CeoControlCentrePageState();
}

class _CeoControlCentrePageState extends State<CeoControlCentrePage> {
  String _activeTab = 'Reports'; // 'Reports', 'Targets', 'Directives', 'Access', 'Audit logs'
  String _searchQuery = '';
  String _statusFilter = 'All';

  final List<String> _tabs = ['Reports', 'Targets', 'Directives', 'Access', 'Audit logs'];

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    final directives = erp.allTasks.where((t) => t.title.contains('[CEO DIRECTIVE]')).toList();
    final auditLogs = erp.allAuditLogs;
    final directiveCount = directives.isEmpty ? 8 : directives.length;
    final auditCount = auditLogs.isEmpty ? 24 : auditLogs.length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 16, isMobile ? 16 : 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & "Create new ->" pill button (Matching Image 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Reports & Control Centre',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212529),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => CeoModals.showCompanyDirectiveModal(context, erp),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create new',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Horizontal Category Tabs (Reports, Targets, Directives, Access, Audit logs)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = tab),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tab,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF212529) : const Color(0xFF868E96),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 2,
                          width: isSelected ? 24 : 0,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF212529) : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Stat Cards (Matching Image 2: Reports received, Active directives, Audit events)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard('Reports received', '5/5', 'All departments'),
                const SizedBox(width: 12),
                _buildStatCard('Active directives', '$directiveCount', '${(directiveCount * 0.75).round()} on track'),
                const SizedBox(width: 12),
                _buildStatCard('Audit events', '$auditCount', 'This week'),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Active Sub-view Based on Tab
          if (_activeTab == 'Reports') _buildMainReportsCard(context, erp),
          if (_activeTab == 'Targets') _buildTargetsManagementSection(context, erp),
          if (_activeTab == 'Directives') _buildDirectivesSection(context, erp),
          if (_activeTab == 'Access') _buildAccessGovernanceSection(context, erp),
          if (_activeTab == 'Audit logs') _buildAuditLogsSection(erp),
        ],
      ),
    );
  }

  // --- Image 2 Main Card: "Reports & administrative activity" ---
  Widget _buildMainReportsCard(BuildContext context, ErpProvider erp) {
    // Default executive administrative records matching Image 2
    final List<_AdminActivityItem> items = [
      _AdminActivityItem(
        title: 'Daily company report',
        departmentOrOwner: 'All departments',
        type: 'Report',
        status: 'Submitted',
      ),
      _AdminActivityItem(
        title: 'Q2 revenue target updated',
        departmentOrOwner: 'Amara Cole',
        type: 'Target',
        status: 'Updated',
      ),
      _AdminActivityItem(
        title: 'Technical authority delegated',
        departmentOrOwner: 'Nolan Kay',
        type: 'Access',
        status: 'Active',
      ),
      _AdminActivityItem(
        title: 'Hiring policy revised',
        departmentOrOwner: 'Priya Nair',
        type: 'Policy',
        status: 'Published',
      ),
      _AdminActivityItem(
        title: 'Cloud infrastructure scaling directive',
        departmentOrOwner: 'Arun Sharma',
        type: 'Directive',
        status: 'In Progress',
      ),
      _AdminActivityItem(
        title: 'Client SLA escalation audit',
        departmentOrOwner: 'Executive Office',
        type: 'Audit',
        status: 'Resolved',
      ),
    ];

    final filtered = items.where((it) {
      final matchesSearch = it.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          it.departmentOrOwner.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_statusFilter == 'Active') return matchesSearch && (it.status == 'Active' || it.status == 'In Progress');
      if (_statusFilter == 'Submitted') return matchesSearch && it.status == 'Submitted';
      return matchesSearch;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports & administrative activity',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212529),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Live company records · Last updated just now',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11.5,
                    color: const Color(0xFF868E96),
                  ),
                ),
              ],
            ),
          ),

          // Search Box & Status Filter (Matching Image 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 18, color: Color(0xFFADB5BD)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF212529)),
                            decoration: InputDecoration(
                              hintText: 'Filter records...',
                              hintStyle: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFFADB5BD)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _statusFilter = val),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'All',
                      child: Text('All statuses', style: GoogleFonts.instrumentSans(fontSize: 12)),
                    ),
                    PopupMenuItem(
                      value: 'Active',
                      child: Text('Active / In Progress', style: GoogleFonts.instrumentSans(fontSize: 12)),
                    ),
                    PopupMenuItem(
                      value: 'Submitted',
                      child: Text('Submitted Reports', style: GoogleFonts.instrumentSans(fontSize: 12)),
                    ),
                  ],
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _statusFilter == 'All' ? 'All statuses' : _statusFilter,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF495057),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF868E96)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE9ECEF)),

          // List Items (Matching Image 2: Bold Title, Subtitle/Owner, Chevron right)
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No matching activity records.',
                  style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final it = filtered[i];
                return InkWell(
                  onTap: () => _showRecordDetailModal(context, it),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            it.title,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF212529),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          it.departmentOrOwner,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12,
                            color: const Color(0xFF6C757D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF868E96)),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Stat Card Helper (Matching Image 2) ---
  Widget _buildStatCard(String title, String val, String sub) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF868E96),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.instrumentSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF212529),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.instrumentSans(
              fontSize: 10.5,
              color: const Color(0xFFADB5BD),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- Modal for Record Details ---
  void _showRecordDetailModal(BuildContext context, _AdminActivityItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEE2E6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Owner / Department: ${item.departmentOrOwner}',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12.5,
                            color: const Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Record Type', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF868E96))),
                        const SizedBox(height: 2),
                        Text(
                          item.type,
                          style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Compliance Status', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF868E96))),
                        const SizedBox(height: 2),
                        Text(
                          'Verified & Validated',
                          style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF2B8A3E)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildModalRow('Authority Level', 'CEO Executive Office'),
              _buildModalRow('Effective Date', '15 October 2026'),
              _buildModalRow('Audit Log ID', 'AUD-DI-${item.type.toUpperCase()}-2026'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Exporting ${item.title} to PDF / Spreadsheet...',
                              style: GoogleFonts.instrumentSans(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16, color: Color(0xFF212529)),
                      label: Text('Export Record', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF212529),
                        side: const BorderSide(color: Color(0xFFDEE2E6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text('Dismiss', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF868E96)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF212529),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Sub-View: Targets Management ---
  Widget _buildTargetsManagementSection(BuildContext context, ErpProvider erp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Company Performance Targets',
                style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Target reconfiguration panel active. Changes synchronize across leadership dashboard.', style: GoogleFonts.instrumentSans()),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Edit Targets', style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTargetProgressItem('FY26 Annual Revenue Target', '₹4.50 Cr', '₹3.80 Cr Achieved (84.4%)', 0.84),
          _buildTargetProgressItem('Client Retention Rate', '95%', '92% Current', 0.92),
          _buildTargetProgressItem('On-Time Delivery Rate', '90%', '86% Current', 0.86),
          _buildTargetProgressItem('Operating Profit Margin (EBITDA)', '28%', '31% Achieved', 1.0),
        ],
      ),
    );
  }

  Widget _buildTargetProgressItem(String title, String target, String current, double ratio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
              Text(target, style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
            ],
          ),
          const SizedBox(height: 3),
          Text(current, style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF868E96))),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFF5F6F7),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF212529)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // --- Sub-View: Directives ---
  Widget _buildDirectivesSection(BuildContext context, ErpProvider erp) {
    final directives = erp.allTasks.where((t) => t.title.contains('[CEO DIRECTIVE]')).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: directives.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No active directives.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96))),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: directives.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final d = directives[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.gavel_rounded, size: 18, color: Color(0xFF212529)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.title.replaceAll('[CEO DIRECTIVE]', '').trim(),
                              style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                            ),
                            Text(
                              'Assigned: ${d.assignedToName} · Deadline: ${d.dueDate.day}/${d.dueDate.month}',
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF868E96)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Text(
                          d.status.name.toUpperCase(),
                          style: GoogleFonts.instrumentSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- Sub-View: Access Governance ---
  Widget _buildAccessGovernanceSection(BuildContext context, ErpProvider erp) {
    final permissions = [
      {'role': 'Chief Technology Officer (CTO)', 'scope': 'Architecture, deployments, engineering budgets < ₹10L'},
      {'role': 'VP of Sales & Marketing', 'scope': 'Proposals < ₹50L, discount authorization up to 10%'},
      {'role': 'Head of HR & Operations', 'scope': 'Candidate offers, leave approvals, vendor staffing'},
      {'role': 'Finance Controller', 'scope': 'Accounts payables, invoice dispatch, ledger audits'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Executive Authority & Delegated Permissions',
            style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
          ),
          const SizedBox(height: 16),
          ...permissions.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['role']!, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                      const SizedBox(height: 3),
                      Text(p['scope']!, style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // --- Sub-View: Audit Logs ---
  Widget _buildAuditLogsSection(ErpProvider erp) {
    final logs = erp.allAuditLogs;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: logs.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text('No audit events logged.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF868E96))),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.take(20).length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
              itemBuilder: (ctx, i) {
                final log = logs[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.security_rounded, size: 16, color: Color(0xFF212529)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.action,
                              style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                            ),
                            Text(
                              '${log.details} · By ${log.actorName}',
                              style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF868E96)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _AdminActivityItem {
  final String title;
  final String departmentOrOwner;
  final String type;
  final String status;

  _AdminActivityItem({
    required this.title,
    required this.departmentOrOwner,
    required this.type,
    required this.status,
  });
}
