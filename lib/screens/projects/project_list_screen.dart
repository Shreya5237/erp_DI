import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/filter_bottom_sheet.dart';
import 'project_detail_dialog.dart';

/// Screen 8: Project Management Screen matching Screen 8 in screenshot
class ProjectListScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProjectListScreen({super.key, this.onBack});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<ErpProvider>().projectSearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateProjectDialog(BuildContext context) {
    final erp = context.read<ErpProvider>();
    final nameController = TextEditingController();
    final clientController = TextEditingController();
    String domain = 'Mobile App';
    double budget = 40000.0;
    String ownerId = erp.allEmployees.first.id;
    final selectedMembers = <String>[erp.allEmployees.first.name];

    // Candidate names for team assignment: employees and interns
    final candidatePool = <String>[
      ...erp.allEmployees.map((e) => e.name),
      ...erp.allInterns.map((i) => '${i.name} (Intern)'),
    ];

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
                constraints: const BoxConstraints(maxWidth: 500),
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
                            'Create Project',
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
                        decoration: const InputDecoration(labelText: 'Project Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: clientController,
                        decoration: const InputDecoration(labelText: 'Client Name'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: domain,
                              decoration: const InputDecoration(labelText: 'Domain'),
                              items: ['Mobile App', 'Web Platform', 'AI / ML', 'Backend', 'Cloud Infra']
                                  .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => domain = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Budget (\$)'),
                              onChanged: (val) => budget = double.tryParse(val) ?? 35000.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Team Lead Selector
                      const Text(
                        'Assign Team Lead',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: ownerId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.star, size: 18, color: Colors.amber),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: erp.allEmployees.map((e) {
                          return DropdownMenuItem(
                            value: e.id,
                            child: Text(
                              '${e.name} • ${e.role}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final emp = erp.allEmployees.firstWhere((e) => e.id == val);
                            setDialogState(() {
                              ownerId = val;
                              if (!selectedMembers.contains(emp.name)) {
                                selectedMembers.insert(0, emp.name);
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Team Members Multi-Select
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Team Members (${selectedMembers.length})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Add Member',
                            icon: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_add_alt_1, size: 16, color: Color(0xFF2563EB)),
                                SizedBox(width: 4),
                                Text(
                                  '+ Add Member',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                            onSelected: (name) {
                              if (!selectedMembers.contains(name)) {
                                setDialogState(() => selectedMembers.add(name));
                              }
                            },
                            itemBuilder: (context) {
                              return candidatePool
                                  .where((c) => !selectedMembers.contains(c))
                                  .map((c) => PopupMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12.5))))
                                  .toList();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Selected Team Member Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: selectedMembers.map((m) {
                          final isLead = erp.allEmployees.any((e) => e.id == ownerId && e.name == m);
                          return Chip(
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: isLead ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            label: Text(
                              isLead ? '$m (Lead)' : m,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isLead ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                            deleteIcon: isLead ? null : const Icon(Icons.close, size: 14, color: Color(0xFF64748B)),
                            onDeleted: isLead
                                ? null
                                : () {
                                    setDialogState(() => selectedMembers.remove(m));
                                  },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) return;
                            erp.addProject(
                              name: nameController.text.trim(),
                              clientName: clientController.text.trim().isEmpty ? 'Client Enterprise' : clientController.text.trim(),
                              domain: domain,
                              description: 'Production solution for client milestones',
                              budget: budget,
                              ownerEmployeeId: ownerId,
                              deadline: DateTime.now().add(const Duration(days: 30)),
                              teamMemberNames: selectedMembers,
                            );
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                          child: const Text('Start Project', style: TextStyle(fontWeight: FontWeight.w600)),
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
    final projects = erp.filteredProjects;
    final activeStatus = erp.projectStatusFilter;

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
          'Project Management',
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
              onTap: () => _showCreateProjectDialog(context),
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
          // Search Bar matching Screen 8
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
                  erp.setProjectSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search project...',
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
                            erp.setProjectSearchQuery('');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF0F172A)),
                        onPressed: () => FilterBottomSheet.show(context),
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Filter Chips: [All] [Planning] [In Progress] [On Hold] matching Screen 8
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip('All', activeStatus == 'All'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Planning', activeStatus == 'Planning'),
                  const SizedBox(width: 8),
                  _buildStatusChip('In Progress', activeStatus == 'In Progress'),
                  const SizedBox(width: 8),
                  _buildStatusChip('On Hold', activeStatus == 'On Hold'),
                  const SizedBox(width: 8),
                  _buildStatusChip('Completed', activeStatus == 'Completed'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Project cards matching Screen 8
          Expanded(
            child: projects.isEmpty
                ? const Center(
                    child: Text(
                      'No projects match filter.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final proj = projects[index];
                      final percentInt = (proj.progress * 100).round();

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => ProjectDetailDialog(project: proj),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.layers_outlined,
                                      size: 18,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          proj.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          proj.domain,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$percentInt%',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Clean black progress bar matching Screen 8
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: proj.progress,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<ErpProvider>().setProjectStatusFilter(label),
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
}
