package org.ayilavan.thiruppugazh

import android.content.Intent
import android.view.WindowManager
import android.widget.Toast
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
            } else if (call.method == "finishShare") {
                // Confirm with a system toast (it stays visible over the app
                // the user came from), then step back to that app.
                val message = call.arguments as? String ?: ""
                runOnUiThread {
                    if (message.isNotEmpty()) {
                        Toast.makeText(applicationContext, message, Toast.LENGTH_LONG).show()
                    }
                    moveTaskToBack(true)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
        channel = newChannel

        // Chanting mode asks to keep the screen on while it is open.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "setKeepScreenOn") {
                    val keepOn = call.arguments as? Boolean ?: false
                    runOnUiThread {
                        if (keepOn) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
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
        private const val SCREEN_CHANNEL = "org.ayilavan.thiruppugazh/screen"
    }
}
