import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/lead.dart';
import '../../../providers/erp_provider.dart';

/// Dialog to record customer requirements, requested changes, and forward to PM or Finance
class CustomerChangeRequestDialog extends StatefulWidget {
  final Lead? preselectedLead;

  const CustomerChangeRequestDialog({super.key, this.preselectedLead});

  static Future<void> show(BuildContext context, {Lead? lead}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomerChangeRequestDialog(preselectedLead: lead),
    );
  }

  @override
  State<CustomerChangeRequestDialog> createState() => _CustomerChangeRequestDialogState();
}

class _CustomerChangeRequestDialogState extends State<CustomerChangeRequestDialog> {
  late String _leadId;
  late String _clientName;
  late String _companyName;
  String? _projectName;
  String _feedbackType = 'Change Request';
  String _forwardedToRole = 'Project Manager';
  final TextEditingController _descController = TextEditingController();
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 3));

  @override
  void initState() {
    super.initState();
    if (widget.preselectedLead != null) {
      _leadId = widget.preselectedLead!.id;
      _clientName = widget.preselectedLead!.clientName;
      _companyName = widget.preselectedLead!.companyName;
      _projectName = widget.preselectedLead!.requirementsScope.isNotEmpty ? widget.preselectedLead!.requirementsScope : widget.preselectedLead!.domain;
    } else {
      _leadId = 'LED-504';
      _clientName = 'Sanjay Patel';
      _companyName = 'SolarEase Energy Corp';
      _projectName = 'Solar IoT Monitoring Dashboard';
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final leads = erp.allLeads;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.handshake_rounded, color: Color(0xFF212529), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Coordination & Changes',
                        style: TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'HR Post-Deal Client Communication',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
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

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notice banner
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFF212529), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'HR coordinates client communication. Technical feasibility, budget impact, and delivery deadlines will be reviewed by the chosen Lead or Finance.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Select Deal
                    const Text('Finalized Deal / Client', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _leadId,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: leads.map((l) {
                            return DropdownMenuItem<String>(
                              value: l.id,
                              child: Text(
                                '${l.companyName} (${l.clientName})',
                                style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id != null) {
                              final l = leads.firstWhere((x) => x.id == id);
                              setState(() {
                                _leadId = l.id;
                                _clientName = l.clientName;
                                _companyName = l.companyName;
                                _projectName = l.requirementsScope.isNotEmpty ? l.requirementsScope : l.domain;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Request / Feedback Type
                    const Text('Feedback / Request Type', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _feedbackType,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(value: 'Change Request', child: Text('Change Request (Scope / Feature)', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: 'Customer Feedback', child: Text('Customer Feedback', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: 'Staffing Inquiries', child: Text('Staffing & Team Inquiries', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: 'SLA Escalation', child: Text('SLA Escalation', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _feedbackType = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Forward to role
                    const Text('Forward To Lead Role', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _forwardedToRole,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(value: 'Project Manager', child: Text('Project Manager (Delivery & Timeline)', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: 'Tech Lead', child: Text('Technical Lead (Feasibility & Architecture)', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                            DropdownMenuItem(value: 'Finance Lead', child: Text('Finance Lead (Budget & Commercials)', style: TextStyle(color: Color(0xFF212529), fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _forwardedToRole = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    const Text('Customer Request / Changes Description', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descController,
                      style: const TextStyle(color: Color(0xFF212529), fontSize: 13),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Record details discussed with customer, requested adjustments...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFFF5F6F7),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF212529))),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Follow up Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Follow-Up Date', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF212529)),
                          label: Text(
                            '${_followUpDate.day}/${_followUpDate.month}/${_followUpDate.year}',
                            style: const TextStyle(color: Color(0xFF212529), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _followUpDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) setState(() => _followUpDate = picked);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Buttons
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
                      if (_descController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFFEF4444),
                            content: Text('Please enter a description for the customer request'),
                          ),
                        );
                        return;
                      }

                      erp.addCustomerChangeRequest(
                        leadId: _leadId,
                        clientName: _clientName,
                        companyName: _companyName,
                        projectName: _projectName,
                        feedbackType: _feedbackType,
                        description: _descController.text.trim(),
                        forwardedToRole: _forwardedToRole,
                        followUpDate: _followUpDate,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text('Customer request recorded & forwarded to $_forwardedToRole'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212529),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Submit & Forward', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
