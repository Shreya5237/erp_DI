import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../models/lead.dart';

/// Focused Dashboard Cockpit for Sales Employee (Rajesh Kumar) adhering to Section 4 & 9.4
class SalesDashboardView extends StatefulWidget {
  final VoidCallback? onOpenPipeline;

  const SalesDashboardView({super.key, this.onOpenPipeline});

  @override
  State<SalesDashboardView> createState() => _SalesDashboardViewState();
}

class _SalesDashboardViewState extends State<SalesDashboardView> {
  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final myLeads = erp.allLeads.where((l) =>
        l.assignedEmployeeId == erp.currentUserId || l.assignedEmployeeName == erp.currentUserName).toList();
    final followUpsDue = myLeads.where((l) => l.needsAttentionToday).toList();
    final totalValueLakhs = (myLeads.fold(0.0, (sum, l) => sum + l.dealValue) / 100000).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Lead Persona Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Welcome, ${erp.currentUserName.split(" ")[0]}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF212529),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SALES BD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Sales & BD • 12-Stage Pipeline Cockpit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showLogInteractionDialog(context, erp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add_call, size: 14, color: Colors.white),
                  label: const Text('Log Call', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3 Outreach Metric Cards: Contacts target, Pending Calls, Pipeline Value
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Calls Made',
                    value: '${erp.contactsCompletedThisWeek} / ${erp.weeklyContactTarget}',
                    subtext: 'Weekly Target',
                    color: const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.schedule_rounded,
                    title: 'Pending Calls',
                    value: '${erp.pendingCallsToday}',
                    subtext: 'Scheduled Today',
                    color: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.monetization_on_outlined,
                    title: 'Pipeline',
                    value: '₹${totalValueLakhs}L',
                    subtext: '${myLeads.length} Opportunities',
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Urgent Follow-Ups Due Section
            if (followUpsDue.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm_on_rounded, size: 18, color: Color(0xFFEF4444)),
                        const SizedBox(width: 8),
                        Text(
                          '${followUpsDue.length} Follow-ups Due / Overdue',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...followUpsDue.map((l) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l.companyName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF212529))),
                                    Text('Client: ${l.clientName} • Stage: ${l.status.label}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  erp.logLeadInteraction(l.id, type: 'Call', summary: 'Follow-up call completed with ${l.clientName}.');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Logged interaction with ${l.companyName}!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  backgroundColor: const Color(0xFF212529),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Mark Called', style: TextStyle(fontSize: 11, color: Colors.white)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 12-Stage Pipeline Summary Cards
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '12-Stage Sales Pipeline',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                      ),
                      if (widget.onOpenPipeline != null)
                        GestureDetector(
                          onTap: widget.onOpenPipeline,
                          child: const Text('Open Kanban', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: LeadStatus.values.map((stage) {
                      final count = myLeads.where((l) => l.status == stage).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: count > 0 ? const Color(0xFFECFDF5) : const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: count > 0 ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              stage.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: count > 0 ? FontWeight.w700 : FontWeight.w500,
                                color: count > 0 ? const Color(0xFF065F46) : const Color(0xFF64748B),
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Opportunities List
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Client Opportunities',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
                  ),
                  const SizedBox(height: 12),
                  ...myLeads.map((lead) => _buildOpportunityCard(context, erp, lead)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, ErpProvider erp, Lead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lead.companyName,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
              ),
              Text(
                '₹${lead.dealValue.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Stage: ${lead.status.label} • Client: ${lead.clientName}',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Source: ${lead.source}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (lead.status == LeadStatus.requirementsCollected)
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                  onPressed: () {
                    erp.submitLeadForInternalApproval(lead.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Submitted ${lead.companyName} for internal approval!')),
                    );
                  },
                  child: const Text('Forward to GM/CEO', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogInteractionDialog(BuildContext context, ErpProvider erp) {
    final noteController = TextEditingController();
    String selectedType = 'Call';
    String selectedLeadId = erp.allLeads.first.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log Client Interaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedLeadId,
                  items: erp.allLeads.map((l) => DropdownMenuItem(value: l.id, child: Text(l.companyName))).toList(),
                  onChanged: (v) => setDialogState(() => selectedLeadId = v!),
                  decoration: InputDecoration(
                    labelText: 'Client Opportunity',
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  items: ['Call', 'Message', 'Meeting', 'Client Response'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: InputDecoration(
                    labelText: 'Interaction Type',
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Notes / Outcome',
                    filled: true,
                    fillColor: const Color(0xFFF5F6F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF212529),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                erp.logLeadInteraction(selectedLeadId, type: selectedType, summary: noteController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interaction recorded successfully!')));
              },
              child: const Text('Save Log'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtext,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF212529)),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(subtext, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
          ],
        ],
      ),
    );
  }
}
