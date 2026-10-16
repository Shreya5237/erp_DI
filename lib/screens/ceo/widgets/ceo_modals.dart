import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/approval.dart';
import '../../../models/task.dart';
import '../../../models/meeting.dart';
import '../../../models/employee.dart';
import '../../auth/login_screen.dart';

class CeoModals {
  CeoModals._();

  /// Modal for Reviewing and Deciding Pending Approvals (Approve, Reject, Request Changes, Delegate)
  static void showApprovalDecisionModal(
    BuildContext context,
    CompanyApprovalRequest request,
    ErpProvider erp,
  ) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fact_check_rounded, color: Color(0xFF212529), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Executive Decision Required',
                    style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                  ),
                  Text(
                    'Approval Request #${request.id}',
                    style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: GoogleFonts.instrumentSans(fontSize: 14.5, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Dept: ${request.submittingDepartment}', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF495057))),
                        const Spacer(),
                        Text(
                          '₹${request.dealValueOrBudget.toStringAsFixed(0)}',
                          style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Submitted by ${request.submittedByName} (${request.submittedByRole})',
                      style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Summary & Business Impact:',
                style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
              ),
              const SizedBox(height: 4),
              Text(
                request.summary,
                style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF495057), height: 1.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Executive Decision Notes (Recorded in Audit Trail):',
                style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF212529)),
                decoration: InputDecoration(
                  hintText: 'Enter executive instructions, conditions, or reason...',
                  hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF212529), width: 1.5)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  final notes = notesController.text.trim();
                  erp.rejectApprovalRequest(request.id, notes: notes.isEmpty ? 'Rejected by CEO' : notes);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF212529),
                      content: Text('Request "${request.title}" rejected and logged.', style: GoogleFonts.instrumentSans(color: Colors.white)),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE03131),
                  side: const BorderSide(color: Color(0xFFE03131)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text('Reject', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  erp.approveApprovalRequest(request.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF212529),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF2F9E44), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Proposal "${request.title}" officially approved!', style: GoogleFonts.instrumentSans(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212529),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text('Approve', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Modal to Issue a Company-Wide Directive with Owner, Deadline & Priority
  static void showCompanyDirectiveModal(BuildContext context, ErpProvider erp) {
    final titleController = TextEditingController();
    final instructionsController = TextEditingController();
    String selectedDept = 'Technical';
    String priority = 'Critical';
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF212529),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue Executive Directive',
                      style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                    ),
                    Text(
                      'Binding order to department heads',
                      style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Directive Title', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF6C757D))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF212529)),
                    decoration: InputDecoration(
                      hintText: 'e.g., Immediate Security Audit / Reallocate 2 Senior Devs',
                      hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F7),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Target Department', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF6C757D))),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE9ECEF)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedDept,
                                  isExpanded: true,
                                  style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF212529)),
                                  items: ['Technical', 'Sales & Marketing', 'Digital Marketing', 'HR & Talent', 'Finance', 'All Departments'].map((d) {
                                    return DropdownMenuItem(value: d, child: Text(d));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => selectedDept = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Urgency', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF6C757D))),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE9ECEF)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: priority,
                                  isExpanded: true,
                                  style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF212529)),
                                  items: ['Critical', 'High', 'Medium'].map((p) {
                                    return DropdownMenuItem(value: p, child: Text(p));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => priority = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Detailed Executive Instructions', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF6C757D))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: instructionsController,
                    maxLines: 3,
                    style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF212529)),
                    decoration: InputDecoration(
                      hintText: 'Specify deliverables, responsible lead, constraints, and success metric...',
                      hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F7),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                // Add directive into Provider Tasks & Audit Log
                erp.createTask(
                  title: '[CEO DIRECTIVE] $title',
                  description: instructionsController.text.trim().isEmpty ? 'Direct executive instruction from CEO' : instructionsController.text.trim(),
                  domain: selectedDept,
                  department: selectedDept,
                  assignedToId: 'DEPT-LEAD',
                  assignedToName: '$selectedDept Head',
                  assigneeType: AssigneeType.employee,
                  dueDate: selectedDeadline,
                  priority: priority == 'Critical' ? TaskPriority.high : TaskPriority.medium,
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF212529),
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF2F9E44), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Directive dispatched to $selectedDept Head with executive priority.',
                            style: GoogleFonts.instrumentSans(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212529),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text('Dispatch Directive', style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  /// Schedule Executive Meeting Modal
  static void showScheduleMeetingModal(BuildContext context, ErpProvider erp) {
    final titleController = TextEditingController();
    final linkController = TextEditingController(text: 'Google Meet / Boardroom A');
    String department = 'All Departments';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Schedule Executive Meeting',
          style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Meeting Agenda / Title', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF6C757D))),
            const SizedBox(height: 6),
            TextField(
              controller: titleController,
              style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF212529)),
              decoration: InputDecoration(
                hintText: 'e.g. Q4 Executive Strategy & Department Heads Review',
                hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                filled: true,
                fillColor: const Color(0xFFF5F6F7),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
              ),
            ),
            const SizedBox(height: 12),
            Text('Location / Virtual Link', style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF6C757D))),
            const SizedBox(height: 6),
            TextField(
              controller: linkController,
              style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF212529)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F6F7),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D))),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              final newMtg = Meeting(
                id: 'MTG-${DateTime.now().millisecondsSinceEpoch % 1000}',
                title: titleController.text.trim(),
                participantNames: ['All Department Heads', 'Operations Lead'],
                date: DateTime.now(),
                startTime: '04:00 PM',
                endTime: '05:00 PM',
                locationOrLink: linkController.text.trim(),
                agenda: titleController.text.trim(),
                organizerName: erp.currentUserName,
                departmentOrProject: department,
              );
              erp.addMeeting(newMtg);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  content: Text('Meeting scheduled and invitations sent.', style: GoogleFonts.instrumentSans(color: Colors.white)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirm Schedule', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Global Search Modal covering permitted employee records, projects, clients, deals, tasks, reports
  static void showGlobalSearchModal(
    BuildContext context,
    ErpProvider erp,
    ValueChanged<int> onSelectModule,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final lower = query.toLowerCase();

            final matchedEmployees = lower.isEmpty
                ? []
                : erp.allEmployees.where((e) => e.name.toLowerCase().contains(lower) || e.department.toLowerCase().contains(lower)).take(4).toList();

            final matchedProjects = lower.isEmpty
                ? []
                : erp.allProjects.where((p) => p.name.toLowerCase().contains(lower) || p.clientName.toLowerCase().contains(lower)).take(4).toList();

            final matchedLeads = lower.isEmpty
                ? []
                : erp.allLeads.where((l) => l.companyName.toLowerCase().contains(lower) || l.clientName.toLowerCase().contains(lower)).take(4).toList();

            final matchedTasks = lower.isEmpty
                ? []
                : erp.allTasks.where((t) => t.title.toLowerCase().contains(lower) || t.assignedToName.toLowerCase().contains(lower)).take(4).toList();

            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540, maxHeight: 520),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        autofocus: true,
                        style: GoogleFonts.instrumentSans(fontSize: 14, color: const Color(0xFF212529)),
                        onChanged: (val) => setModalState(() => query = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search employees, projects, clients, deals, tasks...',
                          hintStyle: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFFADB5BD)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF212529), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF5F6F7),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF212529), width: 1.5)),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE9ECEF)),

                    // Results
                    Expanded(
                      child: lower.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.travel_explore_rounded, size: 36, color: Color(0xFFADB5BD)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Type keywords to search across Digital Inertia ERP',
                                    style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF6C757D)),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              children: [
                                if (matchedProjects.isNotEmpty) ...[
                                  _buildSearchHeader('PROJECTS & DELIVERY'),
                                  ...matchedProjects.map((p) => ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.folder_open_rounded, size: 18, color: Color(0xFF212529)),
                                        title: Text(p.name, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                                        subtitle: Text('${p.clientName} • ${(p.progress * 100).toInt()}% Done', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D))),
                                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFADB5BD)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          onSelectModule(3); // Projects
                                        },
                                      )),
                                ],
                                if (matchedLeads.isNotEmpty) ...[
                                  _buildSearchHeader('CLIENTS & PIPELINE'),
                                  ...matchedLeads.map((l) => ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.trending_up_rounded, size: 18, color: Color(0xFF212529)),
                                        title: Text(l.companyName, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                                        subtitle: Text('${l.contactPerson} • ₹${(l.dealValue / 100000).toStringAsFixed(1)}L', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D))),
                                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFADB5BD)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          onSelectModule(4); // Pipeline
                                        },
                                      )),
                                ],
                                if (matchedEmployees.isNotEmpty) ...[
                                  _buildSearchHeader('PEOPLE & ORGANIZATION'),
                                  ...matchedEmployees.map((e) => ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF212529)),
                                        title: Text(e.name, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                                        subtitle: Text('${e.role} • ${e.department}', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D))),
                                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFADB5BD)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          onSelectModule(2); // People
                                        },
                                      )),
                                ],
                                if (matchedTasks.isNotEmpty) ...[
                                  _buildSearchHeader('TASKS & DEADLINES'),
                                  ...matchedTasks.map((t) => ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.task_alt_rounded, size: 18, color: Color(0xFF212529)),
                                        title: Text(t.title, style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                                        subtitle: Text('Assigned: ${t.assignedToName} • ${t.domain}', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D))),
                                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFADB5BD)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          onSelectModule(8); // Tasks
                                        },
                                      )),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildSearchHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF6C757D), letterSpacing: 0.6),
      ),
    );
  }

  /// Live Notifications Bottom Sheet / Dropdown
  static void showNotificationsModal(
    BuildContext context,
    ErpProvider erp,
    ValueChanged<int> onSelectModule,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String activeFilter = 'All'; // 'All', 'Critical', 'Approvals', 'Projects', 'People'
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final allNotes = erp.allEmployeeNotifications;

            final filtered = allNotes.where((n) {
              if (activeFilter == 'Critical') return n['isUrgent'] == true;
              if (activeFilter == 'Approvals') return n['type'] == 'lead' || n['type'] == 'submission';
              if (activeFilter == 'Projects') return n['type'] == 'deadline' || n['type'] == 'task';
              if (activeFilter == 'People') return n['type'] == 'lead';
              return true;
            }).toList();

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Live Executive Alerts',
                        style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          erp.markAllAlertsAsRead();
                          setModalState(() {});
                        },
                        child: Text(
                          'Mark All as Read',
                          style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Critical', 'Approvals', 'Projects', 'People'].map((f) {
                        final isSel = activeFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: isSel,
                            selectedColor: const Color(0xFF212529),
                            backgroundColor: const Color(0xFFF5F6F7),
                            labelStyle: GoogleFonts.instrumentSans(
                              color: isSel ? Colors.white : const Color(0xFF495057),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => setModalState(() => activeFilter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notifications list
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No unread alerts in this category.',
                              style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D)),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFE9ECEF)),
                            itemBuilder: (ctx, i) {
                              final item = filtered[i];
                              final isRead = item['isRead'] == true;
                              final isUrgent = item['isUrgent'] == true;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isUrgent ? const Color(0xFFFFF5F5) : const Color(0xFFF5F6F7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData? ?? Icons.notifications_none_rounded,
                                    size: 18,
                                    color: isUrgent ? const Color(0xFFE03131) : const Color(0xFF212529),
                                  ),
                                ),
                                title: Text(
                                  item['title']?.toString() ?? '',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 13,
                                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                    color: const Color(0xFF212529),
                                  ),
                                ),
                                subtitle: Text(
                                  item['subtitle']?.toString() ?? '',
                                  style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                                ),
                                trailing: Text(
                                  item['time']?.toString() ?? '',
                                  style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFFADB5BD)),
                                ),
                                onTap: () {
                                  erp.markAlertAsRead(item['id'].toString());
                                  Navigator.pop(ctx);
                                  if (item['type'] == 'lead') onSelectModule(6); // Approvals
                                  if (item['type'] == 'deadline') onSelectModule(8); // Tasks
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Executive Report Export Modal (Section 11)
  static void showReportExportModal(
    BuildContext context,
    DateTime selectedDate,
    ErpProvider erp,
  ) {
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);
    final totalPipeline = (erp.totalPipelineValue / 100000).toStringAsFixed(1);
    final summaryText = '''
DIGITAL INERTIA — EXECUTIVE BRIEFING REPORT
Date: $dateStr
Prepared For: ${erp.currentUserName} (CEO)

1. Executive Performance Summary:
- Total Active Workforce: ${erp.allEmployees.length} employees | ${erp.allInterns.length} interns
- Pipeline Total: ₹$totalPipeline Lakhs across ${erp.allLeads.length} accounts
- Active Project Delivery: ${erp.allProjects.where((p) => p.status.name == 'inProgress').length} in-flight projects
- Executive Decisions Pending: ${erp.pendingApprovals.length} proposals

2. Department Operational Health:
- Finance: ₹${(erp.totalSpentBudget / 100000).toStringAsFixed(1)}L spent of ₹${(erp.totalAllocatedBudget / 100000).toStringAsFixed(1)}L allocation (${(erp.overallBudgetUtilization * 100).toInt()}% utilization)
- Sales & Marketing: 38 calls logged this week • ₹38.5L achieved towards monthly target
- HR: 94% workforce attendance • 5 leave approvals pending • 3 active requisitions
- Technical: 6 milestone deliverables on schedule • 1 blocker being resolved

3. Actionable Items:
- Immediate approval required for pending budget adjustments.
- Q4 Board Review scheduled at 04:00 PM.
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.print_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Executive Daily Report Export', style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                  Text(dateStr, style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D))),
                ],
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    summaryText,
                    style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF212529), height: 1.45),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D))),
          ),
          OutlinedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: summaryText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  content: Text('Executive briefing copied to clipboard.', style: GoogleFonts.instrumentSans(color: Colors.white)),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF212529)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Copy Summary', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF212529),
                  content: Text('Report generated for PDF export archive.', style: GoogleFonts.instrumentSans(color: Colors.white)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212529),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Export PDF / Spreadsheet', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Executive Employee Profile & Assignment Modal (Section 10)
  static void showEmployeeProfileModal(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCED4DA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Executive Profile Dossier',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF6C757D)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFE9ECEF), height: 1),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Avatar & Identity
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFF212529),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  employee.name.isNotEmpty ? employee.name[0] : 'E',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          employee.name,
                                          style: GoogleFonts.instrumentSans(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF212529),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: employee.isPresentToday ? const Color(0xFFE6FCF5) : const Color(0xFFFFF4E6),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          employee.isPresentToday ? 'Present' : 'On Leave',
                                          style: GoogleFonts.instrumentSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: employee.isPresentToday ? const Color(0xFF0CA678) : const Color(0xFFF76707),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    employee.role,
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF495057),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${employee.department} • ${employee.employmentStatus}',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 12,
                                      color: const Color(0xFF868E96),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Reporting Manager Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_tree_outlined, size: 18, color: Color(0xFF212529)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reports Directly To',
                                      style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFF868E96), fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      employee.reportingManager,
                                      style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                                    ),
                                  ],
                                ),
                              ),
                              if (employee.isPOC)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF212529),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'POC Lead',
                                    style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Workload Metrics Grid
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE9ECEF)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Active Tasks', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D))),
                                    const SizedBox(height: 4),
                                    Text('${employee.activeTaskCount}', style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF212529))),
                                    Text('${employee.completedTaskCount} completed', style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFF868E96))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE9ECEF)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Performance', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D))),
                                    const SizedBox(height: 4),
                                    Text('${employee.performanceScore.toStringAsFixed(1)} / 5.0', style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2F9E44))),
                                    Text('Evaluated rating', style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFF868E96))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE9ECEF)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Attendance', style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF6C757D))),
                                    const SizedBox(height: 4),
                                    Text('${employee.attendanceDays}d', style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF212529))),
                                    Text('${employee.attendanceRatio.toStringAsFixed(0)}% ratio', style: GoogleFonts.instrumentSans(fontSize: 10.5, color: const Color(0xFF868E96))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Assigned Projects
                        Text('Assigned Projects', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                        const SizedBox(height: 8),
                        if (employee.assignedProjectNames.isEmpty)
                          Text('No active project assignments.', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF868E96)))
                        else
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: employee.assignedProjectNames.map((proj) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  proj,
                                  style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF212529)),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 18),

                        // Core Skills
                        if (employee.skills.isNotEmpty) ...[
                          Text('Core Capabilities & Stack', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: employee.skills.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFDEE2E6)),
                                ),
                                child: Text(
                                  skill,
                                  style: GoogleFonts.instrumentSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF495057)),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Contact Details
                        Text('Contact & Location', style: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 15, color: Color(0xFF6C757D)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(employee.email, style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF212529)))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 15, color: Color(0xFF6C757D)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(employee.phone, style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF212529)))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF6C757D)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(employee.location, style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF212529)))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Create New Action Sheet inspired by Reference Images ('Create new ->')
  static void showCreateNewActionSheet(
    BuildContext context,
    ErpProvider erp,
    ValueChanged<int> onNavigateModule,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCED4DA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Executive Creation Actions',
              style: GoogleFonts.instrumentSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.campaign_outlined, color: Color(0xFF212529), size: 20),
              ),
              title: Text('Issue Strategic Directive', style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
              subtitle: Text('Dispatch binding instruction to department heads', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pop(ctx);
                showCompanyDirectiveModal(context, erp);
              },
            ),
            const Divider(color: Color(0xFFE9ECEF), height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month_outlined, color: Color(0xFF212529), size: 20),
              ),
              title: Text('Schedule Leadership Meeting', style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
              subtitle: Text('Board review, client steering or management sync', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pop(ctx);
                showScheduleMeetingModal(context, erp);
              },
            ),
            const Divider(color: Color(0xFFE9ECEF), height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.download_rounded, color: Color(0xFF212529), size: 20),
              ),
              title: Text('Export Executive Report', style: GoogleFonts.instrumentSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
              subtitle: Text('Export corporate figures to PDF or Spreadsheet', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFADB5BD)),
              onTap: () {
                Navigator.pop(ctx);
                showReportExportModal(context, DateTime.now(), erp);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Sign Out Confirmation Modal
  static void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Executive Sign Out',
          style: GoogleFonts.instrumentSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
        ),
        content: Text(
          'Are you sure you want to exit your executive workspace? Active synchronization and role session will be closed.',
          style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF495057), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.instrumentSans(color: const Color(0xFF6C757D))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ErpProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE03131),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Sign Out', style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
