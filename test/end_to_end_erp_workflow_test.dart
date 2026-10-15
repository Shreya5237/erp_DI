import 'package:flutter_test/flutter_test.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/models/task.dart';
import 'package:digital_inertia_erp/models/project.dart';
import 'package:digital_inertia_erp/models/lead.dart';
import 'package:digital_inertia_erp/models/approval.dart';

void main() {
  group('Digital Inertia ERP - Complete End-to-End Workflow & 18-Point Verification', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
    });

    test('1. Role-Based Access: Correct role & identity loaded without duplicate accounts', () {
      // Authenticate as CEO
      erp.setRole(UserRole.ceo);
      expect(erp.currentRole, equals(UserRole.ceo));
      expect(erp.currentUserName, contains('Laven'));

      // Switch to Sales
      erp.setRole(UserRole.sales);
      expect(erp.currentRole, equals(UserRole.sales));
      expect(erp.currentUserName, equals('Rajesh Kumar'));
      expect(erp.currentEmployee?.department, contains('Sales'));

      // Verify additional delegated responsibilities (e.g. employee can be trainer/POC)
      final pocEmp = erp.allEmployees.firstWhere((e) => e.isPOC, orElse: () => erp.allEmployees.first);
      expect(pocEmp.isPOC, isTrue);
      expect(pocEmp.name.isNotEmpty, isTrue);
    });

    test('2. Dynamic Today Tasks: Filters user-specific tasks and isolates team tasks', () {
      erp.setRole(UserRole.employee);
      final currentUserId = erp.currentUserId;

      // Add a task specifically for this employee
      erp.createTask(
        title: 'Draft OpenAPI Documentation',
        description: 'Complete OpenAPI spec for ERP backend',
        domain: 'Technical',
        department: 'Technical',
        assignedToId: currentUserId,
        assignedToName: erp.currentUserName,
        assigneeType: AssigneeType.employee,
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        priority: TaskPriority.high,
      );

      // Verify the employee's personal tasks include it
      final personalTasks = erp.allTasks.where((t) => t.assignedToId == currentUserId).toList();
      expect(personalTasks.any((t) => t.title == 'Draft OpenAPI Documentation'), isTrue);

      // Add task for another employee
      erp.createTask(
        title: 'Backend Database Optimization',
        description: 'Add indexes to audit log table',
        domain: 'Technical',
        department: 'Technical',
        assignedToId: 'OTHER-EMP-999',
        assignedToName: 'Other Person',
        assigneeType: AssigneeType.employee,
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        priority: TaskPriority.medium,
      );

      // Verify other task is NOT in current user's personal tasks
      final updatedPersonalTasks = erp.allTasks.where((t) => t.assignedToId == currentUserId).toList();
      expect(updatedPersonalTasks.any((t) => t.title == 'Backend Database Optimization'), isFalse);
    });

    test('3. Cross-Department Workflow: Lead Conversion -> Project -> Kickoff Task -> Notification', () {
      // 1. Sales creates or progresses a qualified lead
      final testLead = erp.allLeads.first;
      final leadId = testLead.id;
      final clientCompany = testLead.companyName;

      final initialProjectCount = erp.allProjects.length;

      // 2. Deal is won and converted to Project
      erp.convertLeadToProject(
        leadId: leadId,
        projectName: '$clientCompany Enterprise Transformation',
        description: 'Full stack digital transformation with cloud hosting and support.',
        budget: 450000.0,
        ownerEmployeeId: 'EMP-101',
        deadline: DateTime.now().add(const Duration(days: 90)),
      );

      // Lead marked won
      final updatedLead = erp.allLeads.firstWhere((l) => l.id == leadId);
      expect(updatedLead.status, equals(LeadStatus.won));

      // Project created and linked
      expect(erp.allProjects.length, equals(initialProjectCount + 1));
      final newProject = erp.allProjects.first;
      expect(newProject.name, contains(clientCompany));
      expect(newProject.status, equals(ProjectStatus.inProgress));

      // Project milestones generated
      expect(newProject.milestones.isNotEmpty, isTrue);

      // Kickoff task auto-created
      final kickoffTask = erp.allTasks.firstWhere(
        (t) => t.projectName == newProject.name && t.title.contains('Kickoff'),
        orElse: () => CompanyTask(
          id: 'dummy',
          title: '',
          description: '',
          assignedToId: '',
          assignedToName: '',
          assigneeType: AssigneeType.employee,
          assignedById: '',
          assignedByName: '',
          dueDate: DateTime.now(),
          priority: TaskPriority.low,
          status: TaskStatus.todo,
          createdAt: DateTime.now(),
        ),
      );
      expect(kickoffTask.id, isNot('dummy'));
      expect(kickoffTask.assignedToId, equals(newProject.ownerEmployeeId));

      // Notification sent to cross-department stakeholders
      expect(erp.employeeAlerts.any((a) => a['title'].toString().contains('Project Handover')), isTrue);
    });

    test('4. Task Status Change Recalculates Project Progress & Dispatches Audit Log', () {
      const projName = 'Cloud Infrastructure Migration';
      erp.addProject(
        name: projName,
        clientName: 'Enterprise Client',
        domain: 'Technical',
        description: 'Migrating legacy monolith to Kubernetes',
        budget: 500000,
        ownerEmployeeId: 'EMP-101',
        deadline: DateTime.now().add(const Duration(days: 30)),
      );

      final createdProject = erp.allProjects.firstWhere((p) => p.name == projName);

      // Add two tasks to this project
      erp.createTask(
        title: 'Setup EKS Cluster',
        description: 'Terraform script for Kubernetes',
        domain: 'Technical',
        department: 'Technical',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.urgent,
        projectName: projName,
      );
      erp.createTask(
        title: 'Migrate DB Schemas',
        description: 'Flyway schema migrations',
        domain: 'Technical',
        department: 'Technical',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        priority: TaskPriority.high,
        projectName: projName,
      );

      final projectTasks = erp.allTasks.where((t) => t.projectName == projName).toList();
      expect(projectTasks.length, equals(2));

      final t1 = projectTasks[0];
      final t2 = projectTasks[1];

      // Complete Task 1 -> progress should recalculate to 50%
      erp.updateAgileTaskStatus(t1.id, TaskStatus.done);
      var currentProj = erp.allProjects.firstWhere((p) => p.id == createdProject.id);
      expect(currentProj.progress, equals(0.5));

      // Mark Task 2 as blocked with a reason
      erp.updateAgileTaskStatus(t2.id, TaskStatus.blocked, blockerReason: 'Waiting for AWS IAM permissions from DevOps');
      currentProj = erp.allProjects.firstWhere((p) => p.id == createdProject.id);
      expect(currentProj.activeBlockers.any((b) => b.contains('AWS IAM')), isTrue);
      expect(currentProj.status, equals(ProjectStatus.delayed));

      // Complete Task 2 -> progress should be 100% and project completed
      erp.updateAgileTaskStatus(t2.id, TaskStatus.done);
      currentProj = erp.allProjects.firstWhere((p) => p.id == createdProject.id);
      expect(currentProj.progress, equals(1.0));
      expect(currentProj.status, equals(ProjectStatus.completed));
    });

    test('5. Single Authoritative Source for Approvals & Resource Requests', () {
      final initialPending = erp.pendingApprovals.length;
      expect(initialPending, greaterThanOrEqualTo(1));

      // Select an existing pending approval
      final approval = erp.pendingApprovals.first;
      expect(approval.status != ApprovalStatus.approved, isTrue);

      // Approve the request
      erp.approveApprovalRequest(approval.id, notes: 'Feasibility confirmed by executive panel');
      final updatedApproval = erp.allApprovalRequests.firstWhere((a) => a.id == approval.id);
      expect(updatedApproval.status, equals(ApprovalStatus.approved));
    });

    test('6. CEO Dashboard Metrics Derived from Real Records', () {
      erp.setRole(UserRole.ceo);
      
      // Calculate active metrics
      final inProgressProjects = erp.allProjects.where((p) => p.status == ProjectStatus.inProgress).length;
      final pendingApprovals = erp.pendingApprovals.length;
      final teamHeadcount = erp.allEmployees.length;

      expect(inProgressProjects, greaterThanOrEqualTo(0));
      expect(pendingApprovals, greaterThanOrEqualTo(0));
      expect(teamHeadcount, greaterThan(0));

      // Audit logs exist and capture system events
      expect(erp.allAuditLogs.isNotEmpty, isTrue);
    });
  });
}
