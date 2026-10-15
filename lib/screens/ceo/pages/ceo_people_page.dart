import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/employee.dart';
import '../../../models/intern.dart';
import '../widgets/ceo_modals.dart';

/// Module 2: People & Departments Workspace (Specification Section 10)
/// Implements:
/// - Dynamic visual expandable tree organizational hierarchy
/// - Department heads & reporting relationships
/// - Searchable employee directory & modal profiles
/// - Employee, intern, and trainee counts & availability
/// - Attendance & leave overview
/// - Staffing requirements & hiring requisitions
class CeoPeoplePage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoPeoplePage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoPeoplePage> createState() => _CeoPeoplePageState();
}

class _CeoPeoplePageState extends State<CeoPeoplePage> {
  String _activeTab = 'Hierarchy'; // 'Hierarchy', 'Directory', 'Interns & Trainees', 'Leave & Attendance'
  String _searchQuery = '';
  String _selectedDeptFilter = 'All';
  final Set<String> _expandedDepts = {'Technical', 'Sales & Marketing', 'Digital Marketing', 'HR', 'Finance'};
  final Set<String> _expandedManagers = {'Arjun Sharma', 'Priya Nair', 'Rajesh Kumar', 'Kavita Reddy', 'Sunita Verma', 'Rameshwar Gupta'};

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
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
          // Breadcrumbs & Header (No Wordy Subheadings)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'People & Departments',
                style: GoogleFonts.instrumentSans(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF212529),
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Text(
                  '${erp.allEmployees.length} Staff Members',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212529),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // High-level Workforce Metrics Cards (Responsive Grid)
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: constraints.maxWidth < 600 ? 1.35 : 1.6,
                children: [
                  _buildHeadcountCard(
                    title: 'Total Workforce',
                    val: '${erp.allEmployees.length + erp.allInterns.length}',
                    sub: '${erp.allEmployees.length} Staff + ${erp.allInterns.length} Trainees',
                    icon: Icons.groups_outlined,
                  ),
                  _buildHeadcountCard(
                    title: 'Attendance Rate',
                    val: '94%',
                    sub: '21 Present • 1 On Leave',
                    icon: Icons.verified_user_outlined,
                  ),
                  _buildHeadcountCard(
                    title: 'Trainees in 1-Wk Eval',
                    val: '${erp.activeInternsCount}',
                    sub: 'Youth Employment Active',
                    icon: Icons.school_outlined,
                  ),
                  _buildHeadcountCard(
                    title: 'Pending Staffing/Leave',
                    val: '${erp.pendingLeaveRequests.length + erp.pendingStaffingRequests.length}',
                    sub: '${erp.pendingStaffingRequests.length} Staffing Requisitions',
                    icon: Icons.badge_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Sub-tabs Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Hierarchy', 'Directory', 'Interns & Trainees', 'Leave & Attendance'].map((tab) {
                final isSel = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: isSel,
                    selectedColor: const Color(0xFF212529),
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.instrumentSans(
                      color: isSel ? Colors.white : const Color(0xFF495057),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _activeTab = tab),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // View Content based on active tab
          if (_activeTab == 'Hierarchy') _buildOrgHierarchyView(erp),
          if (_activeTab == 'Directory') _buildEmployeeDirectoryView(erp),
          if (_activeTab == 'Interns & Trainees') _buildInternsEvaluationView(erp),
          if (_activeTab == 'Leave & Attendance') _buildLeaveAttendanceView(erp),
        ],
      ),
    );
  }

  Widget _buildHeadcountCard({
    required String title,
    required String val,
    required String sub,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: const Color(0xFF212529)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                val,
                style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFFADB5BD)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. DYNAMIC EXPANDABLE ORGANIZATIONAL TREE
  // ==========================================
  Widget _buildOrgHierarchyView(ErpProvider erp) {
    final employees = erp.allEmployees;
    final interns = erp.allInterns;

    final Map<String, List<Employee>> deptBuckets = {
      'Technical': employees.where((e) => e.department.toLowerCase().contains('tech')).toList(),
      'Sales & Marketing': employees.where((e) => e.department.toLowerCase().contains('sale') || e.department.toLowerCase().contains('sm')).toList(),
      'Digital Marketing': employees.where((e) => e.department.toLowerCase().contains('digital') || (e.department.toLowerCase().contains('mkt') && !e.department.toLowerCase().contains('sale'))).toList(),
      'HR': employees.where((e) => e.department.toLowerCase().contains('hr') || e.department.toLowerCase().contains('people')).toList(),
      'Finance': employees.where((e) => e.department.toLowerCase().contains('fin') || e.department.toLowerCase().contains('account')).toList(),
    };

    return Column(
      children: [
        // APEX NODE: CEO
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF212529),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    erp.currentUserName.isNotEmpty ? erp.currentUserName[0] : 'C',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            erp.currentUserName,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'APEX',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chief Executive Officer / Managing Director',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: const Color(0xFFCED4DA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${employees.length} Staff',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Vertical Connecting Line
        Container(
          width: 2,
          height: 18,
          color: const Color(0xFFADB5BD),
        ),

        // 5 Dynamic Department Tree Branches
        ...deptBuckets.entries.map((entry) {
          final deptName = entry.key;
          final deptStaff = entry.value;
          final isDeptExpanded = _expandedDepts.contains(deptName);

          return _buildDepartmentBranch(
            context,
            deptName,
            deptStaff,
            interns,
            isDeptExpanded,
          );
        }),
      ],
    );
  }

  Widget _buildDepartmentBranch(
    BuildContext context,
    String deptName,
    List<Employee> staff,
    List<Intern> interns,
    bool isExpanded,
  ) {
    if (staff.isEmpty) return const SizedBox.shrink();

    // Department Head: first matching lead or senior employee
    final head = staff.firstWhere(
      (e) => e.role.toLowerCase().contains('lead') || e.role.toLowerCase().contains('head') || e.reportingManager.toLowerCase().contains('ceo'),
      orElse: () => staff.first,
    );

    // Subordinates who report to head vs other team leads
    final teamMembers = staff.where((e) => e.id != head.id).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        children: [
          // Department Header Bar
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedDepts.remove(deptName);
                } else {
                  _expandedDepts.add(deptName);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.apartment_rounded, size: 18, color: Color(0xFF212529)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deptName,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                          ),
                        ),
                        Text(
                          'Lead: ${head.name} • ${staff.length} Members',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 11.5,
                            color: const Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Text(
                      '${staff.length} Staff',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF495057),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6C757D),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Tree Content
          if (isExpanded) ...[
            const Divider(color: Color(0xFFF1F3F5), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department Head Node Card (Clickable to open profile)
                  _buildEmployeeNodeCard(
                    context,
                    head,
                    isHead: true,
                  ),

                  // Subordinates & Teams Tree
                  if (teamMembers.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Color(0xFFDEE2E6), width: 1.8),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 14),
                        child: Column(
                          children: teamMembers.map((member) {
                            final isManagerExpanded = _expandedManagers.contains(member.name);
                            // Find any interns mentored by this employee
                            final mentoredInterns = interns.where((i) => i.assignedPocName == member.name).toList();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEmployeeNodeCard(
                                    context,
                                    member,
                                    isHead: false,
                                    hasInterns: mentoredInterns.isNotEmpty,
                                    isManagerExpanded: isManagerExpanded,
                                    onToggleManager: mentoredInterns.isNotEmpty
                                        ? () {
                                            setState(() {
                                              if (isManagerExpanded) {
                                                _expandedManagers.remove(member.name);
                                              } else {
                                                _expandedManagers.add(member.name);
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                  // Mentored Interns branch
                                  if (mentoredInterns.isNotEmpty && isManagerExpanded)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, top: 6),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(color: Color(0xFFCED4DA), width: 1.5),
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Column(
                                          children: mentoredInterns.map((intern) {
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8F9FA),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: const Color(0xFFE9ECEF)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF2F9E44),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '${intern.name} (Trainee / Intern)',
                                                      style: GoogleFonts.instrumentSans(
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF212529),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    intern.status.label,
                                                    style: GoogleFonts.instrumentSans(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF2F9E44),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployeeNodeCard(
    BuildContext context,
    Employee emp, {
    required bool isHead,
    bool hasInterns = false,
    bool isManagerExpanded = false,
    VoidCallback? onToggleManager,
  }) {
    return InkWell(
      onTap: () => CeoModals.showEmployeeProfileModal(context, emp),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isHead ? const Color(0xFFF8F9FA) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHead ? const Color(0xFF212529).withOpacity(0.2) : const Color(0xFFE9ECEF),
            width: isHead ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: isHead ? const Color(0xFF212529) : const Color(0xFF495057),
              child: Text(
                emp.name.isNotEmpty ? emp.name[0] : 'E',
                style: GoogleFonts.instrumentSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11.5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          emp.name,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212529),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isHead) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF212529),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'HEAD',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    emp.role,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 11,
                      color: const Color(0xFF6C757D),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (emp.activeTaskCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${emp.activeTaskCount} tasks',
                  style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF495057)),
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (hasInterns && onToggleManager != null)
              IconButton(
                icon: Icon(
                  isManagerExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: const Color(0xFF6C757D),
                ),
                onPressed: onToggleManager,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              )
            else
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFADB5BD)),
          ],
        ),
      ),
    );
  }

  // 2. EMPLOYEE DIRECTORY
  Widget _buildEmployeeDirectoryView(ErpProvider erp) {
    final employees = erp.allEmployees.where((e) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!e.name.toLowerCase().contains(q) && !e.department.toLowerCase().contains(q) && !e.role.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_selectedDeptFilter != 'All' && !e.department.toLowerCase().contains(_selectedDeptFilter.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Search & Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF212529)),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search employees by name, role, skills, department...',
                  hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF6C757D)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDeptFilter,
                  style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF212529)),
                  items: ['All', 'Technical', 'Sales', 'Marketing', 'HR', 'Finance'].map((d) {
                    return DropdownMenuItem(value: d, child: Text(d == 'All' ? 'All Depts' : d));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDeptFilter = val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: employees.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFE9ECEF)),
            itemBuilder: (ctx, i) {
              final emp = employees[i];
              return ListTile(
                onTap: () => CeoModals.showEmployeeProfileModal(context, emp),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF212529),
                  child: Text(emp.name[0], style: GoogleFonts.instrumentSans(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                title: Text(emp.name, style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                subtitle: Text('${emp.role} • ${emp.department} • Reports to: ${emp.reportingManager}', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFADB5BD)),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. INTERNS & TRAINEES EVALUATION
  Widget _buildInternsEvaluationView(ErpProvider erp) {
    final interns = erp.allInterns;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: interns.length,
        separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFE9ECEF)),
        itemBuilder: (ctx, i) {
          final intern = interns[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF5F6F7),
              child: Text(intern.name[0], style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontWeight: FontWeight.w700)),
            ),
            title: Text(intern.name, style: GoogleFonts.instrumentSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
            subtitle: Text('Batch: ${intern.batchName} • Domain: ${intern.domain} • Mentor: ${intern.assignedPocName ?? "Lead"}', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEBFBEE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                intern.status.label,
                style: GoogleFonts.instrumentSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF2F9E44)),
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. LEAVE & ATTENDANCE
  Widget _buildLeaveAttendanceView(ErpProvider erp) {
    final leaves = erp.allLeaveRequests;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: leaves.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No active leave requests pending review.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D))),
              ),
            )
          : Column(
              children: leaves.map((l) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_busy_outlined, size: 18, color: Color(0xFF212529)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${l.employeeName} (${l.department})', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                            Text('${l.leaveType.label} • ${DateFormat("dd MMM").format(l.startDate)} - ${DateFormat("dd MMM").format(l.endDate)} • Reason: ${l.reason}', style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
                          ],
                        ),
                      ),
                      Text(l.status.name.toUpperCase(), style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
