/// Defines the 7 configurable role-based access categories in Digital Inertia ERP.
enum UserRole {
  ceo('CEO / Administrator', 'Full administrative access across company operations, employees, projects, approvals, and financials.'),
  gm('General Manager / Managing Director', 'Coordinates department leads, reviews proposals, verifies feasibility, and forwards to CEO.'),
  deptLead('Department Lead', 'Manages departmental activities, employee assignments, progress reporting, and cross-team coordination.'),
  employee('Technical Employee', 'Access to assigned technical projects, tasks, schedules, sprint board, and progress updates.'),
  hr('HR Personnel', 'Employee and intern management, Friday recruitment batches, attendance, and resource availability.'),
  sales('Sales and BD Personnel', 'Lead generation, contact logs, 12-stage sales pipeline, follow-ups, opportunities, and proposals.'),
  finance('Finance Personnel', 'Project cost analysis, quotations, budget tracking, margin feasibility, and billing/invoicing.'),
  
  // Legacy / convenience mappings
  poc('Employee / POC', 'Point of contact for intern mentorship and task submissions.'),
  intern('Intern', 'Personal daily assignments, 1-week evaluation tracking, and deliverable submission.');

  final String label;
  final String description;
  const UserRole(this.label, this.description);

  bool get isCeo => this == UserRole.ceo;
  bool get isGm => this == UserRole.gm;
  bool get isExecutive => this == UserRole.ceo || this == UserRole.gm;
  bool get canAccessAdmin => this == UserRole.ceo;
  
  bool get canAccessHr =>
      this == UserRole.ceo || this == UserRole.gm || this == UserRole.hr;
      
  bool get canAccessSales =>
      this == UserRole.ceo || this == UserRole.gm || this == UserRole.sales;
      
  bool get canAccessFinance =>
      this == UserRole.ceo || this == UserRole.gm || this == UserRole.finance;
      
  bool get canAccessMarketing =>
      this == UserRole.ceo || this == UserRole.gm || this == UserRole.deptLead;
      
  bool get canAccessEngineering =>
      this == UserRole.ceo ||
      this == UserRole.gm ||
      this == UserRole.employee ||
      this == UserRole.deptLead ||
      this == UserRole.poc;

  bool get canApproveProposals =>
      this == UserRole.ceo || this == UserRole.gm;
}
