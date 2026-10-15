import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/erp_provider.dart';
import '../widgets/ceo_modals.dart';

/// Module 9: Tasks & Deadlines (Specification Section 13)
/// Provides enterprise-wide task tracking, countdowns, overdue tracking, and directive issuance
class CeoTasksPage extends StatefulWidget {
  final ValueChanged<int> onNavigateModule;

  const CeoTasksPage({
    super.key,
    required this.onNavigateModule,
  });

  @override
  State<CeoTasksPage> createState() => _CeoTasksPageState();
}

class _CeoTasksPageState extends State<CeoTasksPage> {
  String _statusFilter = 'All';
  String _departmentFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final allTasks = erp.allTasks;

    final filtered = allTasks.where((t) {
      if (_statusFilter == 'Overdue') return t.isOverdue && !t.isCompleted;
      if (_statusFilter == 'Due Today') return t.isDueToday && !t.isCompleted;
      if (_statusFilter == 'In Progress') return !t.isCompleted && !t.isOverdue;
      if (_statusFilter == 'Completed') return t.isCompleted;
      return true;
    }).where((t) {
      if (_departmentFilter != 'All' && !t.domain.toLowerCase().contains(_departmentFilter.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs & Header
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text('Executive Overview', style: GoogleFonts.instrumentSans(fontSize: 12, color: const Color(0xFF6C757D))),
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFADB5BD)),
              Text('Tasks & Deadlines', style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF212529))),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 650;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Tasks & Deadlines Oversight',
                    style: GoogleFonts.instrumentSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF212529), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Operational deliverable countdowns, overdue tracking, and company directives.',
                    style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D)),
                  ),
                ],
              );
              final actionBtn = ElevatedButton.icon(
                onPressed: () => CeoModals.showCompanyDirectiveModal(context, erp),
                icon: const Icon(Icons.campaign_outlined, size: 16, color: Colors.white),
                label: Text('Issue Directive', style: GoogleFonts.instrumentSans(fontSize: 12.5, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212529),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    const SizedBox(height: 12),
                    actionBtn,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 16),
                  actionBtn,
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Metrics Bar (Responsive Grid)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final crossAxisCount = isWide ? 4 : 2;
              final childAspectRatio = isWide ? 1.6 : 1.3;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: childAspectRatio,
                children: [
                  _buildTaskMetric('Total Tasks', '${allTasks.length}', 'Company-wide active', Icons.task_alt_outlined),
                  _buildTaskMetric('Overdue Work', '${allTasks.where((t) => t.isOverdue && !t.isCompleted).length}', 'Explicit Overdue Flag', Icons.error_outline_rounded),
                  _buildTaskMetric('Due Today', '${allTasks.where((t) => t.isDueToday && !t.isCompleted).length}', 'Urgent Delivery', Icons.timer_outlined),
                  _buildTaskMetric('Completed', '${allTasks.where((t) => t.isCompleted).length}', 'Verified Quality', Icons.check_circle_outline_rounded),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Filters Bar (Responsive wrap)
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 650;
              final chipsList = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Overdue', 'Due Today', 'In Progress', 'Completed'].map((st) {
                    final isSel = _statusFilter == st;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(st),
                        selected: isSel,
                        selectedColor: const Color(0xFF212529),
                        backgroundColor: Colors.white,
                        labelStyle: GoogleFonts.instrumentSans(
                          color: isSel ? Colors.white : const Color(0xFF495057),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _statusFilter = st),
                      ),
                    );
                  }).toList(),
                ),
              );

              final deptDropdown = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _departmentFilter,
                    style: GoogleFonts.instrumentSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF212529)),
                    items: ['All', 'Technical', 'Sales', 'Marketing', 'HR', 'Finance'].map((d) {
                      return DropdownMenuItem(value: d, child: Text(d == 'All' ? 'All Depts' : d));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _departmentFilter = val);
                    },
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chipsList,
                    const SizedBox(height: 10),
                    deptDropdown,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: chipsList),
                  const SizedBox(width: 12),
                  deptDropdown,
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Tasks List
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
            ),
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text('No tasks found under this filter.', style: GoogleFonts.instrumentSans(fontSize: 13, color: const Color(0xFF6C757D))),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFE9ECEF)),
                    itemBuilder: (ctx, i) {
                      final t = filtered[i];
                      final isOverdue = t.isOverdue && !t.isCompleted;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              t.isCompleted
                                  ? Icons.check_circle_rounded
                                  : (isOverdue ? Icons.error_outline_rounded : Icons.radio_button_unchecked_rounded),
                              size: 20,
                              color: t.isCompleted
                                  ? const Color(0xFF2F9E44)
                                  : (isOverdue ? const Color(0xFFE03131) : const Color(0xFF6C757D)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF212529),
                                      decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  Text(
                                    'Domain: ${t.domain} • Project: ${t.projectName ?? "General Operations"} • Assigned: ${t.assignedToName}',
                                    style: GoogleFonts.instrumentSans(fontSize: 11.5, color: const Color(0xFF6C757D)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isOverdue ? const Color(0xFFE03131) : const Color(0xFF212529),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isOverdue ? 'OVERDUE' : (t.isCompleted ? 'COMPLETED' : t.deadlineCountdownText),
                                style: GoogleFonts.instrumentSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
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

  Widget _buildTaskMetric(String label, String val, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.instrumentSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: const Color(0xFF212529)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF212529)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.instrumentSans(fontSize: 11, color: const Color(0xFFADB5BD)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
