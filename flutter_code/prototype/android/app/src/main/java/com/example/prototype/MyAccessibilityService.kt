package com.example.prototype

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.view.accessibility.AccessibilityEvent
import android.content.Intent
import android.util.Log

class MyAccessibilityService : AccessibilityService() {
    companion object {
        var instance: MyAccessibilityService? = null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // 필요시 이벤트 처리
    }

    override fun onInterrupt() {}

    // 예시: 화면의 (x, y) 위치를 터치하는 함수
    fun performClick(x: Float, y: Float) {
        val path = Path()
        path.moveTo(x, y)
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, 100))
            .build()
        dispatchGesture(gesture, null, null)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val x = intent?.getFloatExtra("x", -1f) ?: -1f
        val y = intent?.getFloatExtra("y", -1f) ?: -1f
        if (x >= 0 && y >= 0) {
            Log.i("MyAccessibilityService", "performClick($x, $y)")
            performClick(x, y)
        }
        return super.onStartCommand(intent, flags, startId)
    }
} 