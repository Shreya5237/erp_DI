import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/hr_models.dart';
import '../../../providers/erp_provider.dart';

/// Page 2 — Leave Management: Review and approve employee leave requests
/// Updates central ERP records and highlights overlapping team absences.
class HrLeaveManagementPage extends StatefulWidget {
  const HrLeaveManagementPage({super.key});

  @override
  State<HrLeaveManagementPage> createState() => _HrLeaveManagementPageState();
}

class _HrLeaveManagementPageState extends State<HrLeaveManagementPage> {
  String _selectedFilter = 'Pending'; // 'Pending', 'All', 'Approved', 'Rejected'
  bool _showEmployeeBalances = false;
  String _balanceSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final allLeaves = erp.allLeaveRequests;
    final pendingLeaves = erp.pendingLeaveRequests;
    final approvedLeaves = erp.approvedLeaveRequests;
    final rejectedLeaves = erp.rejectedLeaveRequests;
    final allEmployees = erp.allEmployees;

    List<EmployeeLeaveRequest> displayList;
    switch (_selectedFilter) {
      case 'Pending':
        displayList = pendingLeaves;
        break;
      case 'Approved':
        displayList = approvedLeaves;
        break;
      case 'Rejected':
        displayList = rejectedLeaves;
        break;
      default:
        displayList = allLeaves;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Leave Management',
          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showEmployeeBalances ? Icons.list_alt_rounded : Icons.account_box_outlined,
              color: const Color(0xFF38BDF8),
            ),
            tooltip: _showEmployeeBalances ? 'Show Leave Requests' : 'Check Employee Balances',
            onPressed: () => setState(() => _showEmployeeBalances = !_showEmployeeBalances),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HR Employee's Own Leave Balance Card
            _buildOwnLeaveBalanceBanner(context, erp),
            const SizedBox(height: 14),

            if (_showEmployeeBalances) ...[
              // Central Employee Balances Explorer
              _buildEmployeeBalancesSection(context, allEmployees),
            ] else ...[
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Pending', pendingLeaves.length, const Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    _buildFilterChip('All', allLeaves.length, const Color(0xFF38BDF8)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Approved', approvedLeaves.length, const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Rejected', rejectedLeaves.length, const Color(0xFFEF4444)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Request Cards List
              if (displayList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Icon(Icons.beach_access_rounded, color: Color(0xFF475569), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No $_selectedFilter leave requests found',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...displayList.map((req) => _buildLeaveRequestCard(context, erp, req)),
            ],
          ],
        ),
      ),
    );
  }

  // HR Employee's Own Leave Balance
  Widget _buildOwnLeaveBalanceBanner(BuildContext context, ErpProvider erp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Leave Balance (Meera Joshi)',
                style: TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                '18 Days Total',
                style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLeaveSubBalance('Annual / Paid', '12', const Color(0xFF38BDF8)),
              const SizedBox(width: 8),
              _buildLeaveSubBalance('Sick Leave', '4', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildLeaveSubBalance('Casual Leave', '2', const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveSubBalance(String label, String days, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF212529),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(days, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Filter Chip
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

  // Leave Request Card
  Widget _buildLeaveRequestCard(BuildContext context, ErpProvider erp, EmployeeLeaveRequest req) {
    // Look up employee record to get current remaining balance
    final emp = erp.allEmployees.firstWhere(
      (e) => e.id == req.employeeId,
      orElse: () => erp.allEmployees.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: req.isPending
              ? (req.hasOverlappingTeamAbsence ? const Color(0xFFF59E0B) : const Color(0xFF334155))
              : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Department, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.employeeName,
                    style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${req.department} • ID: ${req.employeeId}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
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

          // Leave Details Grid
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
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 14, color: req.leaveType.color),
                        const SizedBox(width: 6),
                        Text(
                          '${req.daysCount} Days (${req.leaveType.label})',
                          style: TextStyle(color: req.leaveType.color, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${req.startDate.day}/${req.startDate.month}/${req.startDate.year} - ${req.endDate.day}/${req.endDate.month}/${req.endDate.year}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Available Balance: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    Text(
                      '${emp.leaveBalance} days remaining',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Reason: "${req.reason}"',
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 11.5, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          // Overlapping absence alert
          if (req.hasOverlappingTeamAbsence) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Team overlap: ${req.overlappingEmployeeNames.join(", ")} on same dates',
                      style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Comments if already reviewed
          if (req.hrComments != null) ...[
            const SizedBox(height: 6),
            Text(
              'HR Note: ${req.hrComments}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ],

          // Action Buttons if pending
          if (req.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context, erp, req),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Reject', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApproveDialog(context, erp, req),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Section: Track All Employee Leave Balances
  Widget _buildEmployeeBalancesSection(BuildContext context, List<dynamic> employees) {
    final filtered = employees.where((e) {
      if (_balanceSearchQuery.isEmpty) return true;
      final q = _balanceSearchQuery.toLowerCase();
      return e.name.toLowerCase().contains(q) || e.department.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Company-Wide Leave Balances',
              style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => setState(() => _showEmployeeBalances = false),
              child: const Text('Back to Requests', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: (v) => setState(() => _balanceSearchQuery = v),
          style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search employee or department...',
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
            filled: true,
            fillColor: const Color(0xFF2B3035),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        ...filtered.map((emp) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emp.name, style: const TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('${emp.role} • ${emp.department}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${emp.leaveBalance} Days', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      'P:${emp.paidLeaves} S:${emp.sickLeaves} C:${emp.casualLeaves}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Dialog: Approve Leave
  void _showApproveDialog(BuildContext context, ErpProvider erp, EmployeeLeaveRequest req) {
    final commentController = TextEditingController(text: 'Approved by HR & People Ops.');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Approve Leave for ${req.employeeName}', style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deduct ${req.daysCount} days (${req.leaveType.label}) from employee balance and notify manager.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Optional HR approval notes...',
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
              erp.approveLeaveRequest(req.id, comments: commentController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF10B981),
                  content: Text('Leave request approved for ${req.employeeName}'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm Approval', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Dialog: Reject Leave
  void _showRejectDialog(BuildContext context, ErpProvider erp, EmployeeLeaveRequest req) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Leave for ${req.employeeName}', style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A recorded reason is mandatory for rejection:',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Critical release sprint overlap / Team absence limit reached',
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
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: Color(0xFFEF4444), content: Text('Please enter a rejection reason')),
                );
                return;
              }
              erp.rejectLeaveRequest(req.id, reason: reasonController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFFEF4444),
                  content: Text('Leave request rejected for ${req.employeeName}'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Confirm Rejection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
