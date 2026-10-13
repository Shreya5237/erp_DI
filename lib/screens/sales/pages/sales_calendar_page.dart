import 'package:flutter/material.dart';
import '../../employee/pages/employee_calendar_page.dart';

/// Section 3 — Calendar facility for Sales
/// Unified with Technical Employee Portal Calendar UI:
/// - Every employee has their own calendar with Daily, Weekly, and Monthly segregation
/// - Displays sales calls, follow-ups, meetings, and deliverables in unified technical UI
class SalesCalendarPage extends StatefulWidget {
  const SalesCalendarPage({super.key});

  @override
  State<SalesCalendarPage> createState() => _SalesCalendarPageState();
}

class _SalesCalendarPageState extends State<SalesCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return const EmployeeCalendarPage(
      employeeId: 'EMP-112',
      showAppBar: false,
      allowEmployeeSwitching: true,
    );
  }
}
