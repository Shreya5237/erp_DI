import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../../../models/lead.dart';
import '../widgets/ceo_modals.dart';

/// Module 4: Clients & Business Workspace (Specification Section 8 & Image 4)
/// Features:
/// - Client directory, relationship owners, and active escalations
/// - 12-stage sales pipeline with deal stages and values in ₹
/// - Marketing campaign performance and lead generation
/// - Deal history dossier and CEO follow-up actions
class CeoPipelinePage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoPipelinePage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoPipelinePage> createState() => _CeoPipelinePageState();
}

class _CeoPipelinePageState extends State<CeoPipelinePage> {
  String _activeTab = 'Clients'; // 'Clients', 'Pipeline', 'Sales', 'Marketing', 'Escalations'
  String _selectedStage = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final leads = erp.allLeads;
    final totalPipelineCr = (erp.totalPipelineValue / 10000000).toStringAsFixed(2);

    final filtered = leads.where((l) {
      if (_selectedStage == 'Won' && l.status != LeadStatus.won) return false;
      if (_selectedStage == 'Proposal' && !(l.status == LeadStatus.proposalPrepared || l.status == LeadStatus.internalApproval)) return false;
      if (_selectedStage == 'Qualified' && l.status != LeadStatus.qualified) return false;
      if (_selectedStage == 'Review' && !(l.status == LeadStatus.feasibilityAssessment || l.status == LeadStatus.internalApproval)) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!l.companyName.toLowerCase().contains(q) && !l.clientName.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Clean Executive Style — No Wordy Subheadings)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Clients & Business',
                  style: GoogleFonts.instrumentSans(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212529),
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Action Pill Button (Image 4: "Create new ->")
              ElevatedButton(
                onPressed: () => CeoModals.showCreateNewActionSheet(context, erp, widget.onNavigateModule),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212529),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create new',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Horizontal Tab Pills (Image 4)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Clients', 'Pipeline', 'Sales', 'Marketing', 'Escalations'].map((tab) {
                final isSel = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: isSel,
                    selectedColor: const Color(0xFF212529),
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.instrumentSans(
                      color: isSel ? Colors.white : const Color(0xFF495057),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _activeTab = tab),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPipelineStatCard(
                  'Pipeline value',
                  '₹$totalPipelineCr Cr',
                  '+8.2% this month',
                ),
                const SizedBox(width: 12),
                _buildPipelineStatCard(
                  'Active deals',
                  '${leads.length}',
                  '12 in late stage',
                ),
                const SizedBox(width: 12),
                _buildPipelineStatCard(
                  'Client health',
                  '92%',
                  '3 need attention',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Content Card Container (Image 4: Clean white card with search, filter, and rows)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priority clients & opportunities',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Live company records · Last updated just now',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 11,
                          color: const Color(0xFF868E96),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search & Status Filter Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Search Input
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFDEE2E6)),
                          ),
                          child: TextField(
                            style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF212529)),
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            decoration: InputDecoration(
                              hintText: 'Filter records...',
                              hintStyle: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFFADB5BD)),
                              prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF868E96)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Status Dropdown
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDEE2E6)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStage,
                            style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF495057)),
                            icon: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF868E96)),
                            items: ['All', 'Won', 'Proposal', 'Qualified', 'Review'].map((st) {
                              return DropdownMenuItem(value: st, child: Text(st == 'All' ? 'All statuses' : st));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStage = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE9ECEF), height: 1),

                // Minimalist List Rows (Image 4)
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No client opportunities match the filter.',
                        style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF868E96)),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const Divider(color: Color(0xFFE9ECEF), height: 1),
                    itemBuilder: (ctx, i) {
                      final l = filtered[i];
                      final dealLakhs = (l.dealValue / 100000).toStringAsFixed(1);

                      return InkWell(
                        onTap: () => _showDealDossierModal(context, l),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l.companyName,
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF212529),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '₹${dealLakhs}L',
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF495057),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF868E96)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineStatCard(String title, String val, String sub) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF868E96),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.instrumentSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF212529),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.instrumentSans(
              fontSize: 10.5,
              color: const Color(0xFFADB5BD),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  void _showDealDossierModal(BuildContext context, Lead lead) {
    final dealLakhs = (lead.dealValue / 100000).toStringAsFixed(2);
    final followUpStr = '${lead.nextFollowUpDate.day}/${lead.nextFollowUpDate.month}/${lead.nextFollowUpDate.year}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEE2E6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.companyName,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${lead.clientName} · ${lead.domain}',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12.5,
                            color: const Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lead.status.label,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deal Value',
                          style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF868E96)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹$dealLakhs L',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212529),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Next Follow-up',
                          style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFF868E96)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          followUpStr,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212529),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDossierRow('Relationship Owner', lead.assignedEmployeeName),
              _buildDossierRow('Lead Source', lead.source),
              _buildDossierRow('Contact Email', lead.email),
              _buildDossierRow('Contact Phone', lead.phone),
              _buildDossierRow('Approval Stage', lead.internalApprovalStage),
              if (lead.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Deal Notes',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF495057),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE9ECEF)),
                  ),
                  child: Text(
                    lead.notes,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 12,
                      color: const Color(0xFF495057),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Executive directive sent to ${lead.assignedEmployeeName}',
                              style: GoogleFonts.instrumentSans(),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF212529),
                        side: const BorderSide(color: Color(0xFF212529)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Direct Owner',
                        style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212529),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.instrumentSans(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
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

  Widget _buildDossierRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.instrumentSans(fontSize: 12.5, color: const Color(0xFF6C757D)),
          ),
          Text(
            value,
            style: GoogleFonts.instrumentSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212529),
            ),
          ),
        ],
      ),
    );
  }
}
