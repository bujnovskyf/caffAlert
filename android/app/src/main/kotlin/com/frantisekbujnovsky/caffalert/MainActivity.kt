package com.frantisekbujnovsky.caffalert

import android.content.Intent
import android.os.Bundle
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import io.flutter.embedding.android.FlutterActivity
import java.util.UUID

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android may restore the original system Intent after process death.
        // Keep the already assigned tap ID in saved state as well.
        savedInstanceState?.getString("caff_widget_tap_uri")?.let {
            intent.data = Uri.parse(it)
        }
        identifyWidgetTap(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        identifyWidgetTap(intent)
        super.onNewIntent(intent)
        setIntent(intent)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        val uri = intent.data
        if (uri?.scheme == "caffalert" && uri.host == "widget" && uri.path == "/log") {
            outState.putString("caff_widget_tap_uri", uri.toString())
        }
        super.onSaveInstanceState(outState)
    }

    private fun identifyWidgetTap(intent: Intent) {
        if ((intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0) {
            // Recents replays the original task Intent, including an existing
            // tap UUID. Neutralize both the URI and home_widget action before
            // Flutter/plugin initialization or onNewIntent listeners see them.
            val uri = intent.data
            if (intent.action == HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION ||
                (uri?.scheme == "caffalert" && uri.host == "widget")) {
                intent.action = Intent.ACTION_MAIN
                intent.data = null
            }
            return
        }
        val uri = intent.data ?: return
        if (uri.scheme != "caffalert" || uri.host != "widget" || uri.path != "/log") return
        if (intent.action == HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION &&
            uri.getQueryParameter("tap") == null) {
            // Each PendingIntent delivery is a new tap. Activity recreation retains this ID.
            intent.data = uri.buildUpon().appendQueryParameter("tap", UUID.randomUUID().toString())
                .appendQueryParameter("at", System.currentTimeMillis().toString()).build()
        }
    }
}
