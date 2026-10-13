import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/lead.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/deal_detail_sheet.dart';
import '../widgets/log_call_dialog.dart';

/// Page 3 — Deals & Lead Pipeline
class SalesDealsPipelinePage extends StatefulWidget {
  const SalesDealsPipelinePage({super.key});

  @override
  State<SalesDealsPipelinePage> createState() => _SalesDealsPipelinePageState();
}

class _SalesDealsPipelinePageState extends State<SalesDealsPipelinePage> {
  String _activeStageFilter = 'All'; // 'All', 'New Lead', 'Cold Call Started', 'Interested / Follow-up', 'Forwarded', 'Deal Closed', 'Lost / On Hold'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allLeads = erp.allLeads;

    // Filter leads matching the selected stage filter
    final filteredLeads = allLeads.where((l) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = l.companyName.toLowerCase().contains(q) ||
            l.clientName.toLowerCase().contains(q) ||
            l.domain.toLowerCase().contains(q);
        if (!match) return false;
      }

      if (_activeStageFilter == 'All') return true;
      if (_activeStageFilter == 'New Lead') return l.status == LeadStatus.newLead;
      if (_activeStageFilter == 'Cold Call Started') {
        return l.status == LeadStatus.contactAttempted || l.status == LeadStatus.contactEstablished;
      }
      if (_activeStageFilter == 'Interested / Follow-up') {
        return l.status == LeadStatus.requirementsCollected ||
            l.status == LeadStatus.proposalPrepared ||
            l.status == LeadStatus.proposalSent ||
            l.status == LeadStatus.negotiation;
      }
      if (_activeStageFilter == 'Forwarded') {
        return l.status == LeadStatus.feasibilityAssessment ||
            l.status == LeadStatus.internalApproval ||
            l.internalApprovalStage != 'Draft';
      }
      if (_activeStageFilter == 'Deal Closed') return l.status == LeadStatus.won;
      if (_activeStageFilter == 'Lost / On Hold') return l.status == LeadStatus.lost;
      return true;
    }).toList();

    final totalActiveValue = allLeads
        .where((l) => l.status != LeadStatus.lost)
        .fold(0.0, (sum, l) => sum + l.dealValue);
    final wonDealsCount = allLeads.where((l) => l.status == LeadStatus.won).length;
    final forwardedCount = allLeads.where((l) =>
        l.status == LeadStatus.internalApproval ||
        l.status == LeadStatus.feasibilityAssessment ||
        l.internalApprovalStage.contains('Pending') ||
        l.internalApprovalStage.contains('Forwarded')).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Pipeline Metrics Banner
            _buildPipelineMetrics(totalActiveValue, wonDealsCount, forwardedCount),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'Search pipeline by company or client...',
                    hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 16),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // Suggested Pipeline Stages Filter Bar
            _buildPipelineFilterChips(allLeads),

            // Leads List
            Expanded(
              child: filteredLeads.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredLeads.length,
                      itemBuilder: (context, index) {
                        return _buildDealCard(context, filteredLeads[index], erp);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineMetrics(double totalActiveValue, int wonCount, int forwardedCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricColumn(
            title: 'Active Pipeline',
            value: '₹${(totalActiveValue / 100000).toStringAsFixed(1)}L',
            color: const Color(0xFF38BDF8),
            icon: Icons.account_balance_wallet_rounded,
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          _buildMetricColumn(
            title: 'Forwarded / Review',
            value: '$forwardedCount Deals',
            color: const Color(0xFFA78BFA),
            icon: Icons.supervisor_account_rounded,
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          _buildMetricColumn(
            title: 'Closed (Won)',
            value: '$wonCount Deals',
            color: const Color(0xFF34D399),
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildPipelineFilterChips(List<Lead> allLeads) {
    final stages = [
      {'key': 'All', 'label': 'All Deals'},
      {'key': 'New Lead', 'label': '1. New Lead'},
      {'key': 'Cold Call Started', 'label': '2. Cold Call Started'},
      {'key': 'Interested / Follow-up', 'label': '3. Interested / Follow-up'},
      {'key': 'Forwarded', 'label': '4. Forwarded to Mgr / HR / Fin'},
      {'key': 'Deal Closed', 'label': '5. Deal Closed'},
      {'key': 'Lost / On Hold', 'label': 'Lost / On Hold'},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final s = stages[index];
          final isSelected = _activeStageFilter == s['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(s['label'] as String),
              selected: isSelected,
              onSelected: (_) => setState(() => _activeStageFilter = s['key'] as String),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, Lead lead, ErpProvider erp) {
    final isForwarded = lead.internalApprovalStage != 'Draft' ||
        lead.status == LeadStatus.feasibilityAssessment ||
        lead.status == LeadStatus.internalApproval;

    Color stageColor;
    if (lead.status == LeadStatus.won) {
      stageColor = const Color(0xFF10B981);
    } else if (lead.status == LeadStatus.lost) {
      stageColor = const Color(0xFFEF4444);
    } else if (isForwarded) {
      stageColor = const Color(0xFF8B5CF6);
    } else {
      stageColor = const Color(0xFF3B82F6);
    }

    return InkWell(
      onTap: () => DealDetailSheet.show(context, lead),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: lead.isFollowUpMissed
                ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Company, ID & Deal Value
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              lead.companyName,
                              style: const TextStyle(
                                color: Color(0xFF212529),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lead.id,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lead.clientName} • ${lead.domain}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${_formatCurrency(lead.dealValue)}',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Stage Badge & Forwarding Status
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Pipeline Stage
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: stageColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timeline_rounded, color: stageColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        lead.status.label,
                        style: TextStyle(color: stageColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),

                // Forwarded / Review Badge
                if (lead.internalApprovalStage != 'Draft')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.supervisor_account_rounded, color: Color(0xFFA78BFA), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          lead.internalApprovalStage,
                          style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),

                // Overdue Follow-up Warning
                if (lead.isFollowUpMissed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Follow-up Overdue',
                      style: TextStyle(color: Color(0xFFF87171), fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Card Bottom Actions
            Row(
              children: [
                Icon(Icons.event_available_rounded, size: 13, color: const Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  'Next: ${lead.nextFollowUpDate.day}/${lead.nextFollowUpDate.month}/${lead.nextFollowUpDate.year}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
                const Spacer(),
                // Call Action
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => LogCallDialog(
                        prefilledCompanyName: lead.companyName,
                        prefilledCustomerName: lead.clientName,
                        prefilledPhone: lead.phone,
                        leadId: lead.id,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.phone_in_talk_rounded, color: Color(0xFF60A5FA), size: 12),
                        SizedBox(width: 4),
                        Text('Call', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Forward/Details Action
                InkWell(
                  onTap: () => DealDetailSheet.show(context, lead),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.open_in_new_rounded, color: Color(0xFF212529), size: 12),
                        SizedBox(width: 4),
                        Text('Details', style: TextStyle(color: Color(0xFF212529), fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_open_rounded, size: 40, color: Color(0xFF475569)),
          const SizedBox(height: 10),
          const Text('No deals in this pipeline stage.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => setState(() {
              _activeStageFilter = 'All';
              _searchQuery = '';
            }),
            child: const Text('View All Deals', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
