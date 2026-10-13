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
  bool _isAuthenticating = false;
  bool _isLoadingLeads = false;
  String? _authError;
  String? _leadsError;

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
    'Finance': ['Accounts', 'Payroll', 'Budgeting', 'Invoicing'],
    'Sales': ['Business Development', 'Lead Management', 'Client Acquisition', 'Account Management'],
    'Marketing': ['Digital Marketing', 'SEO', 'Social Media', 'Content Marketing', 'Branding'],
    'HR': ['Recruitment', 'Onboarding', 'Training', 'Leave Management', 'Performance Management'],
    'Technical': ['Frontend', 'Backend', 'Full-stack', 'Mobile Development', 'UI/UX', 'QA', 'DevOps', 'AI/ML'],
  };

  // 5 Primary Departments metrics (PRD Section 3 & 9.1)
  List<DepartmentMetric> get departmentMetrics {
    return const [
      DepartmentMetric(
        department: CompanyDepartment.hr,
        totalEmployees: 3,
        presentToday: 3,
        activeTasks: 4,
        completedTasksThisWeek: 8,
        workloadRatio: 0.65,
      ),
      DepartmentMetric(
        department: CompanyDepartment.sales,
        totalEmployees: 5,
        presentToday: 4,
        activeTasks: 7,
        completedTasksThisWeek: 11,
        workloadRatio: 0.85,
      ),
      DepartmentMetric(
        department: CompanyDepartment.finance,
        totalEmployees: 3,
        presentToday: 3,
        activeTasks: 3,
        completedTasksThisWeek: 6,
        workloadRatio: 0.60,
      ),
      DepartmentMetric(
        department: CompanyDepartment.marketing,
        totalEmployees: 5,
        presentToday: 4,
        activeTasks: 9,
        completedTasksThisWeek: 14,
        workloadRatio: 0.80,
      ),
      DepartmentMetric(
        department: CompanyDepartment.engineering,
        totalEmployees: 8,
        presentToday: 7,
        activeTasks: 16,
        completedTasksThisWeek: 22,
        workloadRatio: 0.90,
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
      return _employees.firstWhere(
        (e) => e.id == _currentUserId || e.name == _currentUserName,
      );
    } catch (_) {
      return _employees.isNotEmpty ? _employees.first : null;
    }
  }

  List<CompanyTask> get myEmployeeTasks {
    final list = _tasks.where((t) =>
      t.assignedToId == _currentUserId ||
      t.assignedToName == _currentUserName ||
      t.assignedById == _currentUserId
    ).toList();
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
    return _projects.where((p) =>
      p.ownerEmployeeId == _currentUserId ||
      p.ownerEmployeeName == _currentUserName ||
      p.teamMemberNames.any((m) => m.contains(_currentUserName))
    ).toList();
  }

  List<Meeting> get myEmployeeMeetings {
    final list = _meetings.where((m) =>
      m.organizerName.contains(_currentUserName) ||
      m.participantNames.any((p) => p.contains(_currentUserName)) ||
      m.departmentOrProject == 'All Departments'
    ).toList();
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
    } else if (role == UserRole.sales) {
      _currentUserName = 'Rajesh Kumar';
      _currentUserEmail = 'rajesh.kumar@digitalinertia.com';
      _currentUserId = 'EMP-112';
    } else if (role == UserRole.employee || role == UserRole.deptLead || role == UserRole.poc) {
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
      _currentUserName = 'Karthik R (Intern)';
      _currentUserEmail = 'karthik.intern@digitalinertia.com';
      _currentUserId = 'INT-201';
    }
    notifyListeners();
  }

  void switchToDemoMode() {
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

      // Map Spring Boot user role to UserRole enum
      final roleStr = result.user.role.toUpperCase();
      if (roleStr.contains('CEO') || roleStr.contains('ADMIN')) {
        _currentRole = UserRole.ceo;
      } else if (roleStr.contains('SALES')) {
        _currentRole = UserRole.sales;
      } else if (roleStr.contains('POC') || roleStr.contains('TECH') || roleStr.contains('EMPLOYEE')) {
        _currentRole = UserRole.employee;
      } else {
        _currentRole = UserRole.employee;
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
      id: 'TSK-${DateTime.now().millisecondsSinceEpoch % 1000}',
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
        role: 'Lead Frontend & Mobile Developer',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-FE',
        subDepartmentName: 'Frontend',
        team: 'Client Experience Engineering',
        reportingManager: 'Laven Lokesh (CEO)',
        joiningDate: DateTime(2024, 3, 15),
        employmentStatus: 'Full-time',
        isPOC: true,
        isActive: true,
        activeTaskCount: 5,
        completedTaskCount: 18,
        performanceScore: 4.85,
        leaveBalance: 14,
        casualLeaves: 6,
        sickLeaves: 5,
        paidLeaves: 3,
        employmentType: 'Permanent Employee',
        batchDetails: 'Batch 2024-Q1 Engineering Lead',
        emergencyContact: '+91 98201 99887 (Pooja Sharma - Spouse)',
        bio: 'Lead Engineer passionate about responsive mobile architecture, clean interfaces, and resilient high-throughput cloud services.',
        location: 'Bengaluru HQ • Hybrid',
        skills: ['Flutter & Dart', 'React & Next.js', 'Go & Node.js', 'PostgreSQL', 'Docker & Kubernetes', 'System Architecture'],
        assignedProjectNames: ['Digital Inertia ERP Core', 'EcoTrack App', 'FinTech Payment Gateway', 'Green Energy Dashboard'],
      ),
      Employee(
        id: 'EMP-102',
        name: 'Priya Nair',
        email: 'priya.nair@digitalinertia.com',
        phone: '+91 98450 78210',
        role: 'Backend Developer',
        category: RoleCategory.technical,
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-BE',
        subDepartmentName: 'Backend',
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
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-FS',
        subDepartmentName: 'Full-stack',
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
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-FE',
        subDepartmentName: 'Frontend',
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
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-MOB',
        subDepartmentName: 'Mobile Development',
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
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-AI',
        subDepartmentName: 'AI/ML',
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
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-BE',
        subDepartmentName: 'Backend',
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
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-QA',
        subDepartmentName: 'QA',
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
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-OPS',
        subDepartmentName: 'DevOps',
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
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentId: 'DEPT-TEC-UIX',
        subDepartmentName: 'UI/UX',
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
        department: 'HR',
        departmentId: 'DEPT-HR',
        subDepartmentId: 'DEPT-HR-REC',
        subDepartmentName: 'Recruitment',
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
        department: 'Sales',
        departmentId: 'DEPT-SAL',
        subDepartmentId: 'DEPT-SAL-BD',
        subDepartmentName: 'Business Development',
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
        department: 'Marketing',
        departmentId: 'DEPT-MKT',
        subDepartmentId: 'DEPT-MKT-DIG',
        subDepartmentName: 'Digital Marketing',
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
        department: 'Finance',
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-BUD',
        subDepartmentName: 'Budgeting',
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
        departmentId: 'DEPT-FIN',
        subDepartmentId: 'DEPT-FIN-ACC',
        subDepartmentName: 'Accounts',
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
        department: 'Sales',
        departmentId: 'DEPT-SAL',
        subDepartmentId: 'DEPT-SAL-ACC',
        subDepartmentName: 'Account Management',
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
        department: 'Marketing',
        departmentId: 'DEPT-MKT',
        subDepartmentId: 'DEPT-MKT-CNT',
        subDepartmentName: 'Content Marketing',
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
        department: 'HR',
        departmentId: 'DEPT-HR',
        subDepartmentId: 'DEPT-HR-ONB',
        subDepartmentName: 'Onboarding',
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
      // Technical Employee (Arjun Sharma) Dedicated Agile Tasks
      CompanyTask(
        id: 'TSK-101',
        title: 'Resolve Redis cache stampede on auth microservice',
        description: 'Implement distributed locking with Redlock and exponential backoff to prevent thundering herd on token validation.',
        domain: 'Backend & DevOps',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair (Lead)',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now(), // Due today
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        progressPercent: 60,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-102',
        title: 'Review API contract swagger specs with Core API team',
        description: 'Validate OpenAPI 3.1 endpoints for billing webhooks, idempotency keys, and error payloads.',
        domain: 'API Engineering',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair (Lead)',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now(), // Due today
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-103',
        title: 'Implement biometric unlock and biometric prompt handler',
        description: 'Add LocalAuthentication plugin support with secure enclave keystore token caching.',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-105',
        assignedByName: 'Rohan Mehta (PM)',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        dueDate: DateTime.now().add(const Duration(days: 1)), // Due tomorrow
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progressPercent: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-104',
        title: 'Setup push notification routing for meeting alerts',
        description: 'Hook background notification handler into local notification scheduler with 15-minute lead time.',
        domain: 'Mobile App',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 1)), // Due tomorrow
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-105',
        title: 'Write end-to-end integration tests for payment webhooks',
        description: 'Automate test harness simulating delayed bank captures, chargeback signals, and signature verifications.',
        domain: 'Testing & QA',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair (Lead)',
        projectId: 'PRJ-304',
        projectName: 'FinTech Payment Gateway',
        dueDate: DateTime.now().add(const Duration(days: 3)), // Next 3 days
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-106',
        title: 'Optimize state tree renders and widget repaint boundaries',
        description: 'Audit DevTools performance overlays, isolate heavy animations into RepaintBoundaries.',
        domain: 'Performance',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-301',
        projectName: 'EcoTrack App',
        dueDate: DateTime.now().add(const Duration(days: 5)), // Next 5 days
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CompanyTask(
        id: 'TSK-107',
        title: 'Prepare sprint 4 release candidate build artifacts',
        description: 'Tag Git commit v1.4.0-rc1, generate signed Android AAB and iOS archive for staging verification.',
        domain: 'DevOps & Release',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().add(const Duration(days: 6)), // Next 6 days
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        progressPercent: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-108',
        title: 'Benchmark Docker container cold-start latency',
        description: 'Profile cold-start times under container resource constraints and document JIT compile warming.',
        domain: 'Cloud Infrastructure',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-102',
        assignedByName: 'Priya Nair (Lead)',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 1)), // Overdue by 1 day!
        status: TaskStatus.overdue,
        priority: TaskPriority.urgent,
        progressPercent: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CompanyTask(
        id: 'TSK-109',
        title: 'Configure responsive tablet grid system',
        description: 'Implement adaptive layout breakpoints for iPad Pro and foldables in employee portal viewports.',
        domain: 'Frontend & UI',
        team: 'Client Experience Engineering',
        department: 'Technology and Engineering',
        assignedToId: 'EMP-101',
        assignedToName: 'Arjun Sharma',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-101',
        assignedByName: 'Arjun Sharma',
        projectId: 'PRJ-306',
        projectName: 'Digital Inertia ERP Core',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        progressPercent: 100,
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
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
      CompanyTask(
        id: 'TSK-443',
        title: 'Launch Q4 Social Media Brand Awareness Campaign',
        description: 'Execute targeted LinkedIn and Meta advertising for Enterprise ERP solution release.',
        domain: 'Marketing / Branding',
        department: 'Marketing',
        team: 'Corporate Growth & Sales',
        assignedToId: 'EMP-113',
        assignedToName: 'Sanjay Menon',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-001',
        assignedByName: 'Laven Lokesh',
        dueDate: DateTime.now(),
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        projectName: 'DI Enterprise Branding',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CompanyTask(
        id: 'TSK-444',
        title: 'Audit SEO Keywords & Technical Blog Backlinks',
        description: 'Optimize high-conversion landing pages for Flutter ERP and Mobile enterprise queries.',
        domain: 'Marketing / SEO',
        department: 'Marketing',
        team: 'Corporate Growth & Sales',
        assignedToId: 'EMP-113',
        assignedToName: 'Sanjay Menon',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-113',
        assignedByName: 'Sanjay Menon',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        projectName: 'Digital Inbound Marketing',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompanyTask(
        id: 'TSK-445',
        title: 'Publish Monthly Client Case Study: EcoTrack',
        description: 'Finalize copy, customer quote approvals, and visual infographics for PDF release.',
        domain: 'Marketing / Content',
        department: 'Marketing',
        team: 'Corporate Growth & Sales',
        assignedToId: 'EMP-113',
        assignedToName: 'Sanjay Menon',
        assigneeType: AssigneeType.employee,
        assignedById: 'EMP-113',
        assignedByName: 'Sanjay Menon',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        projectName: 'DI Enterprise Branding',
        createdAt: DateTime.now(),
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
        teamMemberNames: ['Rohan Mehta', 'Sneha V', 'Arjun Sharma', 'Aarav Sharma (Intern)'],
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
        teamMemberNames: ['Priya Nair', 'Karthik R', 'Arjun Sharma', 'Rahul Verma'],
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


