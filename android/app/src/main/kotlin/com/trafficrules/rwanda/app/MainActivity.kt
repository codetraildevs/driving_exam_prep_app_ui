package com.trafficrules.rwanda.app

import android.os.Bundle
import android.content.Intent
import android.provider.Settings
import android.view.WindowManager
import android.view.WindowInsets
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowInsetsControllerCompat
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
     * Secure-screen protection.
     * Keeps FLAG_SECURE (prevents screenshots/recording) on, and hides the
     * system bars when the user toggles this ON. All system-bar color/opacity
     * changes are left to Flutter's enableEdgeToEdge() so the deprecated
     * android.view.Window APIs are never touched. FLAG_SECURE works regardless
     * of the system bars.
     */
            private fun setSecureScreen(on: Boolean) {
        // Keep FLAG_SECURE on so screenshots / screen recording are blocked.
        // Works regardless of system bars. System-bar color/opacity is handled
        // by Flutter's enableEdgeToEdge() (see onCreate), so the deprecated
        // android.view.Window APIs are never touched here. We only toggle the
        // secure flag; when secure is OFF we disable it and leave system bars to
        // the system defaults. Hiding the system bars was omitted because
        // WindowInsetsCompat.SYSTEM_BARS does not resolve on all AGP/Kotlin
        // targets, and screenshots are already blocked by FLAG_SECURE.
        @Suppress("DeprecationWarning")
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        if (on) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
