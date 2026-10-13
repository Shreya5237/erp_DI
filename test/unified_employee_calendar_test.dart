import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/screens/employee/pages/employee_calendar_page.dart';
import 'package:digital_inertia_erp/screens/employees/employee_detail_dialog.dart';

void main() {
  group('Unified Multi-Department Employee Calendar Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
    });

    Widget createTestApp(Widget child) {
      return MaterialApp(
        home: ChangeNotifierProvider<ErpProvider>.value(
          value: erp,
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('EmployeeCalendarPage renders Daily, Weekly, and Monthly views with 3-way toggle', (tester) async {
      erp.setRole(UserRole.employee);
      await tester.pumpWidget(createTestApp(const EmployeeCalendarPage()));
      await tester.pumpAndSettle();

      // Verify header and 3-way segregation toggle buttons exist
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Switch'), findsOneWidget);

      // Default is Month view: shows weekday headers
      expect(find.text('M'), findsOneWidget);

      // Switch to Day (Daily) view
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();

      // Verify Daily view hourly agenda timeline renders
      expect(find.text('HOURLY AGENDA TIMELINE'), findsOneWidget);
      expect(find.text('08:00 AM'), findsOneWidget);
      expect(find.text('12:00 PM'), findsOneWidget);
      expect(find.text('08:00 PM'), findsOneWidget);

      // Switch to Week (Weekly) view
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();

      // Verify Weekly view 7-day strip renders
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
    });

    testWidgets('Every department employee has their own individual calendar and tasks', (tester) async {
      // 1. Technical Employee Calendar
      final techEmp = erp.allEmployees.firstWhere((e) => e.department == 'Technical');
      final techTasks = erp.tasksForEmployee(techEmp.id, techEmp.name);
      expect(techTasks.isNotEmpty, isTrue);

      // 2. Sales Employee Calendar (Rajesh Kumar)
      final salesEmp = erp.allEmployees.firstWhere((e) => e.id == 'EMP-112');
      final salesTasks = erp.tasksForEmployee(salesEmp.id, salesEmp.name);
      final salesCalls = erp.callsForEmployee(salesEmp.id, salesEmp.name);
      expect(salesTasks.isNotEmpty, isTrue);
      expect(salesCalls.isNotEmpty, isTrue);

      // 3. Finance Employee Calendar (Siddharth Roy)
      final finEmp = erp.allEmployees.firstWhere((e) => e.id == 'EMP-115');
      final finTasks = erp.tasksForEmployee(finEmp.id, finEmp.name);
      final finMeetings = erp.meetingsForEmployee(finEmp.name, finEmp.department);
      expect(finTasks.isNotEmpty, isTrue);
      expect(finMeetings.isNotEmpty, isTrue);

      // 4. HR Employee Calendar (Meera Joshi)
      final hrEmp = erp.allEmployees.firstWhere((e) => e.id == 'EMP-111');
      final hrTasks = erp.tasksForEmployee(hrEmp.id, hrEmp.name);
      expect(hrTasks.isNotEmpty, isTrue);

      // 5. Marketing Employee Calendar (Sanjay Menon)
      final mktEmp = erp.allEmployees.firstWhere((e) => e.id == 'EMP-113');
      final mktTasks = erp.tasksForEmployee(mktEmp.id, mktEmp.name);
      expect(mktTasks.isNotEmpty, isTrue);
    });

    testWidgets('Employee calendar renders specified employee and department badge', (tester) async {
      final salesEmp = erp.allEmployees.firstWhere((e) => e.id == 'EMP-112');

      await tester.pumpWidget(
        createTestApp(EmployeeCalendarPage(employee: salesEmp)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rajesh Kumar'), findsOneWidget);
      expect(find.text('Sales'), findsWidgets);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
    });

    testWidgets('Tapping Switch opens Employee Picker Sheet with all 5 departments', (tester) async {
      await tester.pumpWidget(createTestApp(const EmployeeCalendarPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Switch'));
      await tester.pumpAndSettle();

      // Verify modal sheet opened
      expect(find.text('Select Employee Calendar'), findsOneWidget);
      expect(find.text('Technical'), findsWidgets);
      expect(find.text('Sales'), findsWidgets);
      expect(find.text('Finance'), findsWidgets);
      expect(find.text('HR'), findsWidgets);
      expect(find.text('Marketing'), findsWidgets);

      // Filter by Marketing department chip
      await tester.tap(find.widgetWithText(InkWell, 'Marketing'));
      await tester.pumpAndSettle();

      // Tap on Sanjay Menon (Marketing)
      await tester.tap(find.text('Sanjay Menon'));
      await tester.pumpAndSettle();

      // Calendar now reflects Sanjay Menon
      expect(find.text('Sanjay Menon'), findsOneWidget);
      expect(find.text('Marketing'), findsWidgets);
    });

    testWidgets('EmployeeDetailDialog provides direct 1-tap View Calendar button', (tester) async {
      final emp = erp.allEmployees.firstWhere((e) => e.name == 'Arjun Sharma');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: Scaffold(
              body: EmployeeDetailDialog(employee: emp),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("View Arjun Sharma's Calendar"), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });
  });
}
