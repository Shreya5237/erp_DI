/// Defines the role-based access categories in Digital Inertia ERP.
/// Exclusive Executive Role: CEO
/// 5 Corporate Departments:
/// 1. Sales & Marketing
/// 2. Digital Marketing
/// 3. Technical
/// 4. HR
/// 5. Finance
enum UserRole {
  // Exclusive Executive Role
  ceo('CEO / Administrator', 'Exclusive executive authority across all 5 company departments, operations, financials, and approvals.'),

  // 5 Department Roles
  salesMarketing('Sales & Marketing Personnel', 'B2B client acquisition, contact logs, lead generation, 12-stage sales pipeline, and proposals.'),
  digitalMarketing('Digital Marketing Personnel', 'Digital outreach, SEO/SEM, social media campaigns, content strategy, and brand marketing.'),
  technical('Technical Personnel', 'Technical development, system architecture, sprints, feature implementation, and code deliverables.'),
  hr('HR Personnel', 'Employee and intern management, campus recruitment batches, attendance, and resource availability.'),
  finance('Finance Personnel', 'Project cost analysis, quotations, budget tracking, margin feasibility, and billing/invoicing.'),

  // Legacy & convenience mappings
  gm('General Manager / Managing Director', 'Coordinates department leads, reviews proposals, verifies feasibility, and forwards to CEO.'),
  deptLead('Department Lead', 'Manages departmental activities, employee assignments, progress reporting, and cross-team coordination.'),
  employee('Technical Employee', 'Access to assigned technical projects, tasks, schedules, sprint board, and progress updates.'),
  sales('Sales and BD Personnel', 'Lead generation, contact logs, 12-stage sales pipeline, follow-ups, opportunities, and proposals.'),
  poc('Technical POC / Lead', 'Point of contact for intern mentorship and task submissions.'),
  intern('Intern / Trainee', 'Personal daily assignments, 1-week evaluation tracking, and deliverable submission.');

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
      this == UserRole.ceo || this == UserRole.gm || this == UserRole.sales || this == UserRole.salesMarketing;

  bool get canAccessFinance =>
      this == UserRole.ceo || this == UserRole.gm || this == UserRole.finance;

  bool get canAccessMarketing =>
      this == UserRole.ceo || this == UserRole.gm || this == UserRole.digitalMarketing || this == UserRole.salesMarketing || this == UserRole.deptLead;

  bool get canAccessEngineering =>
      this == UserRole.ceo ||
      this == UserRole.gm ||
      this == UserRole.technical ||
      this == UserRole.employee ||
      this == UserRole.deptLead ||
      this == UserRole.poc;

  bool get canApproveProposals =>
      this == UserRole.ceo || this == UserRole.gm;
}
