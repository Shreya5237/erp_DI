import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_role.dart';
import '../models/hierarchy.dart';
import '../models/employee.dart';
import '../models/intern.dart';
import '../models/task.dart';
import '../models/lead.dart';
import '../models/project.dart';
import '../models/audit_log.dart';

/// Central State Provider for Digital Inertia CEO ERP
/// Implements configurable roles hierarchy, dynamic threshold alerts,
/// and comprehensive filtering across People, Projects, Tasks, and Leads.
class ErpProvider extends ChangeNotifier {
  // Current user session
  UserRole _currentRole = UserRole.ceo;
  String _currentUserName = 'Laven Lokesh';
  String _currentUserEmail = 'laven@digitalinertia.com';
  String _currentUserId = 'EMP-001';

  // Configurable Roles
  List<CompanyRole> _roles = [];

  // Configurable Alert Thresholds
  AlertThresholds _thresholds = AlertThresholds();

  // Core Data Collections
  List<Employee> _employees = [];
  List<Intern> _interns = [];
  List<InternBatch> _batches = [];
  List<CompanyTask> _tasks = [];
  List<Lead> _leads = [];
  List<Project> _projects = [];
  List<AuditLog> _auditLogs = [];

  // Filter States
  String _searchQuery = '';
  String _employeeSearchQuery = '';
  String _internSearchQuery = '';
  String _taskSearchQuery = '';
  String _leadSearchQuery = '';
  String _projectSearchQuery = '';

  RoleCategory? _employeeCategoryFilter; // null = All
  String? _employeeRoleFilter; // null = All
  String? _employeeTeamFilter;
  bool? _employeeActiveFilter;

  RoleCategory? _internCategoryFilter; // null = All
  String? _internDomainFilter;
  String? _internBatchFilter;
  String? _internMentorFilter;
  String _internTaskScope = 'All Tasks'; // 'My Tasks', 'Team Tasks', 'All Tasks'

  String _taskScopeFilter = 'All'; // 'All', 'My Tasks', 'Projects • Domain'
  String _taskStatusFilter = 'All';

  String _leadStageFilter = 'All'; // 'All', 'New', 'Contacted', 'Proposal', 'Qualified', 'Won'
  String _projectStatusFilter = 'All'; // 'All', 'Planning', 'In Progress', 'On Hold', 'Completed'

  ErpProvider() {
    _initRoles();
    _initSeedData();
  }

  // Getters
  UserRole get currentRole => _currentRole;
  String get currentUserName => _currentUserName;
  String get currentUserEmail => _currentUserEmail;
  String get currentUserId => _currentUserId;
  AlertThresholds get thresholds => _thresholds;

  List<CompanyRole> get allRoles => List.unmodifiable(_roles);
  List<CompanyRole> get technicalRoles =>
      _roles.where((r) => r.category == RoleCategory.technical).toList();
  List<CompanyRole> get nonTechnicalRoles =>
      _roles.where((r) => r.category == RoleCategory.nonTechnical).toList();

  List<Employee> get allEmployees => List.unmodifiable(_employees);
  List<Intern> get allInterns => List.unmodifiable(_interns);
  List<InternBatch> get allBatches => List.unmodifiable(_batches);
  List<CompanyTask> get allTasks => List.unmodifiable(_tasks);
  List<Lead> get allLeads => List.unmodifiable(_leads);
  List<Project> get allProjects => List.unmodifiable(_projects);
  List<AuditLog> get allAuditLogs => List.unmodifiable(_auditLogs);

  // Active filter getters
  String get searchQuery => _searchQuery;
  String get employeeSearchQuery => _employeeSearchQuery;
  String get internSearchQuery => _internSearchQuery;
  String get taskSearchQuery => _taskSearchQuery;
  String get leadSearchQuery => _leadSearchQuery;
  String get projectSearchQuery => _projectSearchQuery;

  RoleCategory? get employeeCategoryFilter => _employeeCategoryFilter;
  String? get employeeRoleFilter => _employeeRoleFilter;
  String? get employeeTeamFilter => _employeeTeamFilter;
  bool? get employeeActiveFilter => _employeeActiveFilter;

  RoleCategory? get internCategoryFilter => _internCategoryFilter;
  String? get internDomainFilter => _internDomainFilter;
  String? get internBatchFilter => _internBatchFilter;
  String? get internMentorFilter => _internMentorFilter;
  String get internTaskScope => _internTaskScope;

  String get taskScopeFilter => _taskScopeFilter;
  String get taskStatusFilter => _taskStatusFilter;
  String get leadStageFilter => _leadStageFilter;
  String get projectStatusFilter => _projectStatusFilter;

  // -------------------------------------------------------------
  // Role & Track Matcher (Flexible / Fuzzy)
  // -------------------------------------------------------------

  bool _matchesRole(String entityRole, String filterRole) {
    final e = entityRole.toLowerCase().trim();
    final f = filterRole.toLowerCase().trim();
    if (e == f) return true;
    if (e.contains(f) || f.contains(e)) return true;

    // Technical track aliases
    if ((f.contains('frontend') || f == 'fe') && e.contains('frontend')) return true;
    if ((f.contains('backend') || f == 'be') && e.contains('backend')) return true;
    if (f.contains('full stack') && e.contains('full stack')) return true;
    if (f.contains('mobile') && e.contains('mobile')) return true;
    if ((f.contains('ai') || f.contains('ml')) && (e.contains('ai') || e.contains('ml'))) return true;
    if (f.contains('data') && e.contains('data')) return true;
    if (f.contains('qa') && (e.contains('qa') || e.contains('test') || e.contains('quality'))) return true;
    if ((f.contains('devops') || f.contains('cloud')) && (e.contains('devops') || e.contains('cloud'))) return true;
    if (f.contains('cyber') && e.contains('cyber')) return true;
    if (f.contains('ui/ux') && (e.contains('ui') || e.contains('ux') || e.contains('design'))) return true;

    // Non-Technical track aliases
    if (f.contains('hr') && (e.contains('hr') || e.contains('recruit'))) return true;
    if (f.contains('sales') && (e.contains('sales') || e.contains('business dev'))) return true;
    if (f.contains('market') && e.contains('market')) return true;
    if (f.contains('operat') && e.contains('operat')) return true;
    if ((f.contains('finance') || f.contains('account')) && (e.contains('finance') || e.contains('account'))) return true;
    if (f.contains('support') && e.contains('support')) return true;
    if ((f.contains('content') || f.contains('comm')) && (e.contains('content') || e.contains('comm'))) return true;
    if ((f.contains('admin') || f.contains('administration')) && (e.contains('admin') || e.contains('administrator'))) return true;

    return false;
  }

  // -------------------------------------------------------------
  // Filtered Lists
  // -------------------------------------------------------------

  List<Employee> get filteredEmployees {
    return _employees.where((e) {
      if (_employeeCategoryFilter != null && e.category != _employeeCategoryFilter) {
        return false;
      }
      if (_employeeRoleFilter != null && _employeeRoleFilter!.isNotEmpty) {
        if (!_matchesRole(e.role, _employeeRoleFilter!)) {
          return false;
        }
      }
      if (_employeeTeamFilter != null && _employeeTeamFilter!.isNotEmpty &&
          !e.team.toLowerCase().contains(_employeeTeamFilter!.toLowerCase())) {
        return false;
      }
      if (_employeeActiveFilter != null && e.isActive != _employeeActiveFilter) {
        return false;
      }
      final query = _employeeSearchQuery.isNotEmpty ? _employeeSearchQuery : _searchQuery;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = e.name.toLowerCase().contains(q) ||
            e.role.toLowerCase().contains(q) ||
            e.department.toLowerCase().contains(q) ||
            e.team.toLowerCase().contains(q) ||
            e.email.toLowerCase().contains(q) ||
            _matchesRole(e.role, q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  List<Intern> get filteredInterns {
    return _interns.where((i) {
      if (_internCategoryFilter != null && i.category != _internCategoryFilter) {
        return false;
      }
      if (_internDomainFilter != null && _internDomainFilter!.isNotEmpty) {
        if (!_matchesRole(i.domain, _internDomainFilter!)) {
          return false;
        }
      }
      if (_internBatchFilter != null && _internBatchFilter!.isNotEmpty &&
          i.batchId != _internBatchFilter && i.batchName != _internBatchFilter) {
        return false;
      }
      if (_internMentorFilter != null && _internMentorFilter!.isNotEmpty && i.assignedPocId != _internMentorFilter) {
        return false;
      }
      final query = _internSearchQuery.isNotEmpty ? _internSearchQuery : _searchQuery;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = i.name.toLowerCase().contains(q) ||
            i.domain.toLowerCase().contains(q) ||
            i.college.toLowerCase().contains(q) ||
            i.team.toLowerCase().contains(q) ||
            (i.assignedPocName?.toLowerCase().contains(q) ?? false) ||
            _matchesRole(i.domain, q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  List<CompanyTask> get filteredTasks {
    return _tasks.where((t) {
      if (_taskScopeFilter == 'My Tasks' && t.assignedToId != _currentUserId) {
        return false;
      }
      if (_taskScopeFilter == 'Projects • Domain' && (t.projectName == null || t.projectName!.isEmpty)) {
        return false;
      }
      if (_taskStatusFilter != 'All' && t.status.label != _taskStatusFilter && t.status.name != _taskStatusFilter) {
        return false;
      }
      final query = _taskSearchQuery.isNotEmpty ? _taskSearchQuery : _searchQuery;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.assignedToName.toLowerCase().contains(q) ||
            t.domain.toLowerCase().contains(q) ||
            (t.projectName?.toLowerCase().contains(q) ?? false) ||
            _matchesRole(t.domain, q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  List<Lead> get filteredLeads {
    return _leads.where((l) {
      if (_leadStageFilter != 'All' && l.status.label.toLowerCase() != _leadStageFilter.toLowerCase()) {
        return false;
      }
      final query = _leadSearchQuery.isNotEmpty ? _leadSearchQuery : _searchQuery;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = l.companyName.toLowerCase().contains(q) ||
            l.domain.toLowerCase().contains(q) ||
            l.clientName.toLowerCase().contains(q) ||
            l.assignedEmployeeName.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  List<Project> get filteredProjects {
    return _projects.where((p) {
      if (_projectStatusFilter != 'All' && p.status.label.toLowerCase() != _projectStatusFilter.toLowerCase()) {
        return false;
      }
      final query = _projectSearchQuery.isNotEmpty ? _projectSearchQuery : _searchQuery;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = p.name.toLowerCase().contains(q) ||
            p.clientName.toLowerCase().contains(q) ||
            p.domain.toLowerCase().contains(q) ||
            p.ownerEmployeeName.toLowerCase().contains(q) ||
            p.teamMemberNames.any((m) => m.toLowerCase().contains(q));
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  // -------------------------------------------------------------
  // Dynamic Threshold Alerts Engine
  // -------------------------------------------------------------

  List<ThresholdAlert> get thresholdAlerts {
    final alerts = <ThresholdAlert>[];

    // 1. Task overdue alert
    final overdueCount = _tasks.where((t) => t.daysOverdue >= _thresholds.taskOverdueDays).length;
    if (overdueCount > 0) {
      alerts.add(ThresholdAlert(
        id: 'ALT-TSK',
        title: '$overdueCount tasks are overdue',
        subtitle: 'Needs immediate attention.',
        category: 'tasks',
        time: '10:30 AM',
      ));
    }

    // 2. Inactive interns alert
    final inactiveInterns = _interns.where((i) => i.missedUpdatesDays >= _thresholds.internMissedUpdatesDays).length;
    if (inactiveInterns > 0) {
      alerts.add(ThresholdAlert(
        id: 'ALT-INT',
        title: '$inactiveInterns interns inactive',
        subtitle: 'No updates for ${_thresholds.internMissedUpdatesDays}+ days.',
        category: 'interns',
        time: '09:15 AM',
      ));
    }

    // 3. Delayed project alert
    final delayedProjects = _projects.where((p) => p.behindSchedulePercent >= _thresholds.projectBehindProgressPercent).length;
    if (delayedProjects > 0) {
      alerts.add(ThresholdAlert(
        id: 'ALT-PRJ',
        title: '$delayedProjects project delayed',
        subtitle: 'Milestone behind schedule (${_thresholds.projectBehindProgressPercent}%+ behind).',
        category: 'projects',
        time: 'Yesterday',
      ));
    }

    // 4. Leads follow-up alert
    final missedLeads = _leads.where((l) => l.isFollowUpMissed).length;
    if (missedLeads > 0) {
      alerts.add(ThresholdAlert(
        id: 'ALT-LD',
        title: '$missedLeads leads need follow-up',
        subtitle: 'Next contact date missed.',
        category: 'leads',
        time: 'Yesterday',
      ));
    }

    // 5. Workload capacity alert
    final overloadedEmployees = _employees.where((e) => e.activeTaskCount > _thresholds.employeeWorkloadCapacity).length;
    if (overloadedEmployees > 0) {
      alerts.add(ThresholdAlert(
        id: 'ALT-EMP',
        title: '$overloadedEmployees employees over capacity',
        subtitle: 'Workload > ${_thresholds.employeeWorkloadCapacity} tasks assigned.',
        category: 'employees',
        time: '2 days ago',
      ));
    }

    return alerts;
  }

  // -------------------------------------------------------------
  // Filter Updaters
  // -------------------------------------------------------------

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setEmployeeSearchQuery(String q) {
    _employeeSearchQuery = q;
    notifyListeners();
  }

  void setInternSearchQuery(String q) {
    _internSearchQuery = q;
    notifyListeners();
  }

  void setTaskSearchQuery(String q) {
    _taskSearchQuery = q;
    notifyListeners();
  }

  void setLeadSearchQuery(String q) {
    _leadSearchQuery = q;
    notifyListeners();
  }

  void setProjectSearchQuery(String q) {
    _projectSearchQuery = q;
    notifyListeners();
  }

  void setEmployeeCategoryFilter(RoleCategory? category) {
    _employeeCategoryFilter = category;
    _employeeRoleFilter = null;
    notifyListeners();
  }

  void setEmployeeRoleFilter(String? role) {
    _employeeRoleFilter = role;
    notifyListeners();
  }

  void setEmployeeTeamFilter(String? team) {
    _employeeTeamFilter = team;
    notifyListeners();
  }

  void setEmployeeActiveFilter(bool? active) {
    _employeeActiveFilter = active;
    notifyListeners();
  }

  void setInternCategoryFilter(RoleCategory? category) {
    _internCategoryFilter = category;
    _internDomainFilter = null;
    notifyListeners();
  }

  void setInternDomainFilter(String? domain) {
    _internDomainFilter = domain;
    notifyListeners();
  }

  void setInternBatchFilter(String? batchId) {
    _internBatchFilter = batchId;
    notifyListeners();
  }

  void setInternMentorFilter(String? mentorId) {
    _internMentorFilter = mentorId;
    notifyListeners();
  }

  void setInternTaskScope(String scope) {
    _internTaskScope = scope;
    notifyListeners();
  }

  void setTaskScopeFilter(String scope) {
    _taskScopeFilter = scope;
    notifyListeners();
  }

  void setTaskStatusFilter(String status) {
    _taskStatusFilter = status;
    notifyListeners();
  }

  void setLeadStageFilter(String stage) {
    _leadStageFilter = stage;
    notifyListeners();
  }

  void setProjectStatusFilter(String status) {
    _projectStatusFilter = status;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _employeeSearchQuery = '';
    _internSearchQuery = '';
    _taskSearchQuery = '';
    _leadSearchQuery = '';
    _projectSearchQuery = '';
    _employeeCategoryFilter = null;
    _employeeRoleFilter = null;
    _employeeTeamFilter = null;
    _employeeActiveFilter = null;
    _internCategoryFilter = null;
    _internDomainFilter = null;
    _internBatchFilter = null;
    _internMentorFilter = null;
    _taskScopeFilter = 'All';
    _taskStatusFilter = 'All';
    _leadStageFilter = 'All';
    _projectStatusFilter = 'All';
    notifyListeners();
  }

  // -------------------------------------------------------------
  // Configurable Admin Thresholds & Roles Management
  // -------------------------------------------------------------

  void updateThresholds(AlertThresholds newThresholds) {
    _thresholds = newThresholds;
    _addAuditLog(
      action: 'Alert Thresholds Configured',
      module: 'Admin',
      details: 'Updated threshold parameters (Task overdue: ${_thresholds.taskOverdueDays}d, Missed updates: ${_thresholds.internMissedUpdatesDays}d)',
    );
    notifyListeners();
  }

  void addRole(String name, RoleCategory category) {
    final id = 'ROL-${DateTime.now().millisecondsSinceEpoch % 1000}';
    _roles.add(CompanyRole(id: id, name: name, category: category));
    _addAuditLog(
      action: 'Role Configured',
      module: 'Hierarchy',
      details: 'Added role "$name" under ${category.label}',
    );
    notifyListeners();
  }

  void removeRole(String id) {
    _roles.removeWhere((r) => r.id == id);
    _addAuditLog(
      action: 'Role Removed',
      module: 'Hierarchy',
      details: 'Removed role with ID $id',
    );
    notifyListeners();
  }

  void setRole(UserRole role) {
    _currentRole = role;
    if (role == UserRole.ceo) {
      _currentUserName = 'Laven Lokesh';
      _currentUserEmail = 'laven@digitalinertia.com';
      _currentUserId = 'EMP-001';
    } else if (role == UserRole.poc) {
      _currentUserName = 'Sarah Chen';
      _currentUserEmail = 'sarah.chen@digitalinertia.com';
      _currentUserId = 'EMP-002';
    } else {
      _currentUserName = 'Karthik R';
      _currentUserEmail = 'karthik.intern@digitalinertia.com';
      _currentUserId = 'INT-201';
    }
    notifyListeners();
  }

  // -------------------------------------------------------------
  // CRUD Actions
  // -------------------------------------------------------------

  void addEmployee({
    required String name,
    required String email,
    required String phone,
    required String role,
    required RoleCategory category,
    required String department,
    String team = 'Core Engineering',
    required bool isPOC,
  }) {
    final newEmp = Employee(
      id: 'EMP-${_employees.length + 10}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      category: category,
      department: department,
      team: team,
      isPOC: isPOC,
      isActive: true,
      activeTaskCount: 1,
    );
    _employees.add(newEmp);
    _addAuditLog(
      action: 'Employee Added',
      module: 'People',
      details: 'Added $name ($role, $team)',
    );
    notifyListeners();
  }

  void toggleEmployeeStatus(String empId) {
    final idx = _employees.indexWhere((e) => e.id == empId);
    if (idx != -1) {
      final old = _employees[idx];
      _employees[idx] = old.copyWith(isActive: !old.isActive);
      notifyListeners();
    }
  }

  void addIntern({
    required String name,
    required String email,
    required String phone,
    required String college,
    required RoleCategory category,
    required String domain,
    String team = 'Core Team',
    required String batchId,
    required double interviewScore,
    String? assignedPocId,
  }) {
    final batch = _batches.firstWhere((b) => b.id == batchId, orElse: () => _batches.first);
    String? pocName;
    if (assignedPocId != null) {
      final poc = _employees.firstWhere((e) => e.id == assignedPocId, orElse: () => _employees.first);
      pocName = poc.name;
    }

    final newIntern = Intern(
      id: 'INT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: name,
      email: email,
      phone: phone,
      college: college,
      category: category,
      domain: domain,
      team: team,
      batchId: batchId,
      batchName: batch.code,
      interviewScore: interviewScore,
      selectionDate: DateTime.now(),
      assignedPocId: assignedPocId,
      assignedPocName: pocName,
    );
    _interns.insert(0, newIntern);
    _addAuditLog(
      action: 'Intern Registered',
      module: 'People',
      details: 'Registered $name ($domain) to ${batch.code}',
    );
    notifyListeners();
  }

  void updateInternDecision(String internId, InternFinalDecision decision) {
    final idx = _interns.indexWhere((i) => i.id == internId);
    if (idx != -1) {
      _interns[idx] = _interns[idx].copyWith(finalDecision: decision);
      _addAuditLog(
        action: 'Intern Decision Updated',
        module: 'Interns',
        details: 'Set ${_interns[idx].name} to ${decision.label}',
      );
      notifyListeners();
    }
  }

  void createTask({
    required String title,
    required String description,
    required String domain,
    required String assignedToId,
    required String assignedToName,
    required AssigneeType assigneeType,
    required DateTime dueDate,
    required TaskPriority priority,
    String? projectName,
  }) {
    final newTask = CompanyTask(
      id: 'TSK-${DateTime.now().millisecondsSinceEpoch % 1000}',
      title: title,
      description: description,
      domain: domain,
      assignedToId: assignedToId,
      assignedToName: assignedToName,
      assigneeType: assigneeType,
      assignedById: _currentUserId,
      assignedByName: _currentUserName,
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.todo,
      projectName: projectName,
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, newTask);
    notifyListeners();
  }

  void addLead({
    required String clientName,
    required String companyName,
    required String domain,
    required String email,
    required String phone,
    required double dealValue,
    required String assignedEmployeeId,
    required DateTime nextFollowUpDate,
    required String notes,
  }) {
    final emp = _employees.firstWhere((e) => e.id == assignedEmployeeId, orElse: () => _employees.first);
    final newLead = Lead(
      id: 'LD-${DateTime.now().millisecondsSinceEpoch % 1000}',
      clientName: clientName,
      companyName: companyName,
      domain: domain,
      email: email,
      phone: phone,
      dealValue: dealValue,
      status: LeadStatus.newLead,
      assignedEmployeeId: assignedEmployeeId,
      assignedEmployeeName: emp.name,
      nextFollowUpDate: nextFollowUpDate,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _leads.insert(0, newLead);
    notifyListeners();
  }

  void addProject({
    required String name,
    required String clientName,
    required String domain,
    required String description,
    required double budget,
    required String ownerEmployeeId,
    required DateTime deadline,
    List<String>? teamMemberNames,
  }) {
    final owner = _employees.firstWhere((e) => e.id == ownerEmployeeId, orElse: () => _employees.first);
    final members = (teamMemberNames != null && teamMemberNames.isNotEmpty)
        ? List<String>.from(teamMemberNames)
        : [owner.name];
    if (!members.contains(owner.name)) {
      members.insert(0, owner.name);
    }

    final newProject = Project(
      id: 'PRJ-${DateTime.now().millisecondsSinceEpoch % 1000}',
      name: name,
      clientName: clientName,
      domain: domain,
      description: description,
      budget: budget,
      ownerEmployeeId: owner.id,
      ownerEmployeeName: owner.name,
      teamMemberNames: members,
      status: ProjectStatus.inProgress,
      progress: 0.1,
      plannedProgress: 0.15,
      startDate: DateTime.now(),
      deadline: deadline,
    );
    _projects.insert(0, newProject);
    _addAuditLog(
      action: 'Project Created',
      module: 'Projects',
      details: 'Created $name with Lead ${owner.name} (${members.length} team members)',
    );
    notifyListeners();
  }

  void updateProjectTeam({
    required String projectId,
    required String ownerEmployeeId,
    required List<String> teamMemberNames,
  }) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      final owner = _employees.firstWhere((e) => e.id == ownerEmployeeId, orElse: () => _employees.first);
      final members = List<String>.from(teamMemberNames);
      if (!members.contains(owner.name)) {
        members.insert(0, owner.name);
      }
      _projects[idx] = _projects[idx].copyWith(
        ownerEmployeeId: owner.id,
        ownerEmployeeName: owner.name,
        teamMemberNames: members,
      );
      _addAuditLog(
        action: 'Project Team Reassigned',
        module: 'Projects',
        details: 'Updated team for ${_projects[idx].name}: Lead ${owner.name}, Team: ${members.join(", ")}',
      );
      notifyListeners();
    }
  }

  void updateLeadStatus(String leadId, LeadStatus newStatus) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      _leads[idx] = _leads[idx].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void convertLeadToProject({
    required String leadId,
    required String projectName,
    required String description,
    required double budget,
    required String ownerEmployeeId,
    required DateTime deadline,
  }) {
    final leadIndex = _leads.indexWhere((l) => l.id == leadId);
    final owner = _employees.firstWhere((e) => e.id == ownerEmployeeId, orElse: () => _employees.first);
    final clientName = leadIndex != -1 ? _leads[leadIndex].companyName : 'Enterprise Client';

    final newProjId = 'PRJ-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final newProject = Project(
      id: newProjId,
      name: projectName,
      clientName: clientName,
      description: description,
      budget: budget,
      ownerEmployeeId: owner.id,
      ownerEmployeeName: owner.name,
      teamMemberNames: [owner.name],
      status: ProjectStatus.inProgress,
      startDate: DateTime.now(),
      deadline: deadline,
      sourceLeadId: leadId,
      milestones: [
        ProjectMilestone(
          id: 'M1',
          title: 'System Design & Scoping',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          isCompleted: false,
        ),
      ],
    );

    _projects.insert(0, newProject);
    if (leadIndex != -1) {
      _leads[leadIndex] = _leads[leadIndex].copyWith(
        status: LeadStatus.won,
        convertedProjectId: newProjId,
      );
    }
    notifyListeners();
  }

  void addProjectBlocker(String projectId, String blockerText) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      final p = _projects[idx];
      final blockers = List<String>.from(p.activeBlockers)..add(blockerText);
      _projects[idx] = p.copyWith(activeBlockers: blockers, status: ProjectStatus.delayed);
      notifyListeners();
    }
  }

  void resolveProjectBlocker(String projectId, int blockerIndex) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      final p = _projects[idx];
      final blockers = List<String>.from(p.activeBlockers);
      if (blockerIndex < blockers.length) {
        blockers.removeAt(blockerIndex);
        _projects[idx] = p.copyWith(
          activeBlockers: blockers,
          status: blockers.isEmpty ? ProjectStatus.inProgress : ProjectStatus.delayed,
        );
        notifyListeners();
      }
    }
  }

  void toggleProjectMilestone(String projectId, String milestoneId) {
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      final p = _projects[idx];
      final updatedMilestones = p.milestones.map((m) {
        if (m.id == milestoneId) {
          return m.copyWith(isCompleted: !m.isCompleted);
        }
        return m;
      }).toList();
      final completedCount = updatedMilestones.where((m) => m.isCompleted).length;
      final newProgress = updatedMilestones.isNotEmpty ? completedCount / updatedMilestones.length : 0.0;
      _projects[idx] = p.copyWith(milestones: updatedMilestones, progress: newProgress);
      notifyListeners();
    }
  }

  void reviewTask({
    required String taskId,
    required bool approve,
    required String ceoNotes,
  }) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final t = _tasks[idx];
      final newStatus = approve ? TaskStatus.approved : TaskStatus.needsRework;
      _tasks[idx] = t.copyWith(
        status: newStatus,
        ceoReviewNotes: ceoNotes,
        completedAt: approve ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }

  void submitTaskForReview(String taskId, String notes, String? proofUrl) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final t = _tasks[idx];
      _tasks[idx] = t.copyWith(
        status: TaskStatus.submitted,
        submissionNotes: notes,
        submissionProofUrl: proofUrl,
        progressPercent: 100,
      );
      notifyListeners();
    }
  }

  void updateInternPoc(String internId, String employeeId) {
    final emp = _employees.firstWhere((e) => e.id == employeeId);
    final idx = _interns.indexWhere((i) => i.id == internId);
    if (idx != -1) {
      _interns[idx] = _interns[idx].copyWith(
        assignedPocId: emp.id,
        assignedPocName: emp.name,
      );
      notifyListeners();
    }
  }

  void addInternFeedback(String internId, double newRating, String feedback) {
    final idx = _interns.indexWhere((i) => i.id == internId);
    if (idx != -1) {
      _interns[idx] = _interns[idx].copyWith(
        performanceRating: newRating,
        latestFeedback: feedback,
      );
      notifyListeners();
    }
  }

  void _addAuditLog({
    required String action,
    required String module,
    required String details,
  }) {
    _auditLogs.insert(
      0,
      AuditLog(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        actorName: _currentUserName,
        actorRole: _currentRole.label,
        action: action,
        module: module,
        details: details,
      ),
    );
  }

  String exportDatabaseJson() {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'system': 'Digital Inertia CEO Mobile ERP',
      'employees': _employees.map((e) => e.toJson()).toList(),
      'interns': _interns.map((i) => i.toJson()).toList(),
      'tasks': _tasks.map((t) => t.toJson()).toList(),
      'leads': _leads.map((l) => l.toJson()).toList(),
      'projects': _projects.map((p) => p.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // -------------------------------------------------------------
  // Seed Initialization matching Screenshot Exactly
  // -------------------------------------------------------------

  void _initRoles() {
    _roles = [
      // Technical Roles (matching user hierarchy)
      CompanyRole(id: 'R-FE', name: 'Frontend', category: RoleCategory.technical),
      CompanyRole(id: 'R-BE', name: 'Backend', category: RoleCategory.technical),
      CompanyRole(id: 'R-FS', name: 'Full Stack', category: RoleCategory.technical),
      CompanyRole(id: 'R-MOB', name: 'Mobile App', category: RoleCategory.technical),
      CompanyRole(id: 'R-AI', name: 'AI / ML', category: RoleCategory.technical),
      CompanyRole(id: 'R-DE', name: 'Data Engineering', category: RoleCategory.technical),
      CompanyRole(id: 'R-QA', name: 'QA / Testing', category: RoleCategory.technical),
      CompanyRole(id: 'R-CLD', name: 'DevOps / Cloud', category: RoleCategory.technical),
      CompanyRole(id: 'R-SEC', name: 'Cybersecurity', category: RoleCategory.technical),
      CompanyRole(id: 'R-UX', name: 'UI/UX Engineering', category: RoleCategory.technical),

      // Non-Technical Roles (matching user hierarchy)
      CompanyRole(id: 'R-HR', name: 'HR / Recruitment', category: RoleCategory.nonTechnical),
      CompanyRole(id: 'R-SBD', name: 'Sales / Business Development', category: RoleCategory.nonTechnical),
      CompanyRole(id: 'R-MKT', name: 'Marketing', category: RoleCategory.nonTechnical),
      CompanyRole(id: 'R-OPS', name: 'Operations', category: RoleCategory.nonTechnical),
      CompanyRole(id: 'R-FIN', name: 'Finance / Accounts', category: RoleCategory.nonTechnical),
      CompanyRole(id: 'R-CS', name: 'Customer Support', category: RoleCategory.nonTechnical),
      CompanyRole(id: 'R-CC', name: 'Content / Communications', category: RoleCategory.nonTechnical),
      CompanyRole(id: 'R-ADM', name: 'Administration', category: RoleCategory.nonTechnical),
    ];
  }

  void _initSeedData() {
    _employees = [
      Employee(
        id: 'EMP-101',
        name: 'Arjun Sharma',
        email: 'arjun.sharma@digitalinertia.com',
        phone: '+91 98201 14521',
        role: 'Frontend Developer',
        category: RoleCategory.technical,
        department: 'Engineering',
        team: 'Client Experience Engineering',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
      ),
      Employee(
        id: 'EMP-102',
        name: 'Priya Nair',
        email: 'priya.nair@digitalinertia.com',
        phone: '+91 98450 78210',
        role: 'Backend Developer',
        category: RoleCategory.technical,
        department: 'Engineering',
        team: 'Core Platform Engineering',
        isPOC: true,
        isActive: true,
        activeTaskCount: 5, // Workload capacity overload alert (>4 tasks)
      ),
      Employee(
        id: 'EMP-103',
        name: 'Karthik R',
        email: 'karthik.r@digitalinertia.com',
        phone: '+91 97112 65430',
        role: 'Full Stack Developer',
        category: RoleCategory.technical,
        department: 'Engineering',
        team: 'Core Platform Engineering',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
      ),
      Employee(
        id: 'EMP-104',
        name: 'Sneha V',
        email: 'sneha.v@digitalinertia.com',
        phone: '+91 99304 98124',
        role: 'Frontend Developer',
        category: RoleCategory.technical,
        department: 'Engineering',
        team: 'Client Experience Engineering',
        isPOC: true,
        isActive: true,
        activeTaskCount: 3,
      ),
      Employee(
        id: 'EMP-105',
        name: 'Rohan Mehta',
        email: 'rohan.mehta@digitalinertia.com',
        phone: '+91 98214 33219',
        role: 'Mobile App Developer',
        category: RoleCategory.technical,
        department: 'Engineering',
        team: 'Client Experience Engineering',
        isPOC: true,
        isActive: true,
        activeTaskCount: 5, // Workload capacity overload alert (>4 tasks)
      ),
      Employee(
        id: 'EMP-106',
        name: 'Ananya Deshmukh',
        email: 'ananya.deshmukh@digitalinertia.com',
        phone: '+91 98190 22345',
        role: 'AI / ML Engineer',
        category: RoleCategory.technical,
        department: 'Applied AI',
        team: 'Applied Intelligence Lab',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-107',
        name: 'Vikram Singh',
        email: 'vikram.singh@digitalinertia.com',
        phone: '+91 97401 88320',
        role: 'Data Engineer',
        category: RoleCategory.technical,
        department: 'Engineering',
        team: 'Core Platform Engineering',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-108',
        name: 'Neha Patel',
        email: 'neha.patel@digitalinertia.com',
        phone: '+91 98331 44590',
        role: 'QA / Testing Lead',
        category: RoleCategory.technical,
        department: 'Quality',
        team: 'Quality & Reliability',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-109',
        name: 'Rahul Verma',
        email: 'rahul.verma@digitalinertia.com',
        phone: '+91 98110 99450',
        role: 'DevOps / Cloud Specialist',
        category: RoleCategory.technical,
        department: 'Infrastructure',
        team: 'Core Platform Engineering',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-110',
        name: 'Divya Iyer',
        email: 'divya.iyer@digitalinertia.com',
        phone: '+91 98402 11234',
        role: 'UI/UX Engineering Lead',
        category: RoleCategory.technical,
        department: 'Design',
        team: 'Client Experience Engineering',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-111',
        name: 'Meera Joshi',
        email: 'meera.joshi@digitalinertia.com',
        phone: '+91 98205 66780',
        role: 'HR / Recruitment Specialist',
        category: RoleCategory.nonTechnical,
        department: 'People',
        team: 'People & Workplace',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-112',
        name: 'Rajesh Kumar',
        email: 'rajesh.kumar@digitalinertia.com',
        phone: '+91 98101 44321',
        role: 'Sales / Business Development',
        category: RoleCategory.nonTechnical,
        department: 'Growth',
        team: 'Corporate Growth & Sales',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
      ),
      Employee(
        id: 'EMP-113',
        name: 'Sanjay Menon',
        email: 'sanjay.menon@digitalinertia.com',
        phone: '+91 98410 77650',
        role: 'Marketing Strategist',
        category: RoleCategory.nonTechnical,
        department: 'Growth',
        team: 'Corporate Growth & Sales',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-114',
        name: 'Pooja Hegde',
        email: 'pooja.hegde@digitalinertia.com',
        phone: '+91 98211 22390',
        role: 'Operations Manager',
        category: RoleCategory.nonTechnical,
        department: 'Operations',
        team: 'Financial & Business Ops',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-115',
        name: 'Siddharth Roy',
        email: 'siddharth.roy@digitalinertia.com',
        phone: '+91 98300 88710',
        role: 'Finance / Accounts Lead',
        category: RoleCategory.nonTechnical,
        department: 'Finance',
        team: 'Financial & Business Ops',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-116',
        name: 'Kavita Rao',
        email: 'kavita.rao@digitalinertia.com',
        phone: '+91 98452 33410',
        role: 'Customer Support Manager',
        category: RoleCategory.nonTechnical,
        department: 'Success',
        team: 'Corporate Growth & Sales',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
      ),
      Employee(
        id: 'EMP-117',
        name: 'Aditya Sen',
        email: 'aditya.sen@digitalinertia.com',
        phone: '+91 98115 55620',
        role: 'Content / Communications',
        category: RoleCategory.nonTechnical,
        department: 'Communications',
        team: 'Corporate Growth & Sales',
        isPOC: false,
        isActive: true,
        activeTaskCount: 0,
      ),
      Employee(
        id: 'EMP-118',
        name: 'Shreya Kulkarni',
        email: 'shreya.kulkarni@digitalinertia.com',
        phone: '+91 98204 11980',
        role: 'Administration Lead',
        category: RoleCategory.nonTechnical,
        department: 'Administration',
        team: 'Financial & Business Ops',
        isPOC: false,
        isActive: true,
        activeTaskCount: 0,
      ),
    ];

    // Batches
    _batches = [
      InternBatch(
        id: 'BATCH-2025-W12',
        code: 'Batch Apr-A (2025)',
        title: 'Core Systems & Mobile Acceleration Cohort',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        interviewedCount: 68,
        selectedCount: 26,
        activeCount: 14,
      ),
      InternBatch(
        id: 'BATCH-2025-W14',
        code: 'Batch Apr-B (2025)',
        title: 'Cloud Intelligence & Applied AI Cohort',
        startDate: DateTime.now().subtract(const Duration(days: 4)),
        interviewedCount: 52,
        selectedCount: 18,
        activeCount: 10,
      ),
    ];

    // 24 Active Interns (Zero Placeholders: Premier Engineering & Design Institutes)
    _interns = [
      Intern(
        id: 'INT-201',
        name: 'Aarav Gupta',
        email: 'aarav.gupta@collegemail.edu',
        phone: '+91 98111 20001',
        college: 'IIT Bombay',
        category: RoleCategory.technical,
        domain: 'Backend',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 9.2,
        selectionDate: DateTime.now().subtract(const Duration(days: 20)),
        assignedPocId: 'EMP-102',
        assignedPocName: 'Priya Nair',
        performanceRating: 4.8,
        latestFeedback: 'Clean implementation of PostgreSQL query optimizations.',
        finalDecision: InternFinalDecision.retain,
        completedTasks: 3,
        totalTasks: 4,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-202',
        name: 'Bhavya Shah',
        email: 'bhavya.shah@collegemail.edu',
        phone: '+91 98111 20002',
        college: 'BITS Pilani',
        category: RoleCategory.technical,
        domain: 'Frontend',
        team: 'Client Experience Engineering',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.9,
        selectionDate: DateTime.now().subtract(const Duration(days: 20)),
        assignedPocId: 'EMP-101',
        assignedPocName: 'Arjun Sharma',
        performanceRating: 4.5,
        latestFeedback: 'Converted Figma executive dashboard components accurately.',
        finalDecision: InternFinalDecision.pending,
        completedTasks: 4,
        totalTasks: 5,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-203',
        name: 'Chirag Mathur',
        email: 'chirag.mathur@collegemail.edu',
        phone: '+91 98111 20003',
        college: 'NIT Trichy',
        category: RoleCategory.technical,
        domain: 'Full Stack',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.5,
        selectionDate: DateTime.now().subtract(const Duration(days: 19)),
        assignedPocId: 'EMP-103',
        assignedPocName: 'Karthik R',
        performanceRating: 3.2,
        latestFeedback: 'Missed daily progress check-ins 2 times.',
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 3,
        missedUpdatesDays: 2, // Inactive alert 1!
      ),
      Intern(
        id: 'INT-204',
        name: 'Deepika Pillai',
        email: 'deepika.pillai@collegemail.edu',
        phone: '+91 98111 20004',
        college: 'VIT Vellore',
        category: RoleCategory.technical,
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.8,
        selectionDate: DateTime.now().subtract(const Duration(days: 19)),
        assignedPocId: 'EMP-105',
        assignedPocName: 'Rohan Mehta',
        performanceRating: 4.2,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 2,
        totalTasks: 3,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-205',
        name: 'Eshan Kulkarni',
        email: 'eshan.kulkarni@collegemail.edu',
        phone: '+91 98111 20005',
        college: 'IIIT Hyderabad',
        category: RoleCategory.technical,
        domain: 'AI / ML',
        team: 'Applied Intelligence Lab',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 9.5,
        selectionDate: DateTime.now().subtract(const Duration(days: 18)),
        assignedPocId: 'EMP-106',
        assignedPocName: 'Ananya Deshmukh',
        performanceRating: 4.9,
        finalDecision: InternFinalDecision.retain,
        completedTasks: 3,
        totalTasks: 3,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-206',
        name: 'Falguni Das',
        email: 'falguni.das@collegemail.edu',
        phone: '+91 98111 20006',
        college: 'Delhi Tech University',
        category: RoleCategory.technical,
        domain: 'Data Engineering',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.2,
        selectionDate: DateTime.now().subtract(const Duration(days: 18)),
        assignedPocId: 'EMP-107',
        assignedPocName: 'Vikram Singh',
        performanceRating: 4.0,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 2,
        totalTasks: 2,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-207',
        name: 'Gautam Nambiar',
        email: 'gautam.nambiar@collegemail.edu',
        phone: '+91 98111 20007',
        college: 'RV College Bangalore',
        category: RoleCategory.technical,
        domain: 'QA / Testing',
        team: 'Quality & Reliability',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 7.9,
        selectionDate: DateTime.now().subtract(const Duration(days: 17)),
        assignedPocId: 'EMP-108',
        assignedPocName: 'Neha Patel',
        performanceRating: 3.0,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 2,
        missedUpdatesDays: 3, // Inactive alert 2!
      ),
      Intern(
        id: 'INT-208',
        name: 'Harini Swaminathan',
        email: 'harini.s@collegemail.edu',
        phone: '+91 98111 20008',
        college: 'PSG Tech Coimbatore',
        category: RoleCategory.technical,
        domain: 'DevOps / Cloud',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 9.0,
        selectionDate: DateTime.now().subtract(const Duration(days: 17)),
        assignedPocId: 'EMP-109',
        assignedPocName: 'Rahul Verma',
        performanceRating: 4.6,
        finalDecision: InternFinalDecision.retain,
        completedTasks: 2,
        totalTasks: 2,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-209',
        name: 'Ishaan Saxena',
        email: 'ishaan.saxena@collegemail.edu',
        phone: '+91 98111 20009',
        college: 'IIT Madras',
        category: RoleCategory.technical,
        domain: 'Cybersecurity',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.7,
        selectionDate: DateTime.now().subtract(const Duration(days: 16)),
        assignedPocId: 'EMP-102',
        assignedPocName: 'Priya Nair',
        performanceRating: 4.4,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 2,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-210',
        name: 'Jayati Bose',
        email: 'jayati.bose@collegemail.edu',
        phone: '+91 98111 20010',
        college: 'National Inst of Design',
        category: RoleCategory.technical,
        domain: 'UI/UX Engineering',
        team: 'Client Experience Engineering',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 9.3,
        selectionDate: DateTime.now().subtract(const Duration(days: 16)),
        assignedPocId: 'EMP-110',
        assignedPocName: 'Divya Iyer',
        performanceRating: 4.7,
        finalDecision: InternFinalDecision.retain,
        completedTasks: 3,
        totalTasks: 3,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-211',
        name: 'Kunal Trivedi',
        email: 'kunal.trivedi@collegemail.edu',
        phone: '+91 98111 20011',
        college: 'Symbiosis Pune',
        category: RoleCategory.nonTechnical,
        domain: 'HR / Recruitment',
        team: 'People & Workplace',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.4,
        selectionDate: DateTime.now().subtract(const Duration(days: 15)),
        assignedPocId: 'EMP-111',
        assignedPocName: 'Meera Joshi',
        performanceRating: 4.1,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 1,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-212',
        name: 'Lavanya Sundaram',
        email: 'lavanya.s@collegemail.edu',
        phone: '+91 98111 20012',
        college: 'NMIMS Mumbai',
        category: RoleCategory.nonTechnical,
        domain: 'Sales / Business Development',
        team: 'Corporate Growth & Sales',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.6,
        selectionDate: DateTime.now().subtract(const Duration(days: 15)),
        assignedPocId: 'EMP-112',
        assignedPocName: 'Rajesh Kumar',
        performanceRating: 4.3,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 2,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-213',
        name: 'Manish Chawla',
        email: 'manish.chawla@collegemail.edu',
        phone: '+91 98111 20013',
        college: 'MICA Ahmedabad',
        category: RoleCategory.nonTechnical,
        domain: 'Marketing',
        team: 'Corporate Growth & Sales',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.1,
        selectionDate: DateTime.now().subtract(const Duration(days: 14)),
        assignedPocId: 'EMP-113',
        assignedPocName: 'Sanjay Menon',
        performanceRating: 3.3,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 2,
        missedUpdatesDays: 2, // Inactive alert 3! (Total 3 inactive interns)
      ),
      Intern(
        id: 'INT-214',
        name: 'Nandini Rao',
        email: 'nandini.rao@collegemail.edu',
        phone: '+91 98111 20014',
        college: 'Loyola Chennai',
        category: RoleCategory.nonTechnical,
        domain: 'Operations',
        team: 'Financial & Business Ops',
        batchId: 'BATCH-2025-W12',
        batchName: 'Batch Apr-A (2025)',
        interviewScore: 8.3,
        selectionDate: DateTime.now().subtract(const Duration(days: 14)),
        assignedPocId: 'EMP-114',
        assignedPocName: 'Pooja Hegde',
        performanceRating: 4.2,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 1,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-215',
        name: 'Omkar Jadhav',
        email: 'omkar.jadhav@collegemail.edu',
        phone: '+91 98111 20015',
        college: 'IIT Roorkee',
        category: RoleCategory.technical,
        domain: 'Backend',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 8.9,
        selectionDate: DateTime.now().subtract(const Duration(days: 8)),
        assignedPocId: 'EMP-102',
        assignedPocName: 'Priya Nair',
        performanceRating: 4.4,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 2,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-216',
        name: 'Parul Singhania',
        email: 'parul.s@collegemail.edu',
        phone: '+91 98111 20016',
        college: 'BITS Goa',
        category: RoleCategory.technical,
        domain: 'Frontend',
        team: 'Client Experience Engineering',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 8.6,
        selectionDate: DateTime.now().subtract(const Duration(days: 8)),
        assignedPocId: 'EMP-104',
        assignedPocName: 'Sneha V',
        performanceRating: 4.3,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 2,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-217',
        name: 'Qasim Rizvi',
        email: 'qasim.rizvi@collegemail.edu',
        phone: '+91 98111 20017',
        college: 'Manipal Institute of Tech',
        category: RoleCategory.technical,
        domain: 'Full Stack',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 8.0,
        selectionDate: DateTime.now().subtract(const Duration(days: 7)),
        assignedPocId: 'EMP-103',
        assignedPocName: 'Karthik R',
        performanceRating: 3.9,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 1,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-218',
        name: 'Ritika Kaul',
        email: 'ritika.kaul@collegemail.edu',
        phone: '+91 98111 20018',
        college: 'Thapar University',
        category: RoleCategory.technical,
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 8.5,
        selectionDate: DateTime.now().subtract(const Duration(days: 7)),
        assignedPocId: 'EMP-105',
        assignedPocName: 'Rohan Mehta',
        performanceRating: 4.1,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 1,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-219',
        name: 'Siddhant Bakshi',
        email: 'siddhant.b@collegemail.edu',
        phone: '+91 98111 20019',
        college: 'IIIT Bangalore',
        category: RoleCategory.technical,
        domain: 'AI / ML',
        team: 'Applied Intelligence Lab',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 9.4,
        selectionDate: DateTime.now().subtract(const Duration(days: 6)),
        assignedPocId: 'EMP-106',
        assignedPocName: 'Ananya Deshmukh',
        performanceRating: 4.8,
        finalDecision: InternFinalDecision.retain,
        completedTasks: 2,
        totalTasks: 2,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-220',
        name: 'Tanvi Mahajan',
        email: 'tanvi.m@collegemail.edu',
        phone: '+91 98111 20020',
        college: 'SRM University',
        category: RoleCategory.technical,
        domain: 'Data Engineering',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 8.1,
        selectionDate: DateTime.now().subtract(const Duration(days: 6)),
        assignedPocId: 'EMP-107',
        assignedPocName: 'Vikram Singh',
        performanceRating: 4.0,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 1,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-221',
        name: 'Udayan Sen',
        email: 'udayan.sen@collegemail.edu',
        phone: '+91 98111 20021',
        college: 'Jadavpur University',
        category: RoleCategory.technical,
        domain: 'QA / Testing',
        team: 'Quality & Reliability',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 8.3,
        selectionDate: DateTime.now().subtract(const Duration(days: 5)),
        assignedPocId: 'EMP-108',
        assignedPocName: 'Neha Patel',
        performanceRating: 4.2,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 1,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-222',
        name: 'Varun Somani',
        email: 'varun.somani@collegemail.edu',
        phone: '+91 98111 20022',
        college: 'NIT Surathkal',
        category: RoleCategory.technical,
        domain: 'DevOps / Cloud',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 8.7,
        selectionDate: DateTime.now().subtract(const Duration(days: 5)),
        assignedPocId: 'EMP-109',
        assignedPocName: 'Rahul Verma',
        performanceRating: 4.3,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 1,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-223',
        name: 'Waseem Akram',
        email: 'waseem.akram@collegemail.edu',
        phone: '+91 98111 20023',
        college: 'Aligarh Muslim Univ',
        category: RoleCategory.technical,
        domain: 'Cybersecurity',
        team: 'Core Platform Engineering',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 8.2,
        selectionDate: DateTime.now().subtract(const Duration(days: 4)),
        assignedPocId: 'EMP-102',
        assignedPocName: 'Priya Nair',
        performanceRating: 3.9,
        finalDecision: InternFinalDecision.pending,
        completedTasks: 1,
        totalTasks: 1,
        missedUpdatesDays: 0,
      ),
      Intern(
        id: 'INT-224',
        name: 'Yamini Reddy',
        email: 'yamini.reddy@collegemail.edu',
        phone: '+91 98111 20024',
        college: 'Srishti Inst of Art & Tech',
        category: RoleCategory.technical,
        domain: 'UI/UX Engineering',
        team: 'Client Experience Engineering',
        batchId: 'BATCH-2025-W14',
        batchName: 'Batch Apr-B (2025)',
        interviewScore: 9.1,
        selectionDate: DateTime.now().subtract(const Duration(days: 4)),
        assignedPocId: 'EMP-110',
        assignedPocName: 'Divya Iyer',
        performanceRating: 4.7,
        finalDecision: InternFinalDecision.retain,
        completedTasks: 2,
        totalTasks: 2,
        missedUpdatesDays: 0,
      ),
    ];

    // 42 Total Tasks (matching PostgreSQL 02_seed.sql: 20 Completed, 8 In Progress, 6 To Do, 5 Overdue, 3 Needs Rework)
    _tasks = [
      // 5 Overdue Tasks (triggers ALT-TSK)
      CompanyTask(
        id: 'TSK-401',
        title: 'Database setup',
        description: 'Provision PostgreSQL 18 HA replication cluster and execute initial DDL scripts',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'INT-203',
        assignedToName: 'Chirag Sethi',
        assigneeType: AssigneeType.intern,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.overdue,
        priority: TaskPriority.urgent,
        progressPercent: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CompanyTask(
        id: 'TSK-402',
        title: 'Fix authentication gateway timeout',
        description: 'Resolve 504 gateway timeout under 2,000 concurrent OAuth authorization code grants',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        status: TaskStatus.overdue,
        priority: TaskPriority.urgent,
        progressPercent: 40,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      CompanyTask(
        id: 'TSK-403',
        title: 'Optimize state tree rebuilds',
        description: 'Profile widget subtree renders in Flutter and eliminate unneeded RepaintBoundary redraws',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.overdue,
        priority: TaskPriority.high,
        progressPercent: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CompanyTask(
        id: 'TSK-404',
        title: 'Update client SLA contract addendum',
        description: 'Incorporate Tier-1 99.95% uptime guarantees and incident escalation workflow',
        domain: 'Sales / Business Development',
        team: 'Corporate Growth & Sales',
        assignedToId: 'EMP-112',
        assignedToName: 'Rajesh Kumar',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-112',
        assignedByName: 'Rajesh Kumar',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        status: TaskStatus.overdue,
        priority: TaskPriority.high,
        progressPercent: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CompanyTask(
        id: 'TSK-405',
        title: 'Patch OpenSSL vulnerabilities on production edge',
        description: 'Apply CVE-2024 security updates across reverse proxy ingress pods',
        domain: 'DevOps / Cloud',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.overdue,
        priority: TaskPriority.urgent,
        progressPercent: 40,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),

      // 8 In Progress Tasks
      CompanyTask(
        id: 'TSK-406',
        title: 'Build login API',
        description: 'Implement JWT token exchange, refresh tokens and bcrypt password verification endpoints',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'INT-201',
        assignedToName: 'Aarav Sharma',
        assigneeType: AssigneeType.intern,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 65,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-407',
        title: 'Refactor state provider architecture',
        description: 'Decouple view controllers and establish centralized Provider tree for real-time reactivity',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-302',
        projectName: 'Green Energy Dashboard',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 70,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-408',
        title: 'Integrate biometric local authentication',
        description: 'Implement LocalAuthentication on Android BiometricPrompt and iOS LocalAuthentication FaceID',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 55,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-409',
        title: 'Deploy Prometheus and Grafana alerts',
        description: 'Set up metrics scraping for PostgreSQL connection pools and p99 latency thresholds',
        domain: 'DevOps / Cloud',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-109',
        assignedToName: 'Rahul Verma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        progressPercent: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-410',
        title: 'Train sensor anomaly autoencoder model',
        description: 'Extract historical energy telemetry and train PyTorch autoencoder for voltage spike prediction',
        domain: 'AI / ML',
        team: 'Applied Intelligence Lab',
        assignedToId: 'EMP-106',
        assignedToName: 'Ananya Deshmukh',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-106',
        assignedByName: 'Ananya Deshmukh',
        projectId: 'PRJ-303',
        projectName: 'AI Analytics Platform',
        dueDate: DateTime.now().add(const Duration(days: 6)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 60,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-411',
        title: 'Draft campus hiring assessment rubrics',
        description: 'Compile technical interview grading rubric for Q3 engineering campus drive',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        progressPercent: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-412',
        title: 'Coordinate Q3 sales outreach webinar',
        description: 'Produce demonstration deck for CleanTech and solar energy enterprise prospects',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        progressPercent: 40,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-413',
        title: 'Reconcile Q3 enterprise client receivables',
        description: 'Verify Stripe and wire transfer settlement statements with bank accounts',
        domain: 'Finance / Accounts',
        team: 'Financial & Business Ops',
        assignedToId: 'EMP-115',
        assignedToName: 'Siddharth Roy',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-115',
        assignedByName: 'Siddharth Roy',
        dueDate: DateTime.now().add(const Duration(days: 6)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),

      // 6 To Do Tasks
      CompanyTask(
        id: 'TSK-414',
        title: 'Design dashboard UI',
        description: 'Produce Figma vector components for executive KPI cards and Tasks Donut Chart',
        domain: 'Frontend',
        team: 'Client Experience Engineering',
        assignedToId: 'INT-202',
        assignedToName: 'Bhavna Kulkarni',
        assigneeType: AssigneeType.intern,
        assignedById: 'EMP-110',
        assignedByName: 'Divya Iyer',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-415',
        title: 'Implement Locust load benchmarking',
        description: 'Script realistic user journeys to stress-test 10,000 concurrent requests against GraphQL gateway',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-416',
        title: 'Configure AWS WAF managed rules',
        description: 'Protect payment API endpoints against SQL injection, cross-site scripting and bot attacks',
        domain: 'Cybersecurity',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().add(const Duration(days: 8)),
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-417',
        title: 'Setup multi-region Kafka mirrors',
        description: 'Establish MirrorMaker 2 cluster between AWS Mumbai and Singapore for disaster recovery',
        domain: 'Data Engineering',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-107',
        assignedToName: 'Vikram Singh',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-107',
        assignedByName: 'Vikram Singh',
        projectId: 'PRJ-303',
        projectName: 'AI Analytics Platform',
        dueDate: DateTime.now().add(const Duration(days: 9)),
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-418',
        title: 'Create client onboarding playbook',
        description: 'Write step-by-step documentation for SaaS tenant setup and DNS verification',
        domain: 'Customer Support',
        team: 'Corporate Growth & Sales',
        assignedToId: 'EMP-116',
        assignedToName: 'Kavita Rao',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-116',
        assignedByName: 'Kavita Rao',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 10)),
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-419',
        title: 'Update employee handbook policies',
        description: 'Revise remote work security guidelines and intellectual property clauses',
        domain: 'Administration',
        team: 'Financial & Business Ops',
        assignedToId: 'EMP-114',
        assignedToName: 'Pooja Hegde',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-114',
        assignedByName: 'Pooja Hegde',
        dueDate: DateTime.now().add(const Duration(days: 12)),
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // 3 Needs Rework Tasks
      CompanyTask(
        id: 'TSK-420',
        title: 'Deliverable revision #1 - Lead detail dialog',
        description: 'Address missing responsive layout constraints on small viewport screens',
        domain: 'Frontend',
        team: 'Client Experience Engineering',
        assignedToId: 'INT-202',
        assignedToName: 'Bhavna Kulkarni',
        assigneeType: AssigneeType.intern,
        assignedById: 'EMP-104',
        assignedByName: 'Sneha V',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: TaskStatus.needsRework,
        priority: TaskPriority.medium,
        progressPercent: 60,
        ceoReviewNotes: 'Fix layout overflow and clipping on compact screens',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-421',
        title: 'Deliverable revision #2 - SQL index optimization',
        description: 'Index coverage failed benchmark on multi-tenant partition key scans',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-103',
        assignedToName: 'Karthik R',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        status: TaskStatus.needsRework,
        priority: TaskPriority.high,
        progressPercent: 75,
        ceoReviewNotes: 'Add composite indexes for tenant_id and created_at',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-422',
        title: 'Deliverable revision #3 - Mobile push notification handler',
        description: 'Silent background push notification fails on iOS 18 power-save mode',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-305',
        projectName: 'Fleet Logistics Mobile',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.needsRework,
        priority: TaskPriority.high,
        progressPercent: 65,
        ceoReviewNotes: 'Format APNs background payload to standard specification',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // 20 Completed Tasks
      CompanyTask(
        id: 'TSK-423',
        title: 'Implement CEO executive dashboard layout',
        description: 'Render responsive cards and high-contrast dark visual components',
        domain: 'Frontend',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      CompanyTask(
        id: 'TSK-424',
        title: 'Implement custom Tasks Donut Chart painter',
        description: 'Draw animated SVG/Canvas circular ring with center total counter',
        domain: 'Frontend',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-104',
        assignedToName: 'Sneha V',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      CompanyTask(
        id: 'TSK-425',
        title: 'Design dark navigation drawer matching mockups',
        description: 'Create drawer layout with CEO profile header and routing shortcuts',
        domain: 'UI/UX Engineering',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-110',
        assignedToName: 'Divya Iyer',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-110',
        assignedByName: 'Divya Iyer',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 4)),
        status: TaskStatus.approved,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 4)),
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      CompanyTask(
        id: 'TSK-426',
        title: 'Setup PostgreSQL 18 master configuration',
        description: 'Configure shared_buffers, work_mem and max_connections for workload',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().subtract(const Duration(days: 6)),
        status: TaskStatus.approved,
        priority: TaskPriority.urgent,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 6)),
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      CompanyTask(
        id: 'TSK-427',
        title: 'Implement password hashing with Argon2id',
        description: 'Replace legacy SHA-256 with Argon2id cryptographic salt and key stretching',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-103',
        assignedToName: 'Karthik R',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 6)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 6)),
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
      ),
      CompanyTask(
        id: 'TSK-428',
        title: 'Build unified Filter Bottom Sheet modal',
        description: 'Create domain, role, team and status filter controls with reset action',
        domain: 'Frontend',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 4)),
        status: TaskStatus.approved,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 4)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CompanyTask(
        id: 'TSK-429',
        title: 'Configure iOS Runner bundle identifiers',
        description: 'Update CFBundleIdentifier and FaceID privacy descriptions in Info.plist',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: TaskStatus.approved,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      CompanyTask(
        id: 'TSK-430',
        title: 'Configure Android Gradle 8.13 dependencies',
        description: 'Update AndroidManifest.xml permissions and configure minSdk 24',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: TaskStatus.approved,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      CompanyTask(
        id: 'TSK-431',
        title: 'Deploy Redis cache cluster on AWS ElastiCache',
        description: 'Setup 3-node Redis cluster with automatic failover and read replicas',
        domain: 'DevOps / Cloud',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-109',
        assignedToName: 'Rahul Verma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().subtract(const Duration(days: 7)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      CompanyTask(
        id: 'TSK-432',
        title: 'Conduct intern Batch Apr-A orientation',
        description: 'Host onboarding session covering code standards, Git branches and PR reviews',
        domain: 'HR / Recruitment',
        team: 'People & Workplace',
        assignedToId: 'EMP-111',
        assignedToName: 'Meera Joshi',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-111',
        assignedByName: 'Meera Joshi',
        dueDate: DateTime.now().subtract(const Duration(days: 9)),
        status: TaskStatus.approved,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 9)),
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      CompanyTask(
        id: 'TSK-433',
        title: 'Finalize EcoTrack sensor protocol specs',
        description: 'Document Bluetooth Low Energy GATT characteristics for solar telemetry',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        dueDate: DateTime.now().subtract(const Duration(days: 8)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 8)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      CompanyTask(
        id: 'TSK-434',
        title: 'Verify payment gateway webhooks idempotency',
        description: 'Implement database unique constraint and Redis lock for order IDs',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().subtract(const Duration(days: 7)),
        status: TaskStatus.approved,
        priority: TaskPriority.urgent,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 13)),
      ),
      CompanyTask(
        id: 'TSK-435',
        title: 'Automate CI test execution in GitHub Actions',
        description: 'Create parallel test matrices for unit, widget and integration tests',
        domain: 'QA / Testing',
        team: 'Quality & Reliability',
        assignedToId: 'EMP-108',
        assignedToName: 'Neha Patel',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-108',
        assignedByName: 'Neha Patel',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 6)),
        status: TaskStatus.approved,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 6)),
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
      ),
      CompanyTask(
        id: 'TSK-436',
        title: 'Publish Q3 company press release',
        description: 'Highlight Digital Inertia AI telemetry suite expansion and customer wins',
        domain: 'Content / Communications',
        team: 'Corporate Growth & Sales',
        assignedToId: 'EMP-117',
        assignedToName: 'Aditya Sen',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-117',
        assignedByName: 'Aditya Sen',
        dueDate: DateTime.now().subtract(const Duration(days: 8)),
        status: TaskStatus.approved,
        priority: TaskPriority.low,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 8)),
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      CompanyTask(
        id: 'TSK-437',
        title: 'Prepare GreenTech enterprise quotation',
        description: 'Assemble bill of materials and tiered cloud licensing proposal',
        domain: 'Sales / Business Development',
        team: 'Corporate Growth & Sales',
        assignedToId: 'EMP-112',
        assignedToName: 'Rajesh Kumar',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-112',
        assignedByName: 'Rajesh Kumar',
        dueDate: DateTime.now().subtract(const Duration(days: 6)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 6)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      CompanyTask(
        id: 'TSK-438',
        title: 'Audit AWS VPC security group ingress rules',
        description: 'Close unnecessary inbound ports and restrict SSH to Bastion VPN tunnel',
        domain: 'Cybersecurity',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 7)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 13)),
      ),
      CompanyTask(
        id: 'TSK-439',
        title: 'Build lead pipeline Kanban card components',
        description: 'Design responsive status pill badges and quick contact action buttons',
        domain: 'Frontend',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-104',
        assignedToName: 'Sneha V',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 4)),
        status: TaskStatus.approved,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 4)),
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      CompanyTask(
        id: 'TSK-440',
        title: 'Review Fleet Logistics GPS ping frequency',
        description: 'Optimize location telemetry throttling to conserve 35% battery consumption',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-305',
        projectName: 'Fleet Logistics Mobile',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: TaskStatus.approved,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      CompanyTask(
        id: 'TSK-441',
        title: 'Setup daily automated PostgreSQL backups',
        description: 'Configure pg_dump scheduled snapshots to S3 bucket with 30-day lifecycle rule',
        domain: 'DevOps / Cloud',
        team: 'Core Platform Engineering',
        assignedToId: 'EMP-109',
        assignedToName: 'Rahul Verma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 6)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 6)),
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      CompanyTask(
        id: 'TSK-442',
        title: 'Conduct quarterly financial forecast review',
        description: 'Review burn rate, recurring ARR and contractor disbursements with executive board',
        domain: 'Finance / Accounts',
        team: 'Financial & Business Ops',
        assignedToId: 'EMP-115',
        assignedToName: 'Siddharth Roy',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-115',
        assignedByName: 'Siddharth Roy',
        dueDate: DateTime.now().subtract(const Duration(days: 7)),
        status: TaskStatus.approved,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    // 14 Active Leads (matching PostgreSQL 02_seed.sql: 4 with missed follow-up triggering ALT-LD)
    _leads = [
      Lead(
        id: 'LED-501',
        companyName: 'GreenTech Solutions',
        clientName: 'Vikramaditya Rao',
        domain: 'IT Consulting',
        email: 'vikram@greentech.in',
        phone: '+91 98450 12001',
        dealValue: 35000.0,
        status: LeadStatus.newLead,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Inbound Enterprise Lead',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 2)),
        daysSinceLastContact: 1,
        notes: 'Interested in building unified carbon offset tracking software for solar farms',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Lead(
        id: 'LED-502',
        companyName: 'InnovortX',
        clientName: 'Sarah Al-Mansoor',
        domain: 'Mobile App',
        email: 'sarah.m@innovortx.ae',
        phone: '+971 50 123 4567',
        dealValue: 48000.0,
        status: LeadStatus.contacted,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Dubai Tech Summit Inbound',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 1)),
        daysSinceLastContact: 2,
        notes: 'Requires cross-platform Flutter consumer app with payment gateway integration',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Lead(
        id: 'LED-503',
        companyName: 'Skyline Infra',
        clientName: 'Ramesh Namboodiri',
        domain: 'Web Platform',
        email: 'ramesh@skylineinfra.com',
        phone: '+91 98200 45003',
        dealValue: 62000.0,
        status: LeadStatus.proposal,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Direct Executive Outreach',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 4)),
        daysSinceLastContact: 1,
        notes: 'Smart city IoT asset monitoring portal. Proposal submitted on Oct 4.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Lead(
        id: 'LED-504',
        companyName: 'SolarEase',
        clientName: 'Kavitha Balasubramanian',
        domain: 'Solar Solutions',
        email: 'kavitha@solarease.com',
        phone: '+91 98410 78004',
        dealValue: 28000.0,
        status: LeadStatus.qualified,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Industry Conference Referral',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 6)),
        daysSinceLastContact: 2,
        notes: 'B2B distributor portal for rooftop solar installations and inverter telemetry',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      // 4 Leads with missed follow up (triggers ALT-LD: 4 leads need follow-up)
      Lead(
        id: 'LED-505',
        companyName: 'CyberShield Corp',
        clientName: 'Marcus Vance',
        domain: 'Cloud Services',
        email: 'm.vance@cybershield.us',
        phone: '+1 415 889 0105',
        dealValue: 85000.0,
        status: LeadStatus.contacted,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'AWS Partner Network',
        nextFollowUpDate: DateTime.now().subtract(const Duration(days: 1)), // Missed!
        daysSinceLastContact: 4,
        notes: 'Missed follow-up: Follow-up call requested on Cloud Security Posture Management engine',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Lead(
        id: 'LED-506',
        companyName: 'Nexus Health Systems',
        clientName: 'Dr. Arvind Swaminathan',
        domain: 'Cloud Services',
        email: 'arvind@nexushealth.org',
        phone: '+91 98110 56006',
        dealValue: 95000.0,
        status: LeadStatus.contacted,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Direct Executive Outreach',
        nextFollowUpDate: DateTime.now().subtract(const Duration(days: 1)), // Missed!
        daysSinceLastContact: 3,
        notes: 'Missed follow-up: HIPAA-compliant patient diagnostics archive and HL7 FHIR sync API',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Lead(
        id: 'LED-507',
        companyName: 'Quantra Analytics',
        clientName: 'Dr. Elena Rostova',
        domain: 'Web Platform',
        email: 'elena@quantra.ch',
        phone: '+41 22 767 0107',
        dealValue: 55000.0,
        status: LeadStatus.proposal,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Webinar Attendee Lead',
        nextFollowUpDate: DateTime.now().subtract(const Duration(days: 2)), // Missed!
        daysSinceLastContact: 5,
        notes: 'Missed follow-up: Quantitative risk analytics dashboard. Revised timeline required.',
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      Lead(
        id: 'LED-508',
        companyName: 'Apex Cold-Chain Logistics',
        clientName: 'Harpreet Singh Gill',
        domain: 'Mobile App',
        email: 'harpreet@apexlogistics.in',
        phone: '+91 98720 33008',
        dealValue: 42000.0,
        status: LeadStatus.newLead,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Cold Outreach Campaign',
        nextFollowUpDate: DateTime.now().subtract(const Duration(days: 1)), // Missed!
        daysSinceLastContact: 4,
        notes: 'Missed follow-up: Fleet temperature monitoring sensor app for refrigerated pharma trucks',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // 6 Additional Active Prospects (total 14 leads)
      Lead(
        id: 'LED-509',
        companyName: 'Aura Retail Tech',
        clientName: 'Natasha Sen',
        domain: 'Mobile App',
        email: 'natasha@auraretail.com',
        phone: '+91 98300 22009',
        dealValue: 38000.0,
        status: LeadStatus.newLead,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Shopify Plus Partner Directory',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 8)),
        daysSinceLastContact: 1,
        notes: 'Omnichannel inventory sync and POS companion mobile app for lifestyle stores',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Lead(
        id: 'LED-510',
        companyName: 'BlueWave Maritime',
        clientName: 'Capt. Alistair Finch',
        domain: 'IT Consulting',
        email: 'finch@bluewave.uk',
        phone: '+44 20 7946 0110',
        dealValue: 72000.0,
        status: LeadStatus.proposal,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'London Shipping Summit',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 7)),
        daysSinceLastContact: 2,
        notes: 'Vessel tracking, crew rotation and bunkering fuel cost optimization platform',
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
      ),
      Lead(
        id: 'LED-511',
        companyName: 'Vertex Robotics',
        clientName: 'Chen Wei',
        domain: 'AI / ML',
        email: 'chen.wei@vertexrobotics.sg',
        phone: '+65 6789 0111',
        dealValue: 88000.0,
        status: LeadStatus.qualified,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'RoboAsia Exhibition',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 9)),
        daysSinceLastContact: 2,
        notes: 'Computer vision automated inspection engine for surface defect classification',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Lead(
        id: 'LED-512',
        companyName: 'ZenMatrix AI',
        clientName: 'Amitabh Ghosh',
        domain: 'AI / ML',
        email: 'amitabh@zenmatrix.ai',
        phone: '+91 98210 99012',
        dealValue: 64000.0,
        status: LeadStatus.qualified,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'AngelList Syndicate Lead',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 10)),
        daysSinceLastContact: 1,
        notes: 'LLM semantic search engine and RAG pipeline for internal legal document analysis',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Lead(
        id: 'LED-513',
        companyName: 'CloudSprint Networks',
        clientName: 'David K. O\'Connor',
        domain: 'Cloud Services',
        email: 'david@cloudsprint.io',
        phone: '+1 206 555 0113',
        dealValue: 50000.0,
        status: LeadStatus.contacted,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Kubernetes Community Day',
        nextFollowUpDate: DateTime.now().add(const Duration(days: 5)),
        daysSinceLastContact: 2,
        notes: 'Multi-tenant Kubernetes ingress billing and bandwidth utilization reporter',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Lead(
        id: 'LED-514',
        companyName: 'TerraWatt CleanTech',
        clientName: 'Suresh Poddar',
        domain: 'Solar Solutions',
        email: 'suresh@terrawatt.co.in',
        phone: '+91 98311 44014',
        dealValue: 110000.0,
        status: LeadStatus.won,
        assignedEmployeeId: 'EMP-112',
        assignedEmployeeName: 'Rajesh Kumar',
        source: 'Direct Executive Outreach',
        nextFollowUpDate: DateTime.now().subtract(const Duration(days: 10)),
        daysSinceLastContact: 10,
        notes: 'Won enterprise contract: National solar farm supervisory control and telemetry gateway',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    // 6 Active Projects (matching PostgreSQL 02_seed.sql: PRJ-304 triggers ALT-PRJ delayed alert)
    _projects = [
      Project(
        id: 'PRJ-301',
        name: 'EcoTrack App',
        clientName: 'CleanTech Innovations',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        description: 'Cross-platform Flutter IoT and sustainability telemetry tracker.',
        budget: 45000.0,
        ownerEmployeeId: 'EMP-105',
        ownerEmployeeName: 'Rohan Mehta',
        teamMemberNames: ['Rohan Mehta', 'Sneha V', 'Aarav Sharma (Intern)'],
        status: ProjectStatus.inProgress,
        progress: 0.75, // 75%
        plannedProgress: 0.75,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        deadline: DateTime.now().add(const Duration(days: 15)),
      ),
      Project(
        id: 'PRJ-302',
        name: 'Green Energy Dashboard',
        clientName: 'Enel Horizon Grid',
        domain: 'Web Platform',
        team: 'Client Experience Engineering',
        description: 'Solar microgrid web analytics with live WebSockets.',
        budget: 60000.0,
        ownerEmployeeId: 'EMP-101',
        ownerEmployeeName: 'Arjun Sharma',
        teamMemberNames: ['Arjun Sharma', 'Sneha V', 'Bhavna Kulkarni (Intern)'],
        status: ProjectStatus.inProgress,
        progress: 0.40, // 40%
        plannedProgress: 0.45,
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        deadline: DateTime.now().add(const Duration(days: 25)),
      ),
      Project(
        id: 'PRJ-303',
        name: 'AI Analytics Platform',
        clientName: 'Quantra BioSciences',
        domain: 'AI / ML',
        team: 'Applied Intelligence Lab',
        description: 'Predictive churn and retention model pipeline with PyTorch.',
        budget: 85000.0,
        ownerEmployeeId: 'EMP-106',
        ownerEmployeeName: 'Ananya Deshmukh',
        teamMemberNames: ['Ananya Deshmukh', 'Vikram Singh', 'Eeshan Guha (Intern)'],
        status: ProjectStatus.inProgress,
        progress: 0.90, // 90%
        plannedProgress: 0.90,
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        deadline: DateTime.now().add(const Duration(days: 5)),
      ),
      Project(
        id: 'PRJ-304',
        name: 'FinTech Payment Gateway',
        clientName: 'PulsePay Global',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        description: 'PCI-DSS certified microservices payment routing and webhook settlement.',
        budget: 120000.0,
        ownerEmployeeId: 'EMP-102',
        ownerEmployeeName: 'Priya Nair',
        teamMemberNames: ['Priya Nair', 'Karthik R', 'Rahul Verma'],
        status: ProjectStatus.inProgress,
        progress: 0.15, // 15%
        plannedProgress: 0.35, // 35% -> Behind by 20% (>= 15% threshold) triggers "1 project delayed"
        activeBlockers: ['PCI-DSS hardware security module HSM integration delay from bank sponsor'],
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        deadline: DateTime.now().add(const Duration(days: 60)),
      ),
      Project(
        id: 'PRJ-305',
        name: 'Fleet Logistics Mobile',
        clientName: 'SwiftLogistics Express',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        description: 'Driver dispatching and proof-of-delivery GPS tracking app.',
        budget: 50000.0,
        ownerEmployeeId: 'EMP-105',
        ownerEmployeeName: 'Rohan Mehta',
        teamMemberNames: ['Rohan Mehta', 'Neha Patel', 'Ritika Kaul (Intern)'],
        status: ProjectStatus.inProgress,
        progress: 0.30,
        plannedProgress: 0.30,
        startDate: DateTime.now().subtract(const Duration(days: 25)),
        deadline: DateTime.now().add(const Duration(days: 35)),
      ),
      Project(
        id: 'PRJ-306',
        name: 'Digital Inertia ERP Core',
        clientName: 'Digital Inertia Holdings',
        domain: 'Web Platform',
        team: 'Core Platform Engineering',
        description: 'Executive resource planning & multi-domain enterprise operations hub.',
        budget: 75000.0,
        ownerEmployeeId: 'EMP-103',
        ownerEmployeeName: 'Karthik R',
        teamMemberNames: ['Karthik R', 'Arjun Sharma', 'Divya Iyer'],
        status: ProjectStatus.inProgress,
        progress: 0.85,
        plannedProgress: 0.85,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        deadline: DateTime.now().add(const Duration(days: 10)),
      ),
    ];

    _auditLogs = [
      AuditLog(
        id: 'LOG-01',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        actorName: 'Laven Lokesh',
        actorRole: 'CEO / Admin',
        action: 'Threshold Check',
        module: 'System',
        details: 'Evaluated system thresholds: 5 overdue tasks, 3 inactive interns, 1 delayed project.',
      ),
    ];
  }
}
