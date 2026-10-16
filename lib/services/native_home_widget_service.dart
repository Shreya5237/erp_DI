import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/erp_provider.dart';
import '../widgets/home_screen_weekly_tasks_widget.dart';

/// Serialized Task Item optimized for Android AppWidget and iOS WidgetKit consumption
class WidgetTaskItem {
  final String id;
  final String title;
  final String priority;
  final String status;
  final String dueDateFormatted;
  final String deadlineLabel;
  final int daysRemaining;
  final bool isCompleted;
  final bool isOverdue;
  final bool isDueToday;
  final bool isDueTomorrow;

  const WidgetTaskItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
    required this.dueDateFormatted,
    required this.deadlineLabel,
    required this.daysRemaining,
    required this.isCompleted,
    required this.isOverdue,
    required this.isDueToday,
    required this.isDueTomorrow,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'priority': priority,
    'status': status,
    'dueDateFormatted': dueDateFormatted,
    'deadlineLabel': deadlineLabel,
    'daysRemaining': daysRemaining,
    'isCompleted': isCompleted,
    'isOverdue': isOverdue,
    'isDueToday': isDueToday,
    'isDueTomorrow': isDueTomorrow,
  };

  factory WidgetTaskItem.fromTask(CompanyTask task, [DateTime? referenceDate]) {
    final deadlineInfo = TaskDeadlineInfo.calculate(task, referenceDate);
    final dateFmt = DateFormat('EEE, MMM d');

    return WidgetTaskItem(
      id: task.id,
      title: task.title,
      priority: task.priority.label,
      status: task.status.label,
      dueDateFormatted: dateFmt.format(task.dueDate),
      deadlineLabel: deadlineInfo.label,
      daysRemaining: deadlineInfo.days,
      isCompleted: task.isCompleted,
      isOverdue: deadlineInfo.category == DeadlineCategory.overdue,
      isDueToday: deadlineInfo.category == DeadlineCategory.dueToday,
      isDueTomorrow: deadlineInfo.category == DeadlineCategory.dueTomorrow,
    );
  }
}

/// Comprehensive Weekly Widget Data Structure
class WeeklyWidgetData {
  final String weekRangeLabel;
  final int totalWeeklyTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionPercentage;
  final DateTime lastSyncedAt;
  final List<WidgetTaskItem> prioritizedTasks;

  const WeeklyWidgetData({
    required this.weekRangeLabel,
    required this.totalWeeklyTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionPercentage,
    required this.lastSyncedAt,
    required this.prioritizedTasks,
  });

  Map<String, dynamic> toJson() => {
    'weekRangeLabel': weekRangeLabel,
    'totalWeeklyTasks': totalWeeklyTasks,
    'completedTasks': completedTasks,
    'pendingTasks': pendingTasks,
    'completionPercentage': completionPercentage,
    'lastSyncedAt': lastSyncedAt.toIso8601String(),
    'tasks': prioritizedTasks.map((t) => t.toJson()).toList(),
  };

  String toJsonString() => jsonEncode(toJson());
}

/// Native Home Screen Widget Service
/// Bridges Flutter ERP state with native Android AppWidgets and iOS WidgetKit
class NativeHomeWidgetService {
  static const String appGroupId = 'group.com.digitalinertia.erp';
  static const String androidWidgetProvider = 'DiErpAppWidgetProvider';
  static const String sharedPreferencesKey = 'di_weekly_tasks_payload';

  /// Generates the structured weekly tasks payload from the active ERP provider
  static WeeklyWidgetData buildWeeklyWidgetData(ErpProvider erp, [DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final monday = erp.currentWeekMonday;
    final sunday = monday.add(const Duration(days: 6));
    final rangeFmt = DateFormat('MMM d');
    final weekRangeLabel = '${rangeFmt.format(monday)} – ${rangeFmt.format(sunday)}, ${sunday.year}';

    final prioritized = erp.currentWeekTasksPrioritized;
    final total = erp.currentWeekTasksTotalCount;
    final completed = erp.currentWeekTasksCompletedCount;
    final pending = (total - completed).clamp(0, 999);
    final rate = erp.currentWeekTaskCompletionRate;

    final items = prioritized.map((t) => WidgetTaskItem.fromTask(t, now)).toList();

    return WeeklyWidgetData(
      weekRangeLabel: weekRangeLabel,
      totalWeeklyTasks: total,
      completedTasks: completed,
      pendingTasks: pending,
      completionPercentage: rate,
      lastSyncedAt: now,
      prioritizedTasks: items,
    );
  }

  /// Syncs executive ERP metrics and top priority tasks to the native launcher widget
  static Future<bool> syncToNativeWidgets(ErpProvider erp) async {
    try {
      final data = buildWeeklyWidgetData(erp);
      final jsonPayload = data.toJsonString();

      // 1. Calculate executive counts
      final activeProjects = erp.allProjects.where((p) => p.status == ProjectStatus.inProgress).length;
      final pendingTasks = erp.allTasks.where((t) => !t.isCompleted).length;
      final pendingApprovals = erp.pendingApprovals.length;
      final alertsCount = erp.thresholdAlerts.isNotEmpty ? erp.thresholdAlerts.length : erp.unreadEmployeeAlertsCount;

      // 2. Pick top 3 priority tasks
      final prioritized = erp.currentWeekTasksPrioritized;
      String task1Title = 'No pending tasks';
      String task1Project = '';
      String task1Badge = 'All clear';
      String task1Done = 'false';

      String task2Title = '';
      String task2Project = '';
      String task2Badge = '';
      String task2Done = 'false';

      String task3Title = '';
      String task3Project = '';
      String task3Badge = '';
      String task3Done = 'false';

      if (prioritized.isNotEmpty) {
        final t1 = prioritized[0];
        final info1 = TaskDeadlineInfo.calculate(t1);
        task1Title = t1.title;
        task1Project = t1.projectName ?? (t1.domain.isNotEmpty ? t1.domain : 'General');
        task1Badge = info1.label;
        task1Done = t1.isCompleted ? 'true' : 'false';
      }
      if (prioritized.length > 1) {
        final t2 = prioritized[1];
        final info2 = TaskDeadlineInfo.calculate(t2);
        task2Title = t2.title;
        task2Project = t2.projectName ?? (t2.domain.isNotEmpty ? t2.domain : 'General');
        task2Badge = info2.label;
        task2Done = t2.isCompleted ? 'true' : 'false';
      }
      if (prioritized.length > 2) {
        final t3 = prioritized[2];
        final info3 = TaskDeadlineInfo.calculate(t3);
        task3Title = t3.title;
        task3Project = t3.projectName ?? (t3.domain.isNotEmpty ? t3.domain : 'General');
        task3Badge = info3.label;
        task3Done = t3.isCompleted ? 'true' : 'false';
      }

      final formattedTime = DateFormat('hh:mm a').format(DateTime.now());
      final todayDateStr = DateFormat('EEE, MMM d').format(DateTime.now());
      final firstName = erp.currentUserName.isNotEmpty
          ? erp.currentUserName.trim().split(RegExp(r'\s+')).first
          : 'Employee';
      final progressSummary = '${erp.currentWeekTasksCompletedCount} of ${erp.currentWeekTasksTotalCount} completed';

      // 3. Save atomic widget fields for Android RemoteViews
      await HomeWidget.saveWidgetData<String>('user_name', erp.currentUserName);
      await HomeWidget.saveWidgetData<String>('first_name', firstName);
      await HomeWidget.saveWidgetData<String>('today_date', todayDateStr);
      await HomeWidget.saveWidgetData<String>('progress_summary', progressSummary);
      await HomeWidget.saveWidgetData<String>('active_projects', activeProjects.toString());
      await HomeWidget.saveWidgetData<String>('pending_tasks', pendingTasks.toString());
      await HomeWidget.saveWidgetData<String>('pending_approvals', pendingApprovals.toString());
      await HomeWidget.saveWidgetData<String>('critical_alerts', alertsCount.toString());
      await HomeWidget.saveWidgetData<String>('task_1_title', task1Title);
      await HomeWidget.saveWidgetData<String>('task_1_project', task1Project);
      await HomeWidget.saveWidgetData<String>('task_1_badge', task1Badge);
      await HomeWidget.saveWidgetData<String>('task_1_done', task1Done);
      await HomeWidget.saveWidgetData<String>('task_2_title', task2Title);
      await HomeWidget.saveWidgetData<String>('task_2_project', task2Project);
      await HomeWidget.saveWidgetData<String>('task_2_badge', task2Badge);
      await HomeWidget.saveWidgetData<String>('task_2_done', task2Done);
      await HomeWidget.saveWidgetData<String>('task_3_title', task3Title);
      await HomeWidget.saveWidgetData<String>('task_3_project', task3Project);
      await HomeWidget.saveWidgetData<String>('task_3_badge', task3Badge);
      await HomeWidget.saveWidgetData<String>('task_3_done', task3Done);
      await HomeWidget.saveWidgetData<String>('last_updated', formattedTime);
      await HomeWidget.saveWidgetData<String>(sharedPreferencesKey, jsonPayload);

      // 4. Trigger native widget update
      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );

      if (kDebugMode) {
        debugPrint('[NativeHomeWidgetService] Successfully updated home screen widget at $formattedTime');
      }
      return true;
    } on MissingPluginException {
      if (kDebugMode) {
        debugPrint('[NativeHomeWidgetService] Platform channel not available in current environment');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NativeHomeWidgetService] Error syncing to native widget: $e');
      }
      return false;
    }
  }

  /// Clears sensitive employee widget cache on logout
  static Future<void> clearWidgetData() async {
    try {
      await HomeWidget.saveWidgetData<String>('user_name', '');
      await HomeWidget.saveWidgetData<String>('first_name', '');
      await HomeWidget.saveWidgetData<String>('task_1_title', 'Please log in to view tasks');
      await HomeWidget.saveWidgetData<String>('task_1_project', 'Digital Inertia ERP');
      await HomeWidget.saveWidgetData<String>('task_1_badge', 'Signed Out');
      await HomeWidget.saveWidgetData<String>('task_2_title', '');
      await HomeWidget.saveWidgetData<String>('task_2_project', '');
      await HomeWidget.saveWidgetData<String>('task_2_badge', '');
      await HomeWidget.saveWidgetData<String>('task_3_title', '');
      await HomeWidget.saveWidgetData<String>('task_3_project', '');
      await HomeWidget.saveWidgetData<String>('task_3_badge', '');
      await HomeWidget.saveWidgetData<String>('progress_summary', '0 of 0 completed');
      await HomeWidget.saveWidgetData<String>(sharedPreferencesKey, '');

      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );
    } catch (_) {}
  }

  /// Requests the Android launcher to pin the widget to the home screen (Android API 26+)
  static Future<bool> requestPinWidget() async {
    try {
      await HomeWidget.requestPinWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NativeHomeWidgetService] Error pinning widget: $e');
      }
      return false;
    }
  }

  /// Reference code snippet for Android AppWidget implementation
  static String get androidImplementationGuide => '''
===================================================================
ANDROID APPWIDGET SETUP GUIDE (Digital Inertia ERP)
===================================================================

1. In android/app/src/main/res/xml/weekly_tasks_widget_info.xml:
   <appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
       android:minWidth="250dp"
       android:minHeight="110dp"
       android:updatePeriodMillis="1800000"
       android:initialLayout="@layout/widget_weekly_tasks"
       android:resizeMode="horizontal|vertical"
       android:widgetCategory="home_screen" />

2. In android/app/src/main/res/layout/widget_weekly_tasks.xml:
   - Root: RelativeLayout or LinearLayout (compact ERP card design)
   - Header: App icon, "Weekly Tasks", completion progress badge
   - RemoteViews ListView or StackView showing prioritized tasks:
     - Due Today / Due Tomorrow highlight badges
     - Overdue warning badges
     - Circular toggle checkbox

3. In android/app/src/main/kotlin/.../WeeklyTasksWidgetProvider.kt:
   class WeeklyTasksWidgetProvider : AppWidgetProvider() {
       override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
           // Read SharedPreferences key 'di_weekly_tasks_payload'
           // Update RemoteViews and notify AppWidgetManager
       }
   }
''';

  /// Reference code snippet for iOS WidgetKit implementation
  static String get iosImplementationGuide => '''
===================================================================
IOS WIDGETKIT SETUP GUIDE (Digital Inertia ERP)
===================================================================

1. Add Widget Extension in Xcode:
   - Name: WeeklyTasksWidget
   - Check "Include Configuration Intent" (optional)

2. App Group Configuration:
   - Enable "App Groups" capability in both Main App and Widget Extension
   - Group ID: group.com.digitalinertia.erp

3. In WeeklyTasksWidget.swift:
   struct WeeklyTasksTimelineProvider: TimelineProvider {
       func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklyTasksEntry>) -> Void) {
           let sharedDefaults = UserDefaults(suiteName: "group.com.digitalinertia.erp")
           let json = sharedDefaults?.string(forKey: "di_weekly_tasks_payload")
           // Parse JSON into WidgetTaskItem list
           // Construct Timeline entries and completion()
       }
   }

   struct WeeklyTasksWidgetView: View {
       let entry: WeeklyTasksEntry
       var body: some View {
           // SwiftUI view rendering weekly progress summary + prioritized tasks
       }
   }
''';
}
