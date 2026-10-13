import 'package:flutter_test/flutter_test.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';

void main() {
  group('ERP Provider Filter & Project Tests', () {
    test('Role filtering matches employee roles without empty results', () {
      final erp = ErpProvider();

      // Test "Frontend" role chip filter
      erp.setEmployeeRoleFilter('Frontend');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);
      expect(erp.filteredEmployees.any((e) => e.name == 'Arjun Sharma'), isTrue);
      expect(erp.filteredEmployees.every((e) => e.role.toLowerCase().contains('frontend')), isTrue);

      // Test "Backend" role chip filter
      erp.setEmployeeRoleFilter('Backend');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);
      expect(erp.filteredEmployees.any((e) => e.name == 'Priya Nair'), isTrue);

      // Test "Mobile App" role chip filter
      erp.setEmployeeRoleFilter('Mobile App');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);
      expect(erp.filteredEmployees.any((e) => e.name == 'Rohan Mehta'), isTrue);

      // Test "AI / ML" role chip filter
      erp.setEmployeeRoleFilter('AI / ML');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);
      expect(erp.filteredEmployees.any((e) => e.name == 'Ananya Deshmukh'), isTrue);

      // Test "HR / Recruitment" role chip filter
      erp.setEmployeeRoleFilter('HR / Recruitment');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);
      expect(erp.filteredEmployees.any((e) => e.role.contains('HR')), isTrue);

      // Clear role filter
      erp.setEmployeeRoleFilter(null);
      expect(erp.filteredEmployees.length, equals(erp.allEmployees.length));
    });

    test('Searching for roles in employee search query filters correctly', () {
      final erp = ErpProvider();

      erp.setEmployeeSearchQuery('Frontend');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);
      expect(erp.filteredEmployees.any((e) => e.name == 'Arjun Sharma'), isTrue);

      erp.setEmployeeSearchQuery('Backend');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);
      expect(erp.filteredEmployees.any((e) => e.name == 'Priya Nair'), isTrue);

      erp.setEmployeeSearchQuery('');
      expect(erp.filteredEmployees.length, equals(erp.allEmployees.length));
    });

    test('Module search queries are isolated and do not wipe out other screens', () {
      final erp = ErpProvider();

      // Search for employee name in employee module
      erp.setEmployeeSearchQuery('Arjun');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);

      // Tasks, projects, interns should NOT be filtered by employee search query!
      expect(erp.filteredTasks.isNotEmpty, isTrue);
      expect(erp.filteredProjects.isNotEmpty, isTrue);
      expect(erp.filteredInterns.isNotEmpty, isTrue);
      expect(erp.filteredLeads.isNotEmpty, isTrue);
    });

    test('Project creation and team reassignment works as expected', () {
      final erp = ErpProvider();

      final lead = erp.allEmployees.first;
      final members = [lead.name, 'Sneha V', 'Aarav Gupta (Intern)'];

      erp.addProject(
        name: 'Autonomous Drone Fleet Platform',
        clientName: 'AeroDynamics Global',
        domain: 'AI / ML',
        description: 'Edge drone telemetry platform',
        budget: 75000.0,
        ownerEmployeeId: lead.id,
        deadline: DateTime.now().add(const Duration(days: 45)),
        teamMemberNames: members,
      );

      final created = erp.allProjects.firstWhere((p) => p.name == 'Autonomous Drone Fleet Platform');
      expect(created.ownerEmployeeId, equals(lead.id));
      expect(created.ownerEmployeeName, equals(lead.name));
      expect(created.teamMemberNames, contains('Sneha V'));
      expect(created.teamMemberNames, contains('Aarav Gupta (Intern)'));

      // Now alter / edit / reassign team later
      final newLead = erp.allEmployees.firstWhere((e) => e.name == 'Rohan Mehta');
      final newMembers = [newLead.name, 'Karthik R', 'Bhavya Shah (Intern)'];

      erp.updateProjectTeam(
        projectId: created.id,
        ownerEmployeeId: newLead.id,
        teamMemberNames: newMembers,
      );

      final updated = erp.allProjects.firstWhere((p) => p.id == created.id);
      expect(updated.ownerEmployeeId, equals(newLead.id));
      expect(updated.ownerEmployeeName, equals(newLead.name));
      expect(updated.teamMemberNames, contains('Karthik R'));
      expect(updated.teamMemberNames, contains('Bhavya Shah (Intern)'));
    });

    test('Employee department filter works properly and groups hierarchically', () {
      final erp = ErpProvider();

      expect(erp.availableEmployeeDepartments.isNotEmpty, isTrue);
      expect(erp.availableEmployeeDepartments, contains('All Departments'));
      expect(erp.availableEmployeeDepartments, contains('Technical'));

      // Filter by Technical
      erp.setEmployeeDepartmentFilter('Technical');
      expect(erp.filteredEmployees.isNotEmpty, isTrue);
      expect(erp.filteredEmployees.every((e) => e.department.toLowerCase().contains('technical')), isTrue);

      // Hierarchical grouping: Department leads and POCs are first
      final hierarchical = erp.employeesByDepartmentHierarchical;
      expect(hierarchical.containsKey('Technical'), isTrue);
      final engTeam = hierarchical['Technical']!;
      expect(engTeam.isNotEmpty, isTrue);

      // Reset department filter
      erp.setEmployeeDepartmentFilter(null);
      expect(erp.filteredEmployees.length, equals(erp.allEmployees.length));
    });

    test('Task department grouping and default Ongoing & Overdue status works properly', () {
      final erp = ErpProvider();

      // By default, task status filter is 'Ongoing & Overdue'
      expect(erp.taskStatusFilter, equals('Ongoing & Overdue'));
      for (final task in erp.filteredTasks) {
        expect(task.isOngoing || task.isOverdue, isTrue);
      }

      // Tasks by department grouping
      final tasksByDept = erp.tasksByDepartment;
      expect(tasksByDept.isNotEmpty, isTrue);
      for (final entry in tasksByDept.entries) {
        expect(entry.value.isNotEmpty, isTrue);
        expect(entry.value.every((t) => t.effectiveDepartment == entry.key), isTrue);
      }

      // Filter tasks by specific status
      erp.setTaskStatusFilter('Upcoming');
      for (final task in erp.filteredTasks) {
        expect(task.isUpcoming, isTrue);
      }

      erp.setTaskStatusFilter('Completed');
      for (final task in erp.filteredTasks) {
        expect(task.isCompleted, isTrue);
      }

      // Task department filter
      erp.setTaskDepartmentFilter('Engineering');
      for (final task in erp.filteredTasks) {
        expect(task.effectiveDepartment.toLowerCase().contains('engineering'), isTrue);
      }

      // Reset
      erp.resetFilters();
      expect(erp.taskStatusFilter, equals('Ongoing & Overdue'));
      expect(erp.taskDepartmentFilter, isNull);
    });

    test('Lead and Project domain filtering works properly', () {
      final erp = ErpProvider();

      // Lead domain filter
      expect(erp.availableLeadDomains, contains('All Domains'));
      erp.setLeadDomainFilter('IT Consulting');
      for (final lead in erp.filteredLeads) {
        expect(lead.domain.toLowerCase().contains('it consulting'), isTrue);
      }

      // Project domain filter
      expect(erp.availableProjectDomains, contains('All Domains'));
      erp.setProjectDomainFilter('Mobile App');
      for (final project in erp.filteredProjects) {
        expect(project.domain.toLowerCase().contains('mobile app'), isTrue);
      }

      // Reset
      erp.resetFilters();
      expect(erp.leadDomainFilter, isNull);
      expect(erp.projectDomainFilter, isNull);
    });
  });
}
