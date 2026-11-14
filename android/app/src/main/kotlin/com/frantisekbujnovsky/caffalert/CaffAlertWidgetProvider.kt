package com.frantisekbujnovsky.caffalert

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.graphics.*
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Date
import java.util.Locale
import java.text.SimpleDateFormat
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.roundToInt

class CaffAlertWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences) {
        ids.forEach { id ->
            val views = if (Build.VERSION.SDK_INT >= 31) {
                RemoteViews(mapOf(
                    SizeF(130f, 130f) to buildViews(context, data, false),
                    SizeF(WIDE_MIN_WIDTH_DP.toFloat(), 130f) to buildViews(context, data, true),
                ))
            } else {
                val width = manager.getAppWidgetOptions(id)
                    .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
                // Some hosts send no size options for the initial placement.
                buildViews(context, data, width <= 0 || width >= WIDE_MIN_WIDTH_DP)
            }
            manager.updateAppWidget(id, views)
        }
        schedule(context, data)
    }

    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, id: Int, options: Bundle) {
        onUpdate(context, manager, intArrayOf(id), HomeWidgetPlugin.getData(context))
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action in setOf(REFRESH, Intent.ACTION_TIME_CHANGED, Intent.ACTION_TIMEZONE_CHANGED)) {
            val manager = AppWidgetManager.getInstance(context)
            onUpdate(context, manager, manager.getAppWidgetIds(ComponentName(context, javaClass)), HomeWidgetPlugin.getData(context))
        }
    }

    override fun onDisabled(context: Context) {
        alarms(context).cancel(alarmIntent(context))
        alarms(context).cancel(alarmIntent(context, true))
        super.onDisabled(context)
    }

    private fun duration(data: SharedPreferences): Long = data.getString(DURATION_KEY, null)
        ?.toLongOrNull()?.takeIf { it in 1..(Long.MAX_VALUE / 1000) }?.times(1000)
        ?: 4 * 60 * 60 * 1000L

    private fun end(data: SharedPreferences): Long? = data.getString(LATEST_KEY, null)
        ?.toLongOrNull()?.let { it + duration(data) }

    private fun buildViews(context: Context, data: SharedPreferences, wide: Boolean): RemoteViews {
        val context = localizedContext(context, data)
        val end = end(data)
        val remaining = ((end ?: 0) - System.currentTimeMillis()).coerceAtLeast(0)
        val level = (remaining.toDouble() / duration(data) * 100).roundToInt().coerceIn(0, 100)
        val running = remaining > 0
        val status = context.getString(when {
            end == null -> R.string.caff_widget_state_empty
            !running -> R.string.caff_widget_state_zero
            level <= 20 -> R.string.caff_widget_state_low
            else -> R.string.caff_widget_state_stable
        })
        // Static end time instead of a live Chronometer: RemoteViews cannot
        // stop a countdown at zero, so it would run into negative values.
        val endTime: String? = if (end != null && running) formatEndTime(context, end) else null
        val endToday = end == null || isSameDay(end)
        return RemoteViews(context.packageName, if (wide) R.layout.caff_alert_widget_wide else R.layout.caff_alert_widget).apply {
            setImageViewBitmap(R.id.caff_widget_ring, drawRing(context, level, end == null))
            setContentDescription(R.id.caff_widget_ring, context.getString(R.string.caff_widget_content_description, level, status))
            setTextColor(R.id.caff_widget_status, if (running && level <= 20) EMBER else CREMA)
            setInt(R.id.caff_widget_end_label, "setMaxLines", if (endTime == null || !wide) 2 else 1)
            if (endTime != null) {
                setTextViewText(R.id.caff_widget_end_label, context.getString(
                    if (endToday) R.string.caff_widget_zero_at_label else R.string.caff_widget_zero_tomorrow_label))
                setTextViewText(R.id.caff_widget_end_time, endTime)
                setContentDescription(R.id.caff_widget_end_time, context.getString(
                    if (endToday) R.string.caff_widget_zero_at else R.string.caff_widget_zero_tomorrow_at,
                    endTime))
                setViewVisibility(R.id.caff_widget_end_label, View.VISIBLE)
                setViewVisibility(R.id.caff_widget_end_time, View.VISIBLE)
            } else {
                setViewVisibility(R.id.caff_widget_end_time, View.GONE)
            }
            setOnClickPendingIntent(R.id.caff_widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("caffalert://widget/open")))
            if (wide) {
                // Wide: status always on top, the label line explains the state.
                setTextViewText(R.id.caff_widget_status, status)
                setViewVisibility(R.id.caff_widget_status, View.VISIBLE)
                if (endTime == null) {
                    setTextViewText(R.id.caff_widget_end_label, context.getString(
                        if (end == null) R.string.caff_widget_empty else R.string.caff_widget_zero))
                    setViewVisibility(R.id.caff_widget_end_label, View.VISIBLE)
                }
                // RemoteViews XML is inflated by the launcher in its own locale.
                setTextViewText(R.id.caff_widget_add, context.getString(R.string.caff_widget_add))
                setContentDescription(R.id.caff_widget_add, context.getString(R.string.caff_widget_add_description))
                setOnClickPendingIntent(R.id.caff_widget_add,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("caffalert://widget/log")))
            } else {
                // 2×2: the end time replaces the status line while CAF runs (the
                // ring colour shows "low"); otherwise one short status line.
                if (endTime == null) {
                    setViewVisibility(R.id.caff_widget_end_label, View.GONE)
                    setTextViewText(R.id.caff_widget_status, context.getString(
                        if (end == null) R.string.caff_widget_state_empty else R.string.caff_widget_zero))
                    setViewVisibility(R.id.caff_widget_status, View.VISIBLE)
                } else {
                    setViewVisibility(R.id.caff_widget_status, View.GONE)
                }
            }
        }
    }

    private fun isSameDay(timestamp: Long): Boolean {
        val now = java.util.Calendar.getInstance()
        val other = java.util.Calendar.getInstance().apply { timeInMillis = timestamp }
        return now.get(java.util.Calendar.YEAR) == other.get(java.util.Calendar.YEAR) &&
            now.get(java.util.Calendar.DAY_OF_YEAR) == other.get(java.util.Calendar.DAY_OF_YEAR)
    }

    private fun localizedContext(context: Context, data: SharedPreferences): Context {
        val language = data.getString(LANGUAGE_KEY, null)
            ?: context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .getString("flutter.preferred_locale", null)
            ?: return context
        val configuration = Configuration(context.resources.configuration)
        configuration.setLocale(Locale.forLanguageTag(language))
        return context.createConfigurationContext(configuration)
    }

    private fun formatEndTime(context: Context, timestamp: Long): String {
        val locale = context.resources.configuration.locales[0]
        // Czech always uses 24-hour H:mm, same as the app (DateFormat.Hm cs). Other
        // locales follow the system 24-hour preference and include AM/PM in 12h.
        return if (locale.language == "cs") {
            SimpleDateFormat("H:mm", locale).format(Date(timestamp))
        } else if (android.text.format.DateFormat.is24HourFormat(context)) {
            SimpleDateFormat("HH:mm", locale).format(Date(timestamp))
        } else {
            val format = android.text.format.DateFormat.getTimeFormat(context)
            // Keep the system's localized format, adding a day period if an OEM
            // formatter omits it. Never show an ambiguous 1:27 for 13:27.
            if (format is SimpleDateFormat && format.toPattern().contains('a')) {
                format.format(Date(timestamp))
            } else {
                SimpleDateFormat("h:mm a", locale).format(Date(timestamp))
            }
        }
    }

    private fun drawRing(context: Context, level: Int, empty: Boolean): Bitmap {
        // Match CafGaugePainter: full circle from 12 o'clock, clockwise,
        // 7.5% stroke, four inset quarter ticks and a foam bead.
        val size = 320f
        val center = size / 2f
        val stroke = size * 0.075f
        val radius = center - stroke / 2f - 4f
        val bounds = RectF(center - radius, center - radius, center + radius, center + radius)
        val bitmap = Bitmap.createBitmap(size.toInt(), size.toInt(), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        val low = level in 1..20
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = stroke
        paint.strokeCap = Paint.Cap.ROUND
        // Adapt the track contrast to the espresso card, keeping brand colors
        // for the progress itself identical to AppColors in Flutter.
        paint.color = Color.rgb(89, 64, 53)
        canvas.drawCircle(center, center, radius, paint)

        paint.strokeWidth = 2f
        paint.color = Color.argb(110, 194, 134, 93)
        for (index in 0 until 4) {
            val angle = Math.toRadians(-90.0 + index * 90.0)
            val dx = cos(angle).toFloat()
            val dy = sin(angle).toFloat()
            val outer = radius - stroke / 2f - 3f
            val inner = radius - stroke / 2f - 8f
            canvas.drawLine(center + dx * outer, center + dy * outer,
                center + dx * inner, center + dy * inner, paint)
        }

        if (level > 0) {
            val sweep = 360f * level / 100f
            val colors = if (low) intArrayOf(CARAMEL, EMBER, EMBER)
                else intArrayOf(CARAMEL, ROAST, ESPRESSO)
            // Bring ember into the visible low segment, rather than leaving it
            // beyond the tip of a nearly empty ring.
            val stops = if (low) floatArrayOf(0f, level / 100f, 1f)
                else floatArrayOf(0f, 0.55f, 1f)
            paint.strokeWidth = stroke
            paint.alpha = 255
            paint.shader = SweepGradient(center, center, colors, stops).apply {
                // Shift half a rounded cap before noon, as in CafGaugePainter.
                val capDegrees = Math.toDegrees((stroke / 2f / radius).toDouble()).toFloat()
                setLocalMatrix(Matrix().apply { setRotate(-90f - capDegrees, center, center) })
            }
            canvas.drawArc(bounds, -90f, sweep, false, paint)
            paint.shader = null
            val headAngle = Math.toRadians((-90f + sweep).toDouble())
            paint.style = Paint.Style.FILL
            paint.color = FOAM
            paint.alpha = 242
            canvas.drawCircle(center + radius * cos(headAngle).toFloat(),
                center + radius * sin(headAngle).toFloat(), stroke * 0.24f, paint)
            paint.alpha = 255
        }

        paint.style = Paint.Style.FILL
        paint.textAlign = Paint.Align.CENTER
        paint.color = when {
            level == 0 -> ZERO_GRAY
            low -> EMBER
            else -> FOAM
        }
        paint.typeface = monoTypeface ?: run {
            val face = try { Typeface.createFromAsset(context.assets, "flutter_assets/assets/fonts/IBMPlexMono-Bold.ttf") }
                catch (_: Exception) { Typeface.create("monospace", Typeface.BOLD) }
            monoTypeface = face
            face
        }
        paint.textSize = 67f
        canvas.drawText(if (empty) "—" else "$level%", center, 177f, paint)
        paint.textSize = 22f
        paint.color = when {
            level == 0 -> ZERO_GRAY
            low -> EMBER
            else -> Color.rgb(215, 187, 167)
        }
        canvas.drawText("CAF", center, 215f, paint)
        return bitmap
    }

    private fun schedule(context: Context, data: SharedPreferences) {
        val alarms = alarms(context)
        val intent = alarmIntent(context)
        alarms.cancel(intent)
        val zeroIntent = alarmIntent(context, true)
        alarms.cancel(zeroIntent)
        val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, javaClass))
        val remaining = (end(data) ?: return) - System.currentTimeMillis()
        if (remaining <= 0 || ids.isEmpty()) return
        // Separate end alarm, requested at zero rather than the next 15 min step.
        // Still inexact: Android can defer delivery; no exact-alarm permission.
        val now = System.currentTimeMillis()
        alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, now + remaining, zeroIntent)
        if (remaining > 15 * 60 * 1000L) {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC, now + 15 * 60 * 1000L, intent)
        }
    }

    private fun alarms(context: Context) = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private fun alarmIntent(context: Context, zero: Boolean = false): PendingIntent = PendingIntent.getBroadcast(context, if (zero) 24 else 23,
        Intent(context, CaffAlertWidgetProvider::class.java).setAction(REFRESH),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

    private companion object {
        const val LANGUAGE_KEY = "caff_alert_language"
        // Keep in sync with android:minWidth in xml/caff_alert_widget_info.xml:
        // the default 4×2 placement must get the wide layout with "+ Coffee".
        const val WIDE_MIN_WIDTH_DP = 250
        // Keep in sync with AppColors in lib/app_theme.dart.
        val ESPRESSO = Color.rgb(53, 36, 29)
        val ROAST = Color.rgb(109, 73, 56)
        val CARAMEL = Color.rgb(194, 134, 93)
        val EMBER = Color.rgb(180, 86, 31)
        val FOAM = Color.rgb(255, 251, 247)
        val ZERO_GRAY = Color.rgb(155, 148, 143)
        val CREMA = Color.rgb(244, 233, 222)
        const val LATEST_KEY = "caff_alert_latest_coffee_millis"
        const val DURATION_KEY = "caff_alert_duration_seconds"
        const val REFRESH = "com.frantisekbujnovsky.caffalert.WIDGET_REFRESH"
        var monoTypeface: Typeface? = null
    }
}
