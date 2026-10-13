import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/hr_models.dart';
import '../../../providers/erp_provider.dart';

/// Modal dialog for HR to allocate employees to department or project staffing requests
class AssignStaffingDialog extends StatefulWidget {
  final StaffingRequest request;

  const AssignStaffingDialog({super.key, required this.request});

  static Future<void> show(BuildContext context, StaffingRequest request) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AssignStaffingDialog(request: request),
    );
  }

  @override
  State<AssignStaffingDialog> createState() => _AssignStaffingDialogState();
}

class _AssignStaffingDialogState extends State<AssignStaffingDialog> {
  final Set<String> _selectedEmpIds = {};
  final TextEditingController _notesController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allEmployees = erp.allEmployees;

    final filteredEmployees = allEmployees.where((emp) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return emp.name.toLowerCase().contains(q) ||
          emp.role.toLowerCase().contains(q) ||
          emp.department.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.group_add_rounded, color: Color(0xFF212529), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign Team Members',
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.request.requestingDepartment} • ${widget.request.requiredRole}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Color(0xFFE2E8F0), height: 24),

            // Request summary badge card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Project: ${widget.request.projectName ?? "General Dept Staffing"}',
                        style: const TextStyle(color: Color(0xFF212529), fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Needed: ${widget.request.headcount}',
                          style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.request.requiredSkills.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(s, style: const TextStyle(color: Color(0xFF334155), fontSize: 10, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search filter
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search available employees by name or role...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                filled: true,
                fillColor: const Color(0xFFF5F6F7),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF212529))),
              ),
            ),
            const SizedBox(height: 10),

            // Employee selection list
            Text(
              'Select Employees (${_selectedEmpIds.length}/${widget.request.headcount} selected):',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final emp = filteredEmployees[index];
                  final isSelected = _selectedEmpIds.contains(emp.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF212529).withValues(alpha: 0.06) : const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF212529) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: isSelected,
                      activeColor: const Color(0xFF212529),
                      checkColor: Colors.white,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      title: Text(
                        emp.name,
                        style: const TextStyle(
                          color: Color(0xFF212529),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${emp.role} • ${emp.department} • Active Projects: ${emp.assignedProjectNames.length}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                      onChanged: (bool? val) {
                        setState(() {
                          if (val == true) {
                            _selectedEmpIds.add(emp.id);
                          } else {
                            _selectedEmpIds.remove(emp.id);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Notes input
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Allocation notes for requesting manager...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF5F6F7),
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF212529))),
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedEmpIds.isEmpty
                        ? null
                        : () {
                            final chosenEmps = allEmployees.where((e) => _selectedEmpIds.contains(e.id)).toList();
                            erp.assignStaffingEmployees(
                              widget.request.id,
                              employeeIds: chosenEmps.map((e) => e.id).toList(),
                              employeeNames: chosenEmps.map((e) => e.name).toList(),
                              notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF10B981),
                                content: Text('Assigned ${chosenEmps.length} employees to ${widget.request.requestingDepartment}'),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212529),
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Confirm & Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
