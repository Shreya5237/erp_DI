import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/hr_models.dart';
import '../../../providers/erp_provider.dart';

/// Modal dialog to configure monthly HR targets (Section 2 of prompt)
class HrTargetConfigDialog extends StatefulWidget {
  const HrTargetConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const HrTargetConfigDialog(),
    );
  }

  @override
  State<HrTargetConfigDialog> createState() => _HrTargetConfigDialogState();
}

class _HrTargetConfigDialogState extends State<HrTargetConfigDialog> {
  late TextEditingController _leaveController;
  late TextEditingController _staffingController;
  late TextEditingController _traineeController;
  late TextEditingController _customerController;

  @override
  void initState() {
    super.initState();
    final targets = context.read<ErpProvider>().hrMonthlyTargets;
    _leaveController = TextEditingController(text: targets.leaveRequestsTarget.toString());
    _staffingController = TextEditingController(text: targets.staffingRequestsTarget.toString());
    _traineeController = TextEditingController(text: targets.traineeReviewsTarget.toString());
    _customerController = TextEditingController(text: targets.customerFollowUpsTarget.toString());
  }

  @override
  void dispose() {
    _leaveController.dispose();
    _staffingController.dispose();
    _traineeController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.read<ErpProvider>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212529).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Color(0xFF212529), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure Monthly Targets',
                          style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Editable targets for HR Department KPIs',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 20),

              _buildInputField('Leave Requests Review Target', _leaveController, 'e.g. 20'),
              const SizedBox(height: 10),
              _buildInputField('Staffing Requests Fulfilled Target', _staffingController, 'e.g. 10'),
              const SizedBox(height: 10),
              _buildInputField('Trainee Reviews Completed Target', _traineeController, 'e.g. 10'),
              const SizedBox(height: 10),
              _buildInputField('Customer Follow-Ups Completed Target', _customerController, 'e.g. 15'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final updated = HrMonthlyTargets(
                          leaveRequestsTarget: int.tryParse(_leaveController.text.trim()) ?? 20,
                          staffingRequestsTarget: int.tryParse(_staffingController.text.trim()) ?? 10,
                          traineeReviewsTarget: int.tryParse(_traineeController.text.trim()) ?? 10,
                          customerFollowUpsTarget: int.tryParse(_customerController.text.trim()) ?? 15,
                        );
                        erp.updateHrMonthlyTargets(updated);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF10B981),
                            content: Text('HR Monthly targets successfully updated'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save Targets', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFFF5F6F7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF212529))),
          ),
        ),
      ],
    );
  }
}
