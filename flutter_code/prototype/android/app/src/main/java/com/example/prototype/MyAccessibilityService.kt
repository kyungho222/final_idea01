package com.example.prototype

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.graphics.Rect
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import android.accessibilityservice.GestureDescription
import android.graphics.Path

class MyAccessibilityService : AccessibilityService() {
    
    companion object {
        private const val TAG = "MyAccessibilityService"
        private var instance: MyAccessibilityService? = null
        private var methodChannel: MethodChannel? = null
        
        fun setMethodChannel(channel: MethodChannel) {
            methodChannel = channel
        }
        
        fun getInstance(): MyAccessibilityService? {
            return instance
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        
        // 접근성 서비스 설정
        val info = AccessibilityServiceInfo()
        info.apply {
            // 이벤트 타입 설정
            eventTypes = AccessibilityEvent.TYPES_ALL_MASK
            
            // 피드백 타입 설정
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            
            // 플래그 설정
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
            
            // 알림 설정
            notificationTimeout = 100
        }
        
        serviceInfo = info
        Log.d(TAG, "접근성 서비스가 연결되었습니다")
        
        // Flutter에 서비스 활성화 알림
        methodChannel?.invokeMethod("onAccessibilityServiceConnected", null)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        try {
            when (event.eventType) {
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                    // 화면 변경 감지
                    val elements = getScreenElements()
                    val eventData = JSONObject().apply {
                        put("eventType", event.eventType)
                        put("elements", elements)
                    }
                    methodChannel?.invokeMethod("onAccessibilityEvent", eventData.toString())
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "접근성 이벤트 처리 중 오류: ${e.message}")
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "접근성 서비스가 중단되었습니다")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d(TAG, "접근성 서비스가 종료되었습니다")
    }

    /**
     * 현재 화면의 모든 UI 요소를 가져옴
     */
    public fun getScreenElements(): JSONArray {
        val elements = JSONArray()
        
        try {
            val rootNode = rootInActiveWindow ?: return elements
            
            // UI 트리를 재귀적으로 탐색
            traverseNode(rootNode, elements)
            
        } catch (e: Exception) {
            Log.e(TAG, "화면 요소 가져오기 실패: ${e.message}")
        }
        
        return elements
    }

    /**
     * 노드를 재귀적으로 탐색하여 UI 요소 정보를 수집
     */
    private fun traverseNode(node: AccessibilityNodeInfo, elements: JSONArray) {
        if (node == null) return
        
        try {
            // 노드가 화면에 보이고 의미있는 정보를 가지고 있는지 확인
            if (isValidNode(node)) {
                val element = createElementFromNode(node)
                elements.put(element)
            }
            
            // 자식 노드들 탐색
            for (i in 0 until node.childCount) {
                val child = node.getChild(i)
                if (child != null) {
                    traverseNode(child, elements)
                    child.recycle()
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "노드 탐색 중 오류: ${e.message}")
        }
    }

    /**
     * 노드가 유효한 UI 요소인지 확인
     */
    private fun isValidNode(node: AccessibilityNodeInfo): Boolean {
        return node.isVisibleToUser && 
               (node.text?.isNotEmpty() == true || 
                node.contentDescription?.isNotEmpty() == true ||
                node.isClickable ||
                node.isFocusable)
    }

    /**
     * AccessibilityNodeInfo를 JSON 요소로 변환
     */
    private fun createElementFromNode(node: AccessibilityNodeInfo): JSONObject {
        return JSONObject().apply {
            put("id", node.viewIdResourceName ?: "")
            put("text", node.text?.toString() ?: "")
            put("contentDescription", node.contentDescription?.toString())
            put("type", getElementType(node))
            put("bounds", getBounds(node))
            put("isClickable", node.isClickable)
            put("isEnabled", node.isEnabled)
            put("isVisible", node.isVisibleToUser)
            put("isFocusable", node.isFocusable)
            put("isScrollable", node.isScrollable)
        }
    }

    /**
     * 노드의 타입을 결정
     */
    private fun getElementType(node: AccessibilityNodeInfo): String {
        return when {
            node.isClickable && node.text?.isNotEmpty() == true -> "button"
            node.className?.contains("EditText") == true -> "input"
            node.className?.contains("ImageView") == true -> "image"
            node.className?.contains("TextView") == true -> "text"
            node.isClickable -> "button"
            else -> "unknown"
        }
    }

    /**
     * 노드의 경계 정보를 가져옴
     */
    private fun getBounds(node: AccessibilityNodeInfo): JSONObject {
        val rect = Rect()
        node.getBoundsInScreen(rect)
        
        return JSONObject().apply {
            put("left", rect.left)
            put("top", rect.top)
            put("right", rect.right)
            put("bottom", rect.bottom)
            put("width", rect.width())
            put("height", rect.height())
        }
    }

    /**
     * 특정 좌표를 클릭
     */
    fun performClick(x: Float, y: Float): Boolean {
        return try {
            val gestureBuilder = GestureDescription.Builder()
            val path = Path()
            path.moveTo(x, y)
            gestureBuilder.addStroke(GestureDescription.StrokeDescription(path, 0, 100))
            
            dispatchGesture(gestureBuilder.build(), null, null)
            true
        } catch (e: Exception) {
            Log.e(TAG, "클릭 수행 실패: ${e.message}")
            false
        }
    }

    /**
     * 스크롤 수행
     */
    fun performScroll(direction: String): Boolean {
        return try {
            val rootNode = rootInActiveWindow ?: return false
            
            // 스크롤 가능한 노드 찾기
            val scrollableNode = findScrollableNode(rootNode)
            if (scrollableNode != null) {
                val action = when (direction) {
                    "up" -> AccessibilityNodeInfo.ACTION_SCROLL_BACKWARD
                    "down" -> AccessibilityNodeInfo.ACTION_SCROLL_FORWARD
                    "left" -> AccessibilityNodeInfo.ACTION_SCROLL_BACKWARD
                    "right" -> AccessibilityNodeInfo.ACTION_SCROLL_FORWARD
                    else -> return false
                }
                
                scrollableNode.performAction(action)
                scrollableNode.recycle()
                true
            } else {
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "스크롤 수행 실패: ${e.message}")
            false
        }
    }

    /**
     * 스크롤 가능한 노드 찾기
     */
    private fun findScrollableNode(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        if (node.isScrollable) return node
        
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                val scrollable = findScrollableNode(child)
                if (scrollable != null) {
                    child.recycle()
                    return scrollable
                }
                child.recycle()
            }
        }
        
        return null
    }

    /**
     * 특정 텍스트로 스크롤
     */
    fun scrollToElement(text: String): Boolean {
        return try {
            val rootNode = rootInActiveWindow ?: return false
            
            // 텍스트가 포함된 노드 찾기
            val targetNode = findNodeByText(rootNode, text)
            if (targetNode != null) {
                targetNode.performAction(AccessibilityNodeInfo.ACTION_ACCESSIBILITY_FOCUS)
                targetNode.recycle()
                true
            } else {
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "요소로 스크롤 실패: ${e.message}")
            false
        }
    }

    /**
     * 텍스트로 노드 찾기
     */
    private fun findNodeByText(node: AccessibilityNodeInfo, text: String): AccessibilityNodeInfo? {
        if (node.text?.toString()?.contains(text, ignoreCase = true) == true) {
            return node
        }
        
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                val found = findNodeByText(child, text)
                if (found != null) {
                    child.recycle()
                    return found
                }
                child.recycle()
            }
        }
        
        return null
    }
} 