import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/sales_call.dart';
import '../../../providers/erp_provider.dart';

/// Modal dialog for recording a new cold call or follow-up call
class LogCallDialog extends StatefulWidget {
  final String? prefilledCompanyName;
  final String? prefilledCustomerName;
  final String? prefilledPhone;
  final String? leadId;

  const LogCallDialog({
    super.key,
    this.prefilledCompanyName,
    this.prefilledCustomerName,
    this.prefilledPhone,
    this.leadId,
  });

  @override
  State<LogCallDialog> createState() => _LogCallDialogState();
}

class _LogCallDialogState extends State<LogCallDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customerController;
  late final TextEditingController _companyController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  late final TextEditingController _dealValueController;

  CallOutcome _selectedOutcome = CallOutcome.followUpRequired;
  String _selectedPriority = 'Medium';
  DateTime? _selectedFollowUpDate;
  TimeOfDay _selectedFollowUpTime = const TimeOfDay(hour: 15, minute: 0);

  @override
  void initState() {
    super.initState();
    _customerController = TextEditingController(text: widget.prefilledCustomerName ?? '');
    _companyController = TextEditingController(text: widget.prefilledCompanyName ?? '');
    _phoneController = TextEditingController(text: widget.prefilledPhone ?? '');
    _notesController = TextEditingController();
    _dealValueController = TextEditingController();
    _selectedFollowUpDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _customerController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _dealValueController.dispose();
    super.dispose();
  }

  Future<void> _pickFollowUpDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedFollowUpDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF212529),
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedFollowUpTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF212529),
                surface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (mounted) {
        setState(() {
          _selectedFollowUpTime = pickedTime ?? _selectedFollowUpTime;
          _selectedFollowUpDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedFollowUpTime.hour,
            _selectedFollowUpTime.minute,
          );
        });
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final dealVal = double.tryParse(_dealValueController.text.trim());
    final erp = context.read<ErpProvider>();

    erp.logColdCall(
      customerName: _customerController.text.trim(),
      companyName: _companyController.text.trim(),
      phone: _phoneController.text.trim(),
      outcome: _selectedOutcome,
      notes: _notesController.text.trim(),
      nextFollowUpDate: (_selectedOutcome == CallOutcome.followUpRequired ||
              _selectedOutcome == CallOutcome.interested)
          ? _selectedFollowUpDate
          : null,
      dealValue: dealVal,
      priority: _selectedPriority,
      leadId: widget.leadId,
    );

    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Call logged for ${_customerController.text.trim()} (${_selectedOutcome.label})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
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
                      child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF212529), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Record Sales Call',
                            style: TextStyle(color: Color(0xFF212529), fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Log outcome, notes & next action',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer & Company fields
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _customerController,
                                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                                decoration: _buildInputDecoration('Lead / Contact Name', Icons.person_outline_rounded),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _companyController,
                                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                                decoration: _buildInputDecoration('Company Name', Icons.business_rounded),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Phone & Deal Value
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                                decoration: _buildInputDecoration('Phone Number', Icons.phone_outlined),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _dealValueController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                                decoration: _buildInputDecoration('Estimated Deal (₹)', Icons.currency_rupee_rounded),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Call Outcome Selector
                        const Text(
                          'Call Outcome',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: CallOutcome.values.map((outcome) {
                            final isSelected = _selectedOutcome == outcome;
                            return ChoiceChip(
                              label: Text(outcome.label),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedOutcome = outcome),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              backgroundColor: const Color(0xFFF5F6F7),
                              selectedColor: outcome.color.withValues(alpha: 0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected ? outcome.color : Colors.white10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Next follow-up date (if follow-up or interested)
                        if (_selectedOutcome == CallOutcome.followUpRequired ||
                            _selectedOutcome == CallOutcome.interested) ...[
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Schedule Next Follow-up',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                              DropdownButton<String>(
                                value: _selectedPriority,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Color(0xFF212529), fontSize: 12),
                                underline: const SizedBox(),
                                items: ['Urgent', 'High', 'Medium', 'Low'].map((p) {
                                  return DropdownMenuItem(value: p, child: Text('$p Priority'));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedPriority = val);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickFollowUpDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_rounded, color: Color(0xFF212529), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _selectedFollowUpDate != null
                                          ? '${_selectedFollowUpDate!.day}/${_selectedFollowUpDate!.month}/${_selectedFollowUpDate!.year} at ${_selectedFollowUpTime.format(context)}'
                                          : 'Select Date & Time',
                                      style: const TextStyle(color: Color(0xFF212529), fontSize: 12.5),
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Notes field
                        const Text(
                          'Call Notes & Client Feedback',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          style: const TextStyle(color: Color(0xFF212529), fontSize: 12.5),
                          decoration: InputDecoration(
                            hintText: 'e.g. Discussed cloud pricing, decision maker requested proposal by Thursday...',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
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
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF212529)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      label: const Text('Save Call Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 16),
      filled: true,
      fillColor: const Color(0xFFF5F6F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF212529)),
      ),
    );
  }
}
