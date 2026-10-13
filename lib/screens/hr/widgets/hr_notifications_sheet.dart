import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../pages/hr_leave_management_page.dart';
import '../pages/hr_staffing_requests_page.dart';
import '../pages/hr_onboarding_trainees_page.dart';
import '../pages/hr_pipeline_coordination_page.dart';

/// Notification triggers defined in Section 3 of the HR specification
enum HrNotificationType {
  leaveApproval('Leave Approval', Icons.beach_access_rounded, Color(0xFF38BDF8)),
  staffingRequest('Staffing Request', Icons.group_add_rounded, Color(0xFFF59E0B)),
  trainerAssignment('Trainer Assignment', Icons.person_pin_rounded, Color(0xFF8B5CF6)),
  trainingReminder('Training Reminder', Icons.school_rounded, Color(0xFF10B981)),
  projectStaffing('Project Staffing', Icons.handshake_rounded, Color(0xFF06B6D4)),
  customerFeedback('Customer Feedback', Icons.feedback_rounded, Color(0xFFF97316)),
  pendingReview('Pending Review', Icons.rate_review_rounded, Color(0xFFEC4899)),
  meetingReminder('Meeting Reminder', Icons.alarm_rounded, Color(0xFFEAB308)),
  taskDeadline('Task Deadline', Icons.event_busy_rounded, Color(0xFFEF4444)),
  monthlyTarget('Monthly Target', Icons.flag_rounded, Color(0xFFA855F7));

  final String label;
  final IconData icon;
  final Color color;
  const HrNotificationType(this.label, this.icon, this.color);
}

class HrNotificationItem {
  final String id;
  final HrNotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUrgent;
  final VoidCallback? onTap;

  HrNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isUrgent = false,
    this.onTap,
  });
}

/// Unified HR Notifications & Alerts Modal Sheet
/// Accessible from the top bar across all pages
class HrNotificationsSheet extends StatefulWidget {
  const HrNotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HrNotificationsSheet(),
    );
  }

  @override
  State<HrNotificationsSheet> createState() => _HrNotificationsSheetState();
}

class _HrNotificationsSheetState extends State<HrNotificationsSheet> {
  String _selectedFilter = 'All'; // 'All', 'Urgent', 'Leave', 'Staffing'
  final Set<String> _readIds = {};

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final pendingLeaves = erp.pendingLeaveRequests;
    final pendingStaffing = erp.pendingStaffingRequests;
    final pendingChange = erp.pendingCustomerChangeRequests;
    final attentionTrainees = erp.traineesNeedingAttention;

    // 10 Alert triggers specified in Section 3 of prompt
    final List<HrNotificationItem> notifications = [
      // 1. Leave Approval Trigger
      if (pendingLeaves.isNotEmpty)
        HrNotificationItem(
          id: 'ALERT-LVE-01',
          type: HrNotificationType.leaveApproval,
          title: 'New Leave Request: ${pendingLeaves.first.employeeName}',
          message: '${pendingLeaves.first.employeeName} requested ${pendingLeaves.first.daysCount} days (${pendingLeaves.first.leaveType.label}) for "${pendingLeaves.first.reason}".',
          timeAgo: '15m ago',
          isUrgent: true,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HrLeaveManagementPage()));
          },
        ),

      // 2. Staffing Request Trigger
      if (pendingStaffing.isNotEmpty)
        HrNotificationItem(
          id: 'ALERT-STF-01',
          type: HrNotificationType.staffingRequest,
          title: 'Urgent Staffing: ${pendingStaffing.first.requestingDepartment}',
          message: '${pendingStaffing.first.requesterName} requested ${pendingStaffing.first.headcount} ${pendingStaffing.first.requiredRole} for ${pendingStaffing.first.projectName ?? "Department"}.',
          timeAgo: '1h ago',
          isUrgent: true,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HrStaffingRequestsPage()));
          },
        ),

      // 3. Project Staffing (Finalized deal needs employees assigned)
      HrNotificationItem(
        id: 'ALERT-PRJ-01',
        type: HrNotificationType.projectStaffing,
        title: 'Project Staffing: SolarEase Enterprise',
        message: 'Deal LED-504 finalized by Sales. HR staffing required: 2 Mobile Devs and 1 QA Engineer.',
        timeAgo: '2h ago',
        isUrgent: true,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HrPipelineCoordinationPage()));
        },
      ),

      // 4. Customer Feedback / Change Request Trigger
      if (pendingChange.isNotEmpty)
        HrNotificationItem(
          id: 'ALERT-CFB-01',
          type: HrNotificationType.customerFeedback,
          title: 'Customer Change Request: ${pendingChange.first.clientName}',
          message: '${pendingChange.first.companyName} submitted: "${pendingChange.first.description}". Coordination required.',
          timeAgo: '3h ago',
          isUrgent: pendingChange.first.isEscalated,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HrPipelineCoordinationPage()));
          },
        ),

      // 5. Training Reminder Trigger
      HrNotificationItem(
        id: 'ALERT-TRN-01',
        type: HrNotificationType.trainingReminder,
        title: 'Upcoming Trainee Evaluation Milestone',
        message: 'Friday Evaluation Batch evaluation review for 5 technical trainees due in 2 days.',
        timeAgo: '4h ago',
        isUrgent: false,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HrOnboardingTraineesPage()));
        },
      ),

      // 6. Trainer Assignment Trigger
      HrNotificationItem(
        id: 'ALERT-TNR-01',
        type: HrNotificationType.trainerAssignment,
        title: 'Mentor Assigned: Arjun Sharma',
        message: 'Arjun Sharma assigned as technical mentor for trainee Karthik R (Mobile App batch).',
        timeAgo: 'Yesterday',
        isUrgent: false,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HrOnboardingTraineesPage()));
        },
      ),

      // 7. Pending Review Trigger (Trainees Needing Attention)
      if (attentionTrainees.isNotEmpty)
        HrNotificationItem(
          id: 'ALERT-REV-01',
          type: HrNotificationType.pendingReview,
          title: '${attentionTrainees.length} Trainees Need Attention',
          message: '${attentionTrainees.first.name} has missed sprint updates or is under pending evaluation.',
          timeAgo: '1d ago',
          isUrgent: true,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HrOnboardingTraineesPage()));
          },
        ),

      // 8. Meeting Reminder Trigger
      HrNotificationItem(
        id: 'ALERT-MTG-01',
        type: HrNotificationType.meetingReminder,
        title: 'Meeting in 15 Minutes: Trainee Progress Sync',
        message: 'Weekly Trainee & Intern Onboarding Review with Laven Lokesh and technical POCs at 2:30 PM.',
        timeAgo: '15m reminder',
        isUrgent: false,
      ),

      // 9. Task Deadline Trigger
      HrNotificationItem(
        id: 'ALERT-TSK-01',
        type: HrNotificationType.taskDeadline,
        title: 'HR Task Deadline Today: Leave Approvals',
        message: 'Quarterly leave audit and team attendance reconciliation due today by 6:00 PM.',
        timeAgo: 'Today',
        isUrgent: true,
      ),

      // 10. Monthly Target Trigger
      HrNotificationItem(
        id: 'ALERT-TGT-01',
        type: HrNotificationType.monthlyTarget,
        title: 'Monthly Target: 90% Leave Reviews Achieved',
        message: '18 of 20 monthly leave requests reviewed. 2 remaining to hit monthly HR KPI target.',
        timeAgo: '2d ago',
        isUrgent: false,
      ),
    ];

    final filteredList = notifications.where((item) {
      if (_selectedFilter == 'Urgent') return item.isUrgent;
      if (_selectedFilter == 'Leave') return item.type == HrNotificationType.leaveApproval;
      if (_selectedFilter == 'Staffing') {
        return item.type == HrNotificationType.staffingRequest ||
            item.type == HrNotificationType.projectStaffing;
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF212529),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF38BDF8), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HR Alerts & Notifications',
                        style: TextStyle(
                          color: Color(0xFF212529),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Leave approvals, staffing & onboarding feeds',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final n in notifications) {
                        _readIds.add(n.id);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All HR alerts marked as read'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('Mark all read', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                ),
              ],
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', notifications.length),
                _buildFilterChip('Urgent', notifications.where((n) => n.isUrgent).length),
                _buildFilterChip('Leave', pendingLeaves.length),
                _buildFilterChip('Staffing', pendingStaffing.length + 1),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white, height: 1),

          // Notifications List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final isRead = _readIds.contains(item.id);
                return _buildNotificationCard(item, isRead);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF0284C7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        label: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onSelected: (_) => setState(() => _selectedFilter = label),
      ),
    );
  }

  Widget _buildNotificationCard(HrNotificationItem item, bool isRead) {
    return InkWell(
      onTap: () {
        setState(() => _readIds.add(item.id));
        item.onTap?.call();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? const Color(0xFF131D2E) : const Color(0xFF2B3035),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isUrgent && !isRead
                ? item.type.color.withValues(alpha: 0.6)
                : const Color(0xFF334155).withValues(alpha: 0.4),
            width: item.isUrgent && !isRead ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.type.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.type.icon, color: item.type.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.type.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type.label,
                          style: TextStyle(
                            color: item.type.color,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.timeAgo,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: isRead ? const Color(0xFF64748B) : Colors.white,
                      fontSize: 13.5,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.35),
                  ),
                  if (item.onTap != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Tap to view action',
                          style: TextStyle(color: item.type.color, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: item.type.color, size: 12),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
