package com.trafficrules.rwanda.app

import android.os.Bundle
import android.content.Intent
import android.provider.Settings
import android.view.WindowManager
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterFragmentActivity() {
    private var referralBridge: ReferralBridge? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        referralBridge?.onLink(intent.dataString)
    }

    override fun onDestroy() {
        referralBridge?.dispose()
        super.onDestroy()
    }

    /**
     * Toggle screen-capture protection from the platform channel on the UI thread.
     * Use AndroidX insets APIs for compatibility with older Android versions.
     */
    private fun setSecureScreen(on: Boolean) {
        val controller = WindowCompat.getInsetsController(window, window.decorView)
        if (on) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
        controller.show(WindowInsetsCompat.Type.systemBars())
        controller.isAppearanceLightStatusBars = false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

    override fun onResume() {
        super.onResume()
        WindowCompat.getInsetsController(window, window.decorView).apply {
            show(WindowInsetsCompat.Type.systemBars())
            isAppearanceLightStatusBars = false
        }
    }

    private val CHANNEL = "com.trafficrules.rwanda.app/device_id"
    private val SECURITY_CHANNEL = "com.trafficrules.rwanda.app/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        referralBridge = ReferralBridge(this, flutterEngine.dartExecutor.binaryMessenger) { intent?.dataString }

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
                        setSecureScreen(true)
                        result.success(null)
                    }
                    "secureScreenOff" -> {
                        setSecureScreen(false)
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
