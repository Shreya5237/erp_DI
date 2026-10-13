import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/models/finance_models.dart';
import 'package:digital_inertia_erp/models/lead.dart';
import 'package:digital_inertia_erp/models/task.dart';
import 'package:digital_inertia_erp/screens/finance/finance_navigation_screen.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_dashboard_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_budgets_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_resource_requests_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_leads_pipeline_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_tasks_calendar_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_profile_page.dart';
import 'package:digital_inertia_erp/screens/finance/widgets/finance_notifications_sheet.dart';
import 'package:digital_inertia_erp/screens/finance/widgets/adjust_budget_dialog.dart';
import 'package:digital_inertia_erp/screens/finance/widgets/finance_lead_review_sheet.dart';

void main() {
  group('Finance Mobile App State & Provider Unit Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
      erp.setRole(UserRole.finance);
    });

    test('ErpProvider initializes authenticated Finance Lead session for Siddharth Roy (EMP-115)', () {
      expect(erp.currentRole, equals(UserRole.finance));
      expect(erp.currentUserName, equals('Siddharth Roy'));
      expect(erp.currentUserId, equals('EMP-115'));
      expect(erp.currentUserEmail, equals('siddharth.roy@digitalinertia.com'));
    });

    test('Initial Project Budgets metrics correctly track allocated, spent, and overbudget limits', () {
      expect(erp.allProjectBudgets.length, equals(6));
      expect(erp.totalAllocatedBudget, greaterThan(400000.0));
      expect(erp.totalSpentBudget, greaterThan(300000.0));
      expect(erp.totalRemainingBudget, equals(erp.totalAllocatedBudget - erp.totalSpentBudget));
      expect(erp.overallBudgetUtilization, greaterThan(0.7));

      // Overbudget verification (PRJ-304 FinTech Payment Gateway spent 128500 vs 120000)
      final overbudget = erp.overbudgetProjects;
      expect(overbudget.length, equals(1));
      expect(overbudget.first.projectId, equals('PRJ-304'));
      expect(overbudget.first.isExceeded, isTrue);

      // Threshold alert verification (PRJ-306 DI ERP Core spent 65000 vs 75000 = 86.7%)
      final threshold = erp.thresholdAlertProjects;
      expect(threshold.length, equals(1));
      expect(threshold.first.projectId, equals('PRJ-306'));
      expect(threshold.first.isApproachingLimit, isTrue);
    });

    test('Department Resource Requests are tracked with pending, approved, and rejected states', () {
      expect(erp.allResourceRequests.length, equals(6));
      expect(erp.pendingResourceRequests.length, equals(2)); // REQ-201 and REQ-202
      expect(erp.approvedResourceRequests.length, equals(1)); // REQ-203
      expect(erp.rejectedResourceRequests.length, equals(1)); // REQ-204

      final pendingReq = erp.pendingResourceRequests.first;
      expect(pendingReq.requestedResource, contains('AWS GPU Cluster'));
      expect(pendingReq.requestingDepartment, equals('Technology and Engineering'));
    });

    test('approveResourceRequest updates status, sets allocated budget, and reflects in project allocations', () {
      final reqId = 'REQ-201';
      erp.approveResourceRequest(
        reqId,
        comments: 'Approved for Quantra BioSciences inference sprints.',
        allocatedBudget: 185000.0,
      );

      final updated = erp.allResourceRequests.firstWhere((r) => r.id == reqId);
      expect(updated.status, equals(ResourceRequestStatus.approved));
      expect(updated.allocatedBudget, equals(185000.0));
      expect(updated.reviewedBy, equals('Siddharth Roy'));
      expect(updated.financeComments, contains('Quantra BioSciences'));

      // Check linked project PRJ-303 has new allocation
      final projectBudget = erp.allProjectBudgets.firstWhere((b) => b.projectId == 'PRJ-303');
      expect(projectBudget.allocations.any((a) => a.description.contains('AWS GPU Cluster')), isTrue);
    });

    test('rejectResourceRequest updates status to rejected with audit rationale', () {
      final reqId = 'REQ-202';
      erp.rejectResourceRequest(reqId, reason: 'Out of scope for Q3 budget.');

      final updated = erp.allResourceRequests.firstWhere((r) => r.id == reqId);
      expect(updated.status, equals(ResourceRequestStatus.rejected));
      expect(updated.financeComments, equals('Out of scope for Q3 budget.'));
      expect(updated.reviewedBy, equals('Siddharth Roy'));
    });

    test('requestResourceClarification updates status to clarificationRequested', () {
      final reqId = 'REQ-201';
      erp.requestResourceClarification(reqId, questions: 'Is this spot instance or on-demand?');

      final updated = erp.allResourceRequests.firstWhere((r) => r.id == reqId);
      expect(updated.status, equals(ResourceRequestStatus.clarificationRequested));
      expect(updated.financeComments, equals('Is this spot instance or on-demand?'));
    });

    test('adjustProjectBudget adjusts approved budget, adds history record, and syncs shared ERP projects', () {
      final prjId = 'PRJ-301';
      final initialBudget = erp.allProjectBudgets.firstWhere((b) => b.projectId == prjId).approvedBudget;

      erp.adjustProjectBudget(
        prjId,
        adjustmentAmount: 15000.0,
        reason: 'CEO approved scope extension for solar IoT telemetry',
      );

      final updatedBudget = erp.allProjectBudgets.firstWhere((b) => b.projectId == prjId);
      expect(updatedBudget.approvedBudget, equals(initialBudget + 15000.0));
      expect(updatedBudget.adjustmentHistory.first.reason, contains('CEO approved scope extension'));
      expect(updatedBudget.adjustmentHistory.first.approvedBy, equals('Siddharth Roy'));

      // Also verify shared ERP _projects collection is synchronized
      final sharedProject = erp.allProjects.firstWhere((p) => p.id == prjId);
      expect(sharedProject.budget, equals(initialBudget + 15000.0));
    });

    test('Finance deal feasibility updates and commercial approvals', () {
      final leadsToReview = erp.financeReviewLeads;
      expect(leadsToReview.isNotEmpty, isTrue);

      final leadId = leadsToReview.first.id;

      // Update feasibility
      erp.updateFinanceFeasibilityReview(
        leadId,
        status: FeasibilityStatus.inReview,
        estimatedCost: 180000.0,
        quotedPrice: 300000.0,
        expectedMarginPercent: 40.0,
        paymentTerms: '40% Advance, 60% Delivery',
        budgetFeasibilityNotes: 'Good profit margin alignment',
      );

      var updatedLead = erp.allLeads.firstWhere((l) => l.id == leadId);
      expect(updatedLead.financeFeasibility.estimatedCost, equals(180000.0));
      expect(updatedLead.financeFeasibility.expectedMarginPercent, equals(40.0));
      expect(updatedLead.financeFeasibility.status, equals(FeasibilityStatus.inReview));

      // Approve deal financials
      erp.approveDealFinancials(leadId, comments: 'Signoff complete');
      updatedLead = erp.allLeads.firstWhere((l) => l.id == leadId);
      expect(updatedLead.financeFeasibility.status, equals(FeasibilityStatus.completed));
      expect(updatedLead.internalApprovalStage, contains('Finance Approved'));

      // Reject / return deal
      erp.rejectDealFinancials(leadId, reason: 'Insufficient margin for custom backend');
      updatedLead = erp.allLeads.firstWhere((l) => l.id == leadId);
      expect(updatedLead.financeFeasibility.status, equals(FeasibilityStatus.changesRequested));
      expect(updatedLead.internalApprovalStage, contains('Returned by Finance'));
    });

    test('Finance tasks and personal task creation', () {
      expect(erp.financeTasks.isNotEmpty, isTrue);
      final initialCount = erp.financeTasks.length;
      final task = erp.financeTasks.first;

      // Toggle status
      final wasCompleted = task.isCompleted;
      erp.toggleFinanceTask(task.id);
      final toggled = erp.allTasks.firstWhere((t) => t.id == task.id);
      expect(toggled.isCompleted, equals(!wasCompleted));

      // Add personal task
      erp.addFinancePersonalTask(
        title: 'Review Q4 Vendor Invoices',
        priority: TaskPriority.urgent,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        description: 'Verify GST credits and TDS compliance',
      );

      expect(erp.financeTasks.length, equals(initialCount + 1));
      expect(erp.financeTasks.first.title, equals('Review Q4 Vendor Invoices'));
      expect(erp.financeTasks.first.assignedToId, equals('EMP-115'));
    });
  });

  group('Finance Mobile App Widget & UI Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
      erp.setRole(UserRole.finance);
    });

    Widget createTestApp(Widget child) {
      return ChangeNotifierProvider<ErpProvider>.value(
        value: erp,
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('FinanceNavigationScreen renders 5 bottom nav items and top bar brand', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceNavigationScreen()));
      await tester.pumpAndSettle();

      // Top bar brand
      expect(find.text('DI Finance'), findsOneWidget);
      expect(find.text('Financial Operations & Budgets'), findsOneWidget);

      // Bottom Navigation items (5 main items)
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Budgets'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Top Bar shortcuts (Leads Pipeline and Notification Bell)
      expect(find.byIcon(Icons.trending_up_rounded), findsWidgets);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('Tapping bottom nav items switches tabs to Budgets, Requests, Calendar, Profile', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceNavigationScreen()));
      await tester.pumpAndSettle();

      // Tap 'Budgets' tab
      await tester.tap(find.text('Budgets'));
      await tester.pumpAndSettle();
      expect(find.byType(FinanceBudgetsPage), findsOneWidget);
      expect(find.text('Finance Project Budgets'), findsOneWidget);

      // Tap 'Requests' tab
      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();
      expect(find.byType(FinanceResourceRequestsPage), findsOneWidget);
      expect(find.text('Department Resource Requests'), findsOneWidget);

      // Tap 'Calendar' tab
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(FinanceTasksCalendarPage), findsOneWidget);
      expect(find.text('Finance Tasks & Schedule'), findsOneWidget);

      // Tap 'Profile' tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(FinanceProfilePage), findsOneWidget);
      expect(find.text('Available Leave Balance'), findsOneWidget);
    });

    testWidgets('Tapping notification bell opens FinanceNotificationsSheet modal with 9 alert types', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceNavigationScreen()));
      await tester.pumpAndSettle();

      // Tap notification bell
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(FinanceNotificationsSheet), findsOneWidget);
      expect(find.text('Finance Alerts & Notifications'), findsOneWidget);
      expect(find.text('Critical: Budget Exceeded'), findsOneWidget);
      expect(find.text('Threshold Warning: 86.7% Utilized'), findsOneWidget);
    });

    testWidgets('FinanceDashboardPage prioritizes urgent approvals and overbudget alerts at top', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceDashboardPage()));
      await tester.pumpAndSettle();

      // Urgent priority alerts at the top
      expect(find.text('Action Required: Urgent Approvals & Alerts'), findsOneWidget);
      expect(find.text('Budget Exceeded: FinTech Payment Gateway'), findsOneWidget);
      expect(find.text('Threshold Warning: Digital Inertia ERP Core'), findsOneWidget);

      // Synchronized Leave Balance
      expect(find.text('18 Days'), findsOneWidget);
      expect(find.text('Leave Balance (HR Synced)'), findsOneWidget);

      // Financial Overview
      expect(find.text('Project Budgets Health'), findsOneWidget);
      expect(find.text('Resource Requests Status'), findsOneWidget);
      expect(find.text("Today's Tasks & Deadlines"), findsOneWidget);
    });

    testWidgets('FinanceBudgetsPage displays project budgets and opens AdjustBudgetDialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceBudgetsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Finance Project Budgets'), findsOneWidget);
      expect(find.text('EcoTrack App'), findsOneWidget);
      expect(find.text('FinTech Payment Gateway'), findsOneWidget);

      // Find first 'Adjust Budget' button and tap
      final adjustButtons = find.widgetWithText(ElevatedButton, 'Adjust Budget');
      expect(adjustButtons, findsWidgets);
      await tester.tap(adjustButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(AdjustBudgetDialog), findsOneWidget);
      expect(find.text('Adjust Project Budget'), findsOneWidget);
      expect(find.text('Adjustment Direction'), findsOneWidget);
    });

    testWidgets('FinanceResourceRequestsPage renders department requests and allows review', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceResourceRequestsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Department Resource Requests'), findsOneWidget);
      expect(find.text('Access Shared Leads Pipeline for Deal Feasibility'), findsOneWidget);
      expect(find.text('AWS GPU Cluster (p4d.24xlarge)'), findsOneWidget);

      // Verify workflow action buttons exist
      expect(find.text('Approve & Allocate'), findsWidgets);
      expect(find.text('Reject'), findsWidgets);
      expect(find.text('Clarify'), findsWidgets);
    });

    testWidgets('FinanceLeadsPipelinePage allows commercial feasibility review via FinanceLeadReviewSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceLeadsPipelinePage()));
      await tester.pumpAndSettle();

      expect(find.text('Shared Leads Pipeline'), findsOneWidget);

      // Review deal button
      final reviewButtons = find.widgetWithText(ElevatedButton, 'Review & Sign Off Financials');
      expect(reviewButtons, findsWidgets);
      await tester.tap(reviewButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(FinanceLeadReviewSheet), findsOneWidget);
      expect(find.text('Deal Financial Feasibility Review'), findsOneWidget);
      expect(find.text('Estimated Cost (₹)'), findsOneWidget);
      expect(find.text('Quoted Price (₹)'), findsOneWidget);
      expect(find.text('Approve Financials'), findsOneWidget);
    });

    testWidgets('FinanceTasksCalendarPage toggles between Tasks and Calendar Day/Week/Month view', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceTasksCalendarPage()));
      await tester.pumpAndSettle();

      expect(find.text('Finance Tasks & Schedule'), findsOneWidget);
      expect(find.text('Pending Tasks'), findsOneWidget);

      // Switch to Calendar View
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Meetings & Reviews'), findsOneWidget);
    });

    testWidgets('FinanceProfilePage renders locked company details and central leave balance', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const FinanceProfilePage()));
      await tester.pumpAndSettle();

      expect(find.text('Siddharth Roy'), findsOneWidget);
      expect(find.text('Available Leave Balance'), findsOneWidget);
      expect(find.text('18 Days'), findsOneWidget);
      expect(find.text('Synced with Central HR'), findsOneWidget);
      expect(find.text('Annual / Earned'), findsOneWidget);
      expect(find.text('Sick Leave'), findsOneWidget);
      expect(find.text('Casual Leave'), findsOneWidget);
      expect(find.text('Sign Out of Finance Portal'), findsOneWidget);
    });
  });
}
