import 'package:flutter/material.dart';
import '../employee/pages/employee_dashboard_page.dart';

/// Technical Employee Role Dashboard View
/// Completely replaced by the unified Technical Employee Role Dashboard Implementation
class TechnicalDashboardView extends StatelessWidget {
  final VoidCallback? onOpenWidget;

  const TechnicalDashboardView({super.key, this.onOpenWidget});

  @override
  Widget build(BuildContext context) {
    return const EmployeeDashboardPage();
  }
}
