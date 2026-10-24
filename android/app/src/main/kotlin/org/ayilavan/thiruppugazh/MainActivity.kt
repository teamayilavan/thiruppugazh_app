package org.ayilavan.thiruppugazh

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pendingSharedText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val newChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL)
        newChannel.setMethodCallHandler { call, result ->
            if (call.method == "getInitialSharedText") {
                // Hand the text over exactly once so a later Flutter restart
                // can't replay a share the user already dealt with.
                result.success(pendingSharedText)
                pendingSharedText = null
            } else {
                result.notImplemented()
            }
        }
        channel = newChannel
        // Cold start: the app was launched by the share itself.
        pendingSharedText = takeSharedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Warm start: the app was already running when something was shared.
        takeSharedText(intent)?.let { channel?.invokeMethod("onSharedText", it) }
    }

    /** Returns the text of an ACTION_SEND text/plain intent, consuming it. */
    private fun takeSharedText(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") return null
        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        // Clear the action so recreating the activity doesn't re-deliver it.
        intent.action = null
        return text?.takeIf { it.isNotBlank() }
    }

    companion object {
        private const val SHARE_CHANNEL = "org.ayilavan.thiruppugazh/share"
    }
}
