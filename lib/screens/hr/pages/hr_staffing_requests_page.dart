import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/hr_models.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/assign_staffing_dialog.dart';

/// Page 3 — Team & Resource Requests: Assign employees to departments and projects
/// Distinct from Finance which handles budget expenditure approvals.
class HrStaffingRequestsPage extends StatefulWidget {
  const HrStaffingRequestsPage({super.key});

  @override
  State<HrStaffingRequestsPage> createState() => _HrStaffingRequestsPageState();
}

class _HrStaffingRequestsPageState extends State<HrStaffingRequestsPage> {
  String _selectedFilter = 'Pending'; // 'Pending', 'All', 'In Progress', 'Fulfilled', 'Rejected'

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final allRequests = erp.allStaffingRequests;
    final pendingRequests = erp.pendingStaffingRequests;
    final inProgressRequests = erp.inProgressStaffingRequests;
    final fulfilledRequests = erp.fulfilledStaffingRequests;
    final rejectedRequests = allRequests.where((s) => s.status == StaffingRequestStatus.rejected).toList();

    List<StaffingRequest> displayList;
    switch (_selectedFilter) {
      case 'Pending':
        displayList = pendingRequests;
        break;
      case 'In Progress':
        displayList = inProgressRequests;
        break;
      case 'Fulfilled':
        displayList = fulfilledRequests;
        break;
      case 'Rejected':
        displayList = rejectedRequests;
        break;
      default:
        displayList = allRequests;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Team Staffing & Resource Requests',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanatory Banner: HR vs Finance Responsibility
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFFA78BFA), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HR handles employee allocation and team assignments. Finance separately reviews budget expenditure approvals where required.',
                      style: TextStyle(color: Color(0xFFDDD6FE), fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Pending', pendingRequests.length, const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _buildFilterChip('All', allRequests.length, const Color(0xFF38BDF8)),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', inProgressRequests.length, const Color(0xFF06B6D4)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Fulfilled', fulfilledRequests.length, const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', rejectedRequests.length, const Color(0xFFEF4444)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Requests List
            if (displayList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.group_off_rounded, color: Color(0xFF475569), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No $_selectedFilter staffing requests found',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ...displayList.map((req) => _buildStaffingRequestCard(context, erp, req)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, Color color) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = label);
      },
      selectedColor: color.withValues(alpha: 0.2),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? color : const Color(0xFF64748B),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? color : const Color(0xFF334155)),
    );
  }

  Widget _buildStaffingRequestCard(BuildContext context, ErpProvider erp, StaffingRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: req.isPending ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Role & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          req.requiredRole,
                          style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Headcount: ${req.headcount}',
                            style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${req.requestingDepartment} • Requester: ${req.requesterName}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: req.status.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  req.status.label,
                  style: TextStyle(color: req.status.color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Details container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF212529),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Project: ${req.projectName ?? "General Dept Assignment"}',
                      style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Joining: ${req.requestedJoiningDate.day}/${req.requestedJoiningDate.month}/${req.requestedJoiningDate.year}',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Required Skills:', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: req.requiredSkills.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF475569)),
                      ),
                      child: Text(s, style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 10)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Fulfilled details if fulfilled
          if (req.isFulfilled && req.assignedEmployeeNames.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Assigned: ${req.assignedEmployeeNames.join(", ")}',
                        style: const TextStyle(color: Color(0xFF34D399), fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (req.hrNotes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'HR Note: ${req.hrNotes}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Rejection reason if rejected
          if (req.status == StaffingRequestStatus.rejected && req.hrNotes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Rejection Reason: ${req.hrNotes}',
                style: const TextStyle(color: Color(0xFFF87171), fontSize: 11),
              ),
            ),
          ],

          // Actions
          if (req.isPending || req.status == StaffingRequestStatus.inProgress) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _coordinateWithManager(context, req),
                  icon: const Icon(Icons.forum_outlined, size: 14, color: Color(0xFF38BDF8)),
                  label: const Text('Coordinate', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showRejectStaffingDialog(context, erp, req),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  child: const Text('Reject', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => AssignStaffingDialog.show(context, req),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 14, color: Colors.white),
                  label: const Text('Assign Staff', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _coordinateWithManager(BuildContext context, StaffingRequest req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.forum_rounded, color: Color(0xFF212529), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Coordinate with ${req.requesterName}', style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Department: ${req.requestingDepartment}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 4),
              Text('Project: ${req.projectName ?? "General Department Staffing"}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Internal message logged: HR is reviewing talent availability and active bench engineers for required skills.',
                  style: TextStyle(color: Color(0xFF334155), fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectStaffingDialog(BuildContext context, ErpProvider erp, StaffingRequest req) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Staffing Request ${req.id}', style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter reason for unavailability or rejection:',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. No bench engineers with specified skill set available this month',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              erp.rejectStaffingRequest(req.id, reason: reasonController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: const Color(0xFFEF4444), content: Text('Staffing request ${req.id} rejected')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm Rejection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
