package com.example.prototype

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityManager

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.prototype/accessibility").setMethodCallHandler {
            call, result ->
            if (call.method == "performClick") {
                val x = (call.argument<Double>("x") ?: 0.0).toFloat()
                val y = (call.argument<Double>("y") ?: 0.0).toFloat()
                // AccessibilityService 인스턴스에 직접 performClick 호출
                val service = MyAccessibilityService.instance
                if (service != null) {
                    service.performClick(x, y)
                    result.success(null)
                } else {
                    result.error("NO_SERVICE", "AccessibilityService not running", null)
                }
            } else if (call.method == "isAccessibilityServiceEnabled") {
                val am = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
                val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
                val colonSplitter = TextUtils.SimpleStringSplitter(':')
                colonSplitter.setString(enabledServices)
                var enabled = false
                while (colonSplitter.hasNext()) {
                    val componentName = colonSplitter.next()
                    if (componentName.equals("$packageName/${MyAccessibilityService::class.java.name}", ignoreCase = true)) {
                        enabled = true
                        break
                    }
                }
                result.success(enabled)
            } else {
                result.notImplemented()
            }
        }
    }
} 