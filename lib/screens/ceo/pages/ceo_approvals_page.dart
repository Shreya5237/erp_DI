import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/approval.dart';
import '../widgets/ceo_modals.dart';

/// Module 7: Approvals & Requests (Specification Section 13)
/// Provides CEO decision workflows for:
/// - Sales Proposals & High-Value Deals
/// - Budget Approvals & Financial Reallocations
/// - Staffing & Resource Requisitions
/// - Customer Scope Changes
class CeoApprovalsPage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoApprovalsPage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoApprovalsPage> createState() => _CeoApprovalsPageState();
}

class _CeoApprovalsPageState extends State<CeoApprovalsPage> {
  String _statusFilter = 'Pending'; // 'Pending', 'Approved', 'Changes Requested', 'Rejected', 'All'

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allRequests = erp.allApprovalRequests;

    final filtered = allRequests.where((a) {
      if (_statusFilter == 'Pending') return a.isAwaitingExecutiveAction;
      if (_statusFilter == 'Approved') return a.status == ApprovalStatus.approved;
      if (_statusFilter == 'Changes Requested') return a.status == ApprovalStatus.changesRequested;
      if (_statusFilter == 'Rejected') return a.status == ApprovalStatus.rejected;
      return true;
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 18 : 24,
        isMobile ? 16 : 28,
        40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs & Header
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text('Executive Overview', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFADB5BD)),
              Text('Approvals & Requests', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Executive Approvals & Requests',
            style: GoogleFonts.instrumentSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF212529), letterSpacing: -0.5),
          ),
          const SizedBox(height: 18),

          // Status Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Pending', 'Approved', 'Changes Requested', 'Rejected', 'All'].map((s) {
                final isSel = _statusFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: isSel,
                    selectedColor: const Color(0xFF212529),
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.instrumentSans(
                      color: isSel ? Colors.white : const Color(0xFF495057),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _statusFilter = s),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Requests List
          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.fact_check_outlined, size: 36, color: Color(0xFFADB5BD)),
                    const SizedBox(height: 8),
                    Text(
                      'No approval requests in "$_statusFilter".',
                      style: GoogleFonts.instrumentSans(fontSize: 13.5, color: const Color(0xFF6C757D), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ...filtered.map((req) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: req.status == ApprovalStatus.approved
                                ? const Color(0xFFEBFBEE)
                                : (req.status == ApprovalStatus.rejected
                                    ? const Color(0xFFFFF5F5)
                                    : const Color(0xFFF5F6F7)),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: req.status == ApprovalStatus.approved
                                  ? const Color(0xFFB2F2BB)
                                  : (req.status == ApprovalStatus.rejected
                                      ? const Color(0xFFFFC9C9)
                                      : const Color(0xFFDEE2E6)),
                            ),
                          ),
                          child: Text(
                            req.status.label,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: req.status == ApprovalStatus.approved
                                  ? const Color(0xFF2F9E44)
                                  : (req.status == ApprovalStatus.rejected ? const Color(0xFFE03131) : const Color(0xFF212529)),
                            ),
                          ),
                        ),
                        Text(
                          '₹${req.dealValueOrBudget.toStringAsFixed(0)}',
                          style: GoogleFonts.instrumentSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      req.title,
                      style: GoogleFonts.instrumentSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF212529)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Submitting Department: ${req.submittingDepartment} • Requester: ${req.submittedByName} (${req.submittedByRole})',
                      style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      req.summary,
                      style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF495057), height: 1.4),
                    ),
                    if (req.reviewNotes != null && req.reviewNotes!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Text(
                          'Executive Decision Notes: ${req.reviewNotes}',
                          style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF212529), fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    if (req.isAwaitingExecutiveAction) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => CeoModals.showApprovalDecisionModal(context, req, erp),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFDEE2E6)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              child: Text('Review & Decide', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                erp.approveApprovalRequest(req.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF212529),
                                    content: Text('Proposal "${req.title}" approved.', style: GoogleFonts.instrumentSans(color: Colors.white)),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF212529),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              child: Text('Approve Now', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
