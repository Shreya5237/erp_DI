import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/models/sales_call.dart';
import 'package:digital_inertia_erp/models/lead.dart';
import 'package:digital_inertia_erp/screens/sales/sales_navigation_screen.dart';
import 'package:digital_inertia_erp/screens/sales/pages/sales_dashboard_page.dart';
import 'package:digital_inertia_erp/screens/sales/pages/sales_cold_calls_page.dart';
import 'package:digital_inertia_erp/screens/sales/pages/sales_deals_pipeline_page.dart';
import 'package:digital_inertia_erp/screens/sales/pages/sales_follow_ups_page.dart';
import 'package:digital_inertia_erp/screens/sales/pages/sales_performance_page.dart';
import 'package:digital_inertia_erp/screens/sales/pages/sales_profile_page.dart';
import 'package:digital_inertia_erp/screens/sales/pages/sales_calendar_page.dart';
import 'package:digital_inertia_erp/screens/sales/widgets/sales_notifications_sheet.dart';

void main() {
  group('Sales Mobile App State & Provider Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
      erp.setRole(UserRole.sales);
    });

    test('ErpProvider sets up Sales Associate session for Rajesh Kumar (EMP-112)', () {
      expect(erp.currentRole, equals(UserRole.sales));
      expect(erp.currentUserName, equals('Rajesh Kumar'));
      expect(erp.currentUserId, equals('EMP-112'));
      expect(erp.currentUserEmail, equals('rajesh.kumar@digitalinertia.com'));
    });

    test('Initial Sales metrics, daily targets, and monthly performance adhere to spec', () {
      expect(erp.dailyColdCallTarget, equals(20));
      expect(erp.callsCompletedTodayCount, equals(16));
      expect(erp.pendingColdCallsTodayCount, equals(4));
      expect(erp.monthlySalesTarget, equals(5000000.0));
      expect(erp.monthlySalesAchieved, equals(3850000.0));
      expect(erp.monthlySalesRemaining, equals(1150000.0));
      expect(erp.monthlySalesAchievedRatio, closeTo(0.77, 0.01));
      expect(erp.weeklyCallTotals, equals([38, 52, 45, 42]));
      expect(erp.highestPerformingWeek, equals(2));
      expect(erp.highestPerformingWeekCalls, equals(52));
      expect(erp.monthlyCallsTotal, equals(177));
      expect(erp.dealsClosedCount, equals(8));
      expect(erp.callConversionRate, closeTo(4.5, 0.1));
      expect(erp.followUpCompletionRate, equals(0.92));
    });

    test('Follow-up detection correctly classifies overdue and today calls', () {
      expect(erp.followUpsDueToday.isNotEmpty, isTrue);
      expect(erp.overdueFollowUps.isNotEmpty, isTrue);
      for (final call in erp.overdueFollowUps) {
        expect(call.isFollowUpOverdue, isTrue);
        expect(call.daysOverdue, greaterThanOrEqualTo(1));
      }
    });

    test('Logging a cold call increments completed calls and adds to sales calls list', () {
      final initialCount = erp.allSalesCalls.length;
      final initialToday = erp.callsCompletedTodayCount;

      erp.logColdCall(
        customerName: 'Ashok Leyland Rep',
        companyName: 'Leyland EV Division',
        phone: '+91 98330 11992',
        outcome: CallOutcome.interested,
        notes: 'Discussed high-voltage telemetry sensor gateway.',
        dealValue: 750000.0,
        priority: 'High',
      );

      expect(erp.allSalesCalls.length, equals(initialCount + 1));
      expect(erp.callsCompletedTodayCount, equals(initialToday + 1));

      final logged = erp.allSalesCalls.first;
      expect(logged.customerName, equals('Ashok Leyland Rep'));
      expect(logged.outcome, equals(CallOutcome.interested));
      expect(logged.isCompleted, isTrue);
      expect(logged.isToday, isTrue);
    });

    test('Updating call outcome and rescheduling follow-up reflects in state', () {
      final call = erp.allSalesCalls.first;
      final newDate = DateTime.now().add(const Duration(days: 3));

      erp.updateCallOutcome(call.id, CallOutcome.notInterested, notes: 'Budget frozen for Q3');
      erp.rescheduleFollowUp(call.id, newDate);

      final updated = erp.allSalesCalls.firstWhere((c) => c.id == call.id);
      expect(updated.outcome, equals(CallOutcome.notInterested));
      expect(updated.notes, contains('Budget frozen for Q3'));
      expect(updated.nextFollowUpDate?.day, equals(newDate.day));
    });

    test('Marking follow-up as completed flags the call', () {
      final call = erp.overdueFollowUps.first;
      erp.markFollowUpCompleted(call.id);

      final updated = erp.allSalesCalls.firstWhere((c) => c.id == call.id);
      expect(updated.isCompleted, isTrue);
      expect(updated.notes, contains('Follow-up Completed'));
    });

    test('Forwarding a lead to Manager updates internal approval stage and history', () {
      final lead = erp.allLeads.firstWhere((l) => l.id == 'LED-503');
      erp.forwardLeadToManager(lead.id, comments: 'Commercial discount approval needed');

      final updatedLead = erp.allLeads.firstWhere((l) => l.id == 'LED-503');
      expect(updatedLead.internalApprovalStage, equals('Pending Manager Review'));
      expect(updatedLead.approvalHistory.isNotEmpty, isTrue);
      expect(updatedLead.approvalHistory.first.action, equals('Submitted to Manager'));
      expect(updatedLead.approvalHistory.first.comments, contains('discount approval'));
    });

    test('Forwarding a lead to HR & Finance triggers dual feasibility review', () {
      final lead = erp.allLeads.firstWhere((l) => l.id == 'LED-504');
      erp.forwardLeadToHrFinance(lead.id, comments: 'Need 120h backend capacity validation');

      final updatedLead = erp.allLeads.firstWhere((l) => l.id == 'LED-504');
      expect(updatedLead.status, equals(LeadStatus.feasibilityAssessment));
      expect(updatedLead.internalApprovalStage, equals('Forwarded to HR & Finance'));
      expect(updatedLead.hrFeasibility.status, equals(FeasibilityStatus.inReview));
      expect(updatedLead.financeFeasibility.status, equals(FeasibilityStatus.inReview));
      expect(updatedLead.approvalHistory.first.action, equals('Forwarded to HR & Finance'));
    });
  });

  group('Sales Mobile App Widget Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
      erp.setRole(UserRole.sales);
    });

    testWidgets('SalesNavigationScreen renders all 5 bottom navigation tabs and top branding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const SalesNavigationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check 5 Bottom Navigation items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calls'), findsOneWidget);
      expect(find.text('Deals'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Check Top branding
      expect(find.text('DI Sales'), findsOneWidget);
      expect(find.text('Growth & Outreach Portal'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // Tap 'Calls' tab (index 1)
      await tester.tap(find.text('Calls'));
      await tester.pumpAndSettle();
      expect(find.text('Log Call'), findsWidgets);

      // Tap 'Deals' tab (index 2)
      await tester.tap(find.text('Deals'));
      await tester.pumpAndSettle();
      expect(find.text('Active Pipeline'), findsOneWidget);

      // Tap 'Calendar' tab (index 3)
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);

      // Tap 'Profile' tab (index 4)
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Rajesh Kumar'), findsOneWidget);
    });

    testWidgets('SalesDashboardPage renders leave balance, call target, and urgent section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: SalesDashboardPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sales Overview'), findsOneWidget);
      expect(find.text('Leave Balance'), findsOneWidget);
      expect(find.text('20 Days'), findsOneWidget);
      expect(find.text('Daily Call Target'), findsOneWidget);
      expect(find.text('Monthly Target vs Achieved'), findsOneWidget);
      expect(find.text('Weekly Performance'), findsOneWidget);
      expect(find.text('Follow-ups & Schedule'), findsOneWidget);
      expect(find.text('Performance & Targets'), findsOneWidget);
    });

    testWidgets('SalesColdCallsPage renders target tracker, tabs, and outcome chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: SalesColdCallsPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Call Target'), findsOneWidget);
      expect(find.text("Today's Calls"), findsWidgets);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('All Calls'), findsOneWidget);
      expect(find.text('Log Call'), findsOneWidget);
    });

    testWidgets('SalesDealsPipelinePage renders pipeline stages and active value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: SalesDealsPipelinePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Pipeline'), findsOneWidget);
      expect(find.text('Forwarded / Review'), findsOneWidget);
      expect(find.text('Closed (Won)'), findsOneWidget);
      expect(find.text('All Deals'), findsOneWidget);
      expect(find.text('1. New Lead'), findsOneWidget);
    });

    testWidgets('SalesFollowUpsPage renders overdue alert and meeting agenda', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: SalesFollowUpsPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Follow-ups & Schedule'), findsOneWidget);
      expect(find.text('Overdue Follow-ups (Immediate Action)'), findsOneWidget);
      expect(find.text('Due Today'), findsOneWidget);
    });

    testWidgets('SalesPerformancePage renders monthly target, weekly chart, and SLA', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: SalesPerformancePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Performance & Targets'), findsOneWidget);
      expect(find.text('Monthly Sales Target'), findsOneWidget);
      expect(find.text('Daily Cold Calls Target'), findsOneWidget);
      expect(find.text('Weekly Call Comparison'), findsOneWidget);
    });

    testWidgets('SalesProfilePage renders Rajesh Kumar info, locked fields, and leave balance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: SalesProfilePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rajesh Kumar'), findsOneWidget);
      expect(find.text('Senior Sales & BD Associate'), findsWidgets);
      expect(find.text('Available Leave Balance'), findsOneWidget);
      expect(find.text('20 Days Total'), findsOneWidget);
      expect(find.text('Employment Details (Company Managed)'), findsOneWidget);
    });

    testWidgets('SalesCalendarPage renders month, week, day view toggles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: SalesCalendarPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('SalesNotificationsSheet renders sales alerts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: SalesNotificationsSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sales Alerts & Notifications'), findsOneWidget);
      expect(find.text('Daily Call Target Alert'), findsOneWidget);
      expect(find.text('Urgent Follow-up Due'), findsOneWidget);
      expect(find.text('Upcoming Meeting in 15 Minutes'), findsOneWidget);
      expect(find.text('Manager Response Received'), findsOneWidget);
      expect(find.text('HR & Finance Feasibility Cleared'), findsOneWidget);
    });
  });
}
