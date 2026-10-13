import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/lead.dart';
import '../../../providers/erp_provider.dart';

/// Modal bottom sheet for Finance review and commercial signoff on sales deals
class FinanceLeadReviewSheet extends StatefulWidget {
  final Lead lead;

  const FinanceLeadReviewSheet({super.key, required this.lead});

  static void show(BuildContext context, Lead lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FinanceLeadReviewSheet(lead: lead),
    );
  }

  @override
  State<FinanceLeadReviewSheet> createState() => _FinanceLeadReviewSheetState();
}

class _FinanceLeadReviewSheetState extends State<FinanceLeadReviewSheet> {
  late TextEditingController _costController;
  late TextEditingController _priceController;
  late TextEditingController _termsController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final f = widget.lead.financeFeasibility;
    _costController = TextEditingController(text: f.estimatedCost.toStringAsFixed(0));
    _priceController = TextEditingController(text: (f.quotedPrice > 0 ? f.quotedPrice : widget.lead.dealValue).toStringAsFixed(0));
    _termsController = TextEditingController(text: f.paymentTerms);
    _notesController = TextEditingController(text: f.budgetFeasibilityNotes);
  }

  @override
  void dispose() {
    _costController.dispose();
    _priceController.dispose();
    _termsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _computedMargin {
    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    if (price <= 0) return 0.0;
    return (((price - cost) / price) * 100.0).clamp(-100.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final margin = _computedMargin;
    final isMarginHealthy = margin >= 30.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF212529),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.attach_money_rounded, color: Color(0xFFA78BFA), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deal Financial Feasibility Review',
                        style: TextStyle(
                          color: Color(0xFF212529),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${widget.lead.companyName} • ${widget.lead.id}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white, height: 1),

          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client / Deal Overview Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.lead.clientName,
                              style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.lead.status.label,
                                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Sales Lead: ${widget.lead.assignedEmployeeName}',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                            const Spacer(),
                            Text(
                              'Target Value: ₹${widget.lead.dealValue.toStringAsFixed(0)}',
                              style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Requirements Scope: ${widget.lead.requirementsScope}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Financial Cost & Price Inputs
                  const Text(
                    'Financial Model & Commitment',
                    style: TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Estimated Cost
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated Cost (₹)', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _costController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF2B3035),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Quoted Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quoted Price (₹)', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF2B3035),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Calculated Margin Badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMarginHealthy
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isMarginHealthy
                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                            : const Color(0xFFEF4444).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isMarginHealthy ? Icons.check_circle_rounded : Icons.warning_rounded,
                              color: isMarginHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isMarginHealthy ? 'Healthy Profit Margin' : 'Sub-Target Margin Alert (<30%)',
                              style: TextStyle(
                                color: isMarginHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${margin.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: isMarginHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Terms
                  const Text('Payment Milestone Terms', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _termsController,
                    style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. 30% Advance, 40% Milestone 2, 30% Delivery',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF2B3035),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Review Notes
                  const Text('Financial Review & Feasibility Notes *', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'Record financial evaluation comments, risk exposure, and budget conditions...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF2B3035),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions row: Approve / Return / Clarify
                  Row(
                    children: [
                      // Return / Reject button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleDecision(isApproved: false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Return / Clarify', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Approve button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleDecision(isApproved: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Approve Financials', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDecision({required bool isApproved}) {
    final cost = double.tryParse(_costController.text.trim()) ?? 150000.0;
    final price = double.tryParse(_priceController.text.trim()) ?? widget.lead.dealValue;
    final margin = _computedMargin;
    final terms = _termsController.text.trim().isNotEmpty
        ? _termsController.text.trim()
        : '30% Advance, 70% Delivery';
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : (isApproved
            ? 'Approved by Finance: Margin of ${margin.toStringAsFixed(1)}% satisfies company threshold.'
            : 'Returned for commercial clarification.');

    final erp = context.read<ErpProvider>();

    if (isApproved) {
      erp.updateFinanceFeasibilityReview(
        widget.lead.id,
        status: FeasibilityStatus.completed,
        estimatedCost: cost,
        quotedPrice: price,
        expectedMarginPercent: margin,
        paymentTerms: terms,
        budgetFeasibilityNotes: notes,
      );
      erp.approveDealFinancials(widget.lead.id, comments: notes);
    } else {
      erp.updateFinanceFeasibilityReview(
        widget.lead.id,
        status: FeasibilityStatus.changesRequested,
        estimatedCost: cost,
        quotedPrice: price,
        expectedMarginPercent: margin,
        paymentTerms: terms,
        budgetFeasibilityNotes: notes,
      );
      erp.rejectDealFinancials(widget.lead.id, reason: notes);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isApproved ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        content: Text(
          isApproved
              ? 'Financials approved for ${widget.lead.companyName}'
              : 'Deal returned to Sales with revision notes',
        ),
      ),
    );
  }
}
