package com.trafficrules.rwanda.app

import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Opt into edge-to-edge rendering for Android 15+ compatibility.
        // This makes the system bars transparent and lets Flutter handle
        // insets via MediaQuery, preventing the Play Store warning.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    private val CHANNEL = "com.trafficrules.rwanda.app/device_id"
    private val SECURITY_CHANNEL = "com.trafficrules.rwanda.app/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getPersistentDeviceId") {
                    val id = getPersistentDeviceId()
                    if (id != null) {
                        result.success(id)
                    } else {
                        result.error("UNAVAILABLE", "Could not obtain device ID", null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "secureScreenOn" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "secureScreenOff" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Returns a SHA-256 hash of Settings.Secure.ANDROID_ID.
     */
    private fun getPersistentDeviceId(): String? {
        val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
        if (androidId.isNullOrBlank() || androidId == "9774d56d682e549c") {
            return null
        }
        val bytes = MessageDigest.getInstance("SHA-256")
            .digest("rwandatraffic:$androidId".toByteArray(Charsets.UTF_8))
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
