import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hierarchy.dart';
import '../../models/task.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../tasks/task_detail_dialog.dart';

/// Screen 5: Intern Management Screen matching Screen 5 in screenshot
class InternListScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const InternListScreen({super.key, this.onBack});

  @override
  State<InternListScreen> createState() => _InternListScreenState();
}

class _InternListScreenState extends State<InternListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<ErpProvider>().internSearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddInternDialog(BuildContext context) {
    final erp = context.read<ErpProvider>();
    final nameController = TextEditingController();
    final collegeController = TextEditingController();
    RoleCategory category = RoleCategory.technical;
    String domain = 'Backend';
    String batchId = erp.allBatches.first.id;

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
                constraints: const BoxConstraints(maxWidth: 480),
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
                            'Register Intern',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Intern Full Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: collegeController,
                        decoration: const InputDecoration(labelText: 'College / Institute'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: domain,
                        decoration: const InputDecoration(labelText: 'Domain / Role Track'),
                        items: ['Backend', 'Frontend', 'Full Stack', 'Mobile App', 'AI / ML', 'UI/UX Engineering']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => domain = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: batchId,
                        decoration: const InputDecoration(labelText: 'Weekly Intake Batch'),
                        items: erp.allBatches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.code))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => batchId = val);
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) return;
                            erp.addIntern(
                              name: nameController.text.trim(),
                              email: 'intern@college.edu',
                              phone: '+91 99999 22222',
                              college: collegeController.text.trim().isEmpty ? 'Engineering Institute' : collegeController.text.trim(),
                              category: category,
                              domain: domain,
                              batchId: batchId,
                              interviewScore: 8.5,
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                          child: const Text('Confirm Registration', style: TextStyle(fontWeight: FontWeight.w600)),
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
    final activeCategory = erp.internCategoryFilter;
    final activeScope = erp.internTaskScope;

    // Filter intern-related tasks for the view
    final internTasks = erp.allTasks.where((t) {
      if (t.assigneeType != AssigneeType.intern) return false;
      if (activeCategory != null) {
        final intern = erp.allInterns.firstWhere((i) => i.id == t.assignedToId, orElse: () => erp.allInterns.first);
        if (intern.category != activeCategory) return false;
      }
      if (erp.internDomainFilter != null && erp.internDomainFilter!.isNotEmpty) {
        final d = erp.internDomainFilter!.toLowerCase();
        final td = t.domain.toLowerCase();
        if (!td.contains(d) && !d.contains(td)) {
          return false;
        }
      }
      if (activeScope == 'My Tasks' && t.assignedToId != erp.currentUserId) {
        return false;
      }
      final query = erp.internSearchQuery.isNotEmpty ? erp.internSearchQuery : erp.searchQuery;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matches = t.title.toLowerCase().contains(q) ||
            t.assignedToName.toLowerCase().contains(q) ||
            t.domain.toLowerCase().contains(q) ||
            (t.projectName?.toLowerCase().contains(q) ?? false);
        if (!matches) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text(
          'Intern Management',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _showAddInternDialog(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
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
          // Search Bar matching Screen 5
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {});
                  erp.setInternSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search intern...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            erp.setInternSearchQuery('');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF0F172A)),
                        onPressed: () => FilterBottomSheet.show(context, isForInterns: true),
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Category Tabs: [All] [Technical] [Non-Technical] matching Screen 5
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryPill('All', activeCategory == null, () {
                  erp.setInternCategoryFilter(null);
                }),
                const SizedBox(width: 8),
                _buildCategoryPill('Technical', activeCategory == RoleCategory.technical, () {
                  erp.setInternCategoryFilter(RoleCategory.technical);
                }),
                const SizedBox(width: 8),
                _buildCategoryPill('Non-Technical', activeCategory == RoleCategory.nonTechnical, () {
                  erp.setInternCategoryFilter(RoleCategory.nonTechnical);
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter Dropdowns Bar: [Domain v] [Priority v] [Role v] matching Screen 5
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildDropdownChip(
                  'Domain',
                  erp.internDomainFilter,
                  onTap: () => FilterBottomSheet.show(context, isForInterns: true),
                ),
                const SizedBox(width: 8),
                _buildDropdownChip(
                  'Priority',
                  null,
                  onTap: () => FilterBottomSheet.show(context, isForInterns: true),
                ),
                const SizedBox(width: 8),
                _buildDropdownChip(
                  'DI Roles',
                  null,
                  onTap: () => FilterBottomSheet.show(context, isForInterns: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sub-tabs: [My Tasks] [Team Tasks] [All Tasks] matching Screen 5
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildScopeChip('My Tasks', activeScope == 'My Tasks'),
                const SizedBox(width: 8),
                _buildScopeChip('Team Tasks', activeScope == 'Team Tasks'),
                const SizedBox(width: 8),
                _buildScopeChip('All Tasks', activeScope == 'All Tasks'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Intern task cards matching Screen 5
          Expanded(
            child: internTasks.isEmpty
                ? const Center(
                    child: Text(
                      'No intern tasks found under selected filter.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: internTasks.length,
                    itemBuilder: (context, index) {
                      final task = internTasks[index];
                      final isOverdue = task.status == TaskStatus.overdue || task.isOverdue;

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
                            // Grad cap / Task circular container
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isOverdue ? Icons.south_rounded : Icons.school_outlined,
                                size: 18,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${task.assignedToName} • ${task.domain}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Due: ${task.dueDate.day} ${_getMonth(task.dueDate.month)}',
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
                                color: isOverdue
                                    ? const Color(0xFF0F172A) // Black pill for overdue as in screenshot!
                                    : (task.status == TaskStatus.inProgress
                                        ? const Color(0xFFF1F5F9)
                                        : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isOverdue ? 'Overdue' : task.status.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isOverdue ? Colors.white : const Color(0xFF475569),
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
                                  builder: (_) => TaskDetailDialog(task: task),
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

  Widget _buildCategoryPill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownChip(String label, String? selectedValue, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selectedValue != null ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selectedValue != null ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedValue ?? label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: selectedValue != null ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: selectedValue != null ? Colors.white : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<ErpProvider>().setInternTaskScope(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
