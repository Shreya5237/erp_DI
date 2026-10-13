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
import 'package:digital_inertia_erp/screens/employee/pages/employee_tasks_page.dart';
import 'package:digital_inertia_erp/screens/employee/pages/employee_calendar_page.dart';

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

    testWidgets('EmployeeNavigationScreen renders all 5 bottom navigation tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const EmployeeNavigationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check BottomNavigationBar items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Check top branding and notification bell
      expect(find.text('Digital Inertia'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify no CEO or Sales crossover controls exist
      expect(find.byType(Drawer), findsNothing);
      expect(find.text('CEO / Administrator'), findsNothing);
    });

    testWidgets('EmployeeDashboardPage renders leave balance, meetings, and progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: EmployeeDashboardPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Leave Balance'), findsOneWidget);
      expect(find.textContaining('14 Days Available'), findsOneWidget);
      expect(find.text('Progress Overview'), findsOneWidget);
      expect(find.text("This Week's Tasks"), findsOneWidget);
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

      expect(find.text('In Progress (4)'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('EmployeeTasksPage renders daily work planner and filter tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(body: EmployeeTasksPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Work Planner'), findsOneWidget);
      expect(find.text('Add Task'), findsOneWidget);
      expect(find.textContaining('Today'), findsOneWidget);
      expect(find.textContaining('Tomorrow'), findsOneWidget);
    });

    testWidgets('EmployeeCalendarPage renders monthly grid and day agenda', (tester) async {
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
    });
  });
}

