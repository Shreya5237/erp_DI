import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/models/task.dart';
import 'package:digital_inertia_erp/screens/employee/employee_navigation_screen.dart';
import 'package:digital_inertia_erp/screens/employee/pages/employee_dashboard_page.dart';
import 'package:digital_inertia_erp/screens/employee/pages/employee_profile_page.dart';
import 'package:digital_inertia_erp/screens/employee/pages/employee_projects_page.dart';
import 'package:digital_inertia_erp/screens/employee/pages/employee_calendar_page.dart';
import 'package:digital_inertia_erp/screens/employee/widgets/employee_task_detail_modal.dart';

void main() {
  group('Employee Companion Mobile App Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
      erp.setRole(UserRole.employee);
    });

    test('ErpProvider sets up Technical Employee session for Arjun Sharma', () {
      expect(erp.currentRole, equals(UserRole.employee));
      expect(erp.currentUserName, equals('Arjun Sharma'));
      expect(erp.currentUserId, equals('EMP-101'));
      expect(erp.currentEmployee, isNotNull);
      expect(erp.currentEmployee?.name, equals('Arjun Sharma'));
      expect(erp.currentEmployee?.leaveBalance, equals(14));
      expect(erp.currentEmployee?.employmentType, equals('Permanent Employee'));
    });

    test('Single source of truth: toggling task completion updates provider state', () {
      final initialTasks = erp.myEmployeeTasks;
      expect(initialTasks.isNotEmpty, isTrue);

      final task = initialTasks.firstWhere((t) => !t.isCompleted);
      final initialDone = task.isCompleted;

      erp.toggleTaskCompletion(task.id);
      final updatedTask = erp.allTasks.firstWhere((t) => t.id == task.id);
      expect(updatedTask.isCompleted, equals(!initialDone));

      // Toggle back
      erp.toggleTaskCompletion(task.id);
      final revertedTask = erp.allTasks.firstWhere((t) => t.id == task.id);
      expect(revertedTask.isCompleted, equals(initialDone));
    });

    test('Creating a personal task immediately reflects in employee tasks and calendar', () {
      final initialCount = erp.myEmployeeTasks.length;

      erp.addPersonalTask(
        title: 'Review pull request for auth refactor',
        description: 'Verify edge cases and unit test coverage.',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.high,
        projectName: 'Personal Work Planner',
      );

      expect(erp.myEmployeeTasks.length, equals(initialCount + 1));
      final created = erp.myEmployeeTasks.firstWhere((t) => t.title == 'Review pull request for auth refactor');
      expect(created.isPersonalTask, isTrue);
      expect(created.priority, equals(TaskPriority.high));
    });

    test('Self-service profile update only affects permitted fields', () {
      final employee = erp.currentEmployee!;
      erp.updateEmployeeProfile(
        employeeId: employee.id,
        phone: '+91 99999 11111',
        emergencyContact: '+91 88888 22222 (Brother)',
        bio: 'Updated bio testing permitted edit capability.',
      );

      final updated = erp.currentEmployee!;
      expect(updated.phone, equals('+91 99999 11111'));
      expect(updated.emergencyContact, equals('+91 88888 22222 (Brother)'));
      expect(updated.bio, equals('Updated bio testing permitted edit capability.'));
      // Company locked fields remain untouched
      expect(updated.id, equals(employee.id));
      expect(updated.role, equals(employee.role));
      expect(updated.department, equals(employee.department));
      expect(updated.reportingManager, equals(employee.reportingManager));
    });

    testWidgets('EmployeeNavigationScreen renders exactly 4 bottom navigation destinations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const EmployeeNavigationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check 4 BottomNavigationBar items (Home, Projects, Calendar, Profile)
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Calendar'), findsWidgets);
      expect(find.text('Profile'), findsOneWidget);

      // Check top branding and notification bell
      expect(find.text('DIGITAL INERTIA'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify no CEO or Sales crossover controls exist
      expect(find.byType(Drawer), findsNothing);
      expect(find.text('CEO / Administrator'), findsNothing);
    });

    testWidgets('EmployeeDashboardPage renders 6 black background overview metrics matching hand-drawn sketch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: EmployeeDashboardPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 6 sub widgets in black bg with white text:
      // 1. Date & Time
      expect(find.text('DATE & TIME'), findsOneWidget);
      // 2. Reporting Manager
      expect(find.text('REPORTING MGR'), findsOneWidget);
      expect(find.text('Rajesh Kumar'), findsOneWidget);
      // 3. Leave Balance
      expect(find.text('LEAVE BALANCE'), findsOneWidget);
      expect(find.textContaining('14 Days'), findsOneWidget);
      // 4. Active Projects
      expect(find.text('ACTIVE PROJECTS'), findsOneWidget);
      expect(find.textContaining('Projs'), findsWidgets);
      // 5. Upcoming Deadline
      expect(find.text('DEADLINE'), findsOneWidget);
      // 6. Target
      expect(find.text('TARGET'), findsOneWidget);
      expect(find.textContaining('% Met'), findsOneWidget);

      // Sections matching hand-drawn sketch
      expect(find.text('Todays tasks'), findsOneWidget);
      expect(find.text('Proj Assigned'), findsOneWidget);
      expect(find.text('Upcoming meeting'), findsOneWidget);
      expect(find.text('Join'), findsOneWidget);

      // Branding tagline
      expect(find.text('“COZ’ EVERYONE NEEDS A PUSH”'), findsOneWidget);
      expect(find.text('STRATEGIC CONSULTING'), findsOneWidget);
    });

    testWidgets('Tapping task opens slide-up EmployeeTaskDetailModal matching Image 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: EmployeeDashboardPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final todayTasks = erp.myEmployeeTasks.where((t) => !t.isCompleted).take(3).toList();
      final targetTask = todayTasks.isNotEmpty ? todayTasks.first : erp.myEmployeeTasks.first;
      final taskTitle = find.text(targetTask.title);
      expect(taskTitle, findsOneWidget);
      await tester.ensureVisible(taskTitle);
      await tester.tap(taskTitle);
      await tester.pumpAndSettle();

      // Modal is displayed with Image 2 components
      expect(find.byType(EmployeeTaskDetailModal), findsOneWidget);
      expect(find.text('Your responsibilities'), findsOneWidget);
      expect(find.text('PROJECT MANAGER'), findsOneWidget);
      expect(find.text('YOUR ROLE & TEAM'), findsOneWidget);
      expect(find.text('Submit / Complete Task'), findsOneWidget);
    });

    testWidgets('EmployeeProfilePage renders details, locked fields, and sign out', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: EmployeeProfilePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Arjun Sharma'), findsOneWidget);
      expect(find.text('Company & Reporting Details'), findsOneWidget);
      expect(find.text('Sign Out of Employee Portal'), findsOneWidget);
      expect(find.text('Edit Details'), findsOneWidget);
    });

    testWidgets('EmployeeProjectsPage renders assigned projects', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: EmployeeProjectsPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('In Progress'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('EmployeeCalendarPage renders monthly grid, tags bar and day agenda', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: EmployeeCalendarPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);

      // Tags filter bar
      expect(find.textContaining('All Events'), findsOneWidget);
      expect(find.textContaining('Tasks Breakdown'), findsOneWidget);
    });
  });
}
