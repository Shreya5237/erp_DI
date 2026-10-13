import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/finance_models.dart';
import '../../../providers/erp_provider.dart';

/// Modal dialog for modifying and adjusting an assigned project budget
class AdjustBudgetDialog extends StatefulWidget {
  final ProjectBudget project;

  const AdjustBudgetDialog({super.key, required this.project});

  static Future<void> show(BuildContext context, ProjectBudget project) {
    return showDialog(
      context: context,
      builder: (_) => AdjustBudgetDialog(project: project),
    );
  }

  @override
  State<AdjustBudgetDialog> createState() => _AdjustBudgetDialogState();
}

class _AdjustBudgetDialogState extends State<AdjustBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isIncrease = true;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  double get _currentAdjustmentAmount {
    final val = double.tryParse(_amountController.text.trim()) ?? 0.0;
    return _isIncrease ? val : -val;
  }

  double get _previewBudget {
    return widget.project.approvedBudget + _currentAdjustmentAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded, color: Color(0xFF212529), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adjust Project Budget',
                            style: TextStyle(
                              color: Color(0xFF212529),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${widget.project.projectName} (${widget.project.projectId})',
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
                const SizedBox(height: 16),

                // Current Budget Stat Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Approved', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${widget.project.approvedBudget.toStringAsFixed(0)}',
                            style: const TextStyle(color: Color(0xFF212529), fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Spent', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${widget.project.spentAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: widget.project.isExceeded ? const Color(0xFFEF4444) : const Color(0xFF212529),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Utilization', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '${(widget.project.utilizationPercentage * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: widget.project.isExceeded
                                  ? const Color(0xFFEF4444)
                                  : widget.project.isApproachingLimit
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF10B981),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Adjustment Type Selector
                const Text(
                  'Adjustment Direction',
                  style: TextStyle(color: Color(0xFF212529), fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isIncrease = true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isIncrease
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFF5F6F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isIncrease ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded, color: _isIncrease ? const Color(0xFF10B981) : const Color(0xFF64748B), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Increase (+)',
                                style: TextStyle(
                                  color: _isIncrease ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isIncrease = false),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isIncrease
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF5F6F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: !_isIncrease ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_circle_outline_rounded, color: !_isIncrease ? const Color(0xFFEF4444) : const Color(0xFF64748B), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Decrease (-)',
                                style: TextStyle(
                                  color: !_isIncrease ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount Field
                const Text(
                  'Adjustment Amount (₹)',
                  style: TextStyle(color: Color(0xFF212529), fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF64748B), size: 18),
                    hintText: 'e.g. 15000',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter adjustment amount';
                    final num = double.tryParse(val.trim());
                    if (num == null || num <= 0) return 'Enter a valid positive number';
                    if (!_isIncrease && (widget.project.approvedBudget - num) < 0) {
                      return 'Budget cannot be negative';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Preview Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Resulting Approved Budget:',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                      Text(
                        '₹${_previewBudget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF212529),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Justification Field
                const Text(
                  'Reason / Audit Justification *',
                  style: TextStyle(color: Color(0xFF212529), fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 2,
                  style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Scope expansion approved by CEO: Added mobile telemetry module',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Reason is required for audit logs';
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212529),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Record Budget Adjustment',
                      style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final delta = _isIncrease ? amount : -amount;
    final reason = _reasonController.text.trim();

    final erp = context.read<ErpProvider>();
    erp.adjustProjectBudget(
      widget.project.projectId,
      adjustmentAmount: delta,
      reason: reason,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Text(
          'Budget for ${widget.project.projectName} adjusted by ₹${delta.toStringAsFixed(0)}',
        ),
      ),
    );
  }
}
