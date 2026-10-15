import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import 'deal_detail_sheet.dart';

enum SalesNotificationType {
  dailyCallTarget,
  followUpReminder,
  upcomingMeeting,
  dealStatusUpdate,
  managerResponse,
  hrFinanceResponse,
  monthlyTargetProgress,
}

class SalesNotificationItem {
  final String id;
  final SalesNotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final String? leadId;
  final String? callId;
  final String? meetingId;

  const SalesNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isUnread = true,
    this.leadId,
    this.callId,
    this.meetingId,
  });

  IconData get icon {
    switch (type) {
      case SalesNotificationType.dailyCallTarget:
        return Icons.phone_callback_rounded;
      case SalesNotificationType.followUpReminder:
        return Icons.alarm_rounded;
      case SalesNotificationType.upcomingMeeting:
        return Icons.video_call_rounded;
      case SalesNotificationType.dealStatusUpdate:
        return Icons.trending_up_rounded;
      case SalesNotificationType.managerResponse:
        return Icons.rate_review_rounded;
      case SalesNotificationType.hrFinanceResponse:
        return Icons.account_balance_rounded;
      case SalesNotificationType.monthlyTargetProgress:
        return Icons.flag_rounded;
    }
  }

  Color get color {
    switch (type) {
      case SalesNotificationType.dailyCallTarget:
        return const Color(0xFFEF4444);
      case SalesNotificationType.followUpReminder:
        return const Color(0xFFF59E0B);
      case SalesNotificationType.upcomingMeeting:
        return const Color(0xFF8B5CF6);
      case SalesNotificationType.dealStatusUpdate:
        return const Color(0xFF10B981);
      case SalesNotificationType.managerResponse:
        return const Color(0xFF3B82F6);
      case SalesNotificationType.hrFinanceResponse:
        return const Color(0xFF06B6D4);
      case SalesNotificationType.monthlyTargetProgress:
        return const Color(0xFFEC4899);
    }
  }
}

/// Notification bottom sheet matching Section 2 of Sales App concept
class SalesNotificationsSheet extends StatelessWidget {
  const SalesNotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SalesNotificationsSheet(),
    );
  }

  List<SalesNotificationItem> _getNotifications(ErpProvider erp) {
    return [
      SalesNotificationItem(
        id: 'NOTIF-01',
        type: SalesNotificationType.dailyCallTarget,
        title: 'Daily Call Target Alert',
        message: 'You have completed ${erp.callsCompletedTodayCount}/${erp.dailyColdCallTarget} calls today. ${erp.pendingColdCallsTodayCount} calls remaining to meet minimum target.',
        timeAgo: 'Just now',
        isUnread: true,
      ),
      const SalesNotificationItem(
        id: 'NOTIF-02',
        type: SalesNotificationType.followUpReminder,
        title: 'Urgent Follow-up Due',
        message: 'Scheduled follow-up with Vikramaditya Rao (GreenTech Solutions) due now regarding IoT carbon tracking portal.',
        timeAgo: '10m ago',
        leadId: 'LED-501',
        callId: 'CALL-101',
        isUnread: true,
      ),
      const SalesNotificationItem(
        id: 'NOTIF-03',
        type: SalesNotificationType.upcomingMeeting,
        title: 'Upcoming Meeting in 15 Minutes',
        message: 'Client Feasibility & Architecture Alignment with GreenTech Solutions starts at 04:30 PM on Google Meet.',
        timeAgo: '15m ago',
        meetingId: 'MTG-03',
        isUnread: true,
      ),
      const SalesNotificationItem(
        id: 'NOTIF-04',
        type: SalesNotificationType.managerResponse,
        title: 'Manager Response Received',
        message: 'Priya Nair (GM) reviewed proposal for Skyline Infra: "Commercial terms approved. Proceed to client agreement."',
        timeAgo: '1h ago',
        leadId: 'LED-503',
        isUnread: false,
      ),
      const SalesNotificationItem(
        id: 'NOTIF-05',
        type: SalesNotificationType.hrFinanceResponse,
        title: 'HR & Finance Feasibility Cleared',
        message: 'Meera Joshi (HR) allocated 140h Tech Lead and Siddharth Roy (Finance) validated 42% margin for SolarEase.',
        timeAgo: '2h ago',
        leadId: 'LED-504',
        isUnread: false,
      ),
      const SalesNotificationItem(
        id: 'NOTIF-06',
        type: SalesNotificationType.dealStatusUpdate,
        title: 'Deal Status Updated',
        message: 'InnovortX moved from "Contacted" to "Proposal Prepared" with value ₹4,80,000.',
        timeAgo: '3h ago',
        leadId: 'LED-502',
        isUnread: false,
      ),
      SalesNotificationItem(
        id: 'NOTIF-07',
        type: SalesNotificationType.monthlyTargetProgress,
        title: 'Monthly Target Update',
        message: '₹38.5L achieved out of ₹50.0L monthly target (77%). 8 days remaining to close ₹11.5L pipeline!',
        timeAgo: 'Yesterday',
        isUnread: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final notifications = _getNotifications(erp);
    final unreadCount = notifications.where((n) => n.isUnread).length;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCED4DA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: Color(0xFF212529), size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Sales Alerts & Notifications',
                  style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212529),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount New',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE9ECEF), height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return InkWell(
                  onTap: () => _handleTap(context, notif, erp),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: notif.isUnread ? const Color(0xFFF8F9FA) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: notif.isUnread
                            ? const Color(0xFF212529)
                            : const Color(0xFFE9ECEF),
                        width: notif.isUnread ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(notif.icon, color: const Color(0xFF212529), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      notif.title,
                                      style: TextStyle(
                                        color: const Color(0xFF212529),
                                        fontSize: 13,
                                        fontWeight: notif.isUnread ? FontWeight.w800 : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    notif.timeAgo,
                                    style: const TextStyle(color: Color(0xFF868E96), fontSize: 10.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.message,
                                style: const TextStyle(color: Color(0xFF495057), fontSize: 11.5, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, SalesNotificationItem notif, ErpProvider erp) {
    Navigator.of(context).pop(); // close sheet

    if (notif.leadId != null) {
      final lead = erp.allLeads.firstWhere((l) => l.id == notif.leadId, orElse: () => erp.allLeads.first);
      DealDetailSheet.show(context, lead);
    } else if (notif.meetingId != null) {
      final mtg = erp.allMeetings.firstWhere((m) => m.id == notif.meetingId, orElse: () => erp.allMeetings.first);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(mtg.title, style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time: ${mtg.startTime} - ${mtg.endTime}', style: const TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Location / Link: ${mtg.locationOrLink}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 8),
                Text('Agenda: ${mtg.agenda}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212529),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
}
