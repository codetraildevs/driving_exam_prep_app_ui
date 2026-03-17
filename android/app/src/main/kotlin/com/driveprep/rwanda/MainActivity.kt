package com.driveprep.rwanda

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.driveprep.rwanda/device_id"

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
    }

    /**
     * Returns a SHA-256 hash of Settings.Secure.ANDROID_ID.
     *
     * ANDROID_ID is:
     * - Unique per (device + app signing key) on Android 8.0+
     * - Persistent across uninstall / reinstall (same signing key)
     * - Does NOT require any dangerous permissions
     *
     * We hash it to avoid storing the raw value on the backend.
     */
    private fun getPersistentDeviceId(): String? {
        val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
        if (androidId.isNullOrBlank() || androidId == "9774d56d682e549c") {
            // Known bad value from some old devices — fall back to null
            return null
        }
        // SHA-256 hash for privacy: backend never sees the raw ANDROID_ID
        val bytes = MessageDigest.getInstance("SHA-256")
            .digest("rwandatraffic:$androidId".toByteArray(Charsets.UTF_8))
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
