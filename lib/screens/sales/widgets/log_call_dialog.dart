import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final String _selectedPriority = 'Medium';
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: 'Log a new call' + Close 'X' Button (Image 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Log a new call',
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF212529),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F3F5),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.close_rounded, color: Color(0xFF495057), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Field 1: Lead or customer (Image 1)
                  Text(
                    'Lead or customer',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _customerController,
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter a name',
                      hintStyle: GoogleFonts.instrumentSans(
                        color: const Color(0xFFADB5BD),
                        fontSize: 13.5,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F7),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF212529), width: 1.2),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 18),

                  // Field 2: Outcome Dropdown (Image 1)
                  Text(
                    'Outcome',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CallOutcome>(
                        value: _selectedOutcome,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF212529)),
                        style: GoogleFonts.instrumentSans(
                          color: const Color(0xFF212529),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                        items: CallOutcome.values.map((outcome) {
                          return DropdownMenuItem<CallOutcome>(
                            value: outcome,
                            child: Text(outcome.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedOutcome = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Field 3: Notes (Image 1)
                  Text(
                    'Notes',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF212529),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add call notes...',
                      hintStyle: GoogleFonts.instrumentSans(
                        color: const Color(0xFFADB5BD),
                        fontSize: 13.5,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F7),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF212529), width: 1.2),
                      ),
                    ),
                  ),

                  // Supplementary schedule if follow-up required
                  if (_selectedOutcome == CallOutcome.followUpRequired ||
                      _selectedOutcome == CallOutcome.interested) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickFollowUpDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Color(0xFF212529), size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedFollowUpDate != null
                                    ? 'Follow-up: ${_selectedFollowUpDate!.day}/${_selectedFollowUpDate!.month}/${_selectedFollowUpDate!.year} at ${_selectedFollowUpTime.format(context)}'
                                    : 'Schedule next follow-up',
                                style: GoogleFonts.instrumentSans(
                                  color: const Color(0xFF212529),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF868E96), size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Button: Full Width 'Save call' (Image 1)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Save call',
                        style: GoogleFonts.instrumentSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
