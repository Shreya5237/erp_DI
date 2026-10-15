import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/hierarchy.dart';
import '../models/employee.dart';
import '../models/intern.dart';
import '../models/task.dart';
import '../models/lead.dart';
import '../models/project.dart';
import '../models/audit_log.dart';
import '../models/department.dart';
import '../models/meeting.dart';
import '../models/approval.dart';
import '../models/sales_call.dart';
import '../models/finance_models.dart';
import '../models/hr_models.dart';
import '../services/api_service.dart';

/// Central State Provider for Digital Inertia CEO ERP
/// Implements configurable roles hierarchy, dynamic threshold alerts,
/// and comprehensive filtering across People, Projects, Tasks, and Leads.
class ErpProvider extends ChangeNotifier {
  // Live Backend API Service & Status
  final ApiService _apiService = ApiService();
  bool _isLiveMode = false;
  bool _forceOfflineMode = false;
  bool get forceOfflineMode => _forceOfflineMode;
  void setForceOfflineMode(bool val) {
    _forceOfflineMode = val;
    notifyListeners();
  }
  bool _isAuthenticating = false;
  bool _isLoadingLeads = false;
  String? _authError;
  String? _leadsError;

  // Unique ID Counter to guarantee collision-free IDs across fast operations
  static int _idCounter = 0;

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
  List<CompanyApprovalRequest> _approvalRequests = [];
  List<Meeting> _meetings = [];
  List<SalesCall> _salesCalls = [];
  List<ProjectBudget> _projectBudgets = [];
  List<ResourceRequest> _resourceRequests = [];
  List<EmployeeLeaveRequest> _leaveRequests = [];
  List<StaffingRequest> _staffingRequests = [];
  List<CustomerChangeRequest> _customerChangeRequests = [];
  HrMonthlyTargets _hrMonthlyTargets = const HrMonthlyTargets();

  // Employee Dashboard Target & Live Alert Notifications
  int _employeeTargetGoalPercent = 92;
  int get employeeTargetGoalPercent => _employeeTargetGoalPercent;
  void setEmployeeTargetGoal(int percent) {
    _employeeTargetGoalPercent = percent;
    notifyListeners();
  }

  final List<Map<String, dynamic>> _employeeAlerts = [
    {
      'id': 'ALT-01',
      'title': 'New task assigned by Rajesh Kumar',
      'subtitle': 'Client Pitch Deck Finalization (DI Rebrand & Strategy)',
      'time': '10m ago',
      'type': 'task',
      'lead': 'Rajesh Kumar',
      'isRead': false,
      'isUrgent': true,
    },
    {
      'id': 'ALT-02',
      'title': 'Strategy review meeting scheduled',
      'subtitle': 'Q4 Strategic Alignment with Rajesh K. at 11:00 AM',
      'time': '45m ago',
      'type': 'meeting',
      'lead': 'Rajesh Kumar',
      'isRead': false,
      'isUrgent': false,
    },
    {
      'id': 'ALT-03',
      'title': 'Approaching deadline reminder',
      'subtitle': 'Oct 18 • Rebrand (5 Days Remaining)',
      'time': '2h ago',
      'type': 'deadline',
      'lead': 'System',
      'isRead': false,
      'isUrgent': true,
    },
    {
      'id': 'ALT-04',
      'title': 'Code review approved by Priya Nair',
      'subtitle': 'PR #104 merged into master for Sprint 4',
      'time': 'Yesterday',
      'type': 'update',
      'lead': 'Priya Nair',
      'isRead': true,
      'isUrgent': false,
    },
  ];

  final Set<String> _readAlertIds = {};

  List<Map<String, dynamic>> get employeeAlerts => List.unmodifiable(_employeeAlerts);

  List<Map<String, dynamic>> get allEmployeeNotifications {
    final List<Map<String, dynamic>> list = [];

    // 1. Live Lead & Manager alerts from _employeeAlerts
    for (final a in _employeeAlerts) {
      final id = a['id'] as String;
      final isRead = a['isRead'] == true || _readAlertIds.contains(id);
      list.add({
        'id': id,
        'type': a['type'] ?? 'lead',
        'title': a['title'] ?? 'Alert',
        'subtitle': a['subtitle'] ?? '',
        'time': a['time'] ?? 'Recent',
        'lead': a['lead'] ?? 'Team Lead',
        'isUrgent': a['isUrgent'] == true,
        'isRead': isRead,
        'icon': a['type'] == 'meeting'
            ? Icons.videocam_rounded
            : (a['type'] == 'submission'
                ? Icons.task_alt_rounded
                : (a['type'] == 'deadline' ? Icons.alarm_rounded : Icons.assignment_ind_rounded)),
        'color': a['type'] == 'submission'
            ? const Color(0xFF10B981)
            : (a['isUrgent'] == true ? const Color(0xFFE11D48) : const Color(0xFF212529)),
      });
    }

    // 2. Upcoming meeting reminders
    for (final m in myEmployeeMeetings) {
      final id = 'mtg-${m.id}';
      final isRead = _readAlertIds.contains(id);
      list.add({
        'id': id,
        'type': 'meeting',
        'title': 'Meeting in 15 mins: ${m.title}',
        'time': '${m.startTime} • Today',
        'subtitle': 'Organizer: ${m.organizerName} • ${m.locationOrLink}',
        'lead': m.organizerName,
        'meeting': m,
        'isUrgent': true,
        'isRead': isRead,
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFF0284C7),
      });
    }

    // 3. Overdue and due today task alerts
    final pendingDeadlines = myEmployeeTasks.where((t) => !t.isCompleted && (t.isOverdue || t.isDueToday)).toList();
    for (final t in pendingDeadlines) {
      final id = 'tsk-${t.id}';
      final isRead = _readAlertIds.contains(id);
      list.add({
        'id': id,
        'type': 'deadline',
        'title': t.isOverdue ? 'Overdue Alert: ${t.title}' : 'Due Today: ${t.title}',
        'time': t.deadlineCountdownText,
        'subtitle': 'Assigned by ${t.assignedByName} • Project: ${t.projectName ?? "Corporate Project"}',
        'lead': t.assignedByName,
        'isUrgent': true,
        'isRead': isRead,
        'icon': Icons.alarm_rounded,
        'color': const Color(0xFFE11D48),
      });
    }

    return list;
  }

  int get unreadEmployeeAlertsCount => allEmployeeNotifications.where((a) => a['isRead'] == false).length;

  void markAllAlertsAsRead() {
    for (var a in _employeeAlerts) {
      a['isRead'] = true;
    }
    for (var n in allEmployeeNotifications) {
      _readAlertIds.add(n['id'] as String);
    }
    notifyListeners();
  }

  void markAlertAsRead(String id) {
    _readAlertIds.add(id);
    final idx = _employeeAlerts.indexWhere((a) => a['id'] == id);
    if (idx != -1) {
      _employeeAlerts[idx]['isRead'] = true;
    }
    notifyListeners();
  }

  void clearAlerts() {
    _employeeAlerts.clear();
    for (var n in allEmployeeNotifications) {
      _readAlertIds.add(n['id'] as String);
    }
    notifyListeners();
  }

  void dispatchTaskCompletedAlert(CompanyTask task) {
    // 1. Mark task completed
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(
        status: TaskStatus.approved,
        progressPercent: 100,
        completedAt: DateTime.now(),
      );
    }
    // 2. Dispatch real-time alert to Team Lead / Manager
    _employeeAlerts.insert(0, {
      'id': 'ALT-${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Task Delivered to ${task.assignedByName}',
      'subtitle': '"${task.title}" completed by $_currentUserName. Real-time alert dispatched to lead.',
      'time': 'Just now',
      'type': 'submission',
      'lead': task.assignedByName,
      'isRead': false,
      'isUrgent': false,
    });
    _addAuditLog(
      action: 'Task Completed & Dispatched',
      module: 'Tasks',
      details: '${task.title} completed by $_currentUserName and alert dispatched to lead ${task.assignedByName}',
    );
    notifyListeners();
  }

  // Sales targets & KPIs (PRD Section 4.2)
  final int _weeklyContactTarget = 50;
  int _contactsCompletedThisWeek = 38;
  int _pendingCallsToday = 6;

  // Youth employment mission (PRD Section 1)
  final int _youthEmploymentGoal = 1000;
  int _youthEmploymentPlaced = 542;

  // Filter States
  String _searchQuery = '';
  String _employeeSearchQuery = '';
  String _internSearchQuery = '';
  String _taskSearchQuery = '';
  String _leadSearchQuery = '';
  String _projectSearchQuery = '';

  RoleCategory? _employeeCategoryFilter; // null = All
  String? _employeeRoleFilter; // null = All
  String? _employeeDepartmentFilter; // null = All Departments
  String? _employeeTeamFilter;
  bool? _employeeActiveFilter;

  RoleCategory? _internCategoryFilter; // null = All
  String? _internDomainFilter;
  String? _internBatchFilter;
  String? _internMentorFilter;
  String _internTaskScope = 'All Tasks'; // 'My Tasks', 'Team Tasks', 'All Tasks'

  String _taskScopeFilter = 'All'; // 'All', 'My Tasks', 'Projects • Domain'
  String _taskStatusFilter = 'Ongoing & Overdue'; // 'Ongoing & Overdue', 'Ongoing', 'Overdue', 'Upcoming', 'Completed', 'All'
  String? _taskDepartmentFilter; // null = All Departments

  String _leadStageFilter = 'All'; // 'All', 'New', 'Contacted', 'Proposal', 'Qualified', 'Won'
  String? _leadDomainFilter; // null = All Domains
  String _projectStatusFilter = 'All'; // 'All', 'Planning', 'In Progress', 'On Hold', 'Completed'
  String? _projectDomainFilter; // null = All Domains

  ErpProvider() {
    _initRoles();
    _initSeedData();
  }

  // Getters
  // Live Backend API Status Getters
  ApiService get apiService => _apiService;
  bool get isLiveMode => _isLiveMode;
  bool get isAuthenticating => _isAuthenticating;
  bool get isLoadingLeads => _isLoadingLeads;
  String? get authError => _authError;
  String? get leadsError => _leadsError;

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
  List<CompanyApprovalRequest> get allApprovalRequests => List.unmodifiable(_approvalRequests);
  List<CompanyApprovalRequest> get pendingApprovals =>
      _approvalRequests.where((a) => a.isAwaitingExecutiveAction).toList();
  List<Meeting> get allMeetings => List.unmodifiable(_meetings);
  List<Meeting> get todayMeetings => _meetings.where((m) => m.isToday).toList();

  // Sales targets & KPIs (PRD Section 4.2 & Sales Mobile App)
  int get weeklyContactTarget => _weeklyContactTarget;
  int get contactsCompletedThisWeek => _contactsCompletedThisWeek;
  int get pendingCallsToday => _pendingCallsToday;
  int get overdueFollowUpsCount => _salesCalls.where((c) => c.isFollowUpOverdue).length;
  int get followUpsDueTodayCount => _salesCalls.where((c) => c.isFollowUpToday).length;
  double get totalPipelineValue => _leads
      .where((l) => l.status != LeadStatus.lost)
      .fold(0.0, (sum, l) => sum + l.dealValue);
  int get dealsWonCount => _leads.where((l) => l.status == LeadStatus.won).length;
  int get dealsLostCount => _leads.where((l) => l.status == LeadStatus.lost).length;

  // Sales Mobile App Dedicated Getters
  List<SalesCall> get allSalesCalls => List.unmodifiable(_salesCalls);
  List<SalesCall> get todaySalesCalls => _salesCalls.where((c) => c.isToday).toList();
  List<SalesCall> get completedSalesCallsToday =>
      _salesCalls.where((c) => c.isToday && c.isCompleted).toList();
  int get dailyColdCallTarget => 20;
  int get callsCompletedTodayCount =>
      _salesCalls.where((c) => c.isToday && c.isCompleted).length;
  int get pendingColdCallsTodayCount {
    final pending = dailyColdCallTarget - callsCompletedTodayCount;
    return pending < 0 ? 0 : pending;
  }
  double get monthlySalesTarget => 5000000.0; // ₹50 Lakhs
  double get monthlySalesAchieved => 3850000.0; // ₹38.5 Lakhs
  double get monthlySalesRemaining => (monthlySalesTarget - monthlySalesAchieved).clamp(0.0, monthlySalesTarget);
  double get monthlySalesAchievedRatio => (monthlySalesAchieved / monthlySalesTarget).clamp(0.0, 1.0);
  List<int> get weeklyCallTotals => const [38, 52, 45, 42];
  int get highestPerformingWeek => 2;
  int get highestPerformingWeekCalls => 52;
  int get monthlyCallsTotal => 177;
  int get dealsClosedCount => 8;
  double get callConversionRate => 4.52; // (8 closed / 177 calls = ~4.5%)
  double get followUpCompletionRate => 0.92; // 92% on-time completion

  List<SalesCall> get followUpsDueToday =>
      _salesCalls.where((c) => c.isFollowUpToday).toList();
  List<SalesCall> get overdueFollowUps =>
      _salesCalls.where((c) => c.isFollowUpOverdue).toList();
  List<SalesCall> get upcomingFollowUpsSevenDays {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    return _salesCalls.where((c) {
      if (c.nextFollowUpDate == null) return false;
      return c.nextFollowUpDate!.isAfter(DateTime(now.year, now.month, now.day)) &&
          c.nextFollowUpDate!.isBefore(sevenDaysLater);
    }).toList();
  }

  List<Meeting> get salesMeetings => _meetings.where((m) {
    return m.participantNames.any((p) => p.contains('Rajesh') || p.contains('Sales')) ||
        m.organizerName.contains('Rajesh') ||
        m.departmentOrProject.contains('Sales') ||
        m.departmentOrProject == 'All Departments';
  }).toList();

  List<Lead> get mySalesLeads => _leads;

  // Finance Mobile App Dedicated Getters
  List<ProjectBudget> get allProjectBudgets => List.unmodifiable(_projectBudgets);
  double get totalAllocatedBudget => _projectBudgets.fold(0.0, (sum, b) => sum + b.approvedBudget);
  double get totalSpentBudget => _projectBudgets.fold(0.0, (sum, b) => sum + b.spentAmount);
  double get totalRemainingBudget => totalAllocatedBudget - totalSpentBudget;
  double get overallBudgetUtilization => totalAllocatedBudget > 0 ? (totalSpentBudget / totalAllocatedBudget) : 0.0;
  List<ProjectBudget> get overbudgetProjects => _projectBudgets.where((b) => b.isExceeded).toList();
  List<ProjectBudget> get thresholdAlertProjects => _projectBudgets.where((b) => b.isApproachingLimit).toList();

  List<ResourceRequest> get allResourceRequests => List.unmodifiable(_resourceRequests);
  List<ResourceRequest> get pendingResourceRequests => _resourceRequests.where((r) => r.isPending).toList();
  List<ResourceRequest> get approvedResourceRequests => _resourceRequests.where((r) => r.isApproved).toList();
  List<ResourceRequest> get rejectedResourceRequests => _resourceRequests.where((r) => r.isRejected).toList();

  List<Lead> get financeReviewLeads => _leads.where((l) =>
      l.status == LeadStatus.feasibilityAssessment ||
      l.internalApprovalStage.contains('HR & Finance') ||
      l.status == LeadStatus.proposalPrepared ||
      l.status == LeadStatus.internalApproval).toList();

  List<CompanyTask> get financeTasks => _tasks.where((t) =>
      t.assignedToId == 'EMP-115' ||
      t.assignedToName.contains('Siddharth') ||
      t.domain.contains('Finance') ||
      t.team.contains('Financial')).toList();

  List<Meeting> get financeMeetings => _meetings.where((m) =>
      m.participantNames.any((p) => p.contains('Siddharth') || p.contains('Finance')) ||
      m.organizerName.contains('Siddharth') ||
      m.departmentOrProject.contains('Finance') ||
      m.departmentOrProject == 'All Departments').toList();

  // HR Mobile App Dedicated Getters
  List<EmployeeLeaveRequest> get allLeaveRequests => List.unmodifiable(_leaveRequests);
  List<EmployeeLeaveRequest> get pendingLeaveRequests => _leaveRequests.where((l) => l.isPending).toList();
  List<EmployeeLeaveRequest> get approvedLeaveRequests => _leaveRequests.where((l) => l.isApproved).toList();
  List<EmployeeLeaveRequest> get rejectedLeaveRequests => _leaveRequests.where((l) => l.isRejected).toList();

  List<StaffingRequest> get allStaffingRequests => List.unmodifiable(_staffingRequests);
  List<StaffingRequest> get pendingStaffingRequests => _staffingRequests.where((s) => s.isPending).toList();
  List<StaffingRequest> get inProgressStaffingRequests => _staffingRequests.where((s) => s.status == StaffingRequestStatus.inProgress).toList();
  List<StaffingRequest> get fulfilledStaffingRequests => _staffingRequests.where((s) => s.isFulfilled).toList();

  List<CustomerChangeRequest> get allCustomerChangeRequests => List.unmodifiable(_customerChangeRequests);
  List<CustomerChangeRequest> get pendingCustomerChangeRequests => _customerChangeRequests.where((c) => c.status == CustomerRequestStatus.submitted || c.status == CustomerRequestStatus.inReview || c.isEscalated).toList();

  HrMonthlyTargets get hrMonthlyTargets => _hrMonthlyTargets;
  int get hrLeaveReviewedThisMonthCount => 18;
  int get hrStaffingFulfilledThisMonthCount => 7;
  int get hrTraineeReviewsCompletedThisMonthCount => 8;
  int get hrCustomerFollowUpsCompletedThisMonthCount => 12;

  List<Intern> get traineesNeedingAttention => _interns.where((i) =>
      i.missedUpdatesDays > 0 ||
      i.status == InternStatus.underEvaluation ||
      i.status == InternStatus.needsImprovement).toList();

  List<Intern> get newJoiners => _interns.where((i) =>
      i.status == InternStatus.selected ||
      i.status == InternStatus.internshipActive ||
      i.status == InternStatus.applied).toList();

  List<Project> get projectsNeedingAttention => _projects.where((p) =>
      p.status == ProjectStatus.inProgress && (p.hasResourceConflict || p.activeBlockers.isNotEmpty || p.progress < 0.6)).toList();

  List<CompanyTask> get hrTasks => _tasks.where((t) =>
      t.assignedToId == 'EMP-111' ||
      t.assignedToName.contains('Meera') ||
      t.department.contains('HR') ||
      t.domain.contains('HR') ||
      t.team.contains('People')).toList();

  List<Meeting> get hrMeetings => _meetings.where((m) =>
      m.participantNames.any((p) => p.contains('Meera') || p.contains('HR')) ||
      m.organizerName.contains('Meera') ||
      m.departmentOrProject.contains('HR') ||
      m.departmentOrProject == 'All Departments').toList();

  // Youth employment mission & Friday batch metrics (PRD Section 1 & 8)
  int get youthEmploymentGoal => _youthEmploymentGoal;
  int get youthEmploymentPlaced => _youthEmploymentPlaced;
  int get activeInternsCount => _interns.where((i) => i.isActive).length;
  int get internsAwaitingEvaluationCount =>
      _interns.where((i) => i.status == InternStatus.underEvaluation || i.status == InternStatus.internshipActive).length;
  int get internsRecommendedForHireCount =>
      _interns.where((i) => i.isRecommendedForHire).length;
  int get internsConvertedCount =>
      _interns.where((i) => i.status == InternStatus.hired || i.finalDecision == InternFinalDecision.hired).length;

  // Approved 5 Top-Level Departments (PRD & System Requirements)
  List<String> get topLevelDepartmentNames => const [
    'Finance',
    'Sales',
    'Marketing',
    'HR',
    'Technical',
  ];

  Map<String, List<String>> get departmentSubcategories => const {
    'Sales & Marketing': ['Enterprise Sales', 'Business Development', 'Client Acquisition', 'Account Management', 'B2B Partnerships'],
    'Digital Marketing': ['SEO & SEM', 'Performance Marketing', 'Social Media Marketing', 'Content Strategy', 'Brand & Copywriting'],
    'Technical': ['Frontend', 'Backend', 'Full-stack', 'Mobile Development', 'UI/UX', 'QA / Testing', 'DevOps / Cloud', 'AI / ML', 'Data Engineering', 'Cybersecurity'],
    'HR': ['Talent Acquisition', 'Campus Recruitment', 'Onboarding', 'Leave Management', 'Performance Management', 'Employee Relations'],
    'Finance': ['Financial Planning', 'Accounts & Ledger', 'Invoicing & Billing', 'Budgeting & Auditing', 'Payroll'],
  };

  // 5 Primary Departments metrics (Sales & Marketing, Digital Marketing, Technical, HR, Finance)
  List<DepartmentMetric> get departmentMetrics {
    return const [
      DepartmentMetric(
        department: CompanyDepartment.salesMarketing,
        totalEmployees: 2,
        presentToday: 2,
        activeTasks: 4,
        completedTasksThisWeek: 8,
        workloadRatio: 0.80,
      ),
      DepartmentMetric(
        department: CompanyDepartment.digitalMarketing,
        totalEmployees: 2,
        presentToday: 2,
        activeTasks: 3,
        completedTasksThisWeek: 6,
        workloadRatio: 0.75,
      ),
      DepartmentMetric(
        department: CompanyDepartment.technical,
        totalEmployees: 10,
        presentToday: 9,
        activeTasks: 21,
        completedTasksThisWeek: 30,
        workloadRatio: 0.90,
      ),
      DepartmentMetric(
        department: CompanyDepartment.hr,
        totalEmployees: 2,
        presentToday: 2,
        activeTasks: 3,
        completedTasksThisWeek: 7,
        workloadRatio: 0.65,
      ),
      DepartmentMetric(
        department: CompanyDepartment.finance,
        totalEmployees: 2,
        presentToday: 2,
        activeTasks: 2,
        completedTasksThisWeek: 5,
        workloadRatio: 0.60,
      ),
    ];
  }

  // Personalized 7-Day Task Widget (PRD Section 11)
  List<CompanyTask> get personalSevenDayTasks {
    final now = DateTime.now();
    final nextSevenDays = now.add(const Duration(days: 7));
    final userTasks = _tasks.where((t) {
      if (_currentRole == UserRole.ceo) return true;
      return t.assignedToId == _currentUserId || t.assignedToName == _currentUserName;
    }).where((t) {
      return t.dueDate.isBefore(nextSevenDays);
    }).toList();

    userTasks.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      final pDiff = b.priority.index.compareTo(a.priority.index);
      if (pDiff != 0) return pDiff;
      return a.dueDate.compareTo(b.dueDate);
    });
    return userTasks;
  }

  double get personalTaskCompletionRate {
    final userTasks = _tasks.where((t) {
      if (_currentRole == UserRole.ceo) return t.isEligibleForProgress;
      return (t.assignedToId == _currentUserId || t.assignedToName == _currentUserName) && t.isEligibleForProgress;
    }).toList();

    if (userTasks.isEmpty) return 100.0;
    final completed = userTasks.where((t) => t.isCompleted).length;
    return (completed / userTasks.length) * 100.0;
  }

  // Employee Mobile App Companion Getters
  Employee? get currentEmployee {
    try {
      final emailLower = _currentUserEmail.toLowerCase();
      final idLower = _currentUserId.toLowerCase();
      final nameLower = _currentUserName.toLowerCase();

      // 1. Check full-time employees
      final emp = _employees.where((e) =>
        e.email.toLowerCase() == emailLower ||
        e.id.toLowerCase() == idLower ||
        e.name.toLowerCase() == nameLower
      ).firstOrNull;

      if (emp != null) return emp;

      // 2. Check interns cohort
      final intern = _interns.where((i) =>
        i.email.toLowerCase() == emailLower ||
        i.id.toLowerCase() == idLower ||
        i.name.toLowerCase() == nameLower
      ).firstOrNull;

      if (intern != null) {
        return Employee(
          id: intern.id,
          name: intern.name,
          email: intern.email,
          phone: intern.phone,
          role: '${intern.domain} Trainee',
          category: intern.category,
          department: intern.domain,
          departmentId: 'DEPT-INTERN',
          subDepartmentId: 'DEPT-INT-${intern.domain.replaceAll(' ', '_').toUpperCase()}',
          subDepartmentName: intern.domain,
          team: intern.team,
          reportingManager: intern.assignedPocName ?? 'Priya Nair',
          joiningDate: intern.selectionDate,
          employmentStatus: 'Active Intern',
          isPOC: false,
          isActive: true,
          activeTaskCount: intern.totalTasks - intern.completedTasks,
          completedTaskCount: intern.completedTasks,
          performanceScore: intern.performanceRating,
          leaveBalance: 6,
          casualLeaves: 3,
          sickLeaves: 3,
          paidLeaves: 0,
          employmentType: 'Internship Cohort',
          batchDetails: intern.batchName,
          location: '${intern.college} • Remote/HQ',
          skills: [intern.domain, 'Corporate ERP', 'Agile Delivery'],
          assignedProjectNames: ['Digital Inertia Core Cohort'],
        );
      }

      return _employees.isNotEmpty ? _employees.first : null;
    } catch (_) {
      return _employees.isNotEmpty ? _employees.first : null;
    }
  }

  List<CompanyTask> get myEmployeeTasks {
    final idLower = _currentUserId.toLowerCase();
    final nameLower = _currentUserName.toLowerCase();
    final firstName = nameLower.split(' ').first;
    final isDigitalMarketing = _currentRole == UserRole.digitalMarketing ||
        (_employees.any((e) => e.id.toLowerCase() == idLower && (e.departmentId == 'DEPT-DM' || e.department == 'Digital Marketing')));

    final list = _tasks.where((t) =>
      t.assignedToId.toLowerCase() == idLower ||
      t.assignedToName.toLowerCase() == nameLower ||
      (firstName.length > 2 && t.assignedToName.toLowerCase().contains(firstName)) ||
      t.assignedById.toLowerCase() == idLower
    ).toList();

    if (list.isEmpty) {
      if (isDigitalMarketing) {
        return _tasks.where((t) => t.department == 'Digital Marketing' || t.projectId == 'PRJ-401').toList();
      }
      return _tasks.take(6).toList();
    }
    return list;
  }

  /// Current week start (Monday at 00:00:00) in local timezone
  DateTime get currentWeekMonday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: now.weekday - 1));
  }

  /// Current week end (Sunday at 23:59:59) in local timezone
  DateTime get currentWeekSundayEnd {
    final mon = currentWeekMonday;
    final sun = mon.add(const Duration(days: 6));
    return DateTime(sun.year, sun.month, sun.day, 23, 59, 59);
  }

  /// Tasks scheduled for the current week (Monday to Sunday) for the authenticated user,
  /// including any active overdue tasks.
  List<CompanyTask> get currentWeekTasksForCurrentUser {
    final monday = currentWeekMonday;
    final sundayEnd = currentWeekSundayEnd;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final userTasks = (_currentRole == UserRole.ceo)
        ? _tasks
        : myEmployeeTasks;

    return userTasks.where((t) {
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      final inWeek = !tDate.isBefore(monday) && !tDate.isAfter(sundayEnd);
      final isPendingOverdue = !t.isCompleted && tDate.isBefore(today);
      return inWeek || isPendingOverdue;
    }).toList();
  }

  /// Total count of tasks due in the current week (Monday to Sunday)
  int get currentWeekTasksTotalCount {
    final monday = currentWeekMonday;
    final sundayEnd = currentWeekSundayEnd;
    final userTasks = (_currentRole == UserRole.ceo)
        ? _tasks
        : myEmployeeTasks;
    return userTasks.where((t) {
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return !tDate.isBefore(monday) && !tDate.isAfter(sundayEnd);
    }).length;
  }

  /// Total count of current-week tasks that are completed
  int get currentWeekTasksCompletedCount {
    final monday = currentWeekMonday;
    final sundayEnd = currentWeekSundayEnd;
    final userTasks = (_currentRole == UserRole.ceo)
        ? _tasks
        : myEmployeeTasks;
    return userTasks.where((t) {
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return !tDate.isBefore(monday) && !tDate.isAfter(sundayEnd) && t.isCompleted;
    }).length;
  }

  /// Completion rate (0.0 to 100.0) of current-week tasks
  double get currentWeekTaskCompletionRate {
    final total = currentWeekTasksTotalCount;
    if (total == 0) return 100.0;
    return (currentWeekTasksCompletedCount / total) * 100.0;
  }

  /// Prioritized list of current-week tasks:
  /// 1. Today's pending tasks (highest priority)
  /// 2. Tomorrow's pending tasks
  /// 3. Other upcoming tasks due this week (chronological)
  /// 4. Overdue tasks (most overdue first)
  /// 5. Completed tasks
  List<CompanyTask> get currentWeekTasksPrioritized {
    final tasks = currentWeekTasksForCurrentUser;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final dueToday = <CompanyTask>[];
    final dueTomorrow = <CompanyTask>[];
    final upcomingThisWeek = <CompanyTask>[];
    final overdue = <CompanyTask>[];
    final completed = <CompanyTask>[];

    for (final t in tasks) {
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      if (t.isCompleted) {
        completed.add(t);
      } else if (tDate.isAtSameMomentAs(today)) {
        dueToday.add(t);
      } else if (tDate.isAtSameMomentAs(tomorrow)) {
        dueTomorrow.add(t);
      } else if (tDate.isBefore(today)) {
        overdue.add(t);
      } else {
        upcomingThisWeek.add(t);
      }
    }

    // Sort upcoming chronologically
    upcomingThisWeek.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    // Sort overdue by most days overdue
    overdue.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    // Sort today & tomorrow by priority (urgent first)
    dueToday.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    dueTomorrow.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    completed.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return [
      ...dueToday,
      ...dueTomorrow,
      ...upcomingThisWeek,
      ...overdue,
      ...completed,
    ];
  }

  /// Get tasks assigned to or created for a specific employee across any department
  List<CompanyTask> tasksForEmployee(String employeeId, [String? employeeName]) {
    final nameLower = (employeeName ?? '').toLowerCase();
    final list = _tasks.where((t) {
      if (t.assignedToId == employeeId || t.assignedById == employeeId) return true;
      if (nameLower.isNotEmpty) {
        if (t.assignedToName.toLowerCase() == nameLower || t.assignedByName.toLowerCase() == nameLower) return true;
        final parts = nameLower.split(' ');
        if (parts.isNotEmpty && parts.first.length > 2 && t.assignedToName.toLowerCase().contains(parts.first)) return true;
      }
      return false;
    }).toList();
    return list;
  }

  /// Get meetings for a specific employee across any department
  List<Meeting> meetingsForEmployee(String employeeName, [String? department]) {
    final nameLower = employeeName.toLowerCase();
    final deptLower = (department ?? '').toLowerCase();
    final list = _meetings.where((m) {
      if (m.organizerName.toLowerCase().contains(nameLower)) return true;
      if (m.participantNames.any((p) => p.toLowerCase().contains(nameLower))) return true;
      if (deptLower.isNotEmpty && m.departmentOrProject.toLowerCase().contains(deptLower)) return true;
      if (m.departmentOrProject == 'All Departments') return true;
      return false;
    }).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Get sales calls/events for a sales employee
  List<SalesCall> callsForEmployee(String employeeId, [String? employeeName]) {
    return List.unmodifiable(_salesCalls);
  }

  List<Project> get myEmployeeProjects {
    final nameLower = _currentUserName.toLowerCase();
    final idLower = _currentUserId.toLowerCase();
    final firstName = nameLower.split(' ').first;
    final isDigitalMarketing = _currentRole == UserRole.digitalMarketing ||
        (_employees.any((e) => e.id.toLowerCase() == idLower && (e.departmentId == 'DEPT-DM' || e.department == 'Digital Marketing')));

    final list = _projects.where((p) {
      final isOwner = p.ownerEmployeeId.toLowerCase() == idLower ||
          p.ownerEmployeeName.toLowerCase() == nameLower;
      final isMember = p.teamMemberNames.any((m) =>
          m.toLowerCase().contains(nameLower) ||
          (firstName.length > 2 && m.toLowerCase().contains(firstName)) ||
          m.toLowerCase().contains('shreya') ||
          m.toLowerCase().contains('arjun'));

      if (isOwner || isMember) return true;

      if (isDigitalMarketing) {
        return p.id == 'PRJ-401' ||
            p.domain == 'Digital Marketing' ||
            p.assignedDepartments.contains('Digital Marketing') ||
            p.team.contains('Digital Marketing');
      }

      return p.id == 'PRJ-402' || p.id == 'PRJ-401';
    }).toList();

    // Sort: PRJ-401 first for Digital Marketing, PRJ-402 first for Tech
    list.sort((a, b) {
      if (isDigitalMarketing) {
        if (a.id == 'PRJ-401') return -1;
        if (b.id == 'PRJ-401') return 1;
      } else {
        if (a.id == 'PRJ-402') return -1;
        if (b.id == 'PRJ-402') return 1;
      }
      return 0;
    });

    if (list.isEmpty) {
      if (isDigitalMarketing) {
        return _projects.where((p) => p.domain == 'Digital Marketing' || p.id == 'PRJ-401').toList();
      }
      return _projects.take(4).toList();
    }
    return list;
  }

  List<Meeting> get myEmployeeMeetings {
    final nameLower = _currentUserName.toLowerCase();
    final idLower = _currentUserId.toLowerCase();
    final firstName = nameLower.split(' ').first;
    final isDigitalMarketing = _currentRole == UserRole.digitalMarketing ||
        (_employees.any((e) => e.id.toLowerCase() == idLower && (e.departmentId == 'DEPT-DM' || e.department == 'Digital Marketing')));

    final list = _meetings.where((m) {
      final isDirect = m.organizerName.toLowerCase().contains(nameLower) ||
          m.participantNames.any((p) =>
            p.toLowerCase().contains(nameLower) ||
            (firstName.length > 2 && p.toLowerCase().contains(firstName))
          );
      if (isDirect) return true;

      if (isDigitalMarketing) {
        return m.departmentOrProject.toLowerCase().contains('marketing') ||
            m.departmentOrProject == 'All Departments' ||
            m.participantNames.any((p) => p.toLowerCase().contains('kavita'));
      }

      return m.departmentOrProject == 'All Departments' ||
          m.participantNames.any((p) => p.toLowerCase().contains('arjun') || p.toLowerCase().contains('shreya'));
    }).toList();

    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Meeting? get nextMyMeeting {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final meetings = myEmployeeMeetings.where((m) {
      final mDate = DateTime(m.date.year, m.date.month, m.date.day);
      return !mDate.isBefore(today);
    }).toList();
    if (meetings.isEmpty) return null;
    return meetings.first;
  }

  // Active filter getters
  String get searchQuery => _searchQuery;
  String get employeeSearchQuery => _employeeSearchQuery;
  String get internSearchQuery => _internSearchQuery;
  String get taskSearchQuery => _taskSearchQuery;
  String get leadSearchQuery => _leadSearchQuery;
  String get projectSearchQuery => _projectSearchQuery;

  RoleCategory? get employeeCategoryFilter => _employeeCategoryFilter;
  String? get employeeRoleFilter => _employeeRoleFilter;
  String? get employeeDepartmentFilter => _employeeDepartmentFilter;
  String? get employeeTeamFilter => _employeeTeamFilter;
  bool? get employeeActiveFilter => _employeeActiveFilter;

  RoleCategory? get internCategoryFilter => _internCategoryFilter;
  String? get internDomainFilter => _internDomainFilter;
  String? get internBatchFilter => _internBatchFilter;
  String? get internMentorFilter => _internMentorFilter;
  String get internTaskScope => _internTaskScope;

  String get taskScopeFilter => _taskScopeFilter;
  String get taskStatusFilter => _taskStatusFilter;
  String? get taskDepartmentFilter => _taskDepartmentFilter;
  String get leadStageFilter => _leadStageFilter;
  String? get leadDomainFilter => _leadDomainFilter;
  String get projectStatusFilter => _projectStatusFilter;
  String? get projectDomainFilter => _projectDomainFilter;

  List<String> get availableEmployeeDepartments {
    final depts = _employees.map((e) => e.department).where((d) => d.isNotEmpty).toSet().toList()..sort();
    return ['All Departments', ...depts];
  }

  List<String> get availableTaskDepartments {
    final depts = _tasks.map((t) => t.effectiveDepartment).where((d) => d.isNotEmpty).toSet().toList()..sort();
    return ['All Departments', ...depts];
  }

  List<String> get availableLeadDomains {
    final domains = _leads.map((l) => l.domain).where((d) => d.isNotEmpty).toSet().toList()..sort();
    return ['All Domains', ...domains];
  }

  List<String> get availableProjectDomains {
    final domains = _projects.map((p) => p.domain).where((d) => d.isNotEmpty).toSet().toList()..sort();
    return ['All Domains', ...domains];
  }

  List<String> get availableInternDomains {
    final domains = _interns.map((i) => i.domain).where((d) => d.isNotEmpty).toSet().toList()..sort();
    return ['All Tracks', ...domains];
  }

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
      if (_employeeDepartmentFilter != null &&
          _employeeDepartmentFilter!.isNotEmpty &&
          _employeeDepartmentFilter != 'All' &&
          _employeeDepartmentFilter != 'All Departments') {
        final df = _employeeDepartmentFilter!.toLowerCase().trim();
        final ed = e.department.toLowerCase().trim();
        if (ed != df && !ed.contains(df) && !df.contains(ed)) {
          return false;
        }
      }
      if (_employeeCategoryFilter != null && e.category != _employeeCategoryFilter) {
        return false;
      }
      if (_employeeRoleFilter != null && _employeeRoleFilter!.isNotEmpty && _employeeRoleFilter != 'All') {
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

  Map<String, List<Employee>> get employeesByDepartmentHierarchical {
    final map = <String, List<Employee>>{};
    for (final emp in filteredEmployees) {
      map.putIfAbsent(emp.department, () => []).add(emp);
    }
    for (final dept in map.keys) {
      map[dept]!.sort((a, b) {
        final aLead = a.role.toLowerCase().contains('lead') || a.role.toLowerCase().contains('manager') || a.isPOC;
        final bLead = b.role.toLowerCase().contains('lead') || b.role.toLowerCase().contains('manager') || b.isPOC;
        if (aLead && !bLead) return -1;
        if (!aLead && bLead) return 1;
        return a.name.compareTo(b.name);
      });
    }
    return map;
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
      if (_taskDepartmentFilter != null &&
          _taskDepartmentFilter!.isNotEmpty &&
          _taskDepartmentFilter != 'All' &&
          _taskDepartmentFilter != 'All Departments') {
        final df = _taskDepartmentFilter!.toLowerCase().trim();
        final td = t.effectiveDepartment.toLowerCase().trim();
        if (td != df && !td.contains(df) && !df.contains(td)) {
          return false;
        }
      }
      if (_taskScopeFilter == 'My Tasks' && t.assignedToId != _currentUserId) {
        return false;
      }
      if (_taskScopeFilter == 'Projects • Domain' && (t.projectName == null || t.projectName!.isEmpty)) {
        return false;
      }
      if (_taskStatusFilter != 'All' && _taskStatusFilter != 'All Tasks') {
        if (_taskStatusFilter == 'Ongoing & Overdue') {
          if (!t.isOngoing && !t.isOverdue) return false;
        } else if (_taskStatusFilter == 'Ongoing' || _taskStatusFilter == 'In Progress') {
          if (!t.isOngoing) return false;
        } else if (_taskStatusFilter == 'Overdue') {
          if (!t.isOverdue) return false;
        } else if (_taskStatusFilter == 'Upcoming' || _taskStatusFilter == 'To Do' || _taskStatusFilter == 'To-Be') {
          if (!t.isUpcoming) return false;
        } else if (_taskStatusFilter == 'Completed' || _taskStatusFilter == 'Done') {
          if (!t.isCompleted) return false;
        } else if (t.status.label.toLowerCase() != _taskStatusFilter.toLowerCase() &&
                   t.status.name.toLowerCase() != _taskStatusFilter.toLowerCase()) {
          return false;
        }
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

  Map<String, List<CompanyTask>> get tasksByDepartment {
    final map = <String, List<CompanyTask>>{};
    for (final task in filteredTasks) {
      final dept = task.effectiveDepartment;
      map.putIfAbsent(dept, () => []).add(task);
    }
    return map;
  }

  List<Lead> get filteredLeads {
    return _leads.where((l) {
      if (_leadStageFilter != 'All' && l.status.label.toLowerCase() != _leadStageFilter.toLowerCase()) {
        return false;
      }
      if (_leadDomainFilter != null &&
          _leadDomainFilter!.isNotEmpty &&
          _leadDomainFilter != 'All' &&
          _leadDomainFilter != 'All Domains') {
        final df = _leadDomainFilter!.toLowerCase().trim();
        final ld = l.domain.toLowerCase().trim();
        if (!ld.contains(df) && !df.contains(ld)) return false;
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
      if (_projectDomainFilter != null &&
          _projectDomainFilter!.isNotEmpty &&
          _projectDomainFilter != 'All' &&
          _projectDomainFilter != 'All Domains') {
        final df = _projectDomainFilter!.toLowerCase().trim();
        final pd = p.domain.toLowerCase().trim();
        if (!pd.contains(df) && !df.contains(pd)) return false;
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

  void setEmployeeDepartmentFilter(String? department) {
    _employeeDepartmentFilter = department;
    notifyListeners();
  }

  void setTaskDepartmentFilter(String? department) {
    _taskDepartmentFilter = department;
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

  void setLeadDomainFilter(String? domain) {
    _leadDomainFilter = domain;
    notifyListeners();
  }

  void setProjectStatusFilter(String status) {
    _projectStatusFilter = status;
    notifyListeners();
  }

  void setProjectDomainFilter(String? domain) {
    _projectDomainFilter = domain;
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
    _employeeDepartmentFilter = null;
    _employeeTeamFilter = null;
    _employeeActiveFilter = null;
    _internCategoryFilter = null;
    _internDomainFilter = null;
    _internBatchFilter = null;
    _internMentorFilter = null;
    _taskScopeFilter = 'All';
    _taskStatusFilter = 'Ongoing & Overdue';
    _taskDepartmentFilter = null;
    _leadStageFilter = 'All';
    _leadDomainFilter = null;
    _projectStatusFilter = 'All';
    _projectDomainFilter = null;
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
    } else if (role == UserRole.sales || role == UserRole.salesMarketing) {
      _currentUserName = 'Rajesh Kumar';
      _currentUserEmail = 'rajesh.kumar@digitalinertia.com';
      _currentUserId = 'EMP-112';
    } else if (role == UserRole.digitalMarketing) {
      _currentUserName = 'Sanjay Menon';
      _currentUserEmail = 'sanjay.menon@digitalinertia.com';
      _currentUserId = 'EMP-113';
    } else if (role == UserRole.employee ||
        role == UserRole.deptLead ||
        role == UserRole.poc ||
        role == UserRole.technical) {
      _currentUserName = 'Arjun Sharma';
      _currentUserEmail = 'arjun.sharma@digitalinertia.com';
      _currentUserId = 'EMP-101';
    } else if (role == UserRole.hr) {
      _currentUserName = 'Meera Joshi';
      _currentUserEmail = 'meera.joshi@digitalinertia.com';
      _currentUserId = 'EMP-111';
    } else if (role == UserRole.finance) {
      _currentUserName = 'Siddharth Roy';
      _currentUserEmail = 'siddharth.roy@digitalinertia.com';
      _currentUserId = 'EMP-115';
    } else if (role == UserRole.gm) {
      _currentUserName = 'Priya Nair';
      _currentUserEmail = 'priya.nair@digitalinertia.com';
      _currentUserId = 'EMP-102';
    } else {
      _currentUserName = 'Aarav Gupta';
      _currentUserEmail = 'aarav.gupta@collegemail.edu';
      _currentUserId = 'INT-201';
    }
    notifyListeners();
  }

  void switchToDemoMode() {
    _forceOfflineMode = true;
    _isLiveMode = false;
    _apiService.clearSession();
    _authError = null;
    _leadsError = null;
    _initSeedData();
    notifyListeners();
  }

  void switchToCeoDemo() {
    _isLiveMode = false;
    _apiService.clearSession();
    _authError = null;
    _leadsError = null;
    setRole(UserRole.ceo);
  }

  void switchToTechEmployeeDemo() {
    _isLiveMode = false;
    _apiService.clearSession();
    _authError = null;
    _leadsError = null;
    setRole(UserRole.employee);
  }

  void switchToSalesEmployeeDemo() {
    _isLiveMode = false;
    _apiService.clearSession();
    _authError = null;
    _leadsError = null;
    setRole(UserRole.sales);
  }

  void logout() {
    _isLiveMode = false;
    _forceOfflineMode = false;
    _apiService.clearSession();
    _authError = null;
    _leadsError = null;
    _currentRole = UserRole.ceo;
    _currentUserName = 'Laven Lokesh';
    _currentUserEmail = 'laven@digitalinertia.com';
    _currentUserId = 'EMP-001';
    _initSeedData();
    notifyListeners();
  }

  /// Connects and authenticates against Spring Boot POST /api/v1/auth/login
  Future<bool> loginWithApi(String email, String password) async {
    _isAuthenticating = true;
    _authError = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      _isLiveMode = true;
      _authError = null;

      // Map Spring Boot user role to UserRole enum (CEO + 5 Departments)
      final roleStr = result.user.role.toUpperCase();
      if (roleStr.contains('CEO') || roleStr.contains('ADMIN')) {
        _currentRole = UserRole.ceo;
      } else if (roleStr.contains('DIGITAL_MARKETING') || roleStr.contains('DIGITAL')) {
        _currentRole = UserRole.digitalMarketing;
      } else if (roleStr.contains('SALES')) {
        _currentRole = UserRole.salesMarketing;
      } else if (roleStr.contains('FINANCE') || roleStr.contains('ACCOUNTS')) {
        _currentRole = UserRole.finance;
      } else if (roleStr.contains('HR') || roleStr.contains('PEOPLE')) {
        _currentRole = UserRole.hr;
      } else if (roleStr.contains('POC')) {
        _currentRole = UserRole.poc;
      } else if (roleStr.contains('INTERN')) {
        _currentRole = UserRole.intern;
      } else {
        _currentRole = UserRole.technical;
      }

      _currentUserName = result.user.fullName;
      _currentUserEmail = result.user.email;
      _currentUserId = result.user.employeeId ?? result.user.id;

      _addAuditLog(
        action: 'User Logged In (Live API)',
        module: 'Authentication',
        details: 'Authenticated $_currentUserEmail against ${_apiService.baseUrl}',
      );

      // Fetch live leads from backend
      try {
        await fetchLiveLeads();
      } catch (_) {
        // Leads error is stored in _leadsError without failing login
      }

      _isAuthenticating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAuthenticating = false;
      _isLiveMode = false;
      _authError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  /// Unified authentication method that:
  /// 1. Validates password: 'password123!' (also accepts 'password123')
  /// 2. Normalizes username / email (e.g. 'arjun.sharma' -> 'arjun.sharma@digitalinertia.com')
  /// 3. Attempts live Spring Boot backend authentication if reachable.
  /// 4. Seamlessly authenticates against local database directory when offline,
  ///    mapping any registered user to their proper department dashboard and tasks.
  Future<bool> authenticateUser(String input, String password) async {
    _isAuthenticating = true;
    _authError = null;
    notifyListeners();

    final cleanInput = input.trim();
    final cleanPassword = password.trim();

    if (cleanInput.isEmpty || cleanPassword.isEmpty) {
      _isAuthenticating = false;
      _authError = 'Please enter your username or email and password.';
      notifyListeners();
      throw Exception(_authError);
    }

    // Requirement: Set all passwords to password123!
    if (cleanPassword != 'password123!' && cleanPassword != 'password123') {
      _isAuthenticating = false;
      _authError = 'Invalid password. All corporate accounts use password123!';
      notifyListeners();
      throw Exception(_authError);
    }

    String email = cleanInput;
    if (!email.contains('@')) {
      email = '$cleanInput@digitalinertia.com';
    }
    email = email.toLowerCase();

    // 1. First attempt live backend API if available and not forced offline
    if (!_forceOfflineMode) {
      try {
        final success = await loginWithApi(email, cleanPassword).timeout(const Duration(seconds: 2));
        if (success) {
          return true;
        }
      } catch (_) {
        // Backend is offline or unreachable - continue with database directory matching
      }
    }

    // 2. Offline / Local Database Directory Authentication
    // Check CEO / Executive
    if (email == 'laven@digitalinertia.com' ||
        email == 'laven.lokesh@digitalinertia.com' ||
        cleanInput.toLowerCase() == 'laven' ||
        cleanInput.toLowerCase() == 'ceo' ||
        cleanInput.toLowerCase() == 'admin' ||
        cleanInput.toLowerCase() == 'emp-001') {
      _currentRole = UserRole.ceo;
      _currentUserName = 'Laven Lokesh';
      _currentUserEmail = 'laven@digitalinertia.com';
      _currentUserId = 'EMP-001';
      _isLiveMode = false;
      _isAuthenticating = false;
      _authError = null;
      _addAuditLog(
        action: 'User Logged In',
        module: 'Authentication',
        details: 'Authenticated Laven Lokesh (CEO)',
      );
      notifyListeners();
      return true;
    }

    // Check GM / MD
    if (cleanInput.toLowerCase() == 'emp-gm' ||
        cleanInput.toLowerCase() == 'gm' ||
        cleanInput.toLowerCase() == 'md' ||
        cleanInput.toLowerCase() == 'general manager' ||
        email == 'gm@digitalinertia.com' ||
        email == 'md@digitalinertia.com') {
      _currentRole = UserRole.gm;
      _currentUserName = 'Priya Nair';
      _currentUserEmail = 'priya.nair@digitalinertia.com';
      _currentUserId = 'EMP-102';
      _isLiveMode = false;
      _isAuthenticating = false;
      _authError = null;
      _addAuditLog(
        action: 'User Logged In',
        module: 'Authentication',
        details: 'Authenticated Priya Nair (GM / MD)',
      );
      notifyListeners();
      return true;
    }

    // Check full-time Employees
    Employee? matchedEmployee;
    for (final emp in _employees) {
      if (emp.email.toLowerCase() == email ||
          emp.name.toLowerCase() == cleanInput.toLowerCase() ||
          emp.id.toLowerCase() == cleanInput.toLowerCase() ||
          (cleanInput.toLowerCase() == 'finance' && emp.id == 'EMP-501') ||
          (cleanInput.toLowerCase() == 'sales' && emp.id == 'EMP-201') ||
          (cleanInput.toLowerCase() == 'marketing' && emp.id == 'EMP-301') ||
          (cleanInput.toLowerCase() == 'hr' && emp.id == 'EMP-401') ||
          ((cleanInput.toLowerCase() == 'tech' || cleanInput.toLowerCase() == 'employee') && emp.id == 'EMP-101')) {
        matchedEmployee = emp;
        break;
      }
    }

    if (matchedEmployee != null) {
      _currentUserName = matchedEmployee.name;
      _currentUserEmail = matchedEmployee.email;
      _currentUserId = matchedEmployee.id;

      // Determine department and role across the 5 corporate departments:
      // 1. Sales & Marketing, 2. Digital Marketing, 3. Technical, 4. HR, 5. Finance
      final deptId = matchedEmployee.departmentId.toUpperCase();
      final deptName = matchedEmployee.department.toLowerCase();

      if (deptId == 'DEPT-HR' || deptName == 'hr') {
        _currentRole = UserRole.hr;
      } else if (deptId == 'DEPT-FIN' || deptName == 'finance') {
        _currentRole = UserRole.finance;
      } else if (deptId == 'DEPT-DM' || deptName.contains('digital marketing')) {
        _currentRole = UserRole.digitalMarketing;
      } else if (deptId == 'DEPT-SM' || deptName.contains('sales')) {
        _currentRole = UserRole.salesMarketing;
      } else {
        // Technical Department
        _currentRole = matchedEmployee.isPOC ? UserRole.poc : UserRole.technical;
      }

      _isLiveMode = false;
      _isAuthenticating = false;
      _authError = null;
      _addAuditLog(
        action: 'User Logged In',
        module: 'Authentication',
        details: 'Authenticated ${matchedEmployee.name} (${_currentRole.label})',
      );
      notifyListeners();
      return true;
    }

    // Check Interns
    Intern? matchedIntern;
    for (final intern in _interns) {
      final nameClean = intern.name.toLowerCase().replaceAll(' ', '');
      final inputClean = cleanInput.toLowerCase().replaceAll(' ', '').replaceAll('.', '');
      final emailClean = email.toLowerCase();
      final internEmailClean = intern.email.toLowerCase();
      final corpEmail = '${intern.name.toLowerCase().replaceAll(' ', '.')}@digitalinertia.com';

      if (internEmailClean == emailClean ||
          corpEmail == emailClean ||
          intern.name.toLowerCase() == cleanInput.toLowerCase() ||
          intern.id.toLowerCase() == cleanInput.toLowerCase() ||
          cleanInput.toLowerCase() == 'intern' ||
          emailClean.startsWith(nameClean) ||
          inputClean == nameClean) {
        matchedIntern = intern;
        break;
      }
    }

    if (matchedIntern != null) {
      _currentUserName = matchedIntern.name;
      _currentUserEmail = matchedIntern.email;
      _currentUserId = matchedIntern.id;

      // Interns are strictly mapped to UserRole.intern to guarantee least-privilege intern workspace routing
      _currentRole = UserRole.intern;

      _isLiveMode = false;
      _isAuthenticating = false;
      _authError = null;
      _addAuditLog(
        action: 'User Logged In',
        module: 'Authentication',
        details: 'Authenticated intern ${matchedIntern.name} (${matchedIntern.domain})',
      );
      notifyListeners();
      return true;
    }

    _isAuthenticating = false;
    _authError = 'User "$cleanInput" is not registered in the system database.';
    notifyListeners();
    throw Exception(_authError);
  }

  /// Fetches live leads from GET /api/v1/leads
  Future<void> fetchLiveLeads() async {
    if (!_isLiveMode) return;
    _isLoadingLeads = true;
    _leadsError = null;
    notifyListeners();

    try {
      final liveLeads = await _apiService.getLeads();
      _leads = liveLeads;
      _isLoadingLeads = false;
      _leadsError = null;
      notifyListeners();
    } catch (e) {
      _isLoadingLeads = false;
      _leadsError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  /// Updates lead stage via PATCH /api/v1/leads/{id}/stage?stage={stage}
  Future<void> updateLeadStageWithApi(String leadId, LeadStatus newStatus) async {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx == -1) return;

    final previousLead = _leads[idx];
    if (!_isLiveMode) {
      _leads[idx] = previousLead.copyWith(status: newStatus);
      notifyListeners();
      return;
    }

    // In Live mode: Optimistically update locally
    final backendStage = Lead.toBackendStage(newStatus);
    _leads[idx] = previousLead.copyWith(status: newStatus);
    notifyListeners();

    try {
      final updatedLead = await _apiService.updateLeadStage(leadId, backendStage);
      _leads[idx] = updatedLead;
      _addAuditLog(
        action: 'Lead Stage Updated (Live API)',
        module: 'Sales',
        details: 'Updated ${previousLead.companyName} stage to ${newStatus.label} on server',
      );
      notifyListeners();
    } catch (e) {
      // Revert optimistic update on failure!
      _leads[idx] = previousLead;
      notifyListeners();
      rethrow;
    }
  }

  void approveApprovalRequest(String id, {String? notes}) {
    final idx = _approvalRequests.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final req = _approvalRequests[idx];
      _approvalRequests[idx] = req.copyWith(
        status: ApprovalStatus.approved,
        reviewNotes: notes ?? 'Approved by $_currentUserName',
        reviewedAt: DateTime.now(),
        reviewedBy: _currentUserName,
      );
      if (req.leadId != null) {
        final lIdx = _leads.indexWhere((l) => l.id == req.leadId);
        if (lIdx != -1) {
          final history = List<LeadApprovalAction>.from(_leads[lIdx].approvalHistory)
            ..add(LeadApprovalAction(
              id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
              action: 'Executive Approved',
              authorName: _currentUserName,
              authorRole: _currentRole.label,
              comments: notes ?? 'Proposal approved. Proceed to client negotiation/confirmation.',
              timestamp: DateTime.now(),
            ));
          _leads[lIdx] = _leads[lIdx].copyWith(
            status: LeadStatus.clientDecision,
            internalApprovalStage: 'Approved',
            approvalHistory: history,
          );
        }
      }
      _addAuditLog(
        action: 'Approval Granted',
        module: 'Approvals',
        details: 'Approved "${req.title}" (${req.dealValueOrBudget.toStringAsFixed(0)})',
      );
      notifyListeners();
    }
  }

  void rejectApprovalRequest(String id, {String? notes}) {
    final idx = _approvalRequests.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final req = _approvalRequests[idx];
      _approvalRequests[idx] = req.copyWith(
        status: ApprovalStatus.rejected,
        reviewNotes: notes ?? 'Declined by $_currentUserName',
        reviewedAt: DateTime.now(),
        reviewedBy: _currentUserName,
      );
      if (req.leadId != null) {
        final lIdx = _leads.indexWhere((l) => l.id == req.leadId);
        if (lIdx != -1) {
          _leads[lIdx] = _leads[lIdx].copyWith(
            status: LeadStatus.lost,
            internalApprovalStage: 'Rejected',
            lostReason: notes ?? 'Executive review rejected deal feasibility',
          );
        }
      }
      notifyListeners();
    }
  }

  void requestChangesApprovalRequest(String id, {required String notes}) {
    final idx = _approvalRequests.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final req = _approvalRequests[idx];
      _approvalRequests[idx] = req.copyWith(
        status: ApprovalStatus.changesRequested,
        reviewNotes: notes,
        reviewedAt: DateTime.now(),
        reviewedBy: _currentUserName,
      );
      if (req.leadId != null) {
        final lIdx = _leads.indexWhere((l) => l.id == req.leadId);
        if (lIdx != -1) {
          _leads[lIdx] = _leads[lIdx].copyWith(
            status: LeadStatus.requirementsCollected,
            internalApprovalStage: 'Changes Requested',
          );
        }
      }
      notifyListeners();
    }
  }

  void addMeeting(Meeting meeting) {
    _meetings.insert(0, meeting);
    notifyListeners();
  }

  void updateAgileTaskStatus(String taskId, TaskStatus status, {String? blockerReason}) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final t = _tasks[idx];
      _tasks[idx] = t.copyWith(
        status: status,
        blockerReason: blockerReason,
        progressPercent: status == TaskStatus.done ? 100 : (status == TaskStatus.inProgress ? 50 : 0),
        completedAt: status == TaskStatus.done ? DateTime.now() : null,
      );

      // Recalculate Project Progress if tied to a project (Section 4.D Specification)
      if (t.projectName != null && t.projectName!.isNotEmpty) {
        final projIdx = _projects.indexWhere((p) => p.name.toLowerCase() == t.projectName!.toLowerCase());
        if (projIdx != -1) {
          final projTasks = _tasks.where((tsk) => tsk.projectName?.toLowerCase() == t.projectName!.toLowerCase()).toList();
          if (projTasks.isNotEmpty) {
            final completedTasks = projTasks.where((tsk) => tsk.isCompleted).length;
            final newProgress = (completedTasks / projTasks.length).clamp(0.0, 1.0);
            _projects[projIdx] = _projects[projIdx].copyWith(
              progress: newProgress,
              status: newProgress >= 1.0 ? ProjectStatus.completed : ProjectStatus.inProgress,
            );
          }
        }
      }

      // If blocked, escalate to manager and record in project activeBlockers
      if (status == TaskStatus.blocked && blockerReason != null && blockerReason.isNotEmpty) {
        if (t.projectName != null) {
          final projIdx = _projects.indexWhere((p) => p.name.toLowerCase() == t.projectName!.toLowerCase());
          if (projIdx != -1) {
            final currentBlockers = List<String>.from(_projects[projIdx].activeBlockers);
            if (!currentBlockers.contains(blockerReason)) {
              currentBlockers.add('${t.title}: $blockerReason');
              _projects[projIdx] = _projects[projIdx].copyWith(
                activeBlockers: currentBlockers,
                status: ProjectStatus.delayed,
              );
            }
          }
        }
        _employeeAlerts.insert(0, {
          'id': 'alt-blk-${DateTime.now().millisecondsSinceEpoch}',
          'type': 'blocker',
          'title': 'Task Blocked: ${t.title}',
          'subtitle': 'Reason: $blockerReason • Assigned to ${t.assignedToName}',
          'time': 'Just now',
          'lead': t.assignedByName,
          'isUrgent': true,
          'isRead': false,
        });
      }

      _addAuditLog(
        action: 'Task Status Updated',
        details: 'Task "${t.title}" moved to ${status.label} by $_currentUserName',
        module: 'Tasks & Agile',
      );

      notifyListeners();
    }
  }

  void toggleTaskCompletion(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final t = _tasks[idx];
      final newStatus = t.isCompleted ? TaskStatus.todo : TaskStatus.done;
      updateAgileTaskStatus(taskId, newStatus);
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void addPersonalTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    String? projectName,
    String? assignedToId,
    String? assignedToName,
    String? department,
  }) {
    final targetId = assignedToId ?? _currentUserId;
    final targetName = assignedToName ?? _currentUserName;
    String targetDept = department ?? (currentEmployee?.department ?? 'Technical');
    if (assignedToId != null) {
      try {
        final match = _employees.firstWhere((e) => e.id == assignedToId);
        targetDept = match.department;
      } catch (_) {}
    }
    final newTask = CompanyTask(
      id: 'TSK-${DateTime.now().millisecondsSinceEpoch % 10000}',
      title: title,
      description: description,
      domain: 'Mobile / Personal',
      department: targetDept,
      assignedToId: targetId,
      assignedToName: targetName,
      assigneeType: AssigneeType.employee,
      assignedById: _currentUserId,
      assignedByName: '$_currentUserName (Personal)',
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.todo,
      projectName: projectName ?? 'Personal Work Planner',
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, newTask);
    notifyListeners();
  }

  void updateEmployeeProfile({
    required String employeeId,
    String? phone,
    String? emergencyContact,
    String? bio,
    List<String>? skills,
  }) {
    final idx = _employees.indexWhere((e) => e.id == employeeId);
    if (idx != -1) {
      final e = _employees[idx];
      _employees[idx] = e.copyWith(
        phone: phone ?? e.phone,
        emergencyContact: emergencyContact ?? e.emergencyContact,
        bio: bio ?? e.bio,
        skills: skills ?? e.skills,
      );
      _addAuditLog(
        action: 'Profile Updated',
        module: 'Employee Portal',
        details: 'Self-service contact/bio updated for ${e.name}',
      );
      notifyListeners();
    }
  }

  void submitHrFeasibility(String leadId, {
    required List<String> skills,
    required int hours,
    required String notes,
    bool needsHiring = false,
  }) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final l = _leads[idx];
      final hr = l.hrFeasibility.copyWith(
        status: FeasibilityStatus.completed,
        requiredSkills: skills,
        estimatedEffortHours: hours,
        resourceAvailabilityNotes: notes,
        needsHiring: needsHiring,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
      );
      _leads[idx] = l.copyWith(hrFeasibility: hr);
      notifyListeners();
    }
  }

  void submitFinanceFeasibility(String leadId, {
    required double cost,
    required double price,
    required double margin,
    required String paymentTerms,
  }) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final l = _leads[idx];
      final fin = l.financeFeasibility.copyWith(
        status: FeasibilityStatus.completed,
        estimatedCost: cost,
        quotedPrice: price,
        expectedMarginPercent: margin,
        paymentTerms: paymentTerms,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
      );
      _leads[idx] = l.copyWith(financeFeasibility: fin);
      notifyListeners();
    }
  }

  void submitLeadForInternalApproval(String leadId) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final l = _leads[idx];
      final history = List<LeadApprovalAction>.from(l.approvalHistory)
        ..add(LeadApprovalAction(
          id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
          action: 'Submitted to GM / MD Review',
          authorName: _currentUserName,
          authorRole: _currentRole.label,
          comments: 'Feasibility confirmed by HR and Finance. Forwarded for executive review.',
          timestamp: DateTime.now(),
        ));
      _leads[idx] = l.copyWith(
        status: LeadStatus.internalApproval,
        internalApprovalStage: 'Pending GM Review',
        approvalHistory: history,
      );

      _approvalRequests.insert(0, CompanyApprovalRequest(
        id: 'APR-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: '${l.companyName} Project Proposal',
        submittingDepartment: 'Sales and Business Development',
        submittedByName: _currentUserName,
        submittedByRole: _currentRole.label,
        submittedDate: DateTime.now(),
        dealValueOrBudget: l.dealValue,
        summary: 'Requirements collected and feasibility approved. Scope: ${l.requirementsScope}',
        leadId: l.id,
        status: ApprovalStatus.pendingCeo,
      ));
      notifyListeners();
    }
  }

  void logLeadInteraction(String leadId, {
    required String type,
    required String summary,
  }) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final l = _leads[idx];
      final updatedInteractions = List<LeadInteraction>.from(l.interactions)
        ..insert(0, LeadInteraction(
          id: 'INT-${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          summary: summary,
          authorName: _currentUserName,
          timestamp: DateTime.now(),
        ));
      _leads[idx] = l.copyWith(
        interactions: updatedInteractions,
        daysSinceLastContact: 0,
      );
      if (type.toLowerCase().contains('call')) {
        _contactsCompletedThisWeek++;
        if (_pendingCallsToday > 0) _pendingCallsToday--;
      }
      notifyListeners();
    }
  }

  void convertInternToEmployee(String internId, {
    required String role,
    required String department,
  }) {
    final idx = _interns.indexWhere((i) => i.id == internId);
    if (idx != -1) {
      final intern = _interns[idx];
      _interns[idx] = intern.copyWith(
        status: InternStatus.hired,
        finalDecision: InternFinalDecision.hired,
        latestFeedback: 'Hired as permanent employee: $role',
      );
      final newEmp = Employee(
        id: 'EMP-${_employees.length + 101}',
        name: intern.name,
        email: intern.email.replaceAll('@collegemail.edu', '@digitalinertia.com'),
        phone: intern.phone,
        role: role,
        category: intern.category,
        department: department,
        team: intern.team,
        joiningDate: DateTime.now(),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        performanceScore: intern.performanceRating,
      );
      _employees.add(newEmp);
      _youthEmploymentPlaced++;
      _addAuditLog(
        action: 'Intern Converted to Employee',
        module: 'HR / Recruitment',
        details: 'Converted ${intern.name} to $role in $department',
      );
      notifyListeners();
    }
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
    String? departmentId,
    String? subDepartmentId,
    String? subDepartmentName,
    String team = 'Core Engineering',
    required bool isPOC,
  }) {
    final newEmp = Employee(
      id: 'EMP-${_employees.length + 101}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      category: category,
      department: department,
      departmentId: departmentId,
      subDepartmentId: subDepartmentId,
      subDepartmentName: subDepartmentName,
      team: team,
      isPOC: isPOC,
      isActive: true,
      activeTaskCount: 1,
    );
    _employees.add(newEmp);
    _addAuditLog(
      action: 'Employee Added',
      module: 'People',
      details: 'Added $name ($role, $department)',
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
    String department = 'Technology and Engineering',
    required String assignedToId,
    required String assignedToName,
    required AssigneeType assigneeType,
    required DateTime dueDate,
    required TaskPriority priority,
    String? projectName,
  }) {
    final newTask = CompanyTask(
      id: 'TSK-${DateTime.now().millisecondsSinceEpoch}-${++_idCounter}',
      title: title,
      description: description,
      domain: domain,
      department: department,
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

  Future<void> updateLeadStatus(String leadId, LeadStatus newStatus) async {
    await updateLeadStageWithApi(leadId, newStatus);
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

    // Auto-create kickoff architecture task for owner (Section 6 Step 4 & 5)
    createTask(
      title: 'Project Kickoff & Architecture Blueprint: $projectName',
      description: 'Formal kickoff meeting, team member assignments, and initial sprint deliverables for $clientName.',
      domain: 'Technology and Engineering',
      department: 'Technology and Engineering',
      assignedToId: owner.id,
      assignedToName: owner.name,
      assigneeType: AssigneeType.employee,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.high,
      projectName: projectName,
    );

    // Cross-department Handover Notification
    _employeeAlerts.insert(0, {
      'id': 'alt-prj-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'project',
      'title': 'Deal Won & Project Handover: $projectName',
      'subtitle': 'Client: $clientName • Allocated Budget: ₹${(budget / 100000).toStringAsFixed(1)}L',
      'time': 'Just now',
      'lead': owner.name,
      'isUrgent': false,
      'isRead': false,
    });

    _addAuditLog(
      action: 'Deal Won & Project Handover',
      module: 'Sales & Delivery',
      details: 'Converted deal "$clientName" into Project "$projectName" with ₹${(budget / 100000).toStringAsFixed(1)}L budget',
    );

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
      // ==========================================
      // DEPARTMENT 1: Technical (5 Employees + Specialist)
      // ==========================================
      Employee(
        id: 'EMP-101',
        name: 'Arjun Sharma',
        email: 'arjun.sharma@digitalinertia.com',
        phone: '+91 98201 14521',
        role: 'Lead Frontend Developer & Architect',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-FE',
        subDepartmentName: 'Frontend',
        team: 'Client Experience Engineering',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 4, 15),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 18,
        performanceScore: 4.85,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98201 99887 (Pooja Sharma - Spouse)',
        bio: 'Lead Engineer passionate about responsive mobile architecture, clean interfaces, and resilient high-throughput cloud services.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Flutter & Dart', 'React & Next.js', 'Go & Node.js', 'PostgreSQL', 'Docker & Kubernetes', 'System Architecture'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'Digital Inertia ERP Core', 'OmniChannel Enterprise Sales Rollout', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-102',
        name: 'Priya Nair',
        email: 'priya.nair@digitalinertia.com',
        phone: '+91 98450 78210',
        role: 'Senior Backend Developer & Database Lead',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-BE',
        subDepartmentName: 'Backend',
        team: 'Core Platform Engineering',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 6, 1),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 3,
        completedTaskCount: 24,
        performanceScore: 4.90,
        leaveBalance: 12,
        casualLeaves: 5,
        sickLeaves: 4,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98450 11223 (Ramesh Nair - Brother)',
        bio: 'Database and microservices architect specializing in PostgreSQL replication, high-throughput REST/gRPC APIs, and distributed systems.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Java & Spring Boot', 'PostgreSQL', 'Redis', 'Kafka', 'System Architecture', 'Kubernetes'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'Digital Inertia ERP Core', 'EcoTrack IoT Mobile Platform', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-103',
        name: 'Karthik R',
        email: 'karthik.r@digitalinertia.com',
        phone: '+91 97112 65430',
        role: 'Full Stack Engineer & Cloud Integrations',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-FS',
        subDepartmentName: 'Full-stack',
        team: 'Core Platform Engineering',
        reportingManager: 'Arjun Sharma',
        joiningDate: DateTime(2023, 8, 10),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 16,
        performanceScore: 4.75,
        leaveBalance: 15,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 97112 88990 (Suma R - Mother)',
        bio: 'Full stack builder linking reactive Flutter frontends with cloud-native Spring Boot backends and Redis distributed caching.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Flutter', 'Node.js', 'PostgreSQL', 'Docker', 'AWS', 'GraphQL'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'EcoTrack IoT Mobile Platform', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-104',
        name: 'Sneha V',
        email: 'sneha.v@digitalinertia.com',
        phone: '+91 99304 98124',
        role: 'Frontend UI & Design Systems Engineer',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-FE',
        subDepartmentName: 'Frontend',
        team: 'Client Experience Engineering',
        reportingManager: 'Arjun Sharma',
        joiningDate: DateTime(2023, 9, 1),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 19,
        performanceScore: 4.80,
        leaveBalance: 13,
        casualLeaves: 5,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 99304 55443 (Vipin K - Father)',
        bio: 'Crafts pixel-perfect Flutter UI components, design tokens, micro-interactions, and responsive layout grids.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Flutter UI', 'Design Systems', 'Figma', 'Responsive Layouts', 'Dart Animation'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'OmniChannel Enterprise Sales Rollout', 'Corporate People Hub & Workforce System'],
      ),
      Employee(
        id: 'EMP-105',
        name: 'Rohan Mehta',
        email: 'rohan.mehta@digitalinertia.com',
        phone: '+91 98214 33219',
        role: 'Mobile App Lead (Flutter & Native)',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-MO',
        subDepartmentName: 'Mobile App',
        team: 'Client Experience Engineering',
        reportingManager: 'Arjun Sharma',
        joiningDate: DateTime(2023, 11, 15),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 21,
        performanceScore: 4.82,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98214 77665 (Kavita Mehta - Mother)',
        bio: 'Cross-platform mobile architect specializing in Flutter, native BLE peripherals, IoT background sync, and offline storage.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Flutter', 'Android Native', 'iOS Native', 'BLE Hardware', 'SQLite', 'Push Notifications'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'EcoTrack IoT Mobile Platform', 'Corporate People Hub & Workforce System'],
      ),
      Employee(
        id: 'EMP-118',
        name: 'Shreya Kulkarni',
        email: 'shreya.kulkarni@digitalinertia.com',
        phone: '+91 98204 11980',
        role: 'Technical Specialist & Full Stack Engineer',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-FS',
        subDepartmentName: 'Full-stack',
        team: 'Client Experience Engineering',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2024, 7, 1),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 3,
        completedTaskCount: 15,
        performanceScore: 4.88,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98204 88776 (Anil Kulkarni - Father)',
        bio: 'Technical specialist building end-to-end ERP microservices, state machines, and real-time enterprise dashboards.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Flutter & Dart', 'Spring Boot', 'PostgreSQL', 'State Management', 'Enterprise ERP'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'Digital Marketing & Growth Engine', 'OmniChannel Enterprise Sales Rollout'],
      ),
      Employee(
        id: 'EMP-106',
        name: 'Ananya Deshmukh',
        email: 'ananya.deshmukh@digitalinertia.com',
        phone: '+91 98190 22345',
        role: 'AI / ML Engineer',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-AI',
        subDepartmentName: 'AI / ML',
        team: 'Applied Intelligence Lab',
        reportingManager: 'Arjun Sharma',
        joiningDate: DateTime(2024, 1, 10),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 14,
        performanceScore: 4.84,
        leaveBalance: 15,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98190 88771 (Pravin Deshmukh - Father)',
        bio: 'AI/ML specialist developing predictive models, telemetry autoencoders, and NLP workflows for enterprise ERP.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Python & PyTorch', 'TensorFlow', 'FastAPI', 'MLOps', 'Docker'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'Digital Marketing & Growth Engine'],
      ),
      Employee(
        id: 'EMP-107',
        name: 'Vikram Singh',
        email: 'vikram.singh@digitalinertia.com',
        phone: '+91 97401 88320',
        role: 'Data Engineer & ETL Pipelines Lead',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-DE',
        subDepartmentName: 'Data Engineering',
        team: 'Core Platform Engineering',
        reportingManager: 'Priya Nair',
        joiningDate: DateTime(2024, 2, 1),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 16,
        performanceScore: 4.76,
        leaveBalance: 14,
        casualLeaves: 5,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 97401 11223 (Kiran Singh - Brother)',
        bio: 'Architect of resilient batch and streaming ETL pipelines using PostgreSQL, Kafka, and Apache Spark.',
        location: 'Bengaluru HQ • On-site',
        skills: ['PostgreSQL', 'Apache Kafka', 'Python', 'SQL Optimization', 'Airflow'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-108',
        name: 'Neha Patel',
        email: 'neha.patel@digitalinertia.com',
        phone: '+91 98331 44590',
        role: 'QA / Testing Lead & Automation Architect',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-QA',
        subDepartmentName: 'QA / Testing',
        team: 'Quality & Reliability',
        reportingManager: 'Arjun Sharma',
        joiningDate: DateTime(2024, 3, 1),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 22,
        performanceScore: 4.89,
        leaveBalance: 13,
        casualLeaves: 5,
        sickLeaves: 4,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98331 99008 (Hitesh Patel - Spouse)',
        bio: 'Automated test suite designer for end-to-end integration and load benchmarking across mobile and backend microservices.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Flutter Integration Test', 'Locust & JMeter', 'Selenium', 'CI/CD Pipelines', 'Appium'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'EcoTrack IoT Mobile Platform'],
      ),
      Employee(
        id: 'EMP-109',
        name: 'Rahul Verma',
        email: 'rahul.verma@digitalinertia.com',
        phone: '+91 98110 99450',
        role: 'DevOps & Cloud Specialist',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-OPS',
        subDepartmentName: 'DevOps / Cloud',
        team: 'Core Platform Engineering',
        reportingManager: 'Priya Nair',
        joiningDate: DateTime(2024, 4, 15),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 19,
        performanceScore: 4.82,
        leaveBalance: 16,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98110 22334 (Sarita Verma - Mother)',
        bio: 'Cloud infra engineer managing Kubernetes clusters, zero-downtime rolling deployments, and container security.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Kubernetes', 'Docker', 'AWS', 'Terraform', 'Prometheus & Grafana'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-110',
        name: 'Divya Iyer',
        email: 'divya.iyer@digitalinertia.com',
        phone: '+91 98402 11234',
        role: 'UI/UX Engineering Lead',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-UIX',
        subDepartmentName: 'UI/UX',
        team: 'Client Experience Engineering',
        reportingManager: 'Arjun Sharma',
        joiningDate: DateTime(2024, 5, 1),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 17,
        performanceScore: 4.85,
        leaveBalance: 15,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98402 77889 (Anand Iyer - Father)',
        bio: 'Designs token-based design systems, human-centered UI patterns, and cross-platform Figma design assets for Digital Inertia.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Figma', 'Design Systems', 'Flutter UI', 'Micro-interactions', 'Design Tokens'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'Digital Marketing & Growth Engine'],
      ),
      Employee(
        id: 'EMP-111',
        name: 'Meera Joshi',
        email: 'meera.joshi@digitalinertia.com',
        phone: '+91 98205 66780',
        role: 'HR & Talent Acquisition Specialist',
        category: RoleCategory.nonTechnical,
        department: 'HR',
        departmentId: 'DEPT-HR',
        subDepartmentId: 'DEPT-HR-REC',
        subDepartmentName: 'Recruitment',
        team: 'People & Workplace',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 5, 10),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 25,
        performanceScore: 4.90,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98205 88990 (Alok Joshi - Spouse)',
        bio: 'People specialist orchestrating university recruitment cohorts, intern onboarding, employee leaves, and workforce retention.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Talent Acquisition', 'Campus Hiring', 'Employee Engagement', 'HR Compliance', 'Policy Governance'],
        assignedProjectNames: ['Corporate People Hub & Workforce System', 'Digital Inertia ERP Core'],
      ),
      Employee(
        id: 'EMP-112',
        name: 'Rajesh Kumar',
        email: 'rajesh.kumar@digitalinertia.com',
        phone: '+91 98101 44321',
        role: 'Enterprise Sales & BD Lead',
        category: RoleCategory.nonTechnical,
        department: 'Sales & Marketing',
        departmentId: 'DEPT-SM',
        subDepartmentId: 'DEPT-SM-SLS',
        subDepartmentName: 'Enterprise Sales',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 7, 20),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 28,
        performanceScore: 4.92,
        leaveBalance: 11,
        casualLeaves: 4,
        sickLeaves: 4,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98101 77889 (Sunita Kumar - Spouse)',
        bio: 'Enterprise B2B dealmaker closing Fortune 500 digital transformations, SaaS contracts, and multi-year consulting retainers.',
        location: 'Mumbai Office • Hybrid',
        skills: ['Enterprise Sales', 'Client Negotiation', 'Contract Structuring', 'Executive Relations', 'Pipeline Management'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'OmniChannel Enterprise Sales Rollout'],
      ),
      Employee(
        id: 'EMP-113',
        name: 'Sanjay Menon',
        email: 'sanjay.menon@digitalinertia.com',
        phone: '+91 98410 77650',
        role: 'Digital Marketing Strategist & SEO Lead',
        category: RoleCategory.nonTechnical,
        department: 'Digital Marketing',
        departmentId: 'DEPT-DM',
        subDepartmentId: 'DEPT-MKT-SEO',
        subDepartmentName: 'SEO & Strategy',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 10, 1),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 21,
        performanceScore: 4.87,
        leaveBalance: 13,
        casualLeaves: 5,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98410 44556 (Geeta Menon - Spouse)',
        bio: 'Growth marketing strategist driving technical SEO, organic visibility silos, multi-channel ad engines, and brand authority.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Technical SEO', 'Performance Marketing', 'Conversion Optimization', 'Google Ads', 'Content Architecture'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'OmniChannel Enterprise Sales Rollout'],
      ),
      Employee(
        id: 'EMP-114',
        name: 'Pooja Hegde',
        email: 'pooja.hegde@digitalinertia.com',
        phone: '+91 98211 22390',
        role: 'Financial Operations & Budgeting Manager',
        category: RoleCategory.nonTechnical,
        department: 'Finance',
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-BUD',
        subDepartmentName: 'Budgeting & Ops',
        team: 'Financial & Business Ops',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 12, 5),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 18,
        performanceScore: 4.82,
        leaveBalance: 15,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98211 88992 (Girish Hegde - Father)',
        bio: 'Manages enterprise operational finances, commercial project budgets, cost-benefit allocations, and audit reconciliations.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Financial Analysis', 'Budgeting & Cost Allocation', 'Project Margin Auditing', 'ERP Billing'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-115',
        name: 'Siddharth Roy',
        email: 'siddharth.roy@digitalinertia.com',
        phone: '+91 98300 88710',
        role: 'Finance & Accounts Lead',
        category: RoleCategory.nonTechnical,
        department: 'Finance',
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-ACC',
        subDepartmentName: 'Accounts',
        team: 'Financial & Business Ops',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2024, 2, 15),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 20,
        performanceScore: 4.91,
        leaveBalance: 12,
        casualLeaves: 5,
        sickLeaves: 4,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98300 22119 (Tanushree Roy - Spouse)',
        bio: 'Heads general ledger auditing, client invoicing lifecycles, banking partnerships, and corporate fiscal governance.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Corporate Finance', 'General Ledger', 'Tax & Compliance', 'Banking Reconciliations', 'Statutory Audits'],
        assignedProjectNames: ['FinTech Payment Gateway Microservices', 'Digital Inertia ERP Core'],
      ),
      Employee(
        id: 'EMP-116',
        name: 'Kavita Rao',
        email: 'kavita.rao@digitalinertia.com',
        phone: '+91 98452 33410',
        role: 'Client Acquisition & Account Manager',
        category: RoleCategory.nonTechnical,
        department: 'Sales & Marketing',
        departmentId: 'DEPT-SM',
        subDepartmentId: 'DEPT-SM-ACQ',
        subDepartmentName: 'Client Acquisition',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Rajesh Kumar',
        joiningDate: DateTime(2024, 3, 20),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 14,
        performanceScore: 4.80,
        leaveBalance: 16,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98452 77665 (Kishore Rao - Father)',
        bio: 'Leads high-value B2B enterprise proposals, discovery calls, customer retention strategies, and sales pipeline conversion.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Client Acquisition', 'Account Governance', 'CRM Automation', 'Deal Structuring', 'Customer Success'],
        assignedProjectNames: ['OmniChannel Enterprise Sales Rollout', 'Digital Inertia ERP Core'],
      ),
      Employee(
        id: 'EMP-117',
        name: 'Aditya Sen',
        email: 'aditya.sen@digitalinertia.com',
        phone: '+91 98115 55620',
        role: 'Content & Social Media Specialist',
        category: RoleCategory.nonTechnical,
        department: 'Digital Marketing',
        departmentId: 'DEPT-DM',
        subDepartmentId: 'DEPT-MKT-CNT',
        subDepartmentName: 'Content Marketing',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Sanjay Menon',
        joiningDate: DateTime(2024, 6, 1),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 12,
        performanceScore: 4.72,
        leaveBalance: 17,
        casualLeaves: 8,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98115 11990 (Priya Sen - Sister)',
        bio: 'Creates engaging B2B technical content, developer thought leadership articles, and high-impact social media campaign storytelling.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Content Marketing', 'Copywriting', 'Social Media Growth', 'Brand Storytelling', 'Technical Blogs'],
        assignedProjectNames: ['Digital Marketing & Growth Engine'],
      ),

      // ==========================================
      // DEPARTMENT 2: Sales & Marketing (5 Employees)
      // ==========================================
      Employee(
        id: 'EMP-201',
        name: 'Rajesh Kumar',
        email: 'rajesh.kumar@digitalinertia.com',
        phone: '+91 98101 44321',
        role: 'VP Enterprise Sales & Client Partnerships',
        category: RoleCategory.nonTechnical,
        department: 'Sales & Marketing',
        departmentId: 'DEPT-SM',
        subDepartmentId: 'DEPT-SM-SLS',
        subDepartmentName: 'Enterprise Sales',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 7, 20),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 28,
        performanceScore: 4.92,
        leaveBalance: 11,
        casualLeaves: 4,
        sickLeaves: 4,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98101 77889 (Sunita Kumar - Spouse)',
        bio: 'Enterprise B2B dealmaker closing Fortune 500 digital transformations, SaaS contracts, and multi-year consulting retainers.',
        location: 'Mumbai Office • Hybrid',
        skills: ['Enterprise Sales', 'Client Negotiation', 'Contract Structuring', 'Executive Relations', 'Pipeline Management'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'EcoTrack IoT Mobile Platform', 'OmniChannel Enterprise Sales Rollout', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-202',
        name: 'Meera Sen',
        email: 'meera.sen@digitalinertia.com',
        phone: '+91 98452 33410',
        role: 'Senior Account Executive & Enterprise Deals',
        category: RoleCategory.nonTechnical,
        department: 'Sales & Marketing',
        departmentId: 'DEPT-SM',
        subDepartmentId: 'DEPT-SM-SLS',
        subDepartmentName: 'Enterprise Sales',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Rajesh Kumar',
        joiningDate: DateTime(2023, 9, 12),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 19,
        performanceScore: 4.78,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98452 88991 (Arindam Sen - Father)',
        bio: 'Drives high-velocity enterprise deal cycles, lead discovery calls, product demonstrations, and customer expansion.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Account Management', 'SaaS Demos', 'CRM Automation', 'Deal Closing', 'Lead Nurturing'],
        assignedProjectNames: ['OmniChannel Enterprise Sales Rollout', 'Corporate People Hub & Workforce System'],
      ),
      Employee(
        id: 'EMP-203',
        name: 'Vikram Malhotra',
        email: 'vikram.malhotra@digitalinertia.com',
        phone: '+91 98203 77412',
        role: 'Business Development Manager',
        category: RoleCategory.nonTechnical,
        department: 'Sales & Marketing',
        departmentId: 'DEPT-SM',
        subDepartmentId: 'DEPT-SM-BD',
        subDepartmentName: 'Business Development',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Rajesh Kumar',
        joiningDate: DateTime(2024, 1, 15),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 14,
        performanceScore: 4.70,
        leaveBalance: 15,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98203 11224 (Pooja Malhotra - Sister)',
        bio: 'Spearheads inbound lead qualification, outbound strategic accounts outreach, and joint channel partner alliances.',
        location: 'Mumbai Office • Hybrid',
        skills: ['Business Development', 'Outbound Sales', 'Strategic Partnerships', 'Market Analysis'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'OmniChannel Enterprise Sales Rollout'],
      ),
      Employee(
        id: 'EMP-204',
        name: 'Ananya Kapoor',
        email: 'ananya.kapoor@digitalinertia.com',
        phone: '+91 98190 22345',
        role: 'Solutions Consultant & Deal Strategist',
        category: RoleCategory.nonTechnical,
        department: 'Sales & Marketing',
        departmentId: 'DEPT-SM',
        subDepartmentId: 'DEPT-SM-SOL',
        subDepartmentName: 'Solutions Consulting',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Rajesh Kumar',
        joiningDate: DateTime(2024, 2, 1),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 12,
        performanceScore: 4.81,
        leaveBalance: 16,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98190 66778 (Rohit Kapoor - Spouse)',
        bio: 'Bridges technical capabilities with customer business requirements to author compelling commercial RFP proposals.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Solution Selling', 'RFP Responses', 'Technical Proof of Concept', 'Value Engineering'],
        assignedProjectNames: ['Digital Inertia ERP Core'],
      ),
      Employee(
        id: 'EMP-205',
        name: 'Aditya Joshi',
        email: 'aditya.joshi@digitalinertia.com',
        phone: '+91 98115 55620',
        role: 'Sales Operations & Inbound Lead Specialist',
        category: RoleCategory.nonTechnical,
        department: 'Sales & Marketing',
        departmentId: 'DEPT-SM',
        subDepartmentId: 'DEPT-SM-OPS',
        subDepartmentName: 'Sales Ops',
        team: 'Corporate Growth & Sales',
        reportingManager: 'Rajesh Kumar',
        joiningDate: DateTime(2024, 3, 10),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 11,
        performanceScore: 4.65,
        leaveBalance: 17,
        casualLeaves: 8,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98115 33445 (Suresh Joshi - Father)',
        bio: 'Oversees sales CRM pipeline telemetry, automated deal stage notifications, contract archives, and sales SLA adherence.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Salesforce & HubSpot', 'Sales Operations', 'Lead Routing', 'Quota Reporting'],
        assignedProjectNames: ['EcoTrack IoT Mobile Platform'],
      ),

      // ==========================================
      // DEPARTMENT 3: Digital Marketing (5 Employees)
      // ==========================================
      Employee(
        id: 'EMP-301',
        name: 'Kavita Reddy',
        email: 'kavita.reddy@digitalinertia.com',
        phone: '+91 98410 77650',
        role: 'Head of Digital Marketing & Growth',
        category: RoleCategory.nonTechnical,
        department: 'Digital Marketing',
        departmentId: 'DEPT-DM',
        subDepartmentId: 'DEPT-DM-GRW',
        subDepartmentName: 'Growth & Strategy',
        team: 'Digital Marketing & Growth',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 10, 1),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 22,
        performanceScore: 4.88,
        leaveBalance: 13,
        casualLeaves: 5,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98410 22331 (Mahesh Reddy - Brother)',
        bio: 'Growth marketing leader orchestrating omnichannel acquisition funnels, digital brand performance, and high-ROI ad engines.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Omnichannel Growth', 'PPC Strategy', 'Marketing Telemetry', 'Conversion Rate Optimization', 'Brand Positioning'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'OmniChannel Enterprise Sales Rollout'],
      ),
      Employee(
        id: 'EMP-302',
        name: 'Sameer Deshmukh',
        email: 'sameer.deshmukh@digitalinertia.com',
        phone: '+91 98210 99012',
        role: 'Performance Ads & PPC Campaign Manager',
        category: RoleCategory.nonTechnical,
        department: 'Digital Marketing',
        departmentId: 'DEPT-DM',
        subDepartmentId: 'DEPT-DM-PPC',
        subDepartmentName: 'Paid Media',
        team: 'Digital Marketing & Growth',
        reportingManager: 'Kavita Reddy',
        joiningDate: DateTime(2023, 11, 20),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 18,
        performanceScore: 4.80,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98210 44556 (Shilpa Deshmukh - Mother)',
        bio: 'Manages \$250k+ quarterly paid media budgets across Google Ads, LinkedIn Campaign Manager, Meta Ads, and automated bid rules.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Google Ads', 'Meta Ads Manager', 'LinkedIn B2B Ads', 'ROAS Optimization', 'A/B Creative Testing'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'EcoTrack IoT Mobile Platform'],
      ),
      Employee(
        id: 'EMP-303',
        name: 'Pooja Deshmukh',
        email: 'pooja.deshmukh@digitalinertia.com',
        phone: '+91 98211 22390',
        role: 'SEO & Organic Search Strategist',
        category: RoleCategory.nonTechnical,
        department: 'Digital Marketing',
        departmentId: 'DEPT-DM',
        subDepartmentId: 'DEPT-DM-SEO',
        subDepartmentName: 'Search Engine Optimization',
        team: 'Digital Marketing & Growth',
        reportingManager: 'Kavita Reddy',
        joiningDate: DateTime(2023, 12, 5),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 15,
        performanceScore: 4.75,
        leaveBalance: 15,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98211 88992 (Girish Hegde - Father)',
        bio: 'Technical SEO authority scaling organic impressions through content silo architectures, schema markups, and backlinks.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Technical SEO', 'Keyword Research', 'Google Search Console', 'Ahrefs / Semrush', 'Content Strategy'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'Corporate People Hub & Workforce System'],
      ),
      Employee(
        id: 'EMP-304',
        name: 'Naveen Chandra',
        email: 'naveen.chandra@digitalinertia.com',
        phone: '+91 98300 88710',
        role: 'Social Media & Brand Engagement Lead',
        category: RoleCategory.nonTechnical,
        department: 'Digital Marketing',
        departmentId: 'DEPT-DM',
        subDepartmentId: 'DEPT-DM-SOC',
        subDepartmentName: 'Social & Brand',
        team: 'Digital Marketing & Growth',
        reportingManager: 'Kavita Reddy',
        joiningDate: DateTime(2024, 2, 15),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 13,
        performanceScore: 4.70,
        leaveBalance: 16,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98300 11447 (Radha Chandra - Mother)',
        bio: 'Commands brand presence across LinkedIn, X/Twitter, YouTube, and Discord to drive organic engineering thought leadership.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Social Media Strategy', 'B2B Brand Engagement', 'Influencer Marketing', 'Community Building'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-305',
        name: 'Rhea Pillai',
        email: 'rhea.pillai@digitalinertia.com',
        phone: '+91 98402 11234',
        role: 'Creative Visual & Content Marketing Specialist',
        category: RoleCategory.nonTechnical,
        department: 'Digital Marketing',
        departmentId: 'DEPT-DM',
        subDepartmentId: 'DEPT-DM-CRT',
        subDepartmentName: 'Creative Design',
        team: 'Digital Marketing & Growth',
        reportingManager: 'Kavita Reddy',
        joiningDate: DateTime(2024, 4, 1),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 11,
        performanceScore: 4.82,
        leaveBalance: 18,
        casualLeaves: 8,
        sickLeaves: 5,
        paidLeaves: 5,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98402 66779 (Dev Pillai - Brother)',
        bio: 'Produces high-impact graphic design, promotional brand videos, UI illustrations, and conversion-optimized ad creatives.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Visual Design', 'Figma & Adobe CC', 'Motion Graphics', 'Ad Creative Production', 'Copywriting'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'OmniChannel Enterprise Sales Rollout'],
      ),

      // ==========================================
      // DEPARTMENT 4: HR (5 Employees)
      // ==========================================
      Employee(
        id: 'EMP-401',
        name: 'Sunita Verma',
        email: 'sunita.verma@digitalinertia.com',
        phone: '+91 98205 66780',
        role: 'Director of People & Culture',
        category: RoleCategory.nonTechnical,
        department: 'HR',
        departmentId: 'DEPT-HR',
        subDepartmentId: 'DEPT-HR-DIR',
        subDepartmentName: 'People Leadership',
        team: 'People & Culture',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 5, 10),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 26,
        performanceScore: 4.90,
        leaveBalance: 12,
        casualLeaves: 5,
        sickLeaves: 4,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98205 99001 (Alok Verma - Spouse)',
        bio: 'People executive directing employee engagement, university hiring cohorts, competitive compensation, and corporate ethics.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['People Operations', 'Executive Leadership', 'Organizational Design', 'Talent Strategy', 'Policy Governance'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'FinTech Payment Gateway Microservices', 'Corporate People Hub & Workforce System'],
      ),
      Employee(
        id: 'EMP-402',
        name: 'Amitabh Roy',
        email: 'amitabh.roy@digitalinertia.com',
        phone: '+91 98331 44590',
        role: 'Lead Talent Acquisition & University Hiring',
        category: RoleCategory.nonTechnical,
        department: 'HR',
        departmentId: 'DEPT-HR',
        subDepartmentId: 'DEPT-HR-TA',
        subDepartmentName: 'Talent Acquisition',
        team: 'People & Culture',
        reportingManager: 'Sunita Verma',
        joiningDate: DateTime(2023, 8, 25),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 20,
        performanceScore: 4.82,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98331 77880 (Bina Roy - Mother)',
        bio: 'Heads campus cohort recruitment across IITs, NITs, and BITS, managing technical screening assessments and offer rollout.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Campus Recruitment', 'Technical Interviewing', 'Applicant Tracking', 'Candidate Pipeline'],
        assignedProjectNames: ['EcoTrack IoT Mobile Platform', 'Corporate People Hub & Workforce System'],
      ),
      Employee(
        id: 'EMP-403',
        name: 'Neha Bansal',
        email: 'neha.bansal@digitalinertia.com',
        phone: '+91 98110 99450',
        role: 'HR Operations & People Compliance',
        category: RoleCategory.nonTechnical,
        department: 'HR',
        departmentId: 'DEPT-HR',
        subDepartmentId: 'DEPT-HR-OPS',
        subDepartmentName: 'HR Operations',
        team: 'People & Culture',
        reportingManager: 'Sunita Verma',
        joiningDate: DateTime(2023, 10, 18),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 16,
        performanceScore: 4.76,
        leaveBalance: 15,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98110 33446 (Tarun Bansal - Brother)',
        bio: 'Administers employee lifecycle paperwork, statutory compliance, benefits administration, background verification, and leave portals.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['HR Operations', 'Statutory Compliance', 'Payroll Deductions', 'Benefits Management'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'Corporate People Hub & Workforce System'],
      ),
      Employee(
        id: 'EMP-404',
        name: 'Karan Singhania',
        email: 'karan.singhania@digitalinertia.com',
        phone: '+91 98720 33008',
        role: 'Employee Experience & Learning Specialist',
        category: RoleCategory.nonTechnical,
        department: 'HR',
        departmentId: 'DEPT-HR',
        subDepartmentId: 'DEPT-HR-LND',
        subDepartmentName: 'Learning & Dev',
        team: 'People & Culture',
        reportingManager: 'Sunita Verma',
        joiningDate: DateTime(2024, 1, 20),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 12,
        performanceScore: 4.72,
        leaveBalance: 16,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98720 11225 (Renu Singhania - Mother)',
        bio: 'Designs onboarding bootcamps, continuous engineering learning curricula, team offsites, and internal company hackathons.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Employee Experience', 'L&D Curricula', 'Team Culture', 'Internal Events'],
        assignedProjectNames: ['Digital Marketing & Growth Engine'],
      ),
      Employee(
        id: 'EMP-405',
        name: 'Divya Nambiar',
        email: 'divya.nambiar@digitalinertia.com',
        phone: '+91 98300 22009',
        role: 'Workforce Analytics & HR Business Partner',
        category: RoleCategory.nonTechnical,
        department: 'HR',
        departmentId: 'DEPT-HR',
        subDepartmentId: 'DEPT-HR-BP',
        subDepartmentName: 'HR Business Partner',
        team: 'People & Culture',
        reportingManager: 'Sunita Verma',
        joiningDate: DateTime(2024, 3, 5),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 10,
        performanceScore: 4.80,
        leaveBalance: 17,
        casualLeaves: 8,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98300 88993 (Madhavan Nambiar - Father)',
        bio: 'Consults with department leads on headcount planning, performance management cycles, and team productivity telemetry.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['HR Business Partnering', 'Workforce Analytics', 'Performance Review Systems', 'Headcount Modeling'],
        assignedProjectNames: ['OmniChannel Enterprise Sales Rollout'],
      ),

      // ==========================================
      // DEPARTMENT 5: Finance (5 Employees)
      // ==========================================
      Employee(
        id: 'EMP-501',
        name: 'Rameshwar Gupta',
        email: 'rameshwar.gupta@digitalinertia.com',
        phone: '+91 98111 20005',
        role: 'Chief Financial Officer',
        category: RoleCategory.nonTechnical,
        department: 'Finance',
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-CFO',
        subDepartmentName: 'Executive Finance',
        team: 'Corporate Finance & Accounts',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2023, 3, 1),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 30,
        performanceScore: 4.95,
        leaveBalance: 10,
        casualLeaves: 4,
        sickLeaves: 3,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98111 44557 (Usha Gupta - Spouse)',
        bio: 'Executive CFO overseeing corporate fiscal health, capital allocation, statutory audits, investor relations, and financial risk governance.',
        location: 'Mumbai Office • Hybrid',
        skills: ['Corporate Finance', 'FP&A', 'Taxation & Auditing', 'Cash Flow Optimization', 'Investor Relations'],
        assignedProjectNames: ['FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-502',
        name: 'Shalini Rao',
        email: 'shalini.rao@digitalinertia.com',
        phone: '+91 98200 45003',
        role: 'Financial Controller & Head of Accounts',
        category: RoleCategory.nonTechnical,
        department: 'Finance',
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-CTL',
        subDepartmentName: 'Controllership',
        team: 'Corporate Finance & Accounts',
        reportingManager: 'Rameshwar Gupta',
        joiningDate: DateTime(2023, 6, 15),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 25,
        performanceScore: 4.88,
        leaveBalance: 13,
        casualLeaves: 5,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98200 77882 (Gokul Rao - Spouse)',
        bio: 'Supervises month-end ledger closing, GAAP/IFRS accounting compliance, multi-entity consolidation, and banking accounts.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Financial Controllership', 'General Ledger', 'Audit Readiness', 'Entity Consolidation'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'FinTech Payment Gateway Microservices'],
      ),
      Employee(
        id: 'EMP-503',
        name: 'Manish Aggarwal',
        email: 'manish.aggarwal@digitalinertia.com',
        phone: '+91 98410 78004',
        role: 'Senior Corporate Accountant & Ledger',
        category: RoleCategory.nonTechnical,
        department: 'Finance',
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-ACC',
        subDepartmentName: 'Accounting',
        team: 'Corporate Finance & Accounts',
        reportingManager: 'Shalini Rao',
        joiningDate: DateTime(2023, 9, 1),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 1,
        completedTaskCount: 19,
        performanceScore: 4.74,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98410 11226 (Pawan Aggarwal - Brother)',
        bio: 'Specializes in accounts payable, vendor disbursement cycles, TDS/GST tax filings, and bank reconciliation routines.',
        location: 'Bengaluru HQ • On-site',
        skills: ['Corporate Accounting', 'GST & Direct Tax', 'Accounts Payable', 'Bank Reconciliations'],
        assignedProjectNames: ['EcoTrack IoT Mobile Platform'],
      ),
      Employee(
        id: 'EMP-504',
        name: 'Deepak Chawla',
        email: 'deepak.chawla@digitalinertia.com',
        phone: '+91 98450 12001',
        role: 'Financial Analyst & Budget Planning',
        category: RoleCategory.nonTechnical,
        department: 'Finance',
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-FPA',
        subDepartmentName: 'FP&A',
        team: 'Corporate Finance & Accounts',
        reportingManager: 'Shalini Rao',
        joiningDate: DateTime(2024, 1, 10),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 15,
        performanceScore: 4.82,
        leaveBalance: 16,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98450 99883 (Anita Chawla - Mother)',
        bio: 'Builds revenue forecast models, quarterly department budget variance analyses, burn rate dashboards, and ROI models.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['FP&A Modeling', 'Budget Variance Analysis', 'Unit Economics', 'Excel Financial Engineering'],
        assignedProjectNames: ['Digital Marketing & Growth Engine', 'Corporate People Hub & Workforce System'],
      ),
      Employee(
        id: 'EMP-505',
        name: 'Tanvi Mathur',
        email: 'tanvi.mathur@digitalinertia.com',
        phone: '+91 98311 44014',
        role: 'Billing, Payroll & Invoicing Specialist',
        category: RoleCategory.nonTechnical,
        department: 'Finance',
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-BIL',
        subDepartmentName: 'Billing & Payroll',
        team: 'Corporate Finance & Accounts',
        reportingManager: 'Shalini Rao',
        joiningDate: DateTime(2024, 2, 28),
        employmentStatus: 'Full-time',
        isPOC: false,
        isActive: true,
        activeTaskCount: 2,
        completedTaskCount: 14,
        performanceScore: 4.70,
        leaveBalance: 16,
        casualLeaves: 7,
        sickLeaves: 5,
        paidLeaves: 4,
        employmentType: 'Permanent Employee',
        emergencyContact: '+91 98311 66770 (Sanjay Mathur - Father)',
        bio: 'Directs client milestone invoicing, automated recurring subscription billings, accounts receivable aging, and employee payroll.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Invoicing & Billing', 'Payroll Processing', 'Accounts Receivable', 'Stripe Billing'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'OmniChannel Enterprise Sales Rollout'],
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
      // =========================================================================
      // 1. TECHNICAL EMPLOYEE DASHBOARD FEATURED TASKS (Arjun Sharma - EMP-101)
      // =========================================================================
      CompanyTask(
        id: 'TSK-100A',
        title: 'Client Pitch Deck Finalization',
        description: 'Finalize high-impact executive presentation deck for client pitch. Align value propositions, milestone delivery roadmap, and SLA architecture.',
        domain: 'Technical',
        team: 'Client Experience Engineering',
        department: 'Technical',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-201',
        assignedByName: 'Rajesh Kumar',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now(), // Due today
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 75,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-100B',
        title: 'Strategic Growth Audit Review',
        description: 'Conduct comprehensive audit review on key performance levers, scalability metrics, and client engagement deliverables for Q4 expansion.',
        domain: 'Technical',
        team: 'Client Experience Engineering',
        department: 'Technical',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-201',
        assignedByName: 'Rajesh Kumar',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now(), // Due today
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        progressPercent: 40,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-100C',
        title: 'Beta Architecture Design',
        description: 'Review high-level architectural blueprints for the analytics streaming engine, message broker throughput, and telemetry schema.',
        domain: 'Technical',
        team: 'Core Platform Engineering',
        department: 'Technical',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 80,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-101',
        title: 'Conversion Pixel & Telemetry SDK Integration',
        description: 'Embed Meta CAPI, Google Ads Tag, and server-side tracking pipelines with sub-millisecond response for the Digital Marketing Campaign.',
        domain: 'Technical',
        team: 'Client Experience Engineering',
        department: 'Technical',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime(2026, 10, 18), // Deadline card target
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 60,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CompanyTask(
        id: 'TSK-100D',
        title: 'Executive KPI Card System Implementation',
        description: 'Built 2x3 uniform responsive grid architecture with real-time target metrics and notification badges for the technical dashboard.',
        domain: 'Technical',
        team: 'Client Experience Engineering',
        department: 'Technical',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        status: TaskStatus.done,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // =========================================================================
      // 2. TECHNICAL DEPARTMENT (Priya Nair, Karthik R, Sneha V, Rohan Mehta, Shreya)
      // =========================================================================
      CompanyTask(
        id: 'TSK-102',
        title: 'Real-time Marketing Attribution API',
        description: 'Build high-throughput event ingestion endpoint to reconcile multi-touch campaign attribution IDs with client conversion events.',
        domain: 'Technical',
        team: 'Core Platform Engineering',
        department: 'Technical',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().add(const Duration(days: 6)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 65,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-202',
        title: 'PostgreSQL 18 Query Latency Optimization',
        description: 'Optimize execution plans for employee task rollups and add composite indexes for multi-tenant queries.',
        domain: 'Technical',
        team: 'Core Platform Engineering',
        department: 'Technical',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 70,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-501',
        title: 'PCI-DSS HSM Hardware Security Module Attestation',
        description: 'Deployed Argon2id password hashing, hardware token signing, and SOC-2 Type II audit logs for PulsePay payment microservices.',
        domain: 'Technical',
        team: 'Core Platform Engineering',
        department: 'Technical',
        assignedToId: 'EMP-102',
        assignedToName: 'Priya Nair',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair',
        projectId: 'PRJ-405',
        projectName: 'FinTech Payment Gateway Microservices',
        dueDate: DateTime(2026, 9, 15),
        status: TaskStatus.done,
        priority: TaskPriority.urgent,
        progressPercent: 100,
        completedAt: DateTime(2026, 9, 15),
        createdAt: DateTime(2026, 9, 1),
      ),
      CompanyTask(
        id: 'TSK-203',
        title: 'Centralized State Provider Architecture',
        description: 'Refactor state machines to broadcast granular updates via ChangeNotifier across all department screens.',
        domain: 'Technical',
        team: 'Core Platform Engineering',
        department: 'Technical',
        assignedToId: 'EMP-103',
        assignedToName: 'Karthik R',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 80,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CompanyTask(
        id: 'TSK-302',
        title: 'Edge Telemetry Time-Series Pipeline',
        description: 'Process 5,000 pings/sec of power, voltage, and temperature metrics with TimescaleDB retention.',
        domain: 'Technical',
        team: 'Core Platform Engineering',
        department: 'Technical',
        assignedToId: 'EMP-103',
        assignedToName: 'Karthik R',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-403',
        projectName: 'EcoTrack IoT Mobile Platform',
        dueDate: DateTime.now().add(const Duration(days: 8)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-204',
        title: 'Design Tokens & 2x3 Grid Layout Standard',
        description: 'Implement monochrome theme tokens and uniform childAspectRatio grids across dashboard cards.',
        domain: 'Technical',
        team: 'Client Experience Engineering',
        department: 'Technical',
        assignedToId: 'EMP-104',
        assignedToName: 'Sneha V',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.done,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-403',
        title: 'Sales Companion Offline Field App',
        description: 'Implement local SQLite database caching and optimistic sync for field sales reps in transit.',
        domain: 'Technical',
        team: 'Client Experience Engineering',
        department: 'Technical',
        assignedToId: 'EMP-104',
        assignedToName: 'Sneha V',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-404',
        projectName: 'OmniChannel Enterprise Sales Rollout',
        dueDate: DateTime.now().add(const Duration(days: 9)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-301',
        title: 'BLE Inverter Telemetry Companion App',
        description: 'Implement Bluetooth Low Energy GATT characteristic listener in Flutter for solar inverters.',
        domain: 'Technical',
        team: 'Client Experience Engineering',
        department: 'Technical',
        assignedToId: 'EMP-105',
        assignedToName: 'Rohan Mehta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta',
        projectId: 'PRJ-403',
        projectName: 'EcoTrack IoT Mobile Platform',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 65,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-205',
        title: 'Technical Deliverables & Sub-Task Partitioning',
        description: 'Decompose quarterly sprint objectives into actionable individual developer work packages.',
        domain: 'Technical',
        team: 'Client Experience Engineering',
        department: 'Technical',
        assignedToId: 'EMP-118',
        assignedToName: 'Shreya Kulkarni',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 60,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // =========================================================================
      // 3. SALES & MARKETING DEPARTMENT (Rajesh, Meera, Vikram, Ananya, Aditya)
      // =========================================================================
      CompanyTask(
        id: 'TSK-401',
        title: 'Zenith Logistics Enterprise Master Service Contract',
        description: 'Negotiate master terms, SLA penalty schedules, and multi-year maintenance tiers with client counsel.',
        domain: 'Sales & Marketing',
        team: 'Corporate Growth & Sales',
        department: 'Sales & Marketing',
        assignedToId: 'EMP-201',
        assignedToName: 'Rajesh Kumar',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-201',
        assignedByName: 'Rajesh Kumar',
        projectId: 'PRJ-404',
        projectName: 'OmniChannel Enterprise Sales Rollout',
        dueDate: DateTime.now().add(const Duration(days: 6)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 55,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CompanyTask(
        id: 'TSK-402',
        title: 'Territory Account Mapping & Sales Rep Quota Allocation',
        description: 'Distribute regional enterprise target accounts across 5 enterprise sales account executives.',
        domain: 'Sales & Marketing',
        team: 'Corporate Growth & Sales',
        department: 'Sales & Marketing',
        assignedToId: 'EMP-202',
        assignedToName: 'Meera Sen',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-201',
        assignedByName: 'Rajesh Kumar',
        projectId: 'PRJ-404',
        projectName: 'OmniChannel Enterprise Sales Rollout',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-106',
        title: 'Inbound Lead Qualification & CRM Attribution Sync',
        description: 'Configure automated HubSpot webhook triggers to route marketing-qualified leads to sales reps.',
        domain: 'Sales & Marketing',
        team: 'Corporate Growth & Sales',
        department: 'Sales & Marketing',
        assignedToId: 'EMP-203',
        assignedToName: 'Vikram Malhotra',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-201',
        assignedByName: 'Rajesh Kumar',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 65,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-206',
        title: 'Executive Sales Dashboard Requirements Sign-off',
        description: 'Review pipeline funnel analytics, deal stage transitions, and quarterly quota projections.',
        domain: 'Sales & Marketing',
        team: 'Corporate Growth & Sales',
        department: 'Sales & Marketing',
        assignedToId: 'EMP-204',
        assignedToName: 'Ananya Kapoor',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-201',
        assignedByName: 'Rajesh Kumar',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CompanyTask(
        id: 'TSK-303',
        title: 'CleanTech Enterprise Trial & Demo Coordination',
        description: 'Coordinate on-site hardware pilot demonstration for 3 commercial solar farm operators.',
        domain: 'Sales & Marketing',
        team: 'Corporate Growth & Sales',
        department: 'Sales & Marketing',
        assignedToId: 'EMP-205',
        assignedToName: 'Aditya Joshi',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-201',
        assignedByName: 'Rajesh Kumar',
        projectId: 'PRJ-403',
        projectName: 'EcoTrack IoT Mobile Platform',
        dueDate: DateTime.now().add(const Duration(days: 8)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 55,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // =========================================================================
      // 4. DIGITAL MARKETING DEPARTMENT (Kavita, Sameer, Pooja, Naveen, Rhea)
      // =========================================================================
      CompanyTask(
        id: 'TSK-103B',
        title: 'Omnichannel Marketing Funnel Strategy & Budget Allocation',
        description: 'Direct multi-channel paid ad funnel, retargeting rules, and conversion tracking KPIs for OmniSphere Retail.',
        domain: 'Digital Marketing',
        team: 'Digital Marketing & Growth',
        department: 'Digital Marketing',
        assignedToId: 'EMP-301',
        assignedToName: 'Kavita Reddy',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 75,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CompanyTask(
        id: 'TSK-310',
        title: 'Organic Search Growth & Core Web Vitals Optimization',
        description: 'Lead high-impact SEO strategy, Core Web Vitals performance benchmarks, and keyword clustering for enterprise clients.',
        domain: 'Digital Marketing',
        team: 'Digital Marketing & Growth',
        department: 'Digital Marketing',
        assignedToId: 'EMP-113',
        assignedToName: 'Sanjay Menon',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 65,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-103',
        title: 'Google & Meta Omnichannel PPC Campaign Launch',
        description: 'Configure high-intent search ads, dynamic remarketing catalog, and target ROAS bid strategy.',
        domain: 'Digital Marketing',
        team: 'Digital Marketing & Growth',
        department: 'Digital Marketing',
        assignedToId: 'EMP-302',
        assignedToName: 'Sameer Deshmukh',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 70,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-104',
        title: 'Organic Keyword Silo & Technical SEO Overhaul',
        description: 'Implement Core Web Vitals audit, schema structured data, and high-volume pillar content clusters.',
        domain: 'Digital Marketing',
        team: 'Digital Marketing & Growth',
        department: 'Digital Marketing',
        assignedToId: 'EMP-303',
        assignedToName: 'Pooja Hegde',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 65,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CompanyTask(
        id: 'TSK-209',
        title: 'Corporate Brand Identity & Typography Guidelines',
        description: 'Publish Instrument Sans font styling rules, SVG logo assets, and social badge components.',
        domain: 'Digital Marketing',
        team: 'Digital Marketing & Growth',
        department: 'Digital Marketing',
        assignedToId: 'EMP-304',
        assignedToName: 'Naveen Chandra',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 4)),
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      CompanyTask(
        id: 'TSK-105',
        title: 'High-Converting Ad Creatives & Brand Video Assets',
        description: 'Deliver motion graphics, responsive display banners, and TikTok/Reels product showcases.',
        domain: 'Digital Marketing',
        team: 'Digital Marketing & Growth',
        department: 'Digital Marketing',
        assignedToId: 'EMP-305',
        assignedToName: 'Rhea Pillai',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CompanyTask(
        id: 'TSK-404',
        title: 'B2B Sales Enablement Collateral & Interactive Calculator',
        description: 'Produce interactive ROI savings calculator web widget and enterprise product one-pagers.',
        domain: 'Digital Marketing',
        team: 'Digital Marketing & Growth',
        department: 'Digital Marketing',
        assignedToId: 'EMP-305',
        assignedToName: 'Rhea Pillai',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-301',
        assignedByName: 'Kavita Reddy',
        projectId: 'PRJ-404',
        projectName: 'OmniChannel Enterprise Sales Rollout',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        progressPercent: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // =========================================================================
      // 5. HR DEPARTMENT (Sunita, Amitabh, Neha, Karan, Divya)
      // =========================================================================
      CompanyTask(
        id: 'TSK-504',
        title: 'Compliance & Infosec Security Training Cohort',
        description: 'Conducted mandatory ISO 27001 zero-trust training and secure coding assessment for engineers.',
        domain: 'HR',
        team: 'People & Culture',
        department: 'HR',
        assignedToId: 'EMP-401',
        assignedToName: 'Sunita Verma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-401',
        assignedByName: 'Sunita Verma',
        projectId: 'PRJ-405',
        projectName: 'FinTech Payment Gateway Microservices',
        dueDate: DateTime(2026, 9, 18),
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime(2026, 9, 18),
        createdAt: DateTime(2026, 9, 5),
      ),
      CompanyTask(
        id: 'TSK-306',
        title: 'Embedded Systems Firmware Staffing Requisition',
        description: 'Interview 4 senior embedded C++ and RTOS engineers for Phase 2 hardware integration sprint.',
        domain: 'HR',
        team: 'People & Culture',
        department: 'HR',
        assignedToId: 'EMP-402',
        assignedToName: 'Amitabh Roy',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-401',
        assignedByName: 'Sunita Verma',
        projectId: 'PRJ-403',
        projectName: 'EcoTrack IoT Mobile Platform',
        dueDate: DateTime.now().add(const Duration(days: 8)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        progressPercent: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-207',
        title: 'Employee Directory & Leave Balance Integration',
        description: 'Verify 25 employee profiles, reporting chains, and automated annual leave quota deductions.',
        domain: 'HR',
        team: 'People & Culture',
        department: 'HR',
        assignedToId: 'EMP-403',
        assignedToName: 'Neha Bansal',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-401',
        assignedByName: 'Sunita Verma',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 80,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-108',
        title: 'Creative Agency & Freelance Contractor Onboarding',
        description: 'Execute master services agreements and compliance NDAs for external video production team.',
        domain: 'HR',
        team: 'People & Culture',
        department: 'HR',
        assignedToId: 'EMP-404',
        assignedToName: 'Karan Singhania',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-401',
        assignedByName: 'Sunita Verma',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CompanyTask(
        id: 'TSK-406',
        title: 'Sales Incentive & Commission Policy Framework',
        description: 'Draft quarterly performance incentive tiers, accelerated attainment accelerators, and SPIFFs.',
        domain: 'HR',
        team: 'People & Culture',
        department: 'HR',
        assignedToId: 'EMP-405',
        assignedToName: 'Divya Nambiar',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-401',
        assignedByName: 'Sunita Verma',
        projectId: 'PRJ-404',
        projectName: 'OmniChannel Enterprise Sales Rollout',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // =========================================================================
      // 6. FINANCE DEPARTMENT (Siddharth, Rameshwar, Shalini, Manish, Deepak, Tanvi)
      // =========================================================================
      CompanyTask(
        id: 'TSK-510',
        title: 'Q4 Budget Allocation & Feasibility Sign-off',
        description: 'Review departmental CAPEX/OPEX resource requests, cashflow forecasting, and commercial feasibility margins for upcoming client contracts.',
        domain: 'Finance',
        team: 'Corporate Finance & Accounts',
        department: 'Finance',
        assignedToId: 'EMP-115',
        assignedToName: 'Siddharth Roy',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-115',
        assignedByName: 'Siddharth Roy',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 60,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-503',
        title: 'Banking Settlement & Escrow Account Reconciliation',
        description: 'Automated reconciliation routines matching 100,000 daily transaction batches with central banks.',
        domain: 'Finance',
        team: 'Corporate Finance & Accounts',
        department: 'Finance',
        assignedToId: 'EMP-501',
        assignedToName: 'Rameshwar Gupta',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-501',
        assignedByName: 'Rameshwar Gupta',
        projectId: 'PRJ-405',
        projectName: 'FinTech Payment Gateway Microservices',
        dueDate: DateTime(2026, 9, 25),
        status: TaskStatus.done,
        priority: TaskPriority.urgent,
        progressPercent: 100,
        completedAt: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 10),
      ),
      CompanyTask(
        id: 'TSK-208',
        title: 'Enterprise General Ledger Chart of Accounts Validation',
        description: 'Audit journal voucher posting rules, cost center tagging, and depreciation schedule tables.',
        domain: 'Finance',
        team: 'Corporate Finance & Accounts',
        department: 'Finance',
        assignedToId: 'EMP-502',
        assignedToName: 'Shalini Rao',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-501',
        assignedByName: 'Rameshwar Gupta',
        projectId: 'PRJ-402',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 75,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-305',
        title: 'IoT Sensor Hardware Bill of Materials Audit',
        description: 'Reconcile procurement purchase orders for IoT gateways, sensors, and customs duty fees.',
        domain: 'Finance',
        team: 'Corporate Finance & Accounts',
        department: 'Finance',
        assignedToId: 'EMP-503',
        assignedToName: 'Manish Aggarwal',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-502',
        assignedByName: 'Shalini Rao',
        projectId: 'PRJ-403',
        projectName: 'EcoTrack IoT Mobile Platform',
        dueDate: DateTime.now().subtract(const Duration(days: 4)),
        status: TaskStatus.done,
        priority: TaskPriority.high,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CompanyTask(
        id: 'TSK-107',
        title: 'Marketing Ad Spend & CAC Financial Audit',
        description: 'Reconcile prepaid ad network invoices against monthly burn rate and audit blended CAC metrics.',
        domain: 'Finance',
        team: 'Corporate Finance & Accounts',
        department: 'Finance',
        assignedToId: 'EMP-504',
        assignedToName: 'Deepak Chawla',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-501',
        assignedByName: 'Rameshwar Gupta',
        projectId: 'PRJ-401',
        projectName: 'Digital Marketing & Growth Engine',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 70,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-405',
        title: 'Recurring Enterprise Invoicing & Milestone Schedule',
        description: 'Configure automated recurring billing for quarterly software licenses and bank wire instructions.',
        domain: 'Finance',
        team: 'Corporate Finance & Accounts',
        department: 'Finance',
        assignedToId: 'EMP-505',
        assignedToName: 'Tanvi Mathur',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-502',
        assignedByName: 'Shalini Rao',
        projectId: 'PRJ-404',
        projectName: 'OmniChannel Enterprise Sales Rollout',
        dueDate: DateTime.now().add(const Duration(days: 6)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 55,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
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

    // Active Projects (matching PostgreSQL 02_seed.sql / V5 migrations: PRJ-301 EcoTrack, PRJ-304 delayed alert)
    _projects = [
      // Project 0: EcoTrack App (PRJ-301 - CleanTech Innovations, synchronized with _projectBudgets)
      Project(
        id: 'PRJ-301',
        name: 'EcoTrack App',
        clientName: 'CleanTech Innovations',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedDepartments: const ['Technical', 'Finance', 'Sales & Marketing', 'Digital Marketing', 'HR'],
        description: 'Cross-platform Flutter mobile dashboard and BLE sensor gateway for rooftop solar farms, real-time inverter diagnostics, and battery health telemetry.',
        deliverablesScope: 'Flutter mobile client, BLE GATT communication, TimescaleDB telemetry pipeline, customer trial deployments, and BOM audit.',
        budget: 45000.0,
        ownerEmployeeId: 'EMP-105',
        ownerEmployeeName: 'Rohan Mehta',
        teamMemberNames: [
          'Rohan Mehta (Mobile Lead)',
          'Karthik R (Telemetry Backend)',
          'Priya Nair (Database Lead)',
          'Rajesh Kumar (Enterprise Sales)',
          'Siddharth Roy (Finance Controller)',
        ],
        status: ProjectStatus.inProgress,
        progress: 0.75, // 75%
        plannedProgress: 0.75,
        startDate: DateTime(2025, 1, 15),
        deadline: DateTime(2025, 5, 15),
      ),

      // Project 1: Digital Marketing & Growth Engine (Ongoing / In Progress - The Digital Marketing Project)
      Project(
        id: 'PRJ-401',
        name: 'Digital Marketing & Growth Engine',
        clientName: 'OmniSphere Retail',
        domain: 'Digital Marketing',
        team: 'Digital Marketing & Growth',
        assignedDepartments: const ['Digital Marketing', 'Technical', 'Sales & Marketing', 'Finance', 'HR'],
        description: 'Omnichannel digital marketing transformation: automated PPC retargeting engine, SEO overhaul, conversion tracking telemetry, and viral social campaign.',
        deliverablesScope: 'Full ad funnel, Meta & Google tracking SDKs, technical SEO architecture, conversion rate audit, and creative assets.',
        budget: 65000.0,
        ownerEmployeeId: 'EMP-301',
        ownerEmployeeName: 'Kavita Reddy',
        teamMemberNames: [
          'Kavita Reddy (Digital Marketing Lead)',
          'Sameer Deshmukh (PPC Specialist)',
          'Pooja Hegde (SEO Strategist)',
          'Rhea Pillai (Creative Visuals)',
          'Arjun Sharma (Frontend & SDKs)',
          'Priya Nair (Backend Data Pipeline)',
          'Vikram Malhotra (Lead Attribution Sync)',
          'Deepak Chawla (Ad Spend & CAC Audit)',
          'Karan Singhania (Agency Onboarding)'
        ],
        status: ProjectStatus.inProgress,
        progress: 0.70, // 70%
        plannedProgress: 0.75,
        startDate: DateTime(2026, 8, 1),
        deadline: DateTime(2026, 12, 15),
      ),

      // Project 2: Digital Inertia ERP Core (Ongoing / In Progress)
      Project(
        id: 'PRJ-402',
        name: 'Digital Inertia ERP Core',
        clientName: 'DI Strategic Holdings',
        domain: 'Web Platform',
        team: 'Core Platform Engineering',
        assignedDepartments: const ['Technical', 'Sales & Marketing', 'HR', 'Finance', 'Digital Marketing'],
        description: 'Multi-tenant enterprise ERP platform unifying engineering workflows, sales CRM pipelines, HR workforce directories, and financial accounting ledgers.',
        deliverablesScope: 'State provider architecture, responsive dashboard layouts, PostgreSQL replication, role hierarchies, and real-time alerts.',
        budget: 120000.0,
        ownerEmployeeId: 'EMP-102',
        ownerEmployeeName: 'Priya Nair',
        teamMemberNames: [
          'Priya Nair (Backend Lead)',
          'Arjun Sharma (Frontend Architect)',
          'Karthik R (Full Stack)',
          'Sneha V (Design Systems UI)',
          'Rohan Mehta (Mobile Lead)',
          'Shreya Kulkarni (Full Stack Specialist)',
          'Rajesh Kumar (Sales VP)',
          'Ananya Kapoor (Solutions Consultant)',
          'Sunita Verma (HR Director)',
          'Neha Bansal (HR Compliance)',
          'Shalini Rao (Financial Controller)',
          'Tanvi Mathur (Invoicing Specialist)',
          'Naveen Chandra (Brand & Typography)'
        ],
        status: ProjectStatus.inProgress,
        progress: 0.85, // 85%
        plannedProgress: 0.85,
        startDate: DateTime(2026, 6, 1),
        deadline: DateTime(2026, 11, 30),
      ),

      // Project 3: EcoTrack IoT Mobile Platform (Ongoing / In Progress)
      Project(
        id: 'PRJ-403',
        name: 'EcoTrack IoT Mobile Platform',
        clientName: 'CleanTech Innovations',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        assignedDepartments: const ['Technical', 'Sales & Marketing', 'Finance', 'HR', 'Digital Marketing'],
        description: 'Cross-platform Flutter mobile dashboard and BLE sensor gateway for rooftop solar farms, real-time inverter diagnostics, and battery health telemetry.',
        deliverablesScope: 'Flutter mobile client, BLE GATT communication, TimescaleDB telemetry pipeline, customer trial deployments, and BOM audit.',
        budget: 95000.0,
        ownerEmployeeId: 'EMP-105',
        ownerEmployeeName: 'Rohan Mehta',
        teamMemberNames: [
          'Rohan Mehta (Mobile Lead)',
          'Karthik R (Telemetry Backend)',
          'Priya Nair (Database Lead)',
          'Rajesh Kumar (Enterprise Sales)',
          'Aditya Joshi (Sales Operations)',
          'Manish Aggarwal (Hardware BOM Audit)',
          'Amitabh Roy (Firmware Staffing)',
          'Sameer Deshmukh (CleanTech Case Study)'
        ],
        status: ProjectStatus.inProgress,
        progress: 0.58, // 58%
        plannedProgress: 0.60,
        startDate: DateTime(2026, 7, 15),
        deadline: DateTime(2027, 1, 31),
      ),

      // Project 4: OmniChannel Enterprise Sales Rollout (Ongoing / In Progress)
      Project(
        id: 'PRJ-404',
        name: 'OmniChannel Enterprise Sales Rollout',
        clientName: 'Zenith Global Logistics',
        domain: 'Sales & CRM',
        team: 'Corporate Growth & Sales',
        assignedDepartments: const ['Sales & Marketing', 'Technical', 'Digital Marketing', 'Finance', 'HR'],
        description: 'Automated enterprise B2B sales automation engine, quote-to-cash workflow, field sales mobile companion, and sales commission incentive tracker.',
        deliverablesScope: 'Sales funnel stages, offline SQLite field app, B2B enablement calculator, milestone billing schedules, and quota tier rubrics.',
        budget: 80000.0,
        ownerEmployeeId: 'EMP-201',
        ownerEmployeeName: 'Rajesh Kumar',
        teamMemberNames: [
          'Rajesh Kumar (Sales VP)',
          'Meera Sen (Enterprise Deals)',
          'Vikram Malhotra (BD Manager)',
          'Sneha V (Sales Companion UI)',
          'Arjun Sharma (Frontend Architect)',
          'Kavita Reddy (Digital Marketing Lead)',
          'Rhea Pillai (Sales Enablement Collateral)',
          'Tanvi Mathur (Recurring Invoicing)',
          'Divya Nambiar (Commission Framework)'
        ],
        status: ProjectStatus.inProgress,
        progress: 0.44, // 44%
        plannedProgress: 0.50,
        startDate: DateTime(2026, 9, 1),
        deadline: DateTime(2027, 3, 31),
      ),

      // Project 5: FinTech Multi-Currency Payment Gateway (Completed)
      Project(
        id: 'PRJ-405',
        name: 'FinTech Payment Gateway Microservices',
        clientName: 'PulsePay Global',
        domain: 'Backend',
        team: 'Core Platform Engineering',
        assignedDepartments: const ['Technical', 'Finance', 'Sales & Marketing', 'HR', 'Digital Marketing'],
        description: 'PCI-DSS certified microservices payment routing, high-frequency currency exchange ledger, bank settlement webhooks, and zero-trust security audit.',
        deliverablesScope: 'HSM attestation, multi-currency ledger, bank reconciliation engine, ISO 27001 infosec training, and press wire release.',
        budget: 150000.0,
        ownerEmployeeId: 'EMP-102',
        ownerEmployeeName: 'Priya Nair',
        teamMemberNames: [
          'Priya Nair (Backend Lead)',
          'Karthik R (Ledger Engine)',
          'Arjun Sharma (Security Webhooks)',
          'Rameshwar Gupta (CFO)',
          'Shalini Rao (Controllership)',
          'Rajesh Kumar (Banking Relations)',
          'Sunita Verma (Infosec Compliance)',
          'Naveen Chandra (Global PR Wire)'
        ],
        status: ProjectStatus.completed,
        progress: 1.0, // 100%
        plannedProgress: 1.0,
        startDate: DateTime(2026, 1, 10),
        deadline: DateTime(2026, 9, 28),
      ),

      // Project 6: Corporate People Hub & Workforce System (Completed)
      Project(
        id: 'PRJ-406',
        name: 'Corporate People Hub & Workforce System',
        clientName: 'Inertia Talent Consortium',
        domain: 'HR & Recruitment',
        team: 'People & Culture',
        assignedDepartments: const ['HR', 'Technical', 'Finance', 'Digital Marketing', 'Sales & Marketing'],
        description: 'Comprehensive people ops platform: university campus cohort screening, intern performance rubric evaluation, employee self-service portal, and payroll integration.',
        deliverablesScope: 'Campus recruitment portal, interview panel rostering, employee mobile self-service app, stipend disbursements, and campus employer branding.',
        budget: 45000.0,
        ownerEmployeeId: 'EMP-401',
        ownerEmployeeName: 'Sunita Verma',
        teamMemberNames: [
          'Sunita Verma (HR Director)',
          'Amitabh Roy (University Hiring)',
          'Neha Bansal (People Operations)',
          'Sneha V (Self-Service Mobile UI)',
          'Deepak Chawla (Stipend Disbursement)',
          'Pooja Hegde (Campus Brand Campaign)',
          'Meera Sen (University Relations)'
        ],
        status: ProjectStatus.completed,
        progress: 1.0, // 100%
        plannedProgress: 1.0,
        startDate: DateTime(2026, 2, 1),
        deadline: DateTime(2026, 8, 30),
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

    // Seed Today's Executive Approvals (PRD Section 4.5 & 9.5)
    _approvalRequests = [
      CompanyApprovalRequest(
        id: 'APR-101',
        title: 'Autonomous Drone Fleet Telemetry Platform',
        submittingDepartment: 'Sales and Business Development',
        submittedByName: 'Rajesh Kumar',
        submittedByRole: 'Sales & BD Associate',
        submittedDate: DateTime.now().subtract(const Duration(hours: 4)),
        dealValueOrBudget: 450000.0,
        summary: 'Custom Edge AI & telemetry portal for drone logistics. Feasibility approved by HR (140h Tech Lead) and Finance (42% projected margin). Awaiting final CEO signoff.',
        leadId: 'LED-503',
        status: ApprovalStatus.pendingCeo,
      ),
      CompanyApprovalRequest(
        id: 'APR-102',
        title: 'Solar Energy Distributed Inverter Cloud Portal',
        submittingDepartment: 'Sales and Business Development',
        submittedByName: 'Rajesh Kumar',
        submittedByRole: 'Sales & BD Associate',
        submittedDate: DateTime.now().subtract(const Duration(hours: 6)),
        dealValueOrBudget: 280000.0,
        summary: 'Full Flutter mobile & web monitoring dashboard. HR availability confirmed with mobile & backend devs. Quoted price feasibility accepted.',
        leadId: 'LED-504',
        status: ApprovalStatus.pendingCeo,
      ),
      CompanyApprovalRequest(
        id: 'APR-103',
        title: 'Digital Marketing & Social Media Brand Retainer',
        submittingDepartment: 'Digital Marketing',
        submittedByName: 'Sanjay Menon',
        submittedByRole: 'Marketing Strategist',
        submittedDate: DateTime.now().subtract(const Duration(days: 1)),
        dealValueOrBudget: 150000.0,
        summary: '6-month social media marketing & SEO campaign retainer. 2 video editors and 1 performance marketing specialist allocated.',
        leadId: 'LED-502',
        status: ApprovalStatus.pendingGm,
      ),
    ];

    // Seed Scheduled Meetings (PRD Section 10 & 9.1)
    _meetings = [
      Meeting(
        id: 'MTG-00A',
        title: 'Q4 Strategic Alignment',
        participantNames: ['Rajesh Kumar', 'Arjun Sharma', 'Shreya Kulkarni', 'Laven Lokesh'],
        date: DateTime(2026, 10, 14),
        startTime: '11:00 AM',
        endTime: '12:00 PM',
        locationOrLink: 'Meet: di-q4-alignment',
        agenda: 'Review quarterly goals, delivery milestones, and technical alignment for DI Rebrand & Strategy.',
        organizerName: 'Rajesh K.',
        departmentOrProject: 'DI Rebrand & Strategy',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-02DM',
        title: 'Digital Marketing & Conversion Sprint',
        participantNames: ['Kavita Reddy', 'Sameer Deshmukh', 'Pooja Hegde', 'Rhea Pillai', 'Naveen Chandra', 'Arjun Sharma'],
        date: DateTime.now().add(const Duration(days: 1)),
        startTime: '02:00 PM',
        endTime: '03:00 PM',
        locationOrLink: 'Meet: di-marketing-sprint',
        agenda: 'Review Google Ads & Meta PPC ROAS metrics, conversion tracking pixel health, and organic SEO architecture.',
        organizerName: 'Kavita Reddy',
        departmentOrProject: 'Digital Marketing & Growth Engine',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-01',
        title: 'Weekly Executive Operations & Pipeline Sync',
        participantNames: ['Laven Lokesh', 'Arjun Sharma', 'Rajesh Kumar', 'Meera Joshi', 'Siddharth Roy'],
        date: DateTime.now(),
        startTime: '10:00 AM',
        endTime: '11:00 AM',
        locationOrLink: 'Executive Boardroom / Meet: di-exec-sync',
        agenda: 'Weekly cross-department review: sales targets, client project delivery status, and resource allocation.',
        organizerName: 'Laven Lokesh (CEO)',
        departmentOrProject: 'All Departments',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-02',
        title: 'Friday Internship Evaluation Committee',
        participantNames: ['Laven Lokesh', 'Meera Joshi', 'Arjun Sharma', 'Priya Nair'],
        date: DateTime.now(),
        startTime: '03:00 PM',
        endTime: '04:00 PM',
        locationOrLink: 'Talent Innovation Hub',
        agenda: 'Review 1-week observation results for 25 interns from Batch W41. Evaluate task consistency, interest, and approve employee conversions.',
        organizerName: 'Meera Joshi (HR)',
        departmentOrProject: 'HR & Internship',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-03',
        title: 'Client Feasibility & Architecture Alignment (GreenTech)',
        participantNames: ['Rajesh Kumar', 'Arjun Sharma', 'Priya Nair', 'Vikramaditya Rao (Client)'],
        date: DateTime.now(),
        startTime: '04:30 PM',
        endTime: '05:15 PM',
        locationOrLink: 'Google Meet: meet.google.com/greentech-di',
        agenda: 'Finalize technical dependencies, cloud infrastructure costs, and delivery milestone schedule before proposal signoff.',
        organizerName: 'Rajesh Kumar (Sales)',
        departmentOrProject: 'Technology and Engineering',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-04',
        title: 'Sprint 4 Backlog Grooming & Task Sizing',
        participantNames: ['Arjun Sharma', 'Sneha V', 'Rohan Mehta', 'Priya Nair'],
        date: DateTime.now().add(const Duration(days: 1)),
        startTime: '11:30 AM',
        endTime: '12:30 PM',
        locationOrLink: 'Google Meet: meet.google.com/di-sprint-groom',
        agenda: 'Review backlog user stories for Sprint 4, estimate story points, and commit sprint goals.',
        organizerName: 'Arjun Sharma (Lead)',
        departmentOrProject: 'Technology and Engineering',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-05',
        title: 'Architecture Security & Penetration Review',
        participantNames: ['Arjun Sharma', 'Priya Nair', 'Vikram Singh'],
        date: DateTime.now().add(const Duration(days: 3)),
        startTime: '02:00 PM',
        endTime: '03:00 PM',
        locationOrLink: 'Google Meet: meet.google.com/di-sec-review',
        agenda: 'Examine external pen-testing findings, OAuth token handling, and database connection pooling.',
        organizerName: 'Priya Nair (Engineering)',
        departmentOrProject: 'Technology and Engineering',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-06',
        title: 'Mobile App Performance Profiling Workshop',
        participantNames: ['Arjun Sharma', 'Rohan Mehta', 'Sneha V'],
        date: DateTime.now().add(const Duration(days: 5)),
        startTime: '04:00 PM',
        endTime: '05:00 PM',
        locationOrLink: 'Engineering Lab 2B',
        agenda: 'Hands-on profiling of Flutter raster threads, memory allocation, and render cache reuse.',
        organizerName: 'Arjun Sharma (Lead)',
        departmentOrProject: 'Technology and Engineering',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-07',
        title: 'Marketing & Sales Pipeline Growth Strategy',
        participantNames: ['Sanjay Menon', 'Rajesh Kumar', 'Laven Lokesh'],
        date: DateTime.now(),
        startTime: '01:30 PM',
        endTime: '02:30 PM',
        locationOrLink: 'Conference Room B / Meet: di-growth-sync',
        agenda: 'Review inbound lead conversion, Q4 content schedule, and brand collateral for upcoming tech expo.',
        organizerName: 'Sanjay Menon (Marketing)',
        departmentOrProject: 'Marketing',
        status: 'Scheduled',
      ),
      Meeting(
        id: 'MTG-08',
        title: 'Mid-Month Budget Utilization & Vendor Invoicing',
        participantNames: ['Siddharth Roy', 'Laven Lokesh', 'Pooja Hegde'],
        date: DateTime.now().add(const Duration(days: 2)),
        startTime: '03:00 PM',
        endTime: '04:00 PM',
        locationOrLink: 'Finance Operations Suite',
        agenda: 'Detailed audit of project cost variances, contractor milestone releases, and tax compliance filings.',
        organizerName: 'Siddharth Roy (Finance)',
        departmentOrProject: 'Finance',
        status: 'Scheduled',
      ),
    ];

    // Seed Sales Calls for Rajesh Kumar (EMP-112)
    // 16 calls completed today (target: 20/day), 2 overdue follow-ups, 3 follow-ups due today
    final now = DateTime.now();
    _salesCalls = [
      SalesCall(
        id: 'CALL-101',
        leadId: 'LED-501',
        customerName: 'Vikramaditya Rao',
        companyName: 'GreenTech Solutions',
        phone: '+91 98450 12001',
        timestamp: DateTime(now.year, now.month, now.day, 10, 15),
        outcome: CallOutcome.interested,
        notes: 'Very interested in IoT solar farm telemetry. Demo scheduled for 4:30 PM.',
        nextFollowUpDate: DateTime(now.year, now.month, now.day, 16, 30),
        dealValue: 350000.0,
        priority: 'Urgent',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-102',
        leadId: 'LED-502',
        customerName: 'Sarah Al-Mansoor',
        companyName: 'InnovortX',
        phone: '+971 50 123 4567',
        timestamp: DateTime(now.year, now.month, now.day, 10, 45),
        outcome: CallOutcome.followUpRequired,
        notes: 'Discussed Flutter consumer app payment gateway. Sending quotation breakdown.',
        nextFollowUpDate: DateTime(now.year, now.month, now.day, 16, 0),
        dealValue: 480000.0,
        priority: 'High',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-103',
        customerName: 'Devendra Joshi',
        companyName: 'Surya AgroTech',
        phone: '+91 98230 44101',
        timestamp: DateTime(now.year, now.month, now.day, 11, 10),
        outcome: CallOutcome.followUpRequired,
        notes: 'Requested case studies on cold chain solar monitoring.',
        nextFollowUpDate: DateTime(now.year, now.month, now.day, 17, 30),
        dealValue: 220000.0,
        priority: 'Urgent',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-104',
        leadId: 'LED-505',
        customerName: 'Marcus Vance',
        companyName: 'CyberShield Corp',
        phone: '+1 415 889 0105',
        timestamp: now.subtract(const Duration(days: 2)),
        outcome: CallOutcome.followUpRequired,
        notes: 'Overdue follow-up: Decision maker requested updated SLA and SOC2 terms.',
        nextFollowUpDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
        dealValue: 850000.0,
        priority: 'Urgent',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-105',
        customerName: 'Amit Singhania',
        companyName: 'Apex Logistix',
        phone: '+91 98110 33022',
        timestamp: now.subtract(const Duration(days: 3)),
        outcome: CallOutcome.followUpRequired,
        notes: 'Overdue follow-up: Fleet tracking pilot pricing check with CFO.',
        nextFollowUpDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 2)),
        dealValue: 310000.0,
        priority: 'High',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-106',
        leadId: 'LED-504',
        customerName: 'Kavitha Balasubramanian',
        companyName: 'SolarEase',
        phone: '+91 98410 78004',
        timestamp: DateTime(now.year, now.month, now.day, 11, 40),
        outcome: CallOutcome.interested,
        notes: 'B2B distributor portal. Forwarding feasibility review to HR & Finance.',
        nextFollowUpDate: now.add(const Duration(days: 2)),
        dealValue: 280000.0,
        priority: 'High',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-107',
        leadId: 'LED-503',
        customerName: 'Ramesh Namboodiri',
        companyName: 'Skyline Infra',
        phone: '+91 98200 45003',
        timestamp: DateTime(now.year, now.month, now.day, 12, 10),
        outcome: CallOutcome.interested,
        notes: 'Smart city IoT asset portal. Commercial quotation submitted to GM.',
        nextFollowUpDate: now.add(const Duration(days: 4)),
        dealValue: 620000.0,
        priority: 'Medium',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-108',
        customerName: 'Ananya Roy',
        companyName: 'FinSecure Labs',
        phone: '+91 98700 11223',
        timestamp: DateTime(now.year, now.month, now.day, 12, 35),
        outcome: CallOutcome.interested,
        notes: 'API banking sandbox compliance testing. Scheduled detailed presentation.',
        nextFollowUpDate: now.add(const Duration(days: 5)),
        dealValue: 550000.0,
        priority: 'Medium',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-109',
        customerName: 'Rajesh Khatri',
        companyName: 'Khatri Textiles',
        phone: '+91 97200 99881',
        timestamp: DateTime(now.year, now.month, now.day, 13, 05),
        outcome: CallOutcome.notInterested,
        notes: 'Not considering digital transformation software this quarter.',
        priority: 'Low',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-110',
        customerName: 'Deepak Sethi',
        companyName: 'Northern Logistics',
        phone: '+91 98112 44556',
        timestamp: DateTime(now.year, now.month, now.day, 13, 20),
        outcome: CallOutcome.noResponse,
        notes: 'Left voicemail regarding automated warehouse dispatch integration.',
        nextFollowUpDate: now.add(const Duration(days: 1)),
        priority: 'Low',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-111',
        customerName: 'Sunita Agarwal',
        companyName: 'MedCare Diagnostics',
        phone: '+91 99300 77665',
        timestamp: DateTime(now.year, now.month, now.day, 13, 45),
        outcome: CallOutcome.interested,
        notes: 'Interested in patient appointment mobile app with WhatsApp notifications.',
        nextFollowUpDate: now.add(const Duration(days: 3)),
        dealValue: 180000.0,
        priority: 'Medium',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-112',
        customerName: 'Pradeep Menon',
        companyName: 'Horizon Realty',
        phone: '+91 98480 33441',
        timestamp: DateTime(now.year, now.month, now.day, 14, 0),
        outcome: CallOutcome.noResponse,
        notes: 'Rang 5 times, no answer. Will retry tomorrow morning.',
        nextFollowUpDate: now.add(const Duration(days: 1)),
        priority: 'Low',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-113',
        customerName: 'Alok Verma',
        companyName: 'Verma Electronics',
        phone: '+91 98210 55443',
        timestamp: DateTime(now.year, now.month, now.day, 14, 20),
        outcome: CallOutcome.followUpRequired,
        notes: 'Requested callback after festive weekend to discuss ERP billing migration.',
        nextFollowUpDate: now.add(const Duration(days: 6)),
        dealValue: 140000.0,
        priority: 'Medium',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-114',
        customerName: 'Meenakshi Sundaram',
        companyName: 'Starlight Retail',
        phone: '+91 98400 66778',
        timestamp: DateTime(now.year, now.month, now.day, 14, 40),
        outcome: CallOutcome.notInterested,
        notes: 'Existing vendor contract renewed for 2 years.',
        priority: 'Low',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-115',
        customerName: 'Tarun Bhatia',
        companyName: 'Bhatia Steel Fabricators',
        phone: '+91 98101 22334',
        timestamp: DateTime(now.year, now.month, now.day, 15, 05),
        outcome: CallOutcome.noResponse,
        notes: 'Secretary mentioned executive was traveling.',
        priority: 'Low',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-116',
        customerName: 'Nikhil Nair',
        companyName: 'Nair Hospitality Suites',
        phone: '+91 98455 88990',
        timestamp: DateTime(now.year, now.month, now.day, 15, 25),
        outcome: CallOutcome.interested,
        notes: 'Exploring guest check-in QR solution. Sent feature deck.',
        nextFollowUpDate: now.add(const Duration(days: 3)),
        dealValue: 240000.0,
        priority: 'High',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-117',
        customerName: 'Sangeetha Pillai',
        companyName: 'Kochi Spices Export',
        phone: '+91 98460 33221',
        timestamp: DateTime(now.year, now.month, now.day, 15, 45),
        outcome: CallOutcome.followUpRequired,
        notes: 'ERP inventory batch tracking and customs export portal inquiry.',
        nextFollowUpDate: now.add(const Duration(days: 4)),
        dealValue: 190000.0,
        priority: 'Medium',
        isCompleted: true,
      ),
      SalesCall(
        id: 'CALL-118',
        customerName: 'Rahul Jain',
        companyName: 'Jain Auto Components',
        phone: '+91 98290 77112',
        timestamp: DateTime(now.year, now.month, now.day, 16, 05),
        outcome: CallOutcome.noResponse,
        notes: 'Left message with purchase desk. Will follow up tomorrow.',
        nextFollowUpDate: now.add(const Duration(days: 1)),
        priority: 'Low',
        isCompleted: true,
      ),
    ];

    // Seed Finance Project Budgets (aligned with _projects)
    _projectBudgets = [
      ProjectBudget(
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        clientName: 'CleanTech Innovations',
        domain: 'Mobile App',
        approvedBudget: 45000.0,
        spentAmount: 33750.0,
        allocations: [
          BudgetExpenseAllocation(
            id: 'ALC-01',
            category: 'Developer Hours',
            allocatedAmount: 25000.0,
            spentAmount: 20000.0,
            description: 'Flutter IoT telemetry engineers',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-02',
            category: 'Cloud Infrastructure',
            allocatedAmount: 12000.0,
            spentAmount: 9500.0,
            description: 'AWS IoT Core and DynamoDB tables',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-03',
            category: 'Hardware & Tooling',
            allocatedAmount: 8000.0,
            spentAmount: 4250.0,
            description: 'Solar inverter testing harnesses',
          ),
        ],
        adjustmentHistory: [
          BudgetAdjustmentRecord(
            id: 'ADJ-01',
            previousBudget: 40000.0,
            adjustmentAmount: 5000.0,
            newBudget: 45000.0,
            reason: 'Scope expansion: Added carbon credit export',
            approvedBy: 'Siddharth Roy',
            timestamp: now.subtract(const Duration(days: 15)),
          ),
        ],
      ),
      ProjectBudget(
        projectId: 'PRJ-302',
        projectName: 'Green Energy Dashboard',
        clientName: 'Enel Horizon Grid',
        domain: 'Web Platform',
        approvedBudget: 60000.0,
        spentAmount: 24000.0,
        allocations: [
          BudgetExpenseAllocation(
            id: 'ALC-04',
            category: 'Developer Hours',
            allocatedAmount: 40000.0,
            spentAmount: 16000.0,
            description: 'Full stack React & WebSockets engineering',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-05',
            category: 'Cloud Infrastructure',
            allocatedAmount: 15000.0,
            spentAmount: 6000.0,
            description: 'Redis cluster and TimeScaleDB storage',
          ),
        ],
      ),
      ProjectBudget(
        projectId: 'PRJ-303',
        projectName: 'AI Analytics Platform',
        clientName: 'Quantra BioSciences',
        domain: 'AI & Automation',
        approvedBudget: 85000.0,
        spentAmount: 68000.0,
        allocations: [
          BudgetExpenseAllocation(
            id: 'ALC-07',
            category: 'Developer Hours',
            allocatedAmount: 45000.0,
            spentAmount: 38000.0,
            description: 'Machine learning engineers',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-08',
            category: 'Cloud Infrastructure',
            allocatedAmount: 35000.0,
            spentAmount: 28000.0,
            description: 'AWS SageMaker distributed PyTorch training',
          ),
        ],
      ),
      ProjectBudget(
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        clientName: 'PulsePay Global',
        domain: 'Backend',
        approvedBudget: 120000.0,
        spentAmount: 128500.0, // 107% Overbudget!
        allocations: [
          BudgetExpenseAllocation(
            id: 'ALC-10',
            category: 'Developer Hours',
            allocatedAmount: 65000.0,
            spentAmount: 72000.0,
            description: 'PCI-DSS security compliance refactoring overtime',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-11',
            category: 'Cloud Infrastructure',
            allocatedAmount: 35000.0,
            spentAmount: 39500.0,
            description: 'Dedicated HSM hardware security module instance',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-12',
            category: 'Compliance & Auditing',
            allocatedAmount: 20000.0,
            spentAmount: 17000.0,
            description: 'Third-party CERT-In and SOC-2 penetration audit',
          ),
        ],
        adjustmentHistory: [
          BudgetAdjustmentRecord(
            id: 'ADJ-02',
            previousBudget: 110000.0,
            adjustmentAmount: 10000.0,
            newBudget: 120000.0,
            reason: 'Mandatory PCI-DSS 4.0 HSM hardware requirement',
            approvedBy: 'Siddharth Roy',
            timestamp: now.subtract(const Duration(days: 20)),
          ),
        ],
      ),
      ProjectBudget(
        projectId: 'PRJ-305',
        projectName: 'Fleet Logistics Mobile',
        clientName: 'SwiftLogistics Express',
        domain: 'Mobile App',
        approvedBudget: 50000.0,
        spentAmount: 18000.0,
        allocations: [
          BudgetExpenseAllocation(
            id: 'ALC-13',
            category: 'Developer Hours',
            allocatedAmount: 32000.0,
            spentAmount: 12000.0,
            description: 'Driver dispatch & geolocation tracking',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-14',
            category: 'Cloud Infrastructure',
            allocatedAmount: 12000.0,
            spentAmount: 4500.0,
            description: 'Google Maps Geocoding & Route Optimization APIs',
          ),
        ],
      ),
      ProjectBudget(
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        clientName: 'Digital Inertia Holdings',
        domain: 'Web Platform',
        approvedBudget: 75000.0,
        spentAmount: 65000.0, // 86.7% Approaching Limit!
        allocations: [
          BudgetExpenseAllocation(
            id: 'ALC-16',
            category: 'Developer Hours',
            allocatedAmount: 48000.0,
            spentAmount: 42000.0,
            description: 'Cross-module ERP integration engineering',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-17',
            category: 'Cloud Infrastructure',
            allocatedAmount: 18000.0,
            spentAmount: 16500.0,
            description: 'Multi-tenant PostgreSQL and Kubernetes hosting',
          ),
          BudgetExpenseAllocation(
            id: 'ALC-18',
            category: 'Design & Assets',
            allocatedAmount: 9000.0,
            spentAmount: 6500.0,
            description: 'Design system tokens and responsive layouts',
          ),
        ],
      ),
    ];

    // Seed Departmental Resource Requests
    _resourceRequests = [
      ResourceRequest(
        id: 'REQ-201',
        requestingDepartment: 'Technology and Engineering',
        requestedResource: 'AWS GPU Cluster (p4d.24xlarge)',
        quantity: 1,
        estimatedCost: 185000.0,
        purpose: 'Real-time inference training & churn prediction model tuning for Quantra BioSciences',
        projectId: 'PRJ-303',
        projectName: 'AI Analytics Platform',
        requesterName: 'Priya Nair',
        requesterId: 'EMP-102',
        submittedDate: now.subtract(const Duration(hours: 3)),
        status: ResourceRequestStatus.pending,
      ),
      ResourceRequest(
        id: 'REQ-202',
        requestingDepartment: 'Client Experience Engineering',
        requestedResource: '2 Senior Flutter Contractor Engineers (120 hrs)',
        quantity: 2,
        estimatedCost: 240000.0,
        purpose: 'Battery optimization and offline telemetry sync sprint for fleet drivers',
        projectId: 'PRJ-305',
        projectName: 'Fleet Logistics Mobile',
        requesterName: 'Rohan Mehta',
        requesterId: 'EMP-105',
        submittedDate: now.subtract(const Duration(hours: 6)),
        status: ResourceRequestStatus.pending,
      ),
      ResourceRequest(
        id: 'REQ-203',
        requestingDepartment: 'HR & People Ops',
        requestedResource: 'Campus Hiring Assessment Portal (500 Licenses)',
        quantity: 500,
        estimatedCost: 95000.0,
        purpose: 'Automated screening for Q4 engineering interns and graduate batch',
        requesterName: 'Meera Joshi',
        requesterId: 'EMP-111',
        submittedDate: now.subtract(const Duration(days: 1)),
        status: ResourceRequestStatus.approved,
        financeComments: 'Approved within Q4 Talent Acquisition operational budget.',
        reviewedBy: 'Siddharth Roy',
        reviewedAt: now.subtract(const Duration(hours: 18)),
        allocatedBudget: 95000.0,
      ),
      ResourceRequest(
        id: 'REQ-204',
        requestingDepartment: 'Corporate Growth & Sales',
        requestedResource: 'Gitex Dubai Exhibition Passes & Business Flight Tickets',
        quantity: 2,
        estimatedCost: 350000.0,
        purpose: 'Onsite sales booth sponsorship and client lead acquisition in Dubai',
        requesterName: 'Rajesh Kumar',
        requesterId: 'EMP-112',
        submittedDate: now.subtract(const Duration(days: 2)),
        status: ResourceRequestStatus.rejected,
        financeComments: 'Projected pipeline margin does not satisfy 3x ROI threshold for international travel.',
        reviewedBy: 'Siddharth Roy',
        reviewedAt: now.subtract(const Duration(days: 1)),
      ),
      ResourceRequest(
        id: 'REQ-205',
        requestingDepartment: 'Quality & Reliability',
        requestedResource: 'BrowserStack Real-Device Mobile Cloud Testing',
        quantity: 5,
        estimatedCost: 120000.0,
        purpose: 'Cross-device physical device automated matrix testing for release build',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        requesterName: 'Neha Patel',
        requesterId: 'EMP-108',
        submittedDate: now.subtract(const Duration(days: 3)),
        status: ResourceRequestStatus.fulfilled,
        financeComments: 'Procurement complete. Annual license key provisioned.',
        reviewedBy: 'Siddharth Roy',
        reviewedAt: now.subtract(const Duration(days: 2)),
        allocatedBudget: 120000.0,
      ),
      ResourceRequest(
        id: 'REQ-206',
        requestingDepartment: 'UI/UX Engineering',
        requestedResource: 'Figma Enterprise & Design Tokens Cloud Sync (8 Seats)',
        quantity: 8,
        estimatedCost: 80000.0,
        purpose: 'Centralized token synchronization across Mobile and Web applications',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        requesterName: 'Divya Iyer',
        requesterId: 'EMP-110',
        submittedDate: now.subtract(const Duration(days: 2)),
        status: ResourceRequestStatus.clarificationRequested,
        financeComments: 'Please clarify whether the 8 seats include 3 external contractors.',
        reviewedBy: 'Siddharth Roy',
        reviewedAt: now.subtract(const Duration(hours: 22)),
      ),
    ];

    // Seed HR Employee Leave Requests
    _leaveRequests = [
      EmployeeLeaveRequest(
        id: 'LEV-101',
        employeeId: 'EMP-101',
        employeeName: 'Arjun Sharma',
        department: 'Technology and Engineering',
        leaveType: LeaveType.annual,
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 5)),
        daysCount: 3,
        reason: 'Family wedding attendance in Jaipur',
        status: LeaveRequestStatus.pending,
        appliedDate: now.subtract(const Duration(hours: 4)),
        hasOverlappingTeamAbsence: true,
        overlappingEmployeeNames: ['Rohan Mehta (Client Experience)'],
      ),
      EmployeeLeaveRequest(
        id: 'LEV-102',
        employeeId: 'EMP-103',
        employeeName: 'Sneha Roy',
        department: 'Technology and Engineering',
        leaveType: LeaveType.sick,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        daysCount: 2,
        reason: 'Viral fever and medical rest advised by physician',
        status: LeaveRequestStatus.pending,
        appliedDate: now.subtract(const Duration(hours: 2)),
      ),
      EmployeeLeaveRequest(
        id: 'LEV-103',
        employeeId: 'EMP-112',
        employeeName: 'Rajesh Kumar',
        department: 'Corporate Growth & Sales',
        leaveType: LeaveType.casual,
        startDate: now.add(const Duration(days: 4)),
        endDate: now.add(const Duration(days: 4)),
        daysCount: 1,
        reason: 'Personal urgent registry and bank appointment',
        status: LeaveRequestStatus.pending,
        appliedDate: now.subtract(const Duration(hours: 6)),
      ),
      EmployeeLeaveRequest(
        id: 'LEV-104',
        employeeId: 'EMP-110',
        employeeName: 'Divya Iyer',
        department: 'UI/UX Engineering',
        leaveType: LeaveType.annual,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.subtract(const Duration(days: 2)),
        daysCount: 4,
        reason: 'Annual family holiday vacation',
        status: LeaveRequestStatus.approved,
        appliedDate: now.subtract(const Duration(days: 8)),
        reviewedBy: 'Meera Joshi',
        reviewedAt: now.subtract(const Duration(days: 7)),
        hrComments: 'Approved within annual leave balance quota.',
      ),
      EmployeeLeaveRequest(
        id: 'LEV-105',
        employeeId: 'EMP-105',
        employeeName: 'Rohan Mehta',
        department: 'Client Experience Engineering',
        leaveType: LeaveType.casual,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.subtract(const Duration(days: 2)),
        daysCount: 2,
        reason: 'Urgent family gathering',
        status: LeaveRequestStatus.approved,
        appliedDate: now.subtract(const Duration(days: 5)),
        reviewedBy: 'Meera Joshi',
        reviewedAt: now.subtract(const Duration(days: 4)),
        hrComments: 'Approved. Sprint lead notified.',
      ),
      EmployeeLeaveRequest(
        id: 'LEV-106',
        employeeId: 'EMP-109',
        employeeName: 'Karthik R',
        department: 'Cloud Infrastructure',
        leaveType: LeaveType.annual,
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 5)),
        daysCount: 5,
        reason: 'Outstation leisure travel',
        status: LeaveRequestStatus.rejected,
        appliedDate: now.subtract(const Duration(days: 2)),
        reviewedBy: 'Meera Joshi',
        reviewedAt: now.subtract(const Duration(days: 1)),
        hrComments: 'Rejected: Clashes with mandatory AWS cloud migration window.',
      ),
    ];

    // Seed HR Team Staffing Requests
    _staffingRequests = [
      StaffingRequest(
        id: 'STF-301',
        requestingDepartment: 'Client Experience Engineering',
        projectId: 'PRJ-305',
        projectName: 'Fleet Logistics Mobile',
        requesterName: 'Rohan Mehta',
        requesterId: 'EMP-105',
        requiredRole: 'Senior Flutter Developer',
        requiredSkills: ['Flutter', 'Offline Telemetry Sync', 'Google Maps API'],
        headcount: 2,
        requestedJoiningDate: now.add(const Duration(days: 3)),
        urgency: 'Urgent',
        status: StaffingRequestStatus.pending,
        submittedDate: now.subtract(const Duration(hours: 5)),
      ),
      StaffingRequest(
        id: 'STF-302',
        requestingDepartment: 'Technology and Engineering',
        projectId: 'PRJ-303',
        projectName: 'AI Analytics Platform',
        requesterName: 'Priya Nair',
        requesterId: 'EMP-102',
        requiredRole: 'PyTorch / ML Engineer',
        requiredSkills: ['Python', 'PyTorch', 'AWS SageMaker'],
        headcount: 1,
        requestedJoiningDate: now.add(const Duration(days: 6)),
        urgency: 'High',
        status: StaffingRequestStatus.inProgress,
        submittedDate: now.subtract(const Duration(days: 1)),
        hrNotes: 'Evaluating internal transfer candidates from batch 2024.',
      ),
      StaffingRequest(
        id: 'STF-303',
        requestingDepartment: 'Corporate Growth & Sales',
        requesterName: 'Rajesh Kumar',
        requesterId: 'EMP-112',
        requiredRole: 'Sales & BD Associate',
        requiredSkills: ['Enterprise Outreach', 'CRM Lead Pipeline', 'B2B Qualification'],
        headcount: 2,
        requestedJoiningDate: now.add(const Duration(days: 10)),
        urgency: 'Medium',
        status: StaffingRequestStatus.pending,
        submittedDate: now.subtract(const Duration(days: 2)),
      ),
      StaffingRequest(
        id: 'STF-304',
        requestingDepartment: 'UI/UX Engineering',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        requesterName: 'Divya Iyer',
        requesterId: 'EMP-110',
        requiredRole: 'Design Systems Specialist',
        requiredSkills: ['Figma Tokens', 'Mobile Design System Guidelines'],
        headcount: 1,
        requestedJoiningDate: now.subtract(const Duration(days: 7)),
        urgency: 'High',
        status: StaffingRequestStatus.fulfilled,
        assignedEmployeeIds: ['EMP-108'],
        assignedEmployeeNames: ['Neha Patel'],
        submittedDate: now.subtract(const Duration(days: 10)),
        fulfilledDate: now.subtract(const Duration(days: 7)),
        hrNotes: 'Assigned Neha Patel from QA / Design cross-functional bench.',
      ),
    ];

    // Seed HR Customer Feedback & Post-Deal Coordination Requests
    _customerChangeRequests = [
      CustomerChangeRequest(
        id: 'CR-401',
        leadId: 'LED-504',
        clientName: 'SolarEase Enterprise',
        companyName: 'SolarEase Energy Solutions',
        projectName: 'EcoTrack App',
        feedbackType: 'Change Request',
        description: 'Customer requested multi-inverter telemetry dashboard export in CSV format.',
        forwardedToRole: 'Tech Lead - Arjun Sharma',
        status: CustomerRequestStatus.inReview,
        followUpDate: now.add(const Duration(days: 1)),
        createdDate: now.subtract(const Duration(days: 2)),
      ),
      CustomerChangeRequest(
        id: 'CR-402',
        leadId: 'LED-503',
        clientName: 'Skyline Infrastructure',
        companyName: 'Skyline Smart City Group',
        projectName: 'Green Energy Dashboard',
        feedbackType: 'Feature Scope Addition',
        description: 'Client requested bi-directional power feed alerts via WhatsApp webhook.',
        forwardedToRole: 'Project Manager - Priya Nair',
        status: CustomerRequestStatus.submitted,
        followUpDate: now.add(const Duration(days: 3)),
        createdDate: now.subtract(const Duration(days: 1)),
      ),
      CustomerChangeRequest(
        id: 'CR-403',
        leadId: 'LED-501',
        clientName: 'Quantra BioSciences',
        companyName: 'Quantra BioSciences India',
        projectName: 'AI Analytics Platform',
        feedbackType: 'Feedback',
        description: 'Client satisfied with model accuracy; requested additional evaluation milestone report.',
        forwardedToRole: 'Tech Lead - Arjun Sharma',
        status: CustomerRequestStatus.accepted,
        followUpDate: now.add(const Duration(days: 4)),
        createdDate: now.subtract(const Duration(days: 3)),
        resolutionNotes: 'Accepted for inclusion in Milestone 2 deliverable.',
      ),
      CustomerChangeRequest(
        id: 'CR-404',
        leadId: 'LED-502',
        clientName: 'PulsePay Global',
        companyName: 'PulsePay Global Payments',
        projectName: 'FinTech Payment Gateway',
        feedbackType: 'SLA Inquiry',
        description: 'Customer queried 99.99% uptime guarantee during payment processing peak hours.',
        forwardedToRole: 'Finance Lead - Siddharth Roy',
        status: CustomerRequestStatus.escalated,
        isEscalated: true,
        followUpDate: now,
        createdDate: now.subtract(const Duration(days: 4)),
        resolutionNotes: 'Escalated to Laven Lokesh (CEO) & Siddharth Roy (Finance) for SLA tier sign-off.',
      ),
    ];
  }

  // -------------------------------------------------------------
  // Sales Mobile App Actions
  // -------------------------------------------------------------

  void logColdCall({
    required String customerName,
    required String companyName,
    required String phone,
    required CallOutcome outcome,
    String notes = '',
    DateTime? nextFollowUpDate,
    int durationSeconds = 180,
    double? dealValue,
    String priority = 'Medium',
    String? leadId,
  }) {
    final call = SalesCall(
      id: 'CALL-${DateTime.now().millisecondsSinceEpoch % 10000}',
      customerName: customerName,
      companyName: companyName,
      phone: phone,
      timestamp: DateTime.now(),
      outcome: outcome,
      notes: notes,
      nextFollowUpDate: nextFollowUpDate,
      durationSeconds: durationSeconds,
      isCompleted: true,
      dealValue: dealValue,
      priority: priority,
      leadId: leadId,
    );
    _salesCalls.insert(0, call);

    // If an existing lead matches or leadId is given, link and update interaction
    final matchedIdx = leadId != null
        ? _leads.indexWhere((l) => l.id == leadId)
        : _leads.indexWhere((l) => l.companyName.toLowerCase() == companyName.toLowerCase());

    if (matchedIdx != -1) {
      final old = _leads[matchedIdx];
      LeadStatus newStatus = old.status;
      if (old.status == LeadStatus.newLead) {
        newStatus = outcome == CallOutcome.interested || outcome == CallOutcome.followUpRequired
            ? LeadStatus.contactEstablished
            : LeadStatus.contactAttempted;
      }
      final newInteractions = List<LeadInteraction>.from(old.interactions)
        ..insert(
          0,
          LeadInteraction(
            id: 'INT-${DateTime.now().millisecondsSinceEpoch % 1000}',
            type: 'Call',
            summary: '${outcome.label}: $notes',
            authorName: _currentUserName,
            timestamp: DateTime.now(),
          ),
        );
      _leads[matchedIdx] = old.copyWith(
        status: newStatus,
        nextFollowUpDate: nextFollowUpDate ?? old.nextFollowUpDate,
        interactions: newInteractions,
        notes: notes.isNotEmpty ? notes : old.notes,
      );
    }

    _addAuditLog(
      action: 'Cold Call Recorded',
      module: 'Sales',
      details: 'Recorded call for $customerName ($companyName) - ${outcome.label}',
    );
    notifyListeners();
  }

  void updateCallOutcome(
    String callId,
    CallOutcome outcome, {
    String? notes,
    DateTime? nextFollowUpDate,
  }) {
    final idx = _salesCalls.indexWhere((c) => c.id == callId);
    if (idx != -1) {
      final old = _salesCalls[idx];
      _salesCalls[idx] = old.copyWith(
        outcome: outcome,
        notes: notes ?? old.notes,
        nextFollowUpDate: nextFollowUpDate ?? old.nextFollowUpDate,
      );
      notifyListeners();
    }
  }

  void rescheduleFollowUp(String callId, DateTime newDate) {
    final idx = _salesCalls.indexWhere((c) => c.id == callId);
    if (idx != -1) {
      final old = _salesCalls[idx];
      _salesCalls[idx] = old.copyWith(nextFollowUpDate: newDate);
      notifyListeners();
    }
  }

  void markFollowUpCompleted(String callId) {
    final idx = _salesCalls.indexWhere((c) => c.id == callId);
    if (idx != -1) {
      final old = _salesCalls[idx];
      _salesCalls[idx] = old.copyWith(
        isCompleted: true,
        notes: old.notes.isNotEmpty ? '${old.notes} (Follow-up Completed)' : 'Follow-up Completed',
      );
      notifyListeners();
    }
  }

  void forwardLeadToManager(String leadId, {String comments = 'Forwarded to Manager for review & commercial proposal signoff'}) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final old = _leads[idx];
      final newHistory = List<LeadApprovalAction>.from(old.approvalHistory)
        ..insert(
          0,
          LeadApprovalAction(
            id: 'APR-${DateTime.now().millisecondsSinceEpoch % 1000}',
            action: 'Submitted to Manager',
            authorName: _currentUserName,
            authorRole: 'Sales & BD Associate',
            comments: comments,
            timestamp: DateTime.now(),
          ),
        );
      _leads[idx] = old.copyWith(
        internalApprovalStage: 'Pending Manager Review',
        approvalHistory: newHistory,
      );
      _addAuditLog(
        action: 'Lead Forwarded to Manager',
        module: 'Sales',
        details: 'Forwarded ${old.companyName} to Manager for review: $comments',
      );
      notifyListeners();
    }
  }

  void forwardLeadToHrFinance(String leadId, {String comments = 'Forwarded to HR & Finance for technical capability and margin feasibility check'}) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final old = _leads[idx];
      final newHistory = List<LeadApprovalAction>.from(old.approvalHistory)
        ..insert(
          0,
          LeadApprovalAction(
            id: 'APR-${DateTime.now().millisecondsSinceEpoch % 1000}',
            action: 'Forwarded to HR & Finance',
            authorName: _currentUserName,
            authorRole: 'Sales & BD Associate',
            comments: comments,
            timestamp: DateTime.now(),
          ),
        );
      _leads[idx] = old.copyWith(
        status: LeadStatus.feasibilityAssessment,
        internalApprovalStage: 'Forwarded to HR & Finance',
        hrFeasibility: old.hrFeasibility.copyWith(
          status: FeasibilityStatus.inReview,
          resourceAvailabilityNotes: 'Assessment in progress for 120 dev hours',
        ),
        financeFeasibility: old.financeFeasibility.copyWith(
          status: FeasibilityStatus.inReview,
          budgetFeasibilityNotes: 'Margin check underway for ${old.dealValue} budget',
        ),
        approvalHistory: newHistory,
      );
      _addAuditLog(
        action: 'Lead Forwarded to HR/Finance',
        module: 'Sales',
        details: 'Forwarded ${old.companyName} to HR & Finance: $comments',
      );
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // Finance Mobile App Actions
  // -------------------------------------------------------------

  void approveResourceRequest(
    String requestId, {
    String? comments,
    double? allocatedBudget,
  }) {
    final idx = _resourceRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final old = _resourceRequests[idx];
      final approvedAmount = allocatedBudget ?? old.estimatedCost;
      _resourceRequests[idx] = old.copyWith(
        status: ResourceRequestStatus.approved,
        financeComments: comments ?? 'Approved by Finance within operational budget.',
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
        allocatedBudget: approvedAmount,
      );

      // If associated with a project, reflect this allocation in project budget
      if (old.projectId != null) {
        final bIdx = _projectBudgets.indexWhere((b) => b.projectId == old.projectId);
        if (bIdx != -1) {
          final budget = _projectBudgets[bIdx];
          final newAllocations = List<BudgetExpenseAllocation>.from(budget.allocations)
            ..add(
              BudgetExpenseAllocation(
                id: 'ALC-${DateTime.now().millisecondsSinceEpoch % 10000}',
                category: old.requestingDepartment.contains('HR')
                    ? 'HR & Talent Acquisition'
                    : old.requestingDepartment.contains('Growth') || old.requestingDepartment.contains('Sales')
                        ? 'Sales & BD Operational'
                        : 'Tooling & Infrastructure',
                allocatedAmount: approvedAmount,
                spentAmount: 0.0,
                description: '${old.requestedResource} (${old.purpose})',
              ),
            );
          _projectBudgets[bIdx] = budget.copyWith(
            allocations: newAllocations,
            lastUpdated: DateTime.now(),
          );
        }
      }

      _addAuditLog(
        action: 'Resource Request Approved',
        module: 'Finance',
        details: 'Approved $requestId (${old.requestedResource}) for ₹${approvedAmount.toStringAsFixed(0)}',
      );
      notifyListeners();
    }
  }

  void rejectResourceRequest(String requestId, {required String reason}) {
    final idx = _resourceRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final old = _resourceRequests[idx];
      _resourceRequests[idx] = old.copyWith(
        status: ResourceRequestStatus.rejected,
        financeComments: reason,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
      );
      _addAuditLog(
        action: 'Resource Request Rejected',
        module: 'Finance',
        details: 'Rejected $requestId (${old.requestedResource}): $reason',
      );
      notifyListeners();
    }
  }

  void requestResourceClarification(String requestId, {required String questions}) {
    final idx = _resourceRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final old = _resourceRequests[idx];
      _resourceRequests[idx] = old.copyWith(
        status: ResourceRequestStatus.clarificationRequested,
        financeComments: questions,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
      );
      _addAuditLog(
        action: 'Resource Request Clarification Requested',
        module: 'Finance',
        details: 'Requested clarification on $requestId: $questions',
      );
      notifyListeners();
    }
  }

  void adjustProjectBudget(
    String projectId, {
    required double adjustmentAmount,
    required String reason,
  }) {
    final idx = _projectBudgets.indexWhere((b) => b.projectId == projectId);
    if (idx != -1) {
      final old = _projectBudgets[idx];
      final newBudget = old.approvedBudget + adjustmentAmount;

      final record = BudgetAdjustmentRecord(
        id: 'ADJ-${DateTime.now().millisecondsSinceEpoch % 10000}',
        previousBudget: old.approvedBudget,
        adjustmentAmount: adjustmentAmount,
        newBudget: newBudget,
        reason: reason,
        approvedBy: _currentUserName,
        timestamp: DateTime.now(),
      );

      final newHistory = List<BudgetAdjustmentRecord>.from(old.adjustmentHistory)..insert(0, record);

      _projectBudgets[idx] = old.copyWith(
        approvedBudget: newBudget,
        adjustmentHistory: newHistory,
        lastUpdated: DateTime.now(),
      );

      // Synchronize shared project record in _projects
      final pIdx = _projects.indexWhere((p) => p.id == projectId);
      if (pIdx != -1) {
        final pOld = _projects[pIdx];
        _projects[pIdx] = pOld.copyWith(budget: newBudget);
      }

      _addAuditLog(
        action: 'Project Budget Adjusted',
        module: 'Finance',
        details: 'Adjusted ${old.projectName} by ₹${adjustmentAmount.toStringAsFixed(0)} to ₹${newBudget.toStringAsFixed(0)}: $reason',
      );
      notifyListeners();
    }
  }

  void addBudgetExpenseAllocation(
    String projectId, {
    required String category,
    required double allocatedAmount,
    required double spentAmount,
    String description = '',
  }) {
    final idx = _projectBudgets.indexWhere((b) => b.projectId == projectId);
    if (idx != -1) {
      final old = _projectBudgets[idx];
      final newAllocations = List<BudgetExpenseAllocation>.from(old.allocations)
        ..add(
          BudgetExpenseAllocation(
            id: 'ALC-${DateTime.now().millisecondsSinceEpoch % 10000}',
            category: category,
            allocatedAmount: allocatedAmount,
            spentAmount: spentAmount,
            description: description,
          ),
        );
      _projectBudgets[idx] = old.copyWith(
        allocations: newAllocations,
        spentAmount: old.spentAmount + spentAmount,
        lastUpdated: DateTime.now(),
      );
      _addAuditLog(
        action: 'Expense Allocation Added',
        module: 'Finance',
        details: 'Added allocation for $category (₹$allocatedAmount) in ${old.projectName}',
      );
      notifyListeners();
    }
  }

  void updateFinanceFeasibilityReview(
    String leadId, {
    required FeasibilityStatus status,
    required double estimatedCost,
    required double quotedPrice,
    required double expectedMarginPercent,
    required String paymentTerms,
    required String budgetFeasibilityNotes,
  }) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final old = _leads[idx];
      final newFeasibility = old.financeFeasibility.copyWith(
        status: status,
        estimatedCost: estimatedCost,
        quotedPrice: quotedPrice,
        expectedMarginPercent: expectedMarginPercent,
        paymentTerms: paymentTerms,
        budgetFeasibilityNotes: budgetFeasibilityNotes,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
      );

      final newHistory = List<LeadApprovalAction>.from(old.approvalHistory)
        ..insert(
          0,
          LeadApprovalAction(
            id: 'APR-${DateTime.now().millisecondsSinceEpoch % 1000}',
            action: 'Finance Review: ${status.label}',
            authorName: _currentUserName,
            authorRole: 'Finance Personnel',
            comments: budgetFeasibilityNotes,
            timestamp: DateTime.now(),
          ),
        );

      String stage = old.internalApprovalStage;
      if (status == FeasibilityStatus.completed) {
        stage = 'Finance Approved - Forwarded to Management';
      } else if (status == FeasibilityStatus.changesRequested) {
        stage = 'Returned by Finance for Pricing Revision';
      }

      _leads[idx] = old.copyWith(
        financeFeasibility: newFeasibility,
        internalApprovalStage: stage,
        approvalHistory: newHistory,
      );

      _addAuditLog(
        action: 'Finance Feasibility Updated',
        module: 'Finance',
        details: 'Updated feasibility for ${old.companyName}: ${status.label} ($budgetFeasibilityNotes)',
      );
      notifyListeners();
    }
  }

  void approveDealFinancials(
    String leadId, {
    String comments = 'Approved by Finance. Pricing, margins, and payment milestones verified.',
  }) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final old = _leads[idx];
      final newFeasibility = old.financeFeasibility.copyWith(
        status: FeasibilityStatus.completed,
        budgetFeasibilityNotes: comments,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
      );

      final newHistory = List<LeadApprovalAction>.from(old.approvalHistory)
        ..insert(
          0,
          LeadApprovalAction(
            id: 'APR-${DateTime.now().millisecondsSinceEpoch % 1000}',
            action: 'Finance Approved',
            authorName: _currentUserName,
            authorRole: 'Finance Personnel',
            comments: comments,
            timestamp: DateTime.now(),
          ),
        );

      _leads[idx] = old.copyWith(
        financeFeasibility: newFeasibility,
        internalApprovalStage: 'Finance Approved - Forwarded to Management',
        approvalHistory: newHistory,
      );

      _addAuditLog(
        action: 'Deal Financials Approved',
        module: 'Finance',
        details: 'Approved deal financials for ${old.companyName}',
      );
      notifyListeners();
    }
  }

  void rejectDealFinancials(
    String leadId, {
    required String reason,
  }) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final old = _leads[idx];
      final newFeasibility = old.financeFeasibility.copyWith(
        status: FeasibilityStatus.changesRequested,
        budgetFeasibilityNotes: reason,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
      );

      final newHistory = List<LeadApprovalAction>.from(old.approvalHistory)
        ..insert(
          0,
          LeadApprovalAction(
            id: 'APR-${DateTime.now().millisecondsSinceEpoch % 1000}',
            action: 'Finance Returned / Changes Requested',
            authorName: _currentUserName,
            authorRole: 'Finance Personnel',
            comments: reason,
            timestamp: DateTime.now(),
          ),
        );

      _leads[idx] = old.copyWith(
        financeFeasibility: newFeasibility,
        internalApprovalStage: 'Returned by Finance for Pricing Revision',
        approvalHistory: newHistory,
      );

      _addAuditLog(
        action: 'Deal Financials Returned',
        module: 'Finance',
        details: 'Returned deal for ${old.companyName}: $reason',
      );
      notifyListeners();
    }
  }

  void toggleFinanceTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final old = _tasks[idx];
      final newStatus = old.status == TaskStatus.done ? TaskStatus.inProgress : TaskStatus.done;
      _tasks[idx] = old.copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.done ? DateTime.now() : null,
      );
      _addAuditLog(
        action: 'Task Status Toggled',
        module: 'Finance',
        details: 'Toggled task $taskId to ${newStatus.label}',
      );
      notifyListeners();
    }
  }

  void addFinancePersonalTask({
    required String title,
    required TaskPriority priority,
    required DateTime dueDate,
    String description = '',
  }) {
    final newTask = CompanyTask(
      id: 'TSK-${DateTime.now().millisecondsSinceEpoch % 10000}',
      title: title,
      description: description,
      domain: 'Finance',
      team: 'Financial & Business Ops',
      department: 'Finance',
      assignedToId: 'EMP-115',
      assignedToName: 'Siddharth Roy',
      assigneeType: AssigneeType.employee,
      assignedById: 'EMP-115',
      assignedByName: 'Siddharth Roy',
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.todo,
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, newTask);
    _addAuditLog(
      action: 'Personal Task Created',
      module: 'Finance',
      details: 'Created personal task: $title',
    );
    notifyListeners();
  }

  // -------------------------------------------------------------
  // HR Mobile App Actions
  // -------------------------------------------------------------

  void approveLeaveRequest(String requestId, {String? comments}) {
    final idx = _leaveRequests.indexWhere((l) => l.id == requestId);
    if (idx != -1) {
      final old = _leaveRequests[idx];
      _leaveRequests[idx] = old.copyWith(
        status: LeaveRequestStatus.approved,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
        hrComments: comments ?? 'Approved by HR & People Ops.',
      );

      // Decrement central leave balance in employee record
      final empIdx = _employees.indexWhere((e) => e.id == old.employeeId);
      if (empIdx != -1) {
        final emp = _employees[empIdx];
        final newBalance = (emp.leaveBalance - old.daysCount).clamp(0, 50);
        int casual = emp.casualLeaves;
        int sick = emp.sickLeaves;
        int paid = emp.paidLeaves;
        if (old.leaveType == LeaveType.casual) {
          casual = (casual - old.daysCount).clamp(0, 20);
        } else if (old.leaveType == LeaveType.sick) {
          sick = (sick - old.daysCount).clamp(0, 20);
        } else {
          paid = (paid - old.daysCount).clamp(0, 20);
        }
        _employees[empIdx] = emp.copyWith(
          leaveBalance: newBalance,
          casualLeaves: casual,
          sickLeaves: sick,
          paidLeaves: paid,
        );
      }

      _addAuditLog(
        action: 'Leave Approved',
        module: 'HR',
        details: 'Approved ${old.daysCount} days (${old.leaveType.label}) for ${old.employeeName} (${old.employeeId})',
      );
      notifyListeners();
    }
  }

  void rejectLeaveRequest(String requestId, {required String reason}) {
    final idx = _leaveRequests.indexWhere((l) => l.id == requestId);
    if (idx != -1) {
      final old = _leaveRequests[idx];
      _leaveRequests[idx] = old.copyWith(
        status: LeaveRequestStatus.rejected,
        reviewedBy: _currentUserName,
        reviewedAt: DateTime.now(),
        hrComments: reason,
      );
      _addAuditLog(
        action: 'Leave Rejected',
        module: 'HR',
        details: 'Rejected leave for ${old.employeeName}: $reason',
      );
      notifyListeners();
    }
  }

  void assignStaffingEmployees(
    String requestId, {
    required List<String> employeeIds,
    required List<String> employeeNames,
    String? notes,
  }) {
    final idx = _staffingRequests.indexWhere((s) => s.id == requestId);
    if (idx != -1) {
      final old = _staffingRequests[idx];
      _staffingRequests[idx] = old.copyWith(
        assignedEmployeeIds: employeeIds,
        assignedEmployeeNames: employeeNames,
        status: StaffingRequestStatus.fulfilled,
        fulfilledDate: DateTime.now(),
        hrNotes: notes ?? 'Staffing fulfilled by HR & People Ops.',
      );

      // Reflect in employee projects if projectName is set
      if (old.projectName != null) {
        for (final empId in employeeIds) {
          final empIdx = _employees.indexWhere((e) => e.id == empId);
          if (empIdx != -1) {
            final emp = _employees[empIdx];
            if (!emp.assignedProjectNames.contains(old.projectName)) {
              final newProjects = List<String>.from(emp.assignedProjectNames)..add(old.projectName!);
              _employees[empIdx] = emp.copyWith(assignedProjectNames: newProjects);
            }
          }
        }
      }

      _addAuditLog(
        action: 'Staffing Fulfilled',
        module: 'HR',
        details: 'Assigned ${employeeNames.join(", ")} to ${old.requestingDepartment} (${old.requiredRole})',
      );
      notifyListeners();
    }
  }

  void rejectStaffingRequest(String requestId, {required String reason}) {
    final idx = _staffingRequests.indexWhere((s) => s.id == requestId);
    if (idx != -1) {
      final old = _staffingRequests[idx];
      _staffingRequests[idx] = old.copyWith(
        status: StaffingRequestStatus.rejected,
        hrNotes: reason,
      );
      _addAuditLog(
        action: 'Staffing Request Rejected',
        module: 'HR',
        details: 'Rejected staffing for ${old.requestingDepartment}: $reason',
      );
      notifyListeners();
    }
  }

  void assignTraineeMentor(String internId, {required String mentorId, required String mentorName}) {
    final idx = _interns.indexWhere((i) => i.id == internId);
    if (idx != -1) {
      final old = _interns[idx];
      _interns[idx] = old.copyWith(
        assignedPocId: mentorId,
        assignedPocName: mentorName,
      );

      // Add to employee's assigned interns
      final empIdx = _employees.indexWhere((e) => e.id == mentorId);
      if (empIdx != -1) {
        final emp = _employees[empIdx];
        if (!emp.assignedInternIds.contains(internId)) {
          final newInterns = List<String>.from(emp.assignedInternIds)..add(internId);
          _employees[empIdx] = emp.copyWith(assignedInternIds: newInterns);
        }
      }

      _addAuditLog(
        action: 'Mentor Assigned',
        module: 'HR',
        details: 'Assigned mentor $mentorName to trainee ${old.name} ($internId)',
      );
      notifyListeners();
    }
  }

  void updateTraineeEvaluation(
    String internId, {
    required InternEvaluationRubric rubric,
    required String feedback,
    InternStatus? status,
    InternFinalDecision? finalDecision,
  }) {
    final idx = _interns.indexWhere((i) => i.id == internId);
    if (idx != -1) {
      final old = _interns[idx];
      _interns[idx] = old.copyWith(
        evaluationRubric: rubric,
        latestFeedback: feedback,
        status: status ?? old.status,
        finalDecision: finalDecision ?? old.finalDecision,
        missedUpdatesDays: 0,
      );
      _addAuditLog(
        action: 'Trainee Evaluation Updated',
        module: 'HR',
        details: 'Updated evaluation for ${old.name}: score ${rubric.averageScore.toStringAsFixed(1)}/5.0',
      );
      notifyListeners();
    }
  }

  void forwardCustomerChangeRequest(
    String requestId, {
    required String forwardedToRole,
    required String notes,
  }) {
    final idx = _customerChangeRequests.indexWhere((c) => c.id == requestId);
    if (idx != -1) {
      final old = _customerChangeRequests[idx];
      _customerChangeRequests[idx] = old.copyWith(
        forwardedToRole: forwardedToRole,
        status: CustomerRequestStatus.inReview,
        resolutionNotes: notes,
      );
      _addAuditLog(
        action: 'Change Request Forwarded',
        module: 'HR',
        details: 'Forwarded $requestId to $forwardedToRole: $notes',
      );
      notifyListeners();
    }
  }

  void resolveCustomerChangeRequest(
    String requestId, {
    required String resolutionNotes,
    required CustomerRequestStatus status,
  }) {
    final idx = _customerChangeRequests.indexWhere((c) => c.id == requestId);
    if (idx != -1) {
      final old = _customerChangeRequests[idx];
      _customerChangeRequests[idx] = old.copyWith(
        resolutionNotes: resolutionNotes,
        status: status,
        isEscalated: status == CustomerRequestStatus.escalated,
      );
      _addAuditLog(
        action: 'Change Request Resolved',
        module: 'HR',
        details: 'Resolved $requestId (${status.label}): $resolutionNotes',
      );
      notifyListeners();
    }
  }

  void addCustomerChangeRequest({
    required String leadId,
    required String clientName,
    required String companyName,
    String? projectName,
    required String feedbackType,
    required String description,
    required String forwardedToRole,
    required DateTime followUpDate,
  }) {
    final req = CustomerChangeRequest(
      id: 'CR-${DateTime.now().millisecondsSinceEpoch % 10000}',
      leadId: leadId,
      clientName: clientName,
      companyName: companyName,
      projectName: projectName,
      feedbackType: feedbackType,
      description: description,
      forwardedToRole: forwardedToRole,
      status: CustomerRequestStatus.submitted,
      followUpDate: followUpDate,
      createdDate: DateTime.now(),
    );
    _customerChangeRequests.insert(0, req);
    _addAuditLog(
      action: 'Customer Request Recorded',
      module: 'HR',
      details: 'Recorded customer feedback for $companyName: $description',
    );
    notifyListeners();
  }

  void updateHrMonthlyTargets(HrMonthlyTargets targets) {
    _hrMonthlyTargets = targets;
    notifyListeners();
  }

  void toggleHrTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final old = _tasks[idx];
      final newStatus = old.status == TaskStatus.done ? TaskStatus.inProgress : TaskStatus.done;
      _tasks[idx] = old.copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.done ? DateTime.now() : null,
      );
      _addAuditLog(
        action: 'Task Status Toggled',
        module: 'HR',
        details: 'Toggled task $taskId to ${newStatus.label}',
      );
      notifyListeners();
    }
  }

  void addHrPersonalTask({
    required String title,
    required TaskPriority priority,
    required DateTime dueDate,
    String description = '',
  }) {
    final newTask = CompanyTask(
      id: 'TSK-${DateTime.now().millisecondsSinceEpoch % 10000}',
      title: title,
      description: description,
      domain: 'HR',
      team: 'HR & People Ops',
      department: 'HR',
      assignedToId: 'EMP-111',
      assignedToName: 'Meera Joshi',
      assigneeType: AssigneeType.employee,
      assignedById: 'EMP-111',
      assignedByName: 'Meera Joshi',
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.todo,
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, newTask);
    _addAuditLog(
      action: 'Personal Task Created',
      module: 'HR',
      details: 'Created personal HR task: $title',
    );
    notifyListeners();
  }
}


