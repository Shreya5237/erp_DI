import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/employee.dart';
import '../../providers/erp_provider.dart';
import '../tasks/task_detail_dialog.dart';
import '../interns/intern_detail_dialog.dart';
import '../employee/pages/employee_calendar_page.dart';

/// Employee Inspector with Workload and Mentorship Assignment
class EmployeeDetailDialog extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailDialog({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final emp = erp.allEmployees.firstWhere(
      (e) => e.id == employee.id,
      orElse: () => employee,
    );
    final assignedTasks = erp.allTasks.where((t) => t.assignedToId == emp.id).toList();
    final mentoredInterns = erp.allInterns.where((i) => i.assignedPocId == emp.id).toList();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.backgroundLight,
                    child: Text(
                      emp.name.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emp.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${emp.role} • ${emp.department}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (emp.isPOC)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.electricBlueLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'INTERN POC MENTOR',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.electricBlue,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: emp.isActive
                                    ? AppColors.statusCompletedLight
                                    : AppColors.statusOverdueLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                emp.isActive ? 'ACTIVE' : 'DEACTIVATED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: emp.isActive
                                      ? AppColors.statusCompleted
                                      : AppColors.statusOverdue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Contact & Details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildMeta('Department', emp.subDepartmentName != null && emp.subDepartmentName!.isNotEmpty
                        ? '${emp.department} (${emp.subDepartmentName})'
                        : emp.department),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildMeta('Email', emp.email),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildMeta('Phone', emp.phone),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildMeta('Active Workload', '${assignedTasks.length} Assigned Tasks'),
                    const Divider(height: 12, color: AppColors.borderLight),
                    _buildMeta('Mentored Interns', '${mentoredInterns.length} Active Interns'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Mentored Interns List
              if (emp.isPOC) ...[
                Text(
                  'Assigned Interns Under Mentorship (${mentoredInterns.length})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (mentoredInterns.isEmpty)
                  const Text('No interns currently assigned.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                else
                  ...mentoredInterns.map((intern) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.school_outlined, size: 18, color: AppColors.electricBlue),
                        title: Text(intern.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('${intern.domain} • ${intern.college}', style: const TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right, size: 16),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => InternDetailDialog(intern: intern),
                          );
                        },
                      )),
                const SizedBox(height: 16),
              ],

              // Assigned Tasks List
              Text(
                'Active Tasks & Deliverables (${assignedTasks.length})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (assignedTasks.isEmpty)
                const Text('No pending tasks assigned.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
              else
                ...assignedTasks.map((t) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(
                        t.isOverdue ? Icons.warning_amber_rounded : Icons.task_alt,
                        size: 18,
                        color: t.isOverdue ? AppColors.statusOverdue : AppColors.statusCompleted,
                      ),
                      title: Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('${t.progressPercent}% • Due: ${t.dueDate.month}/${t.dueDate.day}', style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => TaskDetailDialog(task: t),
                        );
                      },
                    )),
              const SizedBox(height: 18),

              // View Employee Calendar Action
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month_rounded, size: 18, color: Colors.white),
                  label: Text(
                    'View ${emp.name}\'s Calendar',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EmployeeCalendarPage(
                          employee: emp,
                          showAppBar: true,
                          allowEmployeeSwitching: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Deactivate / Reactivate Toggle Action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(
                    emp.isActive ? Icons.person_off_outlined : Icons.person_add_alt,
                    size: 16,
                    color: emp.isActive ? AppColors.statusOverdue : AppColors.statusCompleted,
                  ),
                  label: Text(
                    emp.isActive ? 'Deactivate Employee' : 'Reactivate Employee',
                    style: TextStyle(
                      color: emp.isActive ? AppColors.statusOverdue : AppColors.statusCompleted,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: emp.isActive ? AppColors.statusOverdue : AppColors.statusCompleted,
                    ),
                  ),
                  onPressed: () {
                    erp.toggleEmployeeStatus(emp.id);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Employee status updated for ${emp.name}')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeta(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
