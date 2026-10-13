import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../../models/hierarchy.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/compact_filter_bar.dart';
import 'employee_detail_dialog.dart';

/// Screen 4: Employees Management Screen with Hierarchical Display & Compact Dropdown Filter Bar
class EmployeeListScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const EmployeeListScreen({super.key, this.onBack});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late final TextEditingController _searchController;
  bool _isHierarchyView = true;
  final Set<String> _collapsedDepartments = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<ErpProvider>().employeeSearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final erp = context.read<ErpProvider>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    RoleCategory category = RoleCategory.technical;
    String selectedRole = 'Frontend Developer';
    String selectedDept = 'Technical';
    String selectedSubcategory = 'Frontend';
    String team = 'Core Platform Engineering';
    bool isPOC = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final roles = category == RoleCategory.technical
                ? erp.technicalRoles
                : erp.nonTechnicalRoles;
            final availableSubcategories = erp.departmentSubcategories[selectedDept] ?? [];

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Employee',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(labelText: 'Phone'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Category toggle
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Technical')),
                              selected: category == RoleCategory.technical,
                              onSelected: (val) {
                                if (val) {
                                  setDialogState(() {
                                    category = RoleCategory.technical;
                                    selectedRole = erp.technicalRoles.first.name;
                                    selectedDept = 'Technical';
                                    selectedSubcategory = erp.departmentSubcategories['Technical']!.first;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Non-Technical')),
                              selected: category == RoleCategory.nonTechnical,
                              onSelected: (val) {
                                if (val) {
                                  setDialogState(() {
                                    category = RoleCategory.nonTechnical;
                                    selectedRole = erp.nonTechnicalRoles.first.name;
                                    selectedDept = 'HR';
                                    selectedSubcategory = erp.departmentSubcategories['HR']!.first;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: roles.any((r) => r.name == selectedRole) ? selectedRole : roles.first.name,
                        decoration: const InputDecoration(labelText: 'Configured Role'),
                        items: roles.map((r) => DropdownMenuItem(value: r.name, child: Text(r.name))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedRole = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      // 1. Top-Level Department Dropdown (strictly the 5 approved root departments)
                      DropdownButtonFormField<String>(
                        key: ValueKey('dept_$selectedDept'),
                        initialValue: erp.topLevelDepartmentNames.contains(selectedDept) ? selectedDept : erp.topLevelDepartmentNames.first,
                        decoration: const InputDecoration(
                          labelText: 'Top-Level Department',
                          prefixIcon: Icon(Icons.corporate_fare, size: 20),
                        ),
                        items: erp.topLevelDepartmentNames.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDept = val;
                              final subs = erp.departmentSubcategories[val] ?? [];
                              selectedSubcategory = subs.isNotEmpty ? subs.first : '';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // 2. Dynamic Subcategories Dropdown (populated based on selected department)
                      DropdownButtonFormField<String>(
                        key: ValueKey('sub_${selectedDept}_$selectedSubcategory'),
                        initialValue: availableSubcategories.contains(selectedSubcategory)
                            ? selectedSubcategory
                            : (availableSubcategories.isNotEmpty ? availableSubcategories.first : null),
                        decoration: const InputDecoration(
                          labelText: 'Department Subcategory',
                          prefixIcon: Icon(Icons.subdirectory_arrow_right, size: 20),
                        ),
                        items: availableSubcategories.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedSubcategory = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Functional Squad / Team'),
                        controller: TextEditingController(text: team),
                        onChanged: (val) => team = val,
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isPOC,
                        title: const Text('Intern Mentor / POC', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        onChanged: (val) => setDialogState(() => isPOC = val ?? false),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) return;
                            erp.addEmployee(
                              name: nameController.text.trim(),
                              email: emailController.text.trim().isEmpty ? 'employee@digitalinertia.com' : emailController.text.trim(),
                              phone: phoneController.text.trim().isEmpty ? '+91 99999 00000' : phoneController.text.trim(),
                              role: selectedRole,
                              category: category,
                              department: selectedDept,
                              subDepartmentName: selectedSubcategory,
                              team: team,
                              isPOC: isPOC,
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF212529)),
                          child: const Text('Save Employee', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final employees = erp.filteredEmployees;
    final hierarchicalMap = erp.employeesByDepartmentHierarchical;

    final availableDepartments = erp.availableEmployeeDepartments;
    final activeDept = erp.employeeDepartmentFilter ?? 'All Departments';
    final activeCategory = erp.employeeCategoryFilter;
    final activeRole = erp.employeeRoleFilter;

    final hasActiveFilters = (erp.employeeDepartmentFilter != null && erp.employeeDepartmentFilter != 'All Departments') ||
        erp.employeeCategoryFilter != null ||
        (erp.employeeRoleFilter != null && erp.employeeRoleFilter != 'All') ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF212529)),
                onPressed: widget.onBack,
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company Directory',
              style: TextStyle(
                color: Color(0xFF212529),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${employees.length} employees • ${hierarchicalMap.keys.length} departments',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // View Mode Switcher Icon (Hierarchy Tree vs Flat List)
          IconButton(
            tooltip: _isHierarchyView ? 'Switch to Flat List' : 'Switch to Hierarchy Tree',
            icon: Icon(
              _isHierarchyView ? Icons.account_tree_rounded : Icons.view_list_rounded,
              size: 20,
              color: const Color(0xFF212529),
            ),
            onPressed: () {
              setState(() => _isHierarchyView = !_isHierarchyView);
            },
          ),
          // Black circular + button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _showAddEmployeeDialog(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF212529),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {});
                  erp.setEmployeeSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search employee, role, or skill...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            erp.setEmployeeSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Space-Saving Single Dropdown Filter Bar
          CompactFilterBar(
            hasActiveFilters: hasActiveFilters,
            onReset: () {
              _searchController.clear();
              erp.setEmployeeSearchQuery('');
              erp.setEmployeeDepartmentFilter(null);
              erp.setEmployeeCategoryFilter(null);
              erp.setEmployeeRoleFilter(null);
              setState(() {});
            },
            items: [
              // 1. Department Dropdown
              FilterDropdownItem<String>(
                label: 'Department',
                icon: Icons.corporate_fare_rounded,
                value: activeDept,
                options: availableDepartments.map((dept) {
                  return FilterOption<String>(
                    label: dept,
                    value: dept,
                    icon: _getDepartmentIcon(dept),
                  );
                }).toList(),
                onChanged: (val) {
                  erp.setEmployeeDepartmentFilter(val == 'All Departments' ? null : val);
                },
              ),

              // 2. Category / Tier Dropdown
              FilterDropdownItem<String>(
                label: 'Role Category',
                icon: Icons.badge_outlined,
                value: activeCategory == null
                    ? (activeRole ?? 'All Roles')
                    : (activeCategory == RoleCategory.technical ? 'Technical' : 'Non-Technical'),
                options: [
                  const FilterOption<String>(label: 'All Roles', value: 'All Roles'),
                  const FilterOption<String>(label: 'Technical Staff', value: 'Technical', icon: Icons.terminal_rounded),
                  const FilterOption<String>(label: 'Non-Technical Staff', value: 'Non-Technical', icon: Icons.campaign_rounded),
                  const FilterOption<String>(label: 'Leads & POC Mentors', value: 'Leads', icon: Icons.star_rounded),
                ],
                onChanged: (val) {
                  if (val == 'Technical') {
                    erp.setEmployeeCategoryFilter(RoleCategory.technical);
                    erp.setEmployeeRoleFilter(null);
                  } else if (val == 'Non-Technical') {
                    erp.setEmployeeCategoryFilter(RoleCategory.nonTechnical);
                    erp.setEmployeeRoleFilter(null);
                  } else if (val == 'Leads') {
                    erp.setEmployeeCategoryFilter(null);
                    erp.setEmployeeRoleFilter('Lead');
                  } else {
                    erp.setEmployeeCategoryFilter(null);
                    erp.setEmployeeRoleFilter(null);
                  }
                },
              ),

              // 3. View Style Toggle
              FilterDropdownItem<String>(
                label: 'View Mode',
                icon: _isHierarchyView ? Icons.account_tree_outlined : Icons.view_headline_rounded,
                value: _isHierarchyView ? 'Hierarchy Tree' : 'Flat Directory',
                options: const [
                  FilterOption<String>(label: 'Hierarchy Tree', value: 'Hierarchy Tree', icon: Icons.account_tree_rounded),
                  FilterOption<String>(label: 'Flat Directory', value: 'Flat Directory', icon: Icons.view_list_rounded),
                ],
                onChanged: (val) {
                  setState(() => _isHierarchyView = val == 'Hierarchy Tree');
                },
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Main Employee Content
          Expanded(
            child: employees.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 10),
                        const Text(
                          'No employees match selected filters.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.filter_alt_off, size: 16),
                          label: const Text('Reset All Filters'),
                          onPressed: () {
                            _searchController.clear();
                            erp.setEmployeeSearchQuery('');
                            erp.setEmployeeDepartmentFilter(null);
                            erp.setEmployeeCategoryFilter(null);
                            erp.setEmployeeRoleFilter(null);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  )
                : _isHierarchyView
                    ? _buildHierarchicalView(hierarchicalMap)
                    : _buildFlatListView(employees),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HIERARCHICAL TREE VIEW (Grouped by Department, Leads on top, tree links)
  // ---------------------------------------------------------------------------
  Widget _buildHierarchicalView(Map<String, List<Employee>> hierarchicalMap) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: hierarchicalMap.keys.length,
      itemBuilder: (context, index) {
        final deptName = hierarchicalMap.keys.elementAt(index);
        final deptEmployees = hierarchicalMap[deptName]!;
        final isCollapsed = _collapsedDepartments.contains(deptName);

        // Separate Leads from direct team members
        final leads = deptEmployees.where((e) =>
            e.role.toLowerCase().contains('lead') ||
            e.role.toLowerCase().contains('manager') ||
            e.isPOC).toList();
        final teamMembers = deptEmployees.where((e) => !leads.contains(e)).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Header (Collapsible)
              InkWell(
                onTap: () {
                  setState(() {
                    if (isCollapsed) {
                      _collapsedDepartments.remove(deptName);
                    } else {
                      _collapsedDepartments.add(deptName);
                    }
                  });
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9).withOpacity(0.6),
                    borderRadius: isCollapsed
                        ? BorderRadius.circular(16)
                        : const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212529),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getDepartmentIcon(deptName),
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deptName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF212529),
                              ),
                            ),
                            Text(
                              '${deptEmployees.length} members • ${leads.length} leads & mentors',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isCollapsed ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isCollapsed) ...[
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // 1. Department Leadership Tier
                if (leads.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                    child: Row(
                      children: const [
                        Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFFF59E0B)),
                        SizedBox(width: 6),
                        Text(
                          'DEPARTMENT LEADERSHIP & MENTORS',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...leads.map((emp) => _buildHierarchicalEmployeeCard(emp, isLead: true)),
                ],

                // 2. Direct Team Members Tier
                if (teamMembers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                    child: Row(
                      children: const [
                        Icon(Icons.people_alt_outlined, size: 14, color: Color(0xFF3B82F6)),
                        SizedBox(width: 6),
                        Text(
                          'TEAM MEMBERS & SPECIALISTS',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...teamMembers.map((emp) => _buildHierarchicalEmployeeCard(emp, isLead: false)),
                ],
                const SizedBox(height: 6),
              ],
            ],
          ),
        );
      },
    );
  }

  // Hierarchical single employee tile with tree indicator
  Widget _buildHierarchicalEmployeeCard(Employee emp, {required bool isLead}) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => EmployeeDetailDialog(employee: emp),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isLead ? const Color(0xFFF5F6F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLead ? const Color(0xFFCBD5E1) : const Color(0xFFF1F5F9),
          ),
        ),
        child: Row(
          children: [
            // Hierarchical Tree line indicator
            if (!isLead) ...[
              const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
            ],
            // Avatar
            CircleAvatar(
              radius: isLead ? 18 : 16,
              backgroundColor: isLead ? const Color(0xFF212529) : const Color(0xFFE2E8F0),
              child: Text(
                emp.name.substring(0, 1),
                style: TextStyle(
                  fontSize: isLead ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color: isLead ? Colors.white : const Color(0xFF212529),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          emp.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isLead ? FontWeight.w800 : FontWeight.w700,
                            color: const Color(0xFF212529),
                          ),
                        ),
                      ),
                      if (emp.isPOC) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Text(
                            'POC',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emp.role,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                  if (emp.reportingManager.isNotEmpty)
                    Text(
                      'Reports to: ${emp.reportingManager}',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                    ),
                ],
              ),
            ),
            // Tasks pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${emp.activeTaskCount} tasks',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
            ),
            const SizedBox(width: 6),
            // Active status badge
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: emp.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FLAT DIRECTORY VIEW
  // ---------------------------------------------------------------------------
  Widget _buildFlatListView(List<Employee> employees) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      physics: const BouncingScrollPhysics(),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final emp = employees[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFE2E8F0),
                child: Text(
                  emp.name.substring(0, 1),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${emp.role} • ${emp.department}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: emp.isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  emp.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: emp.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => EmployeeDetailDialog(employee: emp),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getDepartmentIcon(String dept) {
    final d = dept.toLowerCase();
    if (d.contains('eng') || d.contains('tech')) return Icons.code_rounded;
    if (d.contains('ai') || d.contains('intell')) return Icons.psychology_rounded;
    if (d.contains('design') || d.contains('ui')) return Icons.palette_rounded;
    if (d.contains('market') || d.contains('growth')) return Icons.campaign_rounded;
    if (d.contains('sales') || d.contains('biz')) return Icons.trending_up_rounded;
    if (d.contains('people') || d.contains('hr')) return Icons.groups_rounded;
    if (d.contains('finance') || d.contains('account')) return Icons.account_balance_rounded;
    if (d.contains('ops') || d.contains('operat')) return Icons.settings_suggest_rounded;
    if (d.contains('qual') || d.contains('qa')) return Icons.verified_rounded;
    return Icons.business_rounded;
  }
}
