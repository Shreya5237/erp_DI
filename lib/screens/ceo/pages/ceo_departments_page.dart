import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/ceo_modals.dart';

/// Module 2: Department Details & Operational Control (Specification Section 6)
/// Implements full drill-down: Company ➔ Department ➔ Team ➔ Employee ➔ Project ➔ Task
/// Supports all 5 departments (Technical, Sales & Marketing, Digital Marketing, HR, Finance)
class CeoDepartmentsPage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;
  final int initialDepartmentIndex;

  const CeoDepartmentsPage({
    super.key,
    required this.onNavigateModule,
    this.initialDepartmentIndex = 0,
  });

  @override
  State<CeoDepartmentsPage> createState() => _CeoDepartmentsPageState();
}

class _CeoDepartmentsPageState extends State<CeoDepartmentsPage> {
  late int _selectedDeptIndex;

  final List<Map<String, dynamic>> _deptConfigs = [
    {
      'title': 'Technical / Engineering',
      'short': 'Technical',
      'head': 'Vikram Sharma',
      'headRole': 'Director of Engineering',
      'teamCount': 11,
      'target': 'Q4 Sprint Releases: 92% On-Time',
      'achieved': '88% Delivery Health',
      'budget': '₹65,00,000 Allocation',
      'spent': '₹48,20,000 Spent (74%)',
      'domainKey': 'Engineering',
    },
    {
      'title': 'Sales & Marketing',
      'short': 'Sales',
      'head': 'Rajesh Kumar',
      'headRole': 'Head of Global Business & Sales',
      'teamCount': 6,
      'target': '₹50,00,000 Monthly Target',
      'achieved': '₹38,50,000 Closed (77%)',
      'budget': '₹40,00,000 Allocation',
      'spent': '₹28,10,000 Spent (70%)',
      'domainKey': 'Sales',
    },
    {
      'title': 'Digital Marketing',
      'short': 'Marketing',
      'head': 'Ananya Sen',
      'headRole': 'Head of Growth & Digital Outreach',
      'teamCount': 3,
      'target': '150 Qualified Leads / Month',
      'achieved': '142 Leads Generated (95%)',
      'budget': '₹25,00,000 Allocation',
      'spent': '₹13,40,000 Spent (54%)',
      'domainKey': 'Marketing',
    },
    {
      'title': 'Human Resources & Talent',
      'short': 'HR & Talent',
      'head': 'Sneha Kapoor',
      'headRole': 'Chief People Officer',
      'teamCount': 4,
      'target': '95% Attendance & 100% 1-Wk Eval',
      'achieved': '94% Attendance • 12 Active Interns',
      'budget': '₹25,00,000 Allocation',
      'spent': '₹18,00,000 Spent (72%)',
      'domainKey': 'HR',
    },
    {
      'title': 'Finance & Commercials',
      'short': 'Finance',
      'head': 'Siddharth Roy',
      'headRole': 'Head of Corporate Finance',
      'teamCount': 4,
      'target': '100% Margin Compliance & Zero Overruns',
      'achieved': '3 Pending Resource Approvals',
      'budget': '₹20,00,000 Allocation',
      'spent': '₹12,00,000 Spent (60%)',
      'domainKey': 'Finance',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDeptIndex = widget.initialDepartmentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final currentDept = _deptConfigs[_selectedDeptIndex];
    final domainKey = currentDept['domainKey'] as String;

    // Filter employees in this department
    final deptEmployees = erp.allEmployees.where((e) {
      final deptName = e.department.toLowerCase();
      final target = (currentDept['short'] as String).toLowerCase();
      return deptName.contains(target) || deptName.contains(domainKey.toLowerCase());
    }).toList();

    // Filter tasks in this department
    final deptTasks = erp.allTasks.where((t) {
      final dom = t.domain.toLowerCase();
      final target = (currentDept['short'] as String).toLowerCase();
      return dom.contains(target) || dom.contains(domainKey.toLowerCase());
    }).toList();

    // Filter active projects
    final deptProjects = erp.allProjects.where((p) {
      return p.domain.toLowerCase().contains(domainKey.toLowerCase()) ||
          p.ownerEmployeeName.toLowerCase().contains(currentDept['head'].toString().toLowerCase()) ||
          _selectedDeptIndex == 0; // Technical touches all projects
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 18 : 24,
        isMobile ? 16 : 28,
        40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs & Header
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text('Executive Overview', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFADB5BD)),
              Text('Departments & Operational Control', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Departmental Operational Workspaces',
            style: GoogleFonts.instrumentSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF212529), letterSpacing: -0.5),
          ),
          const SizedBox(height: 3),
          Text(
            'Direct executive oversight, resource allocation, and accountability drill-down.',
            style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D)),
          ),
          const SizedBox(height: 18),

          // Department Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_deptConfigs.length, (index) {
                final isSelected = _selectedDeptIndex == index;
                final cfg = _deptConfigs[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedDeptIndex = index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF212529) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? const Color(0xFF212529) : const Color(0xFFE9ECEF)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            cfg['short'] as String,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF495057),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Department Profile Dossier Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final isTight = cardConstraints.maxWidth < 650;
                    if (isTight) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF212529),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    (currentDept['short'] as String)[0],
                                    style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentDept['title'] as String,
                                      style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                                    ),
                                    Text(
                                      'Head: ${currentDept['head']}',
                                      style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${currentDept['headRole']} • ${currentDept['teamCount']} Personnel',
                            style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => CeoModals.showCompanyDirectiveModal(context, erp),
                                icon: const Icon(Icons.campaign_outlined, size: 15, color: Color(0xFF212529)),
                                label: Text('Issue Directive', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFDEE2E6)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => widget.onNavigateModule(9), // Daily Reports
                                icon: const Icon(Icons.analytics_outlined, size: 15, color: Colors.white),
                                label: Text('Daily Report', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF212529),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF212529),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              (currentDept['short'] as String)[0],
                              style: GoogleFonts.instrumentSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentDept['title'] as String,
                                style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Department Head: ${currentDept['head']} (${currentDept['headRole']}) • ${currentDept['teamCount']} Personnel',
                                style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF6C757D)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => CeoModals.showCompanyDirectiveModal(context, erp),
                              icon: const Icon(Icons.campaign_outlined, size: 16, color: Color(0xFF212529)),
                              label: Text('Issue Directive', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFDEE2E6)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => widget.onNavigateModule(9), // Daily Reports
                              icon: const Icon(Icons.analytics_outlined, size: 16, color: Colors.white),
                              label: Text('Daily Report', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF212529),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE9ECEF), height: 1),
                const SizedBox(height: 16),

                // Department KPI Metrics (Responsive layout)
                LayoutBuilder(
                  builder: (context, kpiConstraints) {
                    final isNarrow = kpiConstraints.maxWidth < 650;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _buildDeptKpi(
                            label: 'Target vs Achievement',
                            val: currentDept['achieved'] as String,
                            subtext: currentDept['target'] as String,
                            icon: Icons.track_changes_rounded,
                            expanded: false,
                          ),
                          const SizedBox(height: 10),
                          _buildDeptKpi(
                            label: 'Budget & Expenditure',
                            val: currentDept['spent'] as String,
                            subtext: currentDept['budget'] as String,
                            icon: Icons.account_balance_wallet_outlined,
                            expanded: false,
                          ),
                          const SizedBox(height: 10),
                          _buildDeptKpi(
                            label: 'Active Workload',
                            val: '${deptTasks.where((t) => !t.isCompleted).length} Tasks In-Flight',
                            subtext: '${deptTasks.where((t) => t.isOverdue).length} Overdue Items',
                            icon: Icons.task_alt_outlined,
                            expanded: false,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        _buildDeptKpi(
                          label: 'Target vs Achievement',
                          val: currentDept['achieved'] as String,
                          subtext: currentDept['target'] as String,
                          icon: Icons.track_changes_rounded,
                          expanded: true,
                        ),
                        const SizedBox(width: 14),
                        _buildDeptKpi(
                          label: 'Budget & Expenditure',
                          val: currentDept['spent'] as String,
                          subtext: currentDept['budget'] as String,
                          icon: Icons.account_balance_wallet_outlined,
                          expanded: true,
                        ),
                        const SizedBox(width: 14),
                        _buildDeptKpi(
                          label: 'Active Workload',
                          val: '${deptTasks.where((t) => !t.isCompleted).length} Tasks In-Flight',
                          subtext: '${deptTasks.where((t) => t.isOverdue).length} Overdue Items',
                          icon: Icons.task_alt_outlined,
                          expanded: true,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Drill-down Section: Team Roster & Responsibilities
          Text(
            'Department Personnel & Workload Distribution',
            style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
            ),
            child: deptEmployees.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No employee records in this category.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D))),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deptEmployees.take(6).length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFE9ECEF)),
                    itemBuilder: (ctx, i) {
                      final emp = deptEmployees[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF212529),
                          child: Text(
                            emp.name.isNotEmpty ? emp.name[0] : 'E',
                            style: GoogleFonts.instrumentSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        title: Text(emp.name, style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                        subtitle: Text('${emp.role} • Reporting to ${emp.reportingManager}', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBFBEE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFB2F2BB)),
                          ),
                          child: Text(
                            'Active On Duty',
                            style: GoogleFonts.instrumentSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF2F9E44)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),

          // Active Projects & Tasks in this Department
          Text(
            'Active Projects & Operational Deliverables',
            style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
            ),
            child: deptProjects.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No active projects associated with this department.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D))),
                    ),
                  )
                : Column(
                    children: deptProjects.take(4).map((proj) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.folder_open_rounded, size: 20, color: Color(0xFF212529)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(proj.name, style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                                  Text('Client: ${proj.clientName} • PM: ${proj.ownerEmployeeName}', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
                                ],
                              ),
                            ),
                            Text(
                              '${(proj.progress * 100).toInt()}% Done',
                              style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptKpi({
    required String label,
    required String val,
    required String subtext,
    required IconData icon,
    bool expanded = true,
  }) {
    final container = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: const Color(0xFF212529)),
            ],
          ),
          const SizedBox(height: 6),
          Text(val, style: GoogleFonts.instrumentSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF212529))),
          const SizedBox(height: 2),
          Text(subtext, style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFFADB5BD)), overflow: TextOverflow.ellipsis),
        ],
      ),
    );

    if (expanded) return Expanded(child: container);
    return container;
  }
}
