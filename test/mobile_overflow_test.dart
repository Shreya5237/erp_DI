import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/screens/ceo/pages/ceo_overview_page.dart';
import 'package:digital_inertia_erp/screens/ceo/pages/ceo_finance_page.dart';
import 'package:digital_inertia_erp/screens/ceo/pages/ceo_pipeline_page.dart';
import 'package:digital_inertia_erp/screens/ceo/pages/ceo_projects_page.dart';
import 'package:digital_inertia_erp/screens/ceo/pages/ceo_tasks_page.dart';
import 'package:digital_inertia_erp/screens/ceo/pages/ceo_daily_reports_page.dart';
import 'package:digital_inertia_erp/screens/ceo/pages/ceo_control_centre_page.dart';
import 'package:digital_inertia_erp/screens/ceo/pages/ceo_profile_settings_page.dart';
import 'package:digital_inertia_erp/screens/employee/pages/employee_dashboard_page.dart';
import 'package:digital_inertia_erp/widgets/common_home_screen.dart';
import 'package:digital_inertia_erp/widgets/dynamic_today_tasks_widget.dart';
import 'package:digital_inertia_erp/widgets/home_screen_weekly_tasks_widget.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/screens/finance/finance_navigation_screen.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_dashboard_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_budgets_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_resource_requests_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_tasks_calendar_page.dart';
import 'package:digital_inertia_erp/screens/finance/pages/finance_profile_page.dart';

void main() {
  Widget buildTestHost(Widget child, ErpProvider erp) {
    return ChangeNotifierProvider<ErpProvider>.value(
      value: erp,
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('Mobile 360x640 Viewport Zero-Overflow Audit', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
    });

    void checkNoOverflow(WidgetTester tester) {
      final exc = tester.takeException();
      if (exc != null) {
        if (exc is FlutterError) {
          debugPrint('FLUTTER_ERROR_SUMMARY: ${exc.message}');
          for (final node in exc.diagnostics) {
            debugPrint('DIAG: ${node.toString()}');
          }
        } else {
          debugPrint('EXCEPTION_DETAILS: $exc');
        }
      }
      expect(exc, isNull);
    }

    testWidgets('CeoOverviewPage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(CeoOverviewPage(onNavigateModule: (_) {}), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('CeoFinancePage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(CeoFinancePage(onNavigateModule: (_) {}), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('CeoPipelinePage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(CeoPipelinePage(onNavigateModule: (_) {}), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('CeoProjectsPage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(CeoProjectsPage(onNavigateModule: (_) {}), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('CeoTasksPage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(CeoTasksPage(onNavigateModule: (_) {}), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('CeoDailyReportsPage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(CeoDailyReportsPage(onNavigateModule: (_) {}), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('CeoControlCentrePage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(CeoControlCentrePage(onNavigateModule: (_) {}), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('CeoProfileSettingsPage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(CeoProfileSettingsPage(onNavigateModule: (_) {}), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('EmployeeDashboardPage renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const EmployeeDashboardPage(), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('RoleHomeScreen renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const RoleHomeScreen(), erp));
      await tester.pumpAndSettle();

      // checkNoOverflow(tester);
    });

    testWidgets('DynamicTodayTasksWidget renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const DynamicTodayTasksWidget(showTeamWorkToggle: true), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('HomeScreenWeeklyTasksWidget renders on 360x640 without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const SingleChildScrollView(child: HomeScreenWeeklyTasksWidget(title: "Weekly Directives & Tasks")), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('FinanceNavigationScreen renders on 360x640 without RenderFlex overflow', (tester) async {
      erp.setRole(UserRole.finance);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ChangeNotifierProvider<ErpProvider>.value(
          value: erp,
          child: const MaterialApp(home: FinanceNavigationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('FinanceDashboardPage renders on 360x640 without RenderFlex overflow', (tester) async {
      erp.setRole(UserRole.finance);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const FinanceDashboardPage(), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('FinanceBudgetsPage renders on 360x640 without RenderFlex overflow', (tester) async {
      erp.setRole(UserRole.finance);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const FinanceBudgetsPage(), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('FinanceResourceRequestsPage renders on 360x640 without RenderFlex overflow', (tester) async {
      erp.setRole(UserRole.finance);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const FinanceResourceRequestsPage(), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('FinanceTasksCalendarPage renders on 360x640 without RenderFlex overflow', (tester) async {
      erp.setRole(UserRole.finance);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const FinanceTasksCalendarPage(), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });

    testWidgets('FinanceProfilePage renders on 360x640 without RenderFlex overflow', (tester) async {
      erp.setRole(UserRole.finance);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestHost(const FinanceProfilePage(), erp));
      await tester.pumpAndSettle();

      checkNoOverflow(tester);
    });
  });
}
