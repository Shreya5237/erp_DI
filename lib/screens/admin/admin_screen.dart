import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/hierarchy.dart';
import '../../providers/erp_provider.dart';

/// Admin & Settings Screen with Configurable Roles and Thresholds
class AdminScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const AdminScreen({super.key, this.onBack});

  void _showAddRoleDialog(BuildContext context, RoleCategory category) {
    final erp = context.read<ErpProvider>();
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${category.label} Role'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Systems Architect'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                erp.addRole(controller.text.trim(), category);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add Role'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final th = erp.thresholds;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF212529)),
                onPressed: onBack,
              )
            : null,
        title: const Text(
          'Admin & Settings',
          style: TextStyle(
            color: Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Configurable Alert Thresholds Card
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
                    children: const [
                      Icon(Icons.tune_rounded, size: 20, color: Color(0xFF212529)),
                      SizedBox(width: 8),
                      Text(
                        'Configurable Threshold Alerts',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Define corporate tolerance levels before executive alerts trigger:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),

                  _buildThresholdSlider(
                    title: 'Task Overdue Alert',
                    valueStr: '>= ${th.taskOverdueDays} day(s)',
                    value: th.taskOverdueDays.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    onChanged: (val) {
                      erp.updateThresholds(th.copyWith(taskOverdueDays: val.toInt()));
                    },
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  _buildThresholdSlider(
                    title: 'Intern Inactive (Missed Updates)',
                    valueStr: '>= ${th.internMissedUpdatesDays} day(s)',
                    value: th.internMissedUpdatesDays.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (val) {
                      erp.updateThresholds(th.copyWith(internMissedUpdatesDays: val.toInt()));
                    },
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  _buildThresholdSlider(
                    title: 'Project Delay Tolerance',
                    valueStr: '>= ${th.projectBehindProgressPercent}% behind',
                    value: th.projectBehindProgressPercent.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 5,
                    onChanged: (val) {
                      erp.updateThresholds(th.copyWith(projectBehindProgressPercent: val.toInt()));
                    },
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  _buildThresholdSlider(
                    title: 'Employee Max Capacity',
                    valueStr: '> ${th.employeeWorkloadCapacity} tasks',
                    value: th.employeeWorkloadCapacity.toDouble(),
                    min: 2,
                    max: 10,
                    divisions: 8,
                    onChanged: (val) {
                      erp.updateThresholds(th.copyWith(employeeWorkloadCapacity: val.toInt()));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Configurable Technical Roles
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
                        'Technical Roles',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Role', style: TextStyle(fontSize: 12)),
                        onPressed: () => _showAddRoleDialog(context, RoleCategory.technical),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: erp.technicalRoles.map((r) {
                      return Chip(
                        label: Text(r.name, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => erp.removeRole(r.id),
                        backgroundColor: const Color(0xFFF5F6F7),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Configurable Non-Technical Roles
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
                        'Non-Technical Roles',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Role', style: TextStyle(fontSize: 12)),
                        onPressed: () => _showAddRoleDialog(context, RoleCategory.nonTechnical),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: erp.nonTechnicalRoles.map((r) {
                      return Chip(
                        label: Text(r.name, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => erp.removeRole(r.id),
                        backgroundColor: const Color(0xFFF5F6F7),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Role Perspective Switcher
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
                    'Perspective Testing',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Text(
                      'Authenticated as: ${erp.currentRole.label}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Database JSON Export
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export ERP Database (JSON)'),
                onPressed: () {
                  final jsonStr = erp.exportDatabaseJson();
                  Clipboard.setData(ClipboardData(text: jsonStr));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database JSON copied to clipboard!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdSlider({
    required String title,
    required String valueStr,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212529)),
            ),
            Text(
              valueStr,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: const Color(0xFF212529),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
