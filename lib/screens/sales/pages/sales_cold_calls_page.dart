import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/sales_call.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/log_call_dialog.dart';

/// Page 2 — Cold Calls (Record and track sales calls)
class SalesColdCallsPage extends StatefulWidget {
  const SalesColdCallsPage({super.key});

  @override
  State<SalesColdCallsPage> createState() => _SalesColdCallsPageState();
}

class _SalesColdCallsPageState extends State<SalesColdCallsPage> {
  String _activeTab = 'Today'; // 'Today', 'Completed', 'Pending', 'All'
  String _searchQuery = '';
  CallOutcome? _outcomeFilter; // null = all outcomes

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allCalls = erp.allSalesCalls;

    // Filter calls based on active tab
    List<SalesCall> filtered = allCalls.where((c) {
      if (_activeTab == 'Today' && !c.isToday) return false;
      if (_activeTab == 'Completed' && !c.isCompleted) return false;
      if (_activeTab == 'Pending' && c.isCompleted) return false;
      if (_outcomeFilter != null && c.outcome != _outcomeFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = c.customerName.toLowerCase().contains(q) ||
            c.companyName.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q) ||
            c.notes.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Target Progress Bar
            _buildTargetHeader(context, erp),

            // Search & Outcome Filter Chips
            _buildSearchAndFilters(),

            // Tab bar: Today, Completed, Pending, All
            _buildTabsRow(erp),

            // Calls List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildCallCard(context, filtered[index], erp);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const LogCallDialog(),
          );
        },
        backgroundColor: const Color(0xFF212529),
        icon: const Icon(Icons.add_call, color: Colors.white, size: 20),
        label: const Text(
          'Log Call',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildTargetHeader(BuildContext context, ErpProvider erp) {
    final ratio = (erp.callsCompletedTodayCount / erp.dailyColdCallTarget).clamp(0.0, 1.0);
    final percentage = (ratio * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF60A5FA), size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Call Target',
                      style: TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Minimum 20 cold calls required / day',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${erp.callsCompletedTodayCount} / ${erp.dailyColdCallTarget}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '$percentage% Completed',
                    style: TextStyle(
                      color: ratio >= 1.0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(
                ratio >= 1.0 ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniKpi('Today\'s Calls', '${erp.callsCompletedTodayCount}'),
              _buildMiniKpi('Pending Calls', '${erp.pendingColdCallsTodayCount}'),
              _buildMiniKpi('Weekly Total', '${erp.weeklyCallTotals.last}'),
              _buildMiniKpi('Monthly Total', '${erp.monthlyCallsTotal}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniKpi(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Color(0xFF212529), fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // Search box
          Container(
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
                hintText: 'Search by client, company, phone or notes...',
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
          const SizedBox(height: 8),

          // Outcome Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOutcomeFilterChip('All Outcomes', null),
                ...CallOutcome.values.map((outcome) => _buildOutcomeFilterChip(outcome.label, outcome)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeFilterChip(String label, CallOutcome? outcome) {
    final isSelected = _outcomeFilter == outcome;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _outcomeFilter = outcome),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF64748B),
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        backgroundColor: Colors.white,
        selectedColor: outcome != null ? outcome.color.withValues(alpha: 0.8) : const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? (outcome?.color ?? const Color(0xFF3B82F6))
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }

  Widget _buildTabsRow(ErpProvider erp) {
    final tabs = [
      {'key': 'Today', 'label': 'Today\'s Calls', 'count': erp.todaySalesCalls.length},
      {'key': 'Completed', 'label': 'Completed', 'count': erp.allSalesCalls.where((c) => c.isCompleted).length},
      {'key': 'Pending', 'label': 'Pending', 'count': erp.pendingColdCallsTodayCount},
      {'key': 'All', 'label': 'All Calls', 'count': erp.allSalesCalls.length},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: tabs.map((t) {
          final isSelected = _activeTab == t['key'];
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = t['key'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      t['label'] as String,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF64748B),
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${t['count']}',
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCallCard(BuildContext context, SalesCall call, ErpProvider erp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: call.isFollowUpOverdue
              ? const Color(0xFFEF4444).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Company, Outcome Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.customerName,
                      style: const TextStyle(color: Color(0xFF212529), fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${call.companyName} • ${call.phone}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: call.outcome.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: call.outcome.color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  call.outcome.label,
                  style: TextStyle(color: call.outcome.color, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Notes
          if (call.notes.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF212529),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                call.notes,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.3),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Footer: Time, Next Follow-up & Quick Actions
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 13, color: const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                '${call.timestamp.hour}:${call.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
              if (call.nextFollowUpDate != null) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.event_repeat_rounded,
                  size: 13,
                  color: call.isFollowUpOverdue ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                ),
                const SizedBox(width: 4),
                Text(
                  call.isFollowUpOverdue
                      ? 'Overdue (${call.daysOverdue}d ago)'
                      : 'Follow-up: ${call.nextFollowUpDate!.day}/${call.nextFollowUpDate!.month}',
                  style: TextStyle(
                    color: call.isFollowUpOverdue ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: call.isFollowUpOverdue ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              // Quick action: Change outcome
              InkWell(
                onTap: () => _showUpdateOutcomeDialog(context, call, erp),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, size: 14, color: Color(0xFF60A5FA)),
                      SizedBox(width: 4),
                      Text('Update', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpdateOutcomeDialog(BuildContext context, SalesCall call, ErpProvider erp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update ${call.customerName}', style: const TextStyle(color: Color(0xFF212529), fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select new call outcome:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 10),
              ...CallOutcome.values.map((outcome) {
                final isSelected = call.outcome == outcome;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF5F6F7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(outcome.label, style: TextStyle(color: outcome.color, fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: isSelected ? Icon(Icons.check_rounded, color: outcome.color, size: 18) : null,
                    onTap: () {
                      erp.updateCallOutcome(call.id, outcome);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text('Call outcome updated to ${outcome.label}'),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_missed_rounded, size: 40, color: Color(0xFF475569)),
          const SizedBox(height: 10),
          const Text('No sales calls match the filter.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _activeTab = 'All';
                _outcomeFilter = null;
                _searchQuery = '';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF60A5FA)),
            label: const Text('Reset Filters', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
