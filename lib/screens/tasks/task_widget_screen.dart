import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/erp_provider.dart';
import '../../widgets/home_screen_weekly_tasks_widget.dart';
import '../../services/native_home_widget_service.dart';

/// Home Screen Weekly Tasks Widget Screen
/// Provides live in-app dashboard widget, phone launcher simulator, and native OS integration tools
class TaskWidgetScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TaskWidgetScreen({super.key, this.onBack});

  @override
  State<TaskWidgetScreen> createState() => _TaskWidgetScreenState();
}

class _TaskWidgetScreenState extends State<TaskWidgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSyncing = false;
  String? _syncStatusMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSyncNativeWidget(ErpProvider erp) async {
    setState(() {
      _isSyncing = true;
      _syncStatusMessage = null;
    });

    final success = await NativeHomeWidgetService.syncToNativeWidgets(erp);

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _syncStatusMessage = success
            ? 'Successfully synced weekly task data with native widget storage!'
            : 'Error synchronizing widget data.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_syncStatusMessage!),
          backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF212529), size: 20),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: Text(
          'Home Screen Weekly Tasks Widget',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF212529),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF212529),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF212529),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.instrumentSans(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Weekly Widget'),
            Tab(text: 'Launcher Mockup'),
            Tab(text: 'Native OS Setup'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Live Interactive In-App Widget
          _buildLiveWidgetTab(erp),

          // Tab 2: Interactive Mobile Launcher Simulator
          _buildLauncherSimulatorTab(erp),

          // Tab 3: Native Platform Setup & Bridge
          _buildNativeIntegrationTab(erp),
        ],
      ),
    );
  }

  Widget _buildLiveWidgetTab(ErpProvider erp) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Architecture highlight banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF212529),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.widgets_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ERP Home Screen Widget: Real-time Monday-to-Sunday weekly tasks, deadline countdowns, and completion synchronization.',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // THE CORE WIDGET
          HomeScreenWeeklyTasksWidget(
            onRefresh: () => _handleSyncNativeWidget(erp),
          ),
        ],
      ),
    );
  }

  Widget _buildLauncherSimulatorTab(ErpProvider erp) {
    final tasks = erp.currentWeekTasksPrioritized;
    final totalDue = erp.currentWeekTasksTotalCount;
    final completedCount = erp.currentWeekTasksCompletedCount;
    final completionRate = erp.currentWeekTaskCompletionRate;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.phone_iphone_rounded, color: Color(0xFF212529), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Launcher Simulation: Preview how the weekly tasks widget renders on mobile home screen launcher grids.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Phone Mockup Frame
          Center(
            child: Container(
              width: 360,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: const Color(0xFF475569), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Dynamic Island / Speaker Notch
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      width: 110,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone Home Screen Time & Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Icon(Icons.wifi, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Icon(Icons.battery_full, color: Colors.white, size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // THE INTERACTIVE LAUNCHER WIDGET CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF334155)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Widget Header: App icon + "Digital Inertia" + Live % Done
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Text('Di', style: TextStyle(color: Color(0xFF212529), fontSize: 11, fontWeight: FontWeight.w900)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Digital Inertia Weekly',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${completionRate.toStringAsFixed(0)}% Done',
                                style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalDue > 0 ? (completedCount / totalDue).clamp(0.0, 1.0) : 1.0,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount of $totalDue weekly tasks completed',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                        ),
                        const Divider(color: Color(0xFF334155), height: 16),

                        // Tasks list with interactive checkmark
                        if (tasks.isEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text('No tasks due this week!', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ),
                          ),
                        ] else ...[
                          ...tasks.take(4).map((t) {
                            final deadlineInfo = TaskDeadlineInfo.calculate(t);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      erp.toggleTaskCompletion(t.id);
                                    },
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: t.isCompleted ? const Color(0xFF10B981) : Colors.transparent,
                                        border: Border.all(
                                          color: t.isCompleted ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: t.isCompleted
                                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      t.title,
                                      style: TextStyle(
                                        color: t.isCompleted ? const Color(0xFF64748B) : Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: deadlineInfo.badgeBackgroundColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      deadlineInfo.label,
                                      style: TextStyle(
                                        color: deadlineInfo.badgeTextColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Home Screen Mock Grid App Icons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMockAppIcon('Safari', Icons.explore, const Color(0xFF0284C7)),
                        _buildMockAppIcon('Messages', Icons.message, const Color(0xFF22C55E)),
                        _buildMockAppIcon('Calendar', Icons.calendar_month, const Color(0xFFEF4444)),
                        _buildMockAppIcon('Settings', Icons.settings, const Color(0xFF64748B)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Home Indicator bar
                  Container(
                    width: 130,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeIntegrationTab(ErpProvider erp) {
    final widgetData = NativeHomeWidgetService.buildWeeklyWidgetData(erp);
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(widgetData.toJson());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action card: Sync data now
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Widget Data to Native Storage',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Updates SharedPreferences (Android) and UserDefaults AppGroup (iOS).',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isSyncing ? null : () => _handleSyncNativeWidget(erp),
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync_rounded, size: 16),
                  label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Serialized JSON Payload Inspector
          Container(
            padding: const EdgeInsets.all(16),
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
                    Text(
                      'Live Native Payload (JSON)',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    Text(
                      '${widgetData.prioritizedTasks.length} tasks serialized',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      prettyJson,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Platform Setup Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Implementation Guide',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF212529),
                  ),
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    children: const [
                      Icon(Icons.android_rounded, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 8),
                      Text('Android AppWidget Integration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        NativeHomeWidgetService.androidImplementationGuide,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    children: const [
                      Icon(Icons.apple_rounded, color: Color(0xFF212529), size: 18),
                      SizedBox(width: 8),
                      Text('iOS WidgetKit Integration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        NativeHomeWidgetService.iosImplementationGuide,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockAppIcon(String name, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}
