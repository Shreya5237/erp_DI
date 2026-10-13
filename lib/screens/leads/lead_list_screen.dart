import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lead.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/compact_filter_bar.dart';
import 'lead_detail_dialog.dart';

/// Screen 7: Lead Management Screen matching Screen 7 in screenshot
class LeadListScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const LeadListScreen({super.key, this.onBack});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<ErpProvider>().leadSearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddLeadDialog(BuildContext context) {
    final erp = context.read<ErpProvider>();
    final companyController = TextEditingController();
    final clientController = TextEditingController();
    String domain = 'IT Consulting';
    double dealValue = 35000.0;
    String assignedEmpId = erp.allEmployees.firstWhere((e) => e.department.contains('Sales') || e.isPOC).id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Client Lead',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF212529)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: companyController,
                        decoration: const InputDecoration(labelText: 'Company Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: clientController,
                        decoration: const InputDecoration(labelText: 'Contact Person'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: domain,
                        decoration: const InputDecoration(labelText: 'Domain / Industry'),
                        items: ['IT Consulting', 'Mobile App', 'Web Platform', 'Solar Solutions', 'Cloud Services']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => domain = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Deal Value (\$)'),
                        onChanged: (val) => dealValue = double.tryParse(val) ?? 30000.0,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (companyController.text.trim().isEmpty) return;
                            erp.addLead(
                              clientName: clientController.text.trim().isEmpty ? 'Client Lead' : clientController.text.trim(),
                              companyName: companyController.text.trim(),
                              domain: domain,
                              email: 'contact@client.com',
                              phone: '+91 98111 00000',
                              dealValue: dealValue,
                              assignedEmployeeId: assignedEmpId,
                              nextFollowUpDate: DateTime.now().add(const Duration(days: 3)),
                              notes: 'New enquiry registered.',
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF212529)),
                          child: const Text('Save CRM Lead', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final leads = erp.filteredLeads;
    final activeStage = erp.leadStageFilter;
    final activeDomain = erp.leadDomainFilter ?? 'All Domains';
    final hasActiveFilters = activeStage != 'All' ||
        (erp.leadDomainFilter != null && erp.leadDomainFilter != 'All Domains') ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF212529)),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text(
          'Lead Management',
          style: TextStyle(
            color: Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _showAddLeadDialog(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF212529),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {});
                  erp.setLeadSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search lead by company, client, domain...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            erp.setLeadSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Space-Saving Compact Filter Dropdown Bar
          CompactFilterBar(
            hasActiveFilters: hasActiveFilters,
            onReset: () {
              _searchController.clear();
              erp.setLeadSearchQuery('');
              erp.setLeadStageFilter('All');
              erp.setLeadDomainFilter(null);
              setState(() {});
            },
            items: [
              FilterDropdownItem<String>(
                label: 'Stage',
                icon: Icons.tune_rounded,
                value: activeStage,
                options: const [
                  FilterOption<String>(label: 'All Stages', value: 'All'),
                  FilterOption<String>(label: 'New Lead', value: 'New', color: Color(0xFF2563EB)),
                  FilterOption<String>(label: 'Contacted', value: 'Contacted', color: Color(0xFF7C3AED)),
                  FilterOption<String>(label: 'Proposal Sent', value: 'Proposal', color: Color(0xFFD97706)),
                  FilterOption<String>(label: 'Qualified', value: 'Qualified', color: Color(0xFF0D9488)),
                  FilterOption<String>(label: 'Deal Won', value: 'Won', color: Color(0xFF16A34A)),
                  FilterOption<String>(label: 'Lost', value: 'Lost', color: Color(0xFFDC2626)),
                ],
                onChanged: (val) {
                  if (val != null) erp.setLeadStageFilter(val);
                },
              ),
              FilterDropdownItem<String>(
                label: 'Domain / Industry',
                icon: Icons.domain_rounded,
                value: activeDomain,
                options: erp.availableLeadDomains.map((d) => FilterOption<String>(label: d, value: d)).toList(),
                onChanged: (val) {
                  erp.setLeadDomainFilter(val == 'All Domains' ? null : val);
                },
              ),
            ],
          ),

          // Quick Stage Chips Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStageChip('All (${erp.allLeads.length})', activeStage == 'All', () => erp.setLeadStageFilter('All')),
                  const SizedBox(width: 6),
                  _buildStageChip('New (${erp.allLeads.where((l) => l.status == LeadStatus.newLead).length})', activeStage == 'New', () => erp.setLeadStageFilter('New')),
                  const SizedBox(width: 6),
                  _buildStageChip('Contacted (${erp.allLeads.where((l) => l.status == LeadStatus.contactEstablished).length})', activeStage == 'Contacted', () => erp.setLeadStageFilter('Contacted')),
                  const SizedBox(width: 6),
                  _buildStageChip('Proposal (${erp.allLeads.where((l) => l.status == LeadStatus.proposalPrepared || l.status == LeadStatus.proposalSent).length})', activeStage == 'Proposal', () => erp.setLeadStageFilter('Proposal')),
                  const SizedBox(width: 6),
                  _buildStageChip('Qualified (${erp.allLeads.where((l) => l.status == LeadStatus.requirementsCollected).length})', activeStage == 'Qualified', () => erp.setLeadStageFilter('Qualified')),
                  const SizedBox(width: 6),
                  _buildStageChip('Won (${erp.allLeads.where((l) => l.status == LeadStatus.won).length})', activeStage == 'Won', () => erp.setLeadStageFilter('Won')),
                ],
              ),
            ),
          ),

          // Leads list matching Screen 7
          Expanded(
            child: leads.isEmpty
                ? const Center(
                    child: Text(
                      'No leads match filter.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: leads.length,
                    itemBuilder: (context, index) {
                      final lead = leads[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.015),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Call/Chat rounded square icon
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.call_outlined,
                                size: 18,
                                color: Color(0xFF212529),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lead.companyName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212529),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    lead.domain,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Next: ${lead.nextFollowUpDate.day} ${_getMonth(lead.nextFollowUpDate.month)}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                lead.status.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Three dots
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => LeadDetailDialog(lead: lead),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF212529) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m[month - 1];
  }
}
