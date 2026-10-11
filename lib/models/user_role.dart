/// Defines the available user access levels in Digital Inertia ERP.
enum UserRole {
  ceo('CEO / Admin', 'Full visibility and executive control across all company operations.'),
  poc('Employee / POC', 'Team operations, assigned intern mentorship, and task submissions.'),
  intern('Intern', 'Personal daily assignments, progress tracking, and deliverable submission.');

  final String label;
  final String description;
  const UserRole(this.label, this.description);
}
