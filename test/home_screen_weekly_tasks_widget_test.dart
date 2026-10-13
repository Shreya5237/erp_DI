import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/models/task.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/widgets/home_screen_weekly_tasks_widget.dart';
import 'package:digital_inertia_erp/services/native_home_widget_service.dart';
import 'package:digital_inertia_erp/screens/tasks/task_detail_dialog.dart';

void main() {
  group('HomeScreenWeeklyTasksWidget & Deadline Calculations Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
      erp.setRole(UserRole.employee);
    });

    test('Calendar date deadline calculations handle all categories correctly', () {
      final now = DateTime(2026, 10, 13, 14, 30); // Tuesday, Oct 13, 2026

      // 1. Task Due Today
      final taskToday = CompanyTask(
        id: 'T-TODAY',
        title: 'Complete Authentication Refactor',
        description: 'Verify token expiration handler',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-100',
        assignedByName: 'CEO',
        dueDate: DateTime(2026, 10, 13, 23, 59),
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        createdAt: DateTime(2026, 10, 10),
      );
      final infoToday = TaskDeadlineInfo.calculate(taskToday, now);
      expect(infoToday.category, equals(DeadlineCategory.dueToday));
      expect(infoToday.label, equals('Due Today'));

      // 2. Task Due Tomorrow
      final taskTomorrow = CompanyTask(
        id: 'T-TOMORROW',
        title: 'Review PR for Database Migration',
        description: 'Check foreign key indexes',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-100',
        assignedByName: 'CEO',
        dueDate: DateTime(2026, 10, 14, 18, 0),
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        createdAt: DateTime(2026, 10, 10),
      );
      final infoTomorrow = TaskDeadlineInfo.calculate(taskTomorrow, now);
      expect(infoTomorrow.category, equals(DeadlineCategory.dueTomorrow));
      expect(infoTomorrow.label, equals('Due Tomorrow'));
      expect(infoTomorrow.days, equals(1));

      // 3. Task Due Later This Week (e.g. Oct 16 -> 3 days remaining)
      final taskFuture = CompanyTask(
        id: 'T-FUTURE',
        title: 'Deploy to Staging Environment',
        description: 'Run automated smoke tests',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-100',
        assignedByName: 'CEO',
        dueDate: DateTime(2026, 10, 16, 12, 0),
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        createdAt: DateTime(2026, 10, 10),
      );
      final infoFuture = TaskDeadlineInfo.calculate(taskFuture, now);
      expect(infoFuture.category, equals(DeadlineCategory.upcoming));
      expect(infoFuture.label, equals('3 days remaining'));
      expect(infoFuture.days, equals(3));

      // 4. Overdue Task (e.g. Oct 11 -> Overdue by 2 days)
      final taskOverdue = CompanyTask(
        id: 'T-OVERDUE',
        title: 'Resolve Security Scan Finding',
        description: 'Patch vulnerable dependency',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-100',
        assignedByName: 'CEO',
        dueDate: DateTime(2026, 10, 11, 10, 0),
        priority: TaskPriority.urgent,
        status: TaskStatus.todo,
        createdAt: DateTime(2026, 10, 8),
      );
      final infoOverdue = TaskDeadlineInfo.calculate(taskOverdue, now);
      expect(infoOverdue.category, equals(DeadlineCategory.overdue));
      expect(infoOverdue.label, equals('Overdue by 2 days'));
      expect(infoOverdue.days, equals(2));

      // 5. Overdue by 1 day (Oct 12)
      final taskOverdue1 = CompanyTask(
        id: 'T-OVERDUE-1',
        title: 'Submit Weekly Report',
        description: 'Submit technical timesheets',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-100',
        assignedByName: 'CEO',
        dueDate: DateTime(2026, 10, 12, 17, 0),
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        createdAt: DateTime(2026, 10, 8),
      );
      final infoOverdue1 = TaskDeadlineInfo.calculate(taskOverdue1, now);
      expect(infoOverdue1.category, equals(DeadlineCategory.overdue));
      expect(infoOverdue1.label, equals('Overdue by 1 day'));
      expect(infoOverdue1.days, equals(1));

      // 6. Completed Task (deadline not presented as outstanding obligation)
      final taskCompleted = CompanyTask(
        id: 'T-DONE',
        title: 'Initial Database Seed',
        description: 'V1 migration completed',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-100',
        assignedByName: 'CEO',
        dueDate: DateTime(2026, 10, 11),
        priority: TaskPriority.low,
        status: TaskStatus.done,
        createdAt: DateTime(2026, 10, 5),
        completedAt: DateTime(2026, 10, 11),
      );
      final infoCompleted = TaskDeadlineInfo.calculate(taskCompleted, now);
      expect(infoCompleted.category, equals(DeadlineCategory.completed));
      expect(infoCompleted.label, equals('Completed'));
      expect(infoCompleted.days, equals(0));
    });

    test('Current week Monday to Sunday getters adhere to local calendar week', () {
      final monday = erp.currentWeekMonday;
      final sundayEnd = erp.currentWeekSundayEnd;

      expect(monday.weekday, equals(DateTime.monday));
      expect(monday.hour, equals(0));
      expect(monday.minute, equals(0));
      expect(monday.second, equals(0));

      expect(sundayEnd.weekday, equals(DateTime.sunday));
      expect(sundayEnd.hour, equals(23));
      expect(sundayEnd.minute, equals(59));
      expect(sundayEnd.second, equals(59));

      final diffDays = sundayEnd.difference(monday).inDays;
      expect(diffDays, equals(6));
    });

    test('ErpProvider weekly task metrics calculate totals and completion accurately', () {
      final total = erp.currentWeekTasksTotalCount;
      final completed = erp.currentWeekTasksCompletedCount;
      final rate = erp.currentWeekTaskCompletionRate;

      expect(total >= 0, isTrue);
      expect(completed >= 0, isTrue);
      expect(completed <= total, isTrue);
      expect(rate >= 0.0 && rate <= 100.0, isTrue);

      if (total > 0) {
        expect(rate, closeTo((completed / total) * 100.0, 0.01));
      } else {
        expect(rate, equals(100.0));
      }
    });

    test('currentWeekTasksPrioritized sorts Today and Tomorrow to the top', () {
      final prioritized = erp.currentWeekTasksPrioritized;

      if (prioritized.length >= 2) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        int lastCategoryRank = 0;
        for (final t in prioritized) {
          final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
          int rank;
          if (!t.isCompleted && tDate.isAtSameMomentAs(today)) {
            rank = 1;
          } else if (!t.isCompleted && tDate.isAtSameMomentAs(tomorrow)) {
            rank = 2;
          } else if (!t.isCompleted && tDate.isAfter(tomorrow)) {
            rank = 3;
          } else if (!t.isCompleted && tDate.isBefore(today)) {
            rank = 4;
          } else {
            rank = 5; // Completed
          }
          expect(rank >= lastCategoryRank, isTrue,
              reason: 'Task ${t.title} with rank $rank violates priority ordering after rank $lastCategoryRank');
          lastCategoryRank = rank;
        }
      }
    });

    test('NativeHomeWidgetService serializes weekly task payload properly', () async {
      final data = NativeHomeWidgetService.buildWeeklyWidgetData(erp);

      expect(data.weekRangeLabel.isNotEmpty, isTrue);
      expect(data.totalWeeklyTasks, equals(erp.currentWeekTasksTotalCount));
      expect(data.completedTasks, equals(erp.currentWeekTasksCompletedCount));
      expect(data.completionPercentage, equals(erp.currentWeekTaskCompletionRate));

      final jsonMap = data.toJson();
      expect(jsonMap['weekRangeLabel'], isNotNull);
      expect(jsonMap['tasks'], isA<List>());

      final jsonStr = data.toJsonString();
      expect(jsonStr.contains('weekRangeLabel'), isTrue);

      final syncResult = await NativeHomeWidgetService.syncToNativeWidgets(erp);
      expect(syncResult, isTrue);
    });

    testWidgets('HomeScreenWeeklyTasksWidget renders summary, filter tabs, and progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: erp,
            child: const Scaffold(
              body: SingleChildScrollView(
                child: HomeScreenWeeklyTasksWidget(
                  title: "This Week's Tasks",
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Header and Progress Bar
      expect(find.text("This Week's Tasks"), findsOneWidget);
      expect(find.text('WEEKLY PROGRESS'), findsOneWidget);
      expect(find.textContaining('completed'), findsWidgets);

      // Check Filter Tabs
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Today & Tomorrow'), findsOneWidget);
      expect(find.text('Overdue'), findsWidgets);
      expect(find.text('Completed'), findsOneWidget);

      // Check Action Buttons
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('Toggling task completion updates status in provider and widget', (tester) async {
      final tasks = erp.currentWeekTasksPrioritized;
      expect(tasks.isNotEmpty, isTrue);

      final testTask = tasks.first;
      final initialDone = testTask.isCompleted;

      await tester.pumpWidget(
        ChangeNotifierProvider<ErpProvider>.value(
          value: erp,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeScreenWeeklyTasksWidget(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the circular checkbox for the first task
      final checkboxFinder = find.byKey(ValueKey('task-checkbox-${testTask.id}'));
      expect(checkboxFinder, findsOneWidget);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      final updated = erp.allTasks.firstWhere((t) => t.id == testTask.id);
      expect(updated.isCompleted, equals(!initialDone));

      // Toggle back to restore initial state
      erp.toggleTaskCompletion(testTask.id);
      expect(erp.allTasks.firstWhere((t) => t.id == testTask.id).isCompleted, equals(initialDone));
    });

    testWidgets('Tapping task opens TaskDetailDialog', (tester) async {
      final tasks = erp.currentWeekTasksPrioritized;
      expect(tasks.isNotEmpty, isTrue);

      await tester.pumpWidget(
        ChangeNotifierProvider<ErpProvider>.value(
          value: erp,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeScreenWeeklyTasksWidget(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap task card
      final taskCardFinder = find.byKey(ValueKey('task-card-${tasks.first.id}'));
      expect(taskCardFinder, findsOneWidget);

      await tester.tap(taskCardFinder);
      await tester.pumpAndSettle();

      // Verify TaskDetailDialog opened
      expect(find.byType(TaskDetailDialog), findsOneWidget);
      expect(find.text(tasks.first.title), findsWidgets);
    });

    testWidgets('Empty state renders gracefully when no tasks are found', (tester) async {
      // Clear tasks in a fresh provider instance
      final emptyErp = ErpProvider();
      emptyErp.switchToDemoMode();
      emptyErp.setRole(UserRole.employee);
      // Remove all tasks from provider
      for (final t in List<CompanyTask>.from(emptyErp.allTasks)) {
        emptyErp.deleteTask(t.id);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ErpProvider>.value(
            value: emptyErp,
            child: const Scaffold(
              body: SingleChildScrollView(
                child: HomeScreenWeeklyTasksWidget(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Tasks Scheduled for This Week'), findsOneWidget);
      expect(find.textContaining('You are all caught up for Monday through Sunday'), findsOneWidget);
    });
  });
}
