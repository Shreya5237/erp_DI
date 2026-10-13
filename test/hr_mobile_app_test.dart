import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/models/hr_models.dart';
import 'package:digital_inertia_erp/models/intern.dart';
import 'package:digital_inertia_erp/models/task.dart';
import 'package:digital_inertia_erp/screens/hr/hr_navigation_screen.dart';
import 'package:digital_inertia_erp/screens/hr/pages/hr_dashboard_page.dart';
import 'package:digital_inertia_erp/screens/hr/pages/hr_leave_management_page.dart';
import 'package:digital_inertia_erp/screens/hr/pages/hr_staffing_requests_page.dart';
import 'package:digital_inertia_erp/screens/hr/pages/hr_onboarding_trainees_page.dart';
import 'package:digital_inertia_erp/screens/hr/pages/hr_pipeline_coordination_page.dart';
import 'package:digital_inertia_erp/screens/hr/pages/hr_tasks_calendar_page.dart';
import 'package:digital_inertia_erp/screens/hr/pages/hr_profile_page.dart';
import 'package:digital_inertia_erp/screens/hr/widgets/hr_notifications_sheet.dart';

void main() {
  group('HR Mobile App State & Provider Unit Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
      erp.setRole(UserRole.hr);
    });

    test('ErpProvider initializes authenticated HR Lead session for Meera Joshi (EMP-111)', () {
      expect(erp.currentRole, equals(UserRole.hr));
      expect(erp.currentUserName, equals('Meera Joshi'));
      expect(erp.currentUserId, equals('EMP-111'));
      expect(erp.currentUserEmail, equals('meera.joshi@digitalinertia.com'));
    });

    test('Initial Leave Requests are correctly loaded with pending, approved, and overlapping absence flags', () {
      expect(erp.allLeaveRequests.length, greaterThanOrEqualTo(5));
      expect(erp.pendingLeaveRequests.length, greaterThanOrEqualTo(2));

      final pendingWithOverlap = erp.pendingLeaveRequests.firstWhere((l) => l.hasOverlappingTeamAbsence);
      expect(pendingWithOverlap.overlappingEmployeeNames, isNotEmpty);
      expect(pendingWithOverlap.leaveType, equals(LeaveType.annual));
    });

    test('approveLeaveRequest updates status and deducts leave from central employee record', () {
      final req = erp.pendingLeaveRequests.first;
      final empBefore = erp.allEmployees.firstWhere((e) => e.id == req.employeeId);
      final initialBalance = empBefore.leaveBalance;

      erp.approveLeaveRequest(req.id, comments: 'Approved by HR Lead Meera Joshi');

      final reqAfter = erp.allLeaveRequests.firstWhere((l) => l.id == req.id);
      expect(reqAfter.status, equals(LeaveRequestStatus.approved));
      expect(reqAfter.hrComments, contains('Approved'));

      final empAfter = erp.allEmployees.firstWhere((e) => e.id == req.employeeId);
      expect(empAfter.leaveBalance, equals((initialBalance - req.daysCount).clamp(0, 50)));
    });

    test('rejectLeaveRequest records mandatory rejection reason', () {
      final req = erp.pendingLeaveRequests.last;
      erp.rejectLeaveRequest(req.id, reason: 'Sprint release deployment overlap');

      final reqAfter = erp.allLeaveRequests.firstWhere((l) => l.id == req.id);
      expect(reqAfter.status, equals(LeaveRequestStatus.rejected));
      expect(reqAfter.hrComments, equals('Sprint release deployment overlap'));
    });

    test('Staffing Requests tracking and fulfillment assign suitable employees', () {
      expect(erp.allStaffingRequests.length, greaterThanOrEqualTo(3));
      final pendingStaffing = erp.pendingStaffingRequests.first;

      erp.assignStaffingEmployees(
        pendingStaffing.id,
        employeeIds: ['EMP-003', 'EMP-004'],
        employeeNames: ['Vikram Patel', 'Ananya Roy'],
        notes: 'Senior Flutter and QA engineers assigned.',
      );

      final fulfilled = erp.allStaffingRequests.firstWhere((s) => s.id == pendingStaffing.id);
      expect(fulfilled.status, equals(StaffingRequestStatus.fulfilled));
      expect(fulfilled.assignedEmployeeNames, contains('Vikram Patel'));
      expect(fulfilled.assignedEmployeeNames, contains('Ananya Roy'));
    });

    test('Trainee mentorship and rubric evaluation updates', () {
      final intern = erp.allInterns.first;
      erp.assignTraineeMentor(intern.id, mentorId: 'EMP-002', mentorName: 'Arjun Sharma');

      final updatedIntern = erp.allInterns.firstWhere((i) => i.id == intern.id);
      expect(updatedIntern.assignedPocName, equals('Arjun Sharma'));

      const newRubric = InternEvaluationRubric(
        taskQuality: 4.5,
        consistency: 4.8,
        interest: 5.0,
        learningProgress: 4.6,
        communication: 4.2,
      );
      erp.updateTraineeEvaluation(
        intern.id,
        rubric: newRubric,
        feedback: 'Excellent grasp of Flutter state management.',
        status: InternStatus.goodPerformance,
      );

      final evalIntern = erp.allInterns.firstWhere((i) => i.id == intern.id);
      expect(evalIntern.evaluationRubric.averageScore, greaterThan(4.5));
      expect(evalIntern.latestFeedback, contains('Flutter state management'));
      expect(evalIntern.missedUpdatesDays, equals(0));
    });

    test('Customer Change Requests tracking and forwarding to Project Manager', () {
      expect(erp.allCustomerChangeRequests.length, greaterThanOrEqualTo(3));

      erp.addCustomerChangeRequest(
        leadId: 'LED-504',
        clientName: 'Sanjay Patel',
        companyName: 'SolarEase Energy Corp',
        projectName: 'Solar IoT Monitoring',
        feedbackType: 'Change Request',
        description: 'Customer requests addition of dynamic push notifications for battery faults.',
        forwardedToRole: 'Project Manager',
        followUpDate: DateTime.now().add(const Duration(days: 3)),
      );

      final newReq = erp.allCustomerChangeRequests.first;
      expect(newReq.clientName, equals('Sanjay Patel'));
      expect(newReq.forwardedToRole, equals('Project Manager'));

      erp.forwardCustomerChangeRequest(
        newReq.id,
        forwardedToRole: 'Tech Lead',
        notes: 'Tech architecture review required for IoT payload.',
      );

      final forwarded = erp.allCustomerChangeRequests.firstWhere((c) => c.id == newReq.id);
      expect(forwarded.forwardedToRole, equals('Tech Lead'));
      expect(forwarded.status, equals(CustomerRequestStatus.inReview));
    });

    test('Monthly HR Targets are configurable and correctly updated', () {
      const customTargets = HrMonthlyTargets(
        leaveRequestsTarget: 25,
        staffingRequestsTarget: 12,
        traineeReviewsTarget: 15,
        customerFollowUpsTarget: 20,
      );

      erp.updateHrMonthlyTargets(customTargets);
      expect(erp.hrMonthlyTargets.leaveRequestsTarget, equals(25));
      expect(erp.hrMonthlyTargets.staffingRequestsTarget, equals(12));
      expect(erp.hrMonthlyTargets.traineeReviewsTarget, equals(15));
      expect(erp.hrMonthlyTargets.customerFollowUpsTarget, equals(20));
    });

    test('HR Personal Tasks creation and completion toggling', () {
      erp.addHrPersonalTask(
        title: 'Conduct weekly intern sprint review',
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        description: 'Sync with technical POCs on weekly evaluation rubric.',
      );

      final newTask = erp.hrTasks.firstWhere((t) => t.title == 'Conduct weekly intern sprint review');
      expect(newTask.status, equals(TaskStatus.todo));

      erp.toggleHrTask(newTask.id);
      final toggled = erp.hrTasks.firstWhere((t) => t.id == newTask.id);
      expect(toggled.status, equals(TaskStatus.done));
    });
  });

  group('HR Mobile App Widget & Screen Rendering Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
      erp.setRole(UserRole.hr);
    });

    Widget createTestApp(Widget child) {
      return ChangeNotifierProvider<ErpProvider>.value(
        value: erp,
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('HrNavigationScreen renders 5 bottom nav tabs and top bar actions', (tester) async {
      await tester.pumpWidget(createTestApp(const HrNavigationScreen()));
      await tester.pumpAndSettle();

      // Top bar branding
      expect(find.text('DI HR'), findsOneWidget);
      expect(find.text('People & Talent Operations'), findsOneWidget);

      // Bottom nav items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('People'), findsOneWidget);
      expect(find.text('Trainees'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Top bar icons
      expect(find.byIcon(Icons.beach_access_rounded), findsWidgets);
      expect(find.byIcon(Icons.handshake_rounded), findsWidgets);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('Bottom navigation tabs switch screens properly', (tester) async {
      await tester.pumpWidget(createTestApp(const HrNavigationScreen()));
      await tester.pumpAndSettle();

      // Tap People tab
      await tester.tap(find.text('People'));
      await tester.pumpAndSettle();
      expect(find.text('Team Staffing & Resource Requests'), findsOneWidget);

      // Tap Trainees tab
      await tester.tap(find.text('Trainees'));
      await tester.pumpAndSettle();
      expect(find.text('Onboarding & Trainees'), findsOneWidget);

      // Tap Calendar tab
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Tasks & Calendar'), findsOneWidget);

      // Tap Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Personal Profile'), findsOneWidget);
    });

    testWidgets('HrDashboardPage displays pending approvals, targets, and deadlines', (tester) async {
      await tester.pumpWidget(createTestApp(const HrDashboardPage()));
      await tester.pumpAndSettle();

      expect(find.text('Meera Joshi'), findsOneWidget);
      expect(find.text('HR Monthly Targets & KPI'), findsOneWidget);
      expect(find.text('Monthly Target Overview'), findsOneWidget);
      expect(find.text('Next Important Deadline'), findsOneWidget);
      expect(find.text('2 days'), findsOneWidget);
    });

    testWidgets('HrLeaveManagementPage displays employee requests and own leave balance', (tester) async {
      await tester.pumpWidget(createTestApp(const HrLeaveManagementPage()));
      await tester.pumpAndSettle();

      expect(find.text('Leave Management'), findsOneWidget);
      expect(find.text('My Leave Balance (Meera Joshi)'), findsOneWidget);
      expect(find.text('18 Days Total'), findsOneWidget);
      expect(find.text('Pending (3)'), findsOneWidget);
    });

    testWidgets('HrStaffingRequestsPage displays department requests and allocation banner', (tester) async {
      await tester.pumpWidget(createTestApp(const HrStaffingRequestsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Team Staffing & Resource Requests'), findsOneWidget);
      expect(find.textContaining('HR handles employee allocation'), findsOneWidget);
      expect(find.text('Pending (2)'), findsOneWidget);
    });

    testWidgets('HrOnboardingTraineesPage displays trainee stats and tabs', (tester) async {
      await tester.pumpWidget(createTestApp(const HrOnboardingTraineesPage()));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding & Trainees'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Review Due'), findsWidgets);
      expect(find.text('Flagged'), findsWidgets);
    });

    testWidgets('HrPipelineCoordinationPage displays finalized deals and change requests', (tester) async {
      await tester.pumpWidget(createTestApp(const HrPipelineCoordinationPage()));
      await tester.pumpAndSettle();

      expect(find.text('Pipeline & Project Coordination'), findsOneWidget);
      expect(find.textContaining('Once a deal is finalized, HR coordinates people'), findsOneWidget);
      expect(find.textContaining('Deals & Staffing'), findsOneWidget);
      expect(find.textContaining('Customer Changes'), findsOneWidget);
    });

    testWidgets('HrTasksCalendarPage displays tasks, checklist, and tab switching', (tester) async {
      await tester.pumpWidget(createTestApp(const HrTasksCalendarPage()));
      await tester.pumpAndSettle();

      expect(find.text('Tasks & Calendar'), findsOneWidget);
      expect(find.textContaining('Tasks ('), findsOneWidget);
      expect(find.textContaining('Calendar ('), findsOneWidget);
    });

    testWidgets('HrProfilePage displays Meera Joshi details and leave days', (tester) async {
      await tester.pumpWidget(createTestApp(const HrProfilePage()));
      await tester.pumpAndSettle();

      expect(find.text('Personal Profile'), findsOneWidget);
      expect(find.text('Meera Joshi'), findsOneWidget);
      expect(find.text('Head of HR & People Operations'), findsWidgets);
      expect(find.text('Own Leave Balance'), findsOneWidget);
      expect(find.text('18 Days Remaining'), findsOneWidget);
      expect(find.text('Sign Out / Switch Role'), findsOneWidget);
    });

    testWidgets('HrNotificationsSheet shows all 10 notification triggers', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestApp(
          Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => HrNotificationsSheet.show(ctx),
                child: const Text('Open Alerts'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Alerts'));
      await tester.pumpAndSettle();

      expect(find.text('HR Alerts & Notifications'), findsOneWidget);
      expect(find.textContaining('Leave Approval'), findsWidgets);
      expect(find.textContaining('Staffing Request'), findsWidgets);
      expect(find.textContaining('Project Staffing'), findsWidgets);
      expect(find.textContaining('Training Reminder'), findsWidgets);
      expect(find.textContaining('Monthly Target'), findsWidgets);
    });
  });
}
