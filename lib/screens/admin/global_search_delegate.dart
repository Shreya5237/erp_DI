import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/erp_provider.dart';
import '../tasks/task_detail_dialog.dart';
import '../interns/intern_detail_dialog.dart';
import '../leads/lead_detail_dialog.dart';
import '../projects/project_detail_dialog.dart';
import '../employees/employee_detail_dialog.dart';

/// Global Search across all ERP records
class GlobalSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Search interns, tasks, leads, team...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final erp = Provider.of<ErpProvider>(context, listen: false);
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return const Center(
        child: Text(
          'Type to search across employees, interns, tasks, leads, and projects.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    final matchedInterns = erp.allInterns.where((i) =>
        i.name.toLowerCase().contains(q) ||
        i.domain.toLowerCase().contains(q) ||
        i.college.toLowerCase().contains(q)).toList();

    final matchedTasks = erp.allTasks.where((t) =>
        t.title.toLowerCase().contains(q) ||
        t.description.toLowerCase().contains(q) ||
        t.assignedToName.toLowerCase().contains(q)).toList();

    final matchedLeads = erp.allLeads.where((l) =>
        l.companyName.toLowerCase().contains(q) ||
        l.clientName.toLowerCase().contains(q)).toList();

    final matchedProjects = erp.allProjects.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.clientName.toLowerCase().contains(q)).toList();

    final matchedEmployees = erp.allEmployees.where((e) =>
        e.name.toLowerCase().contains(q) ||
        e.role.toLowerCase().contains(q)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (matchedInterns.isNotEmpty) ...[
          _buildHeader('Interns (${matchedInterns.length})'),
          ...matchedInterns.map((i) => ListTile(
                leading: const Icon(Icons.school_outlined, color: AppColors.electricBlue),
                title: Text(i.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${i.domain} • ${i.college} • Batch: ${i.batchName}'),
                onTap: () {
                  close(context, null);
                  showDialog(context: context, builder: (ctx) => InternDetailDialog(intern: i));
                },
              )),
          const SizedBox(height: 12),
        ],

        if (matchedTasks.isNotEmpty) ...[
          _buildHeader('Tasks (${matchedTasks.length})'),
          ...matchedTasks.map((t) => ListTile(
                leading: const Icon(Icons.task_alt, color: AppColors.statusCompleted),
                title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Assigned: ${t.assignedToName} • Status: ${t.status.label}'),
                onTap: () {
                  close(context, null);
                  showDialog(context: context, builder: (ctx) => TaskDetailDialog(task: t));
                },
              )),
          const SizedBox(height: 12),
        ],

        if (matchedLeads.isNotEmpty) ...[
          _buildHeader('CRM Leads (${matchedLeads.length})'),
          ...matchedLeads.map((l) => ListTile(
                leading: const Icon(Icons.trending_up, color: AppColors.statusInProgress),
                title: Text(l.companyName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Contact: ${l.clientName} • Value: \$${l.dealValue.toInt()}'),
                onTap: () {
                  close(context, null);
                  showDialog(context: context, builder: (ctx) => LeadDetailDialog(lead: l));
                },
              )),
          const SizedBox(height: 12),
        ],

        if (matchedProjects.isNotEmpty) ...[
          _buildHeader('Projects (${matchedProjects.length})'),
          ...matchedProjects.map((p) => ListTile(
                leading: const Icon(Icons.layers_outlined, color: Color(0xFF0D9488)),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Client: ${p.clientName} • ${(p.progress * 100).toInt()}% Done'),
                onTap: () {
                  close(context, null);
                  showDialog(context: context, builder: (ctx) => ProjectDetailDialog(project: p));
                },
              )),
          const SizedBox(height: 12),
        ],

        if (matchedEmployees.isNotEmpty) ...[
          _buildHeader('Employees (${matchedEmployees.length})'),
          ...matchedEmployees.map((e) => ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.primaryDark),
                title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${e.role} • ${e.department}'),
                onTap: () {
                  close(context, null);
                  showDialog(context: context, builder: (ctx) => EmployeeDetailDialog(employee: e));
                },
              )),
        ],
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
      ),
    );
  }
}
