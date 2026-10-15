import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../pages/finance_budgets_page.dart';
import '../pages/finance_resource_requests_page.dart';
import '../pages/finance_leads_pipeline_page.dart';

/// Notification type enum covering all 9 required Finance alerts
enum FinanceNotificationType {
  meetingReminder('Meeting Reminder', Icons.access_time_filled_rounded, Color(0xFF212529)),
  leaveBalance('Leave Balance', Icons.calendar_month_outlined, Color(0xFF212529)),
  resourceRequest('Resource Request', Icons.inventory_2_rounded, Color(0xFF212529)),
  pendingApproval('Pending Approval', Icons.hourglass_top_rounded, Color(0xFF212529)),
  budgetThreshold('Budget Threshold', Icons.warning_amber_rounded, Color(0xFF212529)),
  budgetExceeded('Budget Exceeded', Icons.report_problem_rounded, Color(0xFF212529)),
  leadsPipeline('Leads Pipeline', Icons.trending_up_rounded, Color(0xFF212529)),
  approvalDecision('Approval Decision', Icons.verified_rounded, Color(0xFF212529)),
  taskDeadline('Task Deadline', Icons.alarm_on_rounded, Color(0xFF212529));

  final String label;
  final IconData icon;
  final Color color;
  const FinanceNotificationType(this.label, this.icon, this.color);
}

class FinanceNotificationItem {
  final String id;
  final FinanceNotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUrgent;
  final bool isRead;
  final VoidCallback? onTap;

  FinanceNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isUrgent = false,
    this.isRead = false,
    this.onTap,
  });
}

/// Unified Finance Notifications & Alerts Modal Sheet
/// Accessible from the top bar across all pages
class FinanceNotificationsSheet extends StatefulWidget {
  const FinanceNotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FinanceNotificationsSheet(),
    );
  }

  @override
  State<FinanceNotificationsSheet> createState() => _FinanceNotificationsSheetState();
}

class _FinanceNotificationsSheetState extends State<FinanceNotificationsSheet> {
  String _selectedFilter = 'All'; // 'All', 'Urgent', 'Budgets', 'Approvals'
  final Set<String> _readIds = {};

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final overbudgetCount = erp.overbudgetProjects.length;
    final thresholdCount = erp.thresholdAlertProjects.length;
    final pendingRequestsCount = erp.pendingResourceRequests.length;
    final pipelineLeadsCount = erp.financeReviewLeads.length;

    // Build the dynamic notification items covering all 9 required types
    final List<FinanceNotificationItem> notifications = [
      // 1. Budget Exceeded Alert (Urgent)
      if (overbudgetCount > 0)
        FinanceNotificationItem(
          id: 'ALERT-OVR-01',
          type: FinanceNotificationType.budgetExceeded,
          title: 'Critical: Budget Exceeded',
          message: 'FinTech Payment Gateway (PRJ-304) spending reached ₹1,28,500 vs approved ₹1,20,000 (107.1% spent). Immediate budget revision required.',
          timeAgo: '12m ago',
          isUrgent: true,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceBudgetsPage()));
          },
        ),

      // 2. Budget Threshold Warning (85%+)
      if (thresholdCount > 0)
        FinanceNotificationItem(
          id: 'ALERT-THR-01',
          type: FinanceNotificationType.budgetThreshold,
          title: 'Threshold Warning: 86.7% Utilized',
          message: 'Digital Inertia ERP Core (PRJ-306) has utilized ₹65,000 of ₹75,000. Spending pace indicates limit breach within 14 days.',
          timeAgo: '45m ago',
          isUrgent: true,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceBudgetsPage()));
          },
        ),

      // 3. Pending Approvals Queue
      FinanceNotificationItem(
        id: 'ALERT-REQ-01',
        type: FinanceNotificationType.pendingApproval,
        title: 'Action Required: Pending Resource Approvals',
        message: 'There are $pendingRequestsCount departmental resource procurement requests waiting for Siddharth Roy\'s finance allocation signoff.',
        timeAgo: '1h ago',
        isUrgent: true,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceResourceRequestsPage()));
        },
      ),

      // 4. Resource Request Submitted Alert
      FinanceNotificationItem(
        id: 'ALERT-REQ-02',
        type: FinanceNotificationType.resourceRequest,
        title: 'New Request: Technology & Engineering',
        message: 'Priya Nair submitted REQ-201 for AWS GPU Cluster (p4d.24xlarge) estimated at ₹1,85,000 for Quantra BioSciences AI platform.',
        timeAgo: '3h ago',
        isUrgent: false,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceResourceRequestsPage()));
        },
      ),

      // 5. Leads Pipeline Notification
      FinanceNotificationItem(
        id: 'ALERT-LED-01',
        type: FinanceNotificationType.leadsPipeline,
        title: 'Sales Forwarded Deal for Financial Review',
        message: 'Rajesh Kumar forwarded SolarEase Enterprise (LED-504, ₹4,50,000) for commercial feasibility and margin sign-off.',
        timeAgo: '4h ago',
        isUrgent: true,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceLeadsPipelinePage()));
        },
      ),

      // 6. Meeting Reminder
      FinanceNotificationItem(
        id: 'ALERT-MTG-01',
        type: FinanceNotificationType.meetingReminder,
        title: 'Upcoming Meeting in 15 Minutes',
        message: 'Q4 Budget & Revenue Alignment with Laven Lokesh and Priya Nair starts at 2:30 PM (Google Meet / Boardroom A).',
        timeAgo: '15m reminder',
        isUrgent: false,
      ),

      // 7. Task Deadline Reminder
      FinanceNotificationItem(
        id: 'ALERT-TSK-01',
        type: FinanceNotificationType.taskDeadline,
        title: 'Task Deadline Due Today',
        message: 'Reconciliation of Q3 vendor invoices and tax credits is due by 6:00 PM today.',
        timeAgo: 'Today 6:00 PM',
        isUrgent: true,
      ),

      // 8. Approval Decision Update
      FinanceNotificationItem(
        id: 'ALERT-DEC-01',
        type: FinanceNotificationType.approvalDecision,
        title: 'Decision Logged: REQ-203 Approved',
        message: 'Campus Hiring Assessment Portal (₹95,000) approved for HR team. Budget allocated under Talent Acquisition.',
        timeAgo: '1d ago',
        isUrgent: false,
      ),

      // 9. Leave Balance Synchronization
      FinanceNotificationItem(
        id: 'ALERT-LVE-01',
        type: FinanceNotificationType.leaveBalance,
        title: 'Leave Balance Synchronized',
        message: 'Synchronized with HR Central Core: 18 available leave days (12 Annual, 4 Sick, 2 Casual). 0 pending leave requests.',
        timeAgo: 'Yesterday',
        isUrgent: false,
      ),
    ];

    final filteredList = notifications.where((item) {
      if (_selectedFilter == 'Urgent') return item.isUrgent;
      if (_selectedFilter == 'Budgets') {
        return item.type == FinanceNotificationType.budgetExceeded ||
            item.type == FinanceNotificationType.budgetThreshold;
      }
      if (_selectedFilter == 'Approvals') {
        return item.type == FinanceNotificationType.pendingApproval ||
            item.type == FinanceNotificationType.resourceRequest ||
            item.type == FinanceNotificationType.leadsPipeline;
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
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
              color: const Color(0xFFE9ECEF),
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
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF212529), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finance Alerts & Notifications',
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF212529),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Real-time ERP financial event feeds',
                        style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 11.5),
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
                        content: Text('All alerts marked as read'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.instrumentSans(color: const Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.w700),
                  ),
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
                _buildFilterChip('Budgets', 2),
                _buildFilterChip('Approvals', pendingRequestsCount + pipelineLeadsCount),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE9ECEF), height: 1),

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
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF212529) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? const Color(0xFF212529) : const Color(0xFFE9ECEF)),
          ),
          child: Text(
            '$label ($count)',
            style: GoogleFonts.instrumentSans(
              color: isSelected ? Colors.white : const Color(0xFF495057),
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(FinanceNotificationItem item, bool isRead) {
    return InkWell(
      onTap: () {
        setState(() => _readIds.add(item.id));
        item.onTap?.call();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? const Color(0xFFF8F9FA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isUrgent && !isRead ? const Color(0xFF212529) : const Color(0xFFE9ECEF),
            width: item.isUrgent && !isRead ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.type.icon, color: const Color(0xFF212529), size: 18),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type.label,
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF495057),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.timeAgo,
                        style: GoogleFonts.instrumentSans(color: const Color(0xFF868E96), fontSize: 10.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 13.5,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF6C757D),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  if (item.onTap != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Tap to view details',
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0xFF212529),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, color: Color(0xFF212529), size: 12),
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
