package com.digitalinertia.digital_inertia_erp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
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
                // 1. Employee & Header Info
                val firstName = widgetData.getString("first_name", "") ?: ""
                val todayDate = widgetData.getString("today_date", "Today") ?: "Today"
                val progressSummary = widgetData.getString("progress_summary", "Assigned Tasks") ?: "Assigned Tasks"
                val lastUpdated = widgetData.getString("last_updated", "Just now") ?: "Just now"

                val subtitle = if (firstName.isNotEmpty()) {
                    "$firstName's Tasks • $todayDate"
                } else {
                    "Today's Tasks • $todayDate"
                }
                setTextViewText(R.id.tv_widget_subtitle, subtitle)
                setTextViewText(R.id.tv_progress_summary, progressSummary)

                // 2. Task Row 1
                val t1Title = widgetData.getString("task_1_title", "No pending tasks") ?: "No pending tasks"
                val t1Project = widgetData.getString("task_1_project", "Digital Inertia ERP") ?: "Digital Inertia ERP"
                val t1Badge = widgetData.getString("task_1_badge", "All Clear") ?: "All Clear"
                val t1Done = widgetData.getString("task_1_done", "false") == "true"

                setTextViewText(R.id.tv_task_1_title, t1Title)
                setTextViewText(R.id.tv_task_1_project, t1Project)
                setTextViewText(R.id.tv_task_1_badge, t1Badge)
                setInt(
                    R.id.iv_task_1_check,
                    "setBackgroundResource",
                    if (t1Done) R.drawable.di_circle_check_done else R.drawable.di_circle_check_pending
                )

                // 3. Task Row 2
                val t2Title = widgetData.getString("task_2_title", "") ?: ""
                val t2Project = widgetData.getString("task_2_project", "") ?: ""
                val t2Badge = widgetData.getString("task_2_badge", "") ?: ""
                val t2Done = widgetData.getString("task_2_done", "false") == "true"

                if (t2Title.isNotEmpty()) {
                    setViewVisibility(R.id.row_task_2, View.VISIBLE)
                    setTextViewText(R.id.tv_task_2_title, t2Title)
                    setTextViewText(R.id.tv_task_2_project, t2Project)
                    setTextViewText(R.id.tv_task_2_badge, t2Badge)
                    setInt(
                        R.id.iv_task_2_check,
                        "setBackgroundResource",
                        if (t2Done) R.drawable.di_circle_check_done else R.drawable.di_circle_check_pending
                    )
                } else {
                    setViewVisibility(R.id.row_task_2, View.GONE)
                }

                // 4. Task Row 3
                val t3Title = widgetData.getString("task_3_title", "") ?: ""
                val t3Project = widgetData.getString("task_3_project", "") ?: ""
                val t3Badge = widgetData.getString("task_3_badge", "") ?: ""
                val t3Done = widgetData.getString("task_3_done", "false") == "true"

                if (t3Title.isNotEmpty()) {
                    setViewVisibility(R.id.row_task_3, View.VISIBLE)
                    setTextViewText(R.id.tv_task_3_title, t3Title)
                    setTextViewText(R.id.tv_task_3_project, t3Project)
                    setTextViewText(R.id.tv_task_3_badge, t3Badge)
                    setInt(
                        R.id.iv_task_3_check,
                        "setBackgroundResource",
                        if (t3Done) R.drawable.di_circle_check_done else R.drawable.di_circle_check_pending
                    )
                } else {
                    setViewVisibility(R.id.row_task_3, View.GONE)
                }

                // 5. Deep Link Intents
                val tasksLaunchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("dierp://tasks")
                )
                setOnClickPendingIntent(R.id.widget_container, tasksLaunchIntent)
                setOnClickPendingIntent(R.id.btn_launch_tasks, tasksLaunchIntent)
                setOnClickPendingIntent(R.id.row_task_1, tasksLaunchIntent)
                setOnClickPendingIntent(R.id.row_task_2, tasksLaunchIntent)
                setOnClickPendingIntent(R.id.row_task_3, tasksLaunchIntent)

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
