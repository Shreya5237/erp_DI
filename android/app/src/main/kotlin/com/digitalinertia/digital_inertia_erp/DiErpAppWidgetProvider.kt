package com.digitalinertia.digital_inertia_erp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class DiErpAppWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.di_erp_appwidget).apply {
                // Header / Subtitle
                val lastUpdated = widgetData.getString("last_updated", "Just now") ?: "Just now"
                val subtitle = "Executive Overview • Updated $lastUpdated"
                setTextViewText(R.id.tv_widget_subtitle, subtitle)

                // Key metrics
                val projects = widgetData.getString("active_projects", "12") ?: "12"
                val tasks = widgetData.getString("pending_tasks", "28") ?: "28"
                val approvals = widgetData.getString("pending_approvals", "5") ?: "5"
                val alerts = widgetData.getString("critical_alerts", "3") ?: "3"

                setTextViewText(R.id.tv_projects_count, projects)
                setTextViewText(R.id.tv_tasks_count, tasks)
                setTextViewText(R.id.tv_approvals_count, approvals)
                setTextViewText(R.id.tv_alerts_count, alerts)

                // Priority Tasks
                val task1Title = widgetData.getString("task_1_title", "Review Q4 Plant Automation Plan") ?: "Review Q4 Plant Automation Plan"
                val task1Badge = widgetData.getString("task_1_badge", "Due Today") ?: "Due Today"
                val task2Title = widgetData.getString("task_2_title", "Approve Vendor Invoice #4128") ?: "Approve Vendor Invoice #4128"
                val task2Badge = widgetData.getString("task_2_badge", "High Priority") ?: "High Priority"

                setTextViewText(R.id.tv_task_1_title, task1Title)
                setTextViewText(R.id.tv_task_1_badge, task1Badge)
                setTextViewText(R.id.tv_task_2_title, task2Title)
                setTextViewText(R.id.tv_task_2_badge, task2Badge)

                // Click Actions (Open App / Deep Links)
                val defaultLaunchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("dierp://dashboard")
                )
                setOnClickPendingIntent(R.id.widget_container, defaultLaunchIntent)
                setOnClickPendingIntent(R.id.btn_launch_app, defaultLaunchIntent)

                val tasksLaunchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("dierp://tasks")
                )
                setOnClickPendingIntent(R.id.card_tasks, tasksLaunchIntent)
                setOnClickPendingIntent(R.id.btn_launch_tasks, tasksLaunchIntent)
                setOnClickPendingIntent(R.id.row_task_1, tasksLaunchIntent)
                setOnClickPendingIntent(R.id.row_task_2, tasksLaunchIntent)

                val approvalsLaunchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("dierp://approvals")
                )
                setOnClickPendingIntent(R.id.card_approvals, approvalsLaunchIntent)
                setOnClickPendingIntent(R.id.btn_launch_approvals, approvalsLaunchIntent)

                val syncLaunchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("dierp://sync")
                )
                setOnClickPendingIntent(R.id.btn_refresh_widget, syncLaunchIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
