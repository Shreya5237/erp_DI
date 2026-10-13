import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/department.dart';

/// 5 Departments Hub Screen adhering to Section 3 & 9.2 of the ERP PRD
class DepartmentHubScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final CompanyDepartment initialDepartment;

  const DepartmentHubScreen({
    super.key,
    this.onBack,
    this.initialDepartment = CompanyDepartment.engineering,
  });

  @override
  State<DepartmentHubScreen> createState() => _DepartmentHubScreenState();
}

class _DepartmentHubScreenState extends State<DepartmentHubScreen> {
  late CompanyDepartment _selectedDept;

  @override
  void initState() {
    super.initState();
    _selectedDept = widget.initialDepartment;
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final metrics = erp.departmentMetrics;
    final currentMetric = metrics.firstWhere(
      (m) => m.department == _selectedDept,
      orElse: () => metrics.last,
    );

    final deptEmployees = erp.allEmployees.where((e) {
      return e.departmentId == _selectedDept.departmentId ||
          e.department.toLowerCase() == _selectedDept.title.toLowerCase() ||
          e.department.toLowerCase() == _selectedDept.shortName.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF212529), size: 18),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: const Text(
          'Departmental Operations',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Department Chips Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: CompanyDepartment.values.map((dept) {
                  final isSelected = dept == _selectedDept;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(dept.shortName),
                      selected: isSelected,
                      selectedColor: const Color(0xFF212529),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedDept = dept),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Department Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_getDeptIcon(_selectedDept), color: const Color(0xFF212529), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDept.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                            ),
                            Text(
                              '${deptEmployees.length} Team Members • ${currentMetric.activeTasks} Active Tasks',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Attendance & Workload Progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance: ${currentMetric.presentToday}/${currentMetric.totalEmployees} (${currentMetric.attendancePercentage.toStringAsFixed(0)}%)',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: currentMetric.presentToday / currentMetric.totalEmployees,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workload Capacity: ${(currentMetric.workloadRatio * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: currentMetric.workloadRatio,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Predefined Roles for Department (PRD Section 3)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Predefined Departmental Roles',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedDept.predefinedRoles.map((role) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(role, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Department Staff Directory
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assigned Personnel',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                      ),
                      Text(
                        '${deptEmployees.length} Active',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (deptEmployees.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No employees assigned to this department yet.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ),
                  ] else ...[
                    ...deptEmployees.map((emp) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
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
                                    emp.name[0],
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(emp.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529))),
                                    Text(emp.role, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Present',
                                  style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeptIcon(CompanyDepartment dept) {
    switch (dept) {
      case CompanyDepartment.hr:
        return Icons.people_alt_rounded;
      case CompanyDepartment.sales:
        return Icons.trending_up_rounded;
      case CompanyDepartment.finance:
        return Icons.account_balance_wallet_rounded;
      case CompanyDepartment.marketing:
        return Icons.campaign_rounded;
      case CompanyDepartment.engineering:
        return Icons.code_rounded;
    }
  }
}
