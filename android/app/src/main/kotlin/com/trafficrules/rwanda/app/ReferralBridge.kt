package com.trafficrules.rwanda.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** Private, encrypted pending attribution. The server decides final ownership. */
class ReferralBridge(private val context: Context, messenger: BinaryMessenger, private val initialLink: () -> String?) {
    private val channel = MethodChannel(messenger, "com.trafficrules.rwanda.app/referrals")
    private val prefs = context.getSharedPreferences("referral_attribution", Context.MODE_PRIVATE)
    private val handler = Handler(Looper.getMainLooper())
    private var closeReferrer: (() -> Unit)? = null

    init {
        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "read" -> result.success(read())
                    "write" -> { write(call.arguments as String); result.success(null) }
                    "initialLink" -> result.success(initialLink())
                    "installReferrer" -> installReferrer(result)
                    else -> result.notImplemented()
                }
            } catch (_: Exception) {
                result.error("REFERRAL_STORAGE", "Unable to store invitation securely", null)
            }
        }
    }

    fun onLink(link: String?) { if (link != null) channel.invokeMethod("link", link) }
    fun dispose() { closeReferrer?.invoke(); channel.setMethodCallHandler(null) }

    private fun key(): SecretKey {
        val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val alias = "rwanda_referral_attribution_v1"
        (store.getKey(alias, null) as? SecretKey)?.let { return it }
        return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore").apply {
            init(KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build())
        }.generateKey()
    }

    private fun read(): String? {
        val raw = prefs.getString("pending", null) ?: return null
        return try {
            val parts = raw.split(":")
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128, Base64.decode(parts[0], Base64.NO_WRAP)))
            String(cipher.doFinal(Base64.decode(parts[1], Base64.NO_WRAP)), Charsets.UTF_8)
        } catch (_: Exception) {
            // A restored backup has no matching Android Keystore key.
            prefs.edit().remove("pending").commit()
            null
        }
    }

    private fun write(value: String) {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key())
        val encrypted = cipher.doFinal(value.toByteArray(Charsets.UTF_8))
        check(prefs.edit().putString("pending", Base64.encodeToString(cipher.iv, Base64.NO_WRAP) + ":" +
            Base64.encodeToString(encrypted, Base64.NO_WRAP)).commit())
    }

    private fun installReferrer(result: MethodChannel.Result) {
        closeReferrer?.invoke()
        val client = InstallReferrerClient.newBuilder(context).build()
        var completed = false
        lateinit var timeout: Runnable
        fun finish(value: Map<String, Any?>) {
            if (completed) return
            completed = true
            handler.removeCallbacks(timeout)
            try { client.endConnection() } catch (_: Exception) { }
            closeReferrer = null
            result.success(value)
        }
        timeout = Runnable { finish(mapOf("complete" to false)) }
        closeReferrer = { finish(mapOf("complete" to false)) }
        handler.postDelayed(timeout, 3500)
        try {
            client.startConnection(object : InstallReferrerStateListener {
                override fun onInstallReferrerSetupFinished(responseCode: Int) {
                    handler.post {
                        if (!completed) {
                            try {
                                when (responseCode) {
                                    InstallReferrerClient.InstallReferrerResponse.OK ->
                                        finish(mapOf("complete" to true, "referrer" to client.installReferrer.installReferrer))
                                    InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED ->
                                        finish(mapOf("complete" to true))
                                    else -> finish(mapOf("complete" to false))
                                }
                            } catch (_: Exception) { finish(mapOf("complete" to false)) }
                        }
                    }
                }
                override fun onInstallReferrerServiceDisconnected() {
                    handler.post { finish(mapOf("complete" to false)) }
                }
            })
        } catch (_: Exception) { finish(mapOf("complete" to false)) }
    }
}
