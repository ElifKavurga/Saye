package com.example.frontend

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.frontend/emergency_actions"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "placeDirectCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")?.trim()
                    if (phoneNumber.isNullOrEmpty()) {
                        result.error(
                            "INVALID_PHONE_NUMBER",
                            "Phone number is required for direct call.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val intent = Intent(Intent.ACTION_CALL).apply {
                            data = Uri.parse("tel:$phoneNumber")
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (error: SecurityException) {
                        result.error(
                            "CALL_PERMISSION_DENIED",
                            "CALL_PHONE permission is required for direct call.",
                            null
                        )
                    } catch (error: Exception) {
                        result.error("DIRECT_CALL_FAILED", error.message, null)
                    }
                }
                "sendBulkSms" -> {
                    val phoneNumbers = call.argument<List<String>>("phoneNumbers")
                        ?.map { it.trim() }
                        ?.filter { it.isNotEmpty() }
                        .orEmpty()
                    val message = call.argument<String>("message")?.trim()

                    if (phoneNumbers.isEmpty()) {
                        result.error(
                            "INVALID_PHONE_LIST",
                            "At least one phone number is required for SMS.",
                            null
                        )
                        return@setMethodCallHandler
                    }
                    if (message.isNullOrEmpty()) {
                        result.error(
                            "INVALID_SMS_MESSAGE",
                            "SMS message is required.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            getSystemService(SmsManager::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            SmsManager.getDefault()
                        }

                        for (phoneNumber in phoneNumbers) {
                            sendSms(smsManager, phoneNumber, message)
                        }
                        result.success(null)
                    } catch (error: SecurityException) {
                        result.error(
                            "SMS_PERMISSION_DENIED",
                            "SEND_SMS permission is required for automatic SMS.",
                            null
                        )
                    } catch (error: Exception) {
                        result.error("DIRECT_SMS_FAILED", error.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun sendSms(smsManager: SmsManager, phoneNumber: String, message: String) {
        val messageParts = smsManager.divideMessage(message)
        if (messageParts.size > 1) {
            smsManager.sendMultipartTextMessage(
                phoneNumber,
                null,
                ArrayList(messageParts),
                null,
                null
            )
            return
        }

        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
    }

    override fun getRenderMode(): RenderMode = RenderMode.texture
}
