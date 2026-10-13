import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hierarchy.dart';
import '../providers/erp_provider.dart';

/// Clean Filters Bottom Sheet matching Screen 9
class FilterBottomSheet extends StatefulWidget {
  final bool isForInterns;

  const FilterBottomSheet({super.key, this.isForInterns = false});

  static void show(BuildContext context, {bool isForInterns = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterBottomSheet(isForInterns: isForInterns),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RoleCategory? _selectedCategory = RoleCategory.technical;
  String? _selectedRole;
  String? _selectedTeam;
  String _selectedStatus = 'All'; // 'All', 'Active', 'Inactive'
  String? _selectedBatch;

  @override
  void initState() {
    super.initState();
    final erp = context.read<ErpProvider>();
    _selectedCategory = widget.isForInterns
        ? erp.internCategoryFilter
        : erp.employeeCategoryFilter;
    _selectedRole = widget.isForInterns
        ? erp.internDomainFilter
        : erp.employeeRoleFilter;
    _selectedTeam = erp.employeeTeamFilter;
    if (erp.employeeActiveFilter != null) {
      _selectedStatus = erp.employeeActiveFilter! ? 'Active' : 'Inactive';
    } else {
      _selectedStatus = 'All';
    }
    _selectedBatch = erp.internBatchFilter;
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final roles = _selectedCategory == RoleCategory.technical
        ? erp.technicalRoles
        : (_selectedCategory == RoleCategory.nonTechnical
            ? erp.nonTechnicalRoles
            : erp.allRoles);

    final teams = [
      'Web Platform',
      'Core API',
      'Platform',
      'Core Mobile',
      'Design System',
      'Enterprise BD',
      'Talent Acquisition',
      'Cloud Infra',
    ];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212529),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF212529)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Domain (All, Technical, Non-Technical)
              const Text(
                'Domain',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPill('All', _selectedCategory == null, () {
                    setState(() => _selectedCategory = null);
                  }),
                  const SizedBox(width: 8),
                  _buildPill('Technical', _selectedCategory == RoleCategory.technical, () {
                    setState(() => _selectedCategory = RoleCategory.technical);
                  }),
                  const SizedBox(width: 8),
                  _buildPill('Non-Technical', _selectedCategory == RoleCategory.nonTechnical, () {
                    setState(() => _selectedCategory = RoleCategory.nonTechnical);
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              const Text(
                'Role',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
              ),
              const SizedBox(height: 6),
              _buildDropdown(
                value: _selectedRole,
                hint: 'Select role',
                items: roles.map((r) => r.name).toList(),
                onChanged: (val) => setState(() => _selectedRole = val),
              ),
              const SizedBox(height: 16),

              // Team Dropdown
              const Text(
                'Team',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
              ),
              const SizedBox(height: 6),
              _buildDropdown(
                value: _selectedTeam,
                hint: 'Select team',
                items: teams,
                onChanged: (val) => setState(() => _selectedTeam = val),
              ),
              const SizedBox(height: 16),

              // Status (All, Active, Inactive)
              const Text(
                'Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPill('All', _selectedStatus == 'All', () {
                    setState(() => _selectedStatus = 'All');
                  }),
                  const SizedBox(width: 8),
                  _buildPill('Active', _selectedStatus == 'Active', () {
                    setState(() => _selectedStatus = 'Active');
                  }),
                  const SizedBox(width: 8),
                  _buildPill('Inactive', _selectedStatus == 'Inactive', () {
                    setState(() => _selectedStatus = 'Inactive');
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // Batch (for interns)
              if (widget.isForInterns) ...[
                const Text(
                  'Batch (for interns)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                ),
                const SizedBox(height: 6),
                _buildDropdown(
                  value: _selectedBatch,
                  hint: 'Select batch',
                  items: erp.allBatches.map((b) => b.code).toList(),
                  onChanged: (val) => setState(() => _selectedBatch = val),
                ),
                const SizedBox(height: 20),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        erp.resetFilters();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.isForInterns) {
                          erp.setInternCategoryFilter(_selectedCategory);
                          erp.setInternDomainFilter(_selectedRole);
                          erp.setInternBatchFilter(_selectedBatch);
                        } else {
                          erp.setEmployeeCategoryFilter(_selectedCategory);
                          erp.setEmployeeRoleFilter(_selectedRole);
                          erp.setEmployeeTeamFilter(_selectedTeam);
                          erp.setEmployeeActiveFilter(
                            _selectedStatus == 'All'
                                ? null
                                : (_selectedStatus == 'Active'),
                          );
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildPill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF212529) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF212529))),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
