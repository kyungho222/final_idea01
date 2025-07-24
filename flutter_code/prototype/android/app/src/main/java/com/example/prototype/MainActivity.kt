package com.example.prototype

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.prototype/accessibility"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    val isEnabled = isAccessibilityServiceEnabled()
                    result.success(isEnabled)
                }
                "requestAccessibilityPermission" -> {
                    requestAccessibilityPermission()
                    result.success(null)
                }
                "getScreenElements" -> {
                    val elements = getScreenElements()
                    result.success(elements)
                }
                "performClick" -> {
                    val x = call.argument<Double>("x")?.toFloat() ?: 0f
                    val y = call.argument<Double>("y")?.toFloat() ?: 0f
                    val success = performClick(x, y)
                    result.success(success)
                }
                "performScroll" -> {
                    val direction = call.argument<String>("direction") ?: "down"
                    val success = performScroll(direction)
                    result.success(success)
                }
                "scrollToElement" -> {
                    val text = call.argument<String>("text") ?: ""
                    val success = scrollToElement(text)
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // 접근성 서비스에 MethodChannel 설정
        MyAccessibilityService.setMethodChannel(methodChannel!!)
    }

    /**
     * 접근성 서비스 활성화 상태 확인
     */
    private fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityEnabled = Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED,
            0
        )
        
        if (accessibilityEnabled == 1) {
            val service = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            
            return service?.contains("${packageName}/.MyAccessibilityService") == true
        }
        
        return false
    }

    /**
     * 접근성 서비스 권한 요청
     */
    private fun requestAccessibilityPermission() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    /**
     * 화면 요소 가져오기
     */
    private fun getScreenElements(): String? {
        val service = MyAccessibilityService.getInstance()
        return service?.let {
            val elements = it.getScreenElements()
            elements.toString()
        }
    }

    /**
     * 클릭 수행
     */
    private fun performClick(x: Float, y: Float): Boolean {
        val service = MyAccessibilityService.getInstance()
        return service?.performClick(x, y) ?: false
    }

    /**
     * 스크롤 수행
     */
    private fun performScroll(direction: String): Boolean {
        val service = MyAccessibilityService.getInstance()
        return service?.performScroll(direction) ?: false
    }

    /**
     * 특정 요소로 스크롤
     */
    private fun scrollToElement(text: String): Boolean {
        val service = MyAccessibilityService.getInstance()
        return service?.scrollToElement(text) ?: false
    }
} 