package com.frantisekbujnovsky.caffalert

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Locale
import kotlin.math.roundToInt

class CaffAlertWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            appWidgetManager.updateAppWidget(
                appWidgetId,
                buildViews(context, widgetData),
            )
        }
    }

    private fun buildViews(
        context: Context,
        widgetData: SharedPreferences,
    ): RemoteViews {
        val latestCoffeeMillis = widgetData
            .getString(LATEST_COFFEE_KEY, null)
            ?.toLongOrNull()
        val durationMillis = widgetData
            .getString(DURATION_KEY, null)
            ?.toLongOrNull()
            ?.takeIf { it > 0L }
            ?.times(1000L)
            ?: DEFAULT_DURATION_MILLIS
        val remainingMillis = latestCoffeeMillis?.let { recordedAt ->
            (durationMillis - (System.currentTimeMillis() - recordedAt)).coerceAtLeast(0L)
        } ?: 0L
        val level = if (latestCoffeeMillis == null) {
            0
        } else {
            (remainingMillis.toDouble() / durationMillis * 100)
                .roundToInt()
                .coerceIn(0, 100)
        }

        return RemoteViews(context.packageName, R.layout.caff_alert_widget).apply {
            setTextViewText(
                R.id.caff_widget_level,
                context.getString(R.string.caff_widget_level, level),
            )
            setProgressBar(R.id.caff_widget_progress, 100, level, false)
            setTextViewText(
                R.id.caff_widget_status,
                statusText(context, latestCoffeeMillis, remainingMillis, level),
            )
            setContentDescription(
                R.id.caff_widget_root,
                context.getString(
                    R.string.caff_widget_content_description,
                    level,
                ),
            )
            setOnClickPendingIntent(R.id.caff_widget_root, launchIntent(context))
        }
    }

    private fun statusText(
        context: Context,
        latestCoffeeMillis: Long?,
        remainingMillis: Long,
        level: Int,
    ): String = when {
        latestCoffeeMillis == null -> context.getString(R.string.caff_widget_empty)
        level == 0 -> context.getString(R.string.caff_widget_zero)
        level <= LOW_LEVEL_THRESHOLD -> context.getString(R.string.caff_widget_low)
        else -> context.getString(
            R.string.caff_widget_remaining,
            formatRemaining(remainingMillis),
        )
    }

    private fun launchIntent(context: Context): PendingIntent {
        val intent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP }
            ?: Intent()
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun formatRemaining(remainingMillis: Long): String {
        val totalMinutes = remainingMillis / 60_000L
        val hours = totalMinutes / 60L
        val minutes = totalMinutes % 60L
        return String.format(Locale.getDefault(), "%d:%02d", hours, minutes)
    }

    private companion object {
        const val LATEST_COFFEE_KEY = "caff_alert_latest_coffee_millis"
        const val DURATION_KEY = "caff_alert_duration_seconds"
        const val DEFAULT_DURATION_MILLIS = 4 * 60 * 60 * 1000L
        const val LOW_LEVEL_THRESHOLD = 20
    }
}
