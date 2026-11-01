// 🤖 Generated wholely or partially with GPT-5; Google Antigravity
package com.adilhanney.saber

import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.os.Bundle
import android.view.InputDevice
import android.view.KeyEvent
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.adilhanney.saber/stylus_buttons"
    private var methodChannel: MethodChannel? = null
    private var isLearningMode: Boolean = false
    private val customKeys: MutableSet<Int> = mutableSetOf()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "setLearningMode" -> {
                        isLearningMode = call.arguments as? Boolean ?: false
                        result.success(null)
                    }
                    "setCustomKeys" -> {
                        customKeys.clear()
                        val keys = call.arguments as? List<*>
                        keys?.forEach { item ->
                            val code = (item as? Number)?.toInt() ?: -1
                            if (code > 0) customKeys.add(code)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        val windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController.isAppearanceLightNavigationBars = true
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val keyCode = event.keyCode

        // Never intercept core Android system navigation keys
        if (keyCode == KeyEvent.KEYCODE_BACK ||
            keyCode == KeyEvent.KEYCODE_HOME ||
            keyCode == KeyEvent.KEYCODE_APP_SWITCH ||
            keyCode == KeyEvent.KEYCODE_POWER
        ) {
            return super.dispatchKeyEvent(event)
        }

        // Button Learning Mode: capture ANY button press from any Bluetooth/Stylus device
        if (isLearningMode) {
            if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                isLearningMode = false
                val payload = mapOf(
                    "keyCode" to keyCode,
                    "keyName" to KeyEvent.keyCodeToString(keyCode),
                    "deviceName" to (event.device?.name ?: "Universal Input"),
                )
                methodChannel?.invokeMethod("onKeyLearned", payload)
            }
            return true
        }

        // Check user-learned custom Bluetooth / Stylus keycodes first
        if (customKeys.contains(keyCode)) {
            if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                methodChannel?.invokeMethod("stylusCustomKey", keyCode)
            }
            return true
        }

        val device = event.device
        val isExternal = device?.isExternal == true
        val isStylusSource = (event.source and InputDevice.SOURCE_STYLUS) != 0 ||
                (event.source and InputDevice.SOURCE_BLUETOOTH_STYLUS) != 0

        val button = when (keyCode) {
            // Standard Android Stylus (API 34+) & Generic Bluetooth Pen Buttons
            KeyEvent.KEYCODE_STYLUS_BUTTON_PRIMARY,
            KeyEvent.KEYCODE_BUTTON_A,
            KeyEvent.KEYCODE_BUTTON_1,
            KeyEvent.KEYCODE_PAGE_DOWN -> 1

            KeyEvent.KEYCODE_STYLUS_BUTTON_SECONDARY,
            KeyEvent.KEYCODE_BUTTON_B,
            KeyEvent.KEYCODE_BUTTON_2,
            KeyEvent.KEYCODE_PAGE_UP -> 2

            KeyEvent.KEYCODE_STYLUS_BUTTON_TERTIARY,
            KeyEvent.KEYCODE_BUTTON_C,
            KeyEvent.KEYCODE_BUTTON_3 -> 3

            KeyEvent.KEYCODE_STYLUS_BUTTON_TAIL -> 1

            // Surface Pen & MPP Top Click / Bluetooth Pen Shortcut Keys
            KeyEvent.KEYCODE_F20 -> 1
            KeyEvent.KEYCODE_F19 -> 3
            KeyEvent.KEYCODE_F18 -> 2

            // External Bluetooth Styluses & Clickers (Baseus, Goojodoq, ESR, Remotes)
            KeyEvent.KEYCODE_VOLUME_DOWN,
            KeyEvent.KEYCODE_CAMERA,
            KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE,
            KeyEvent.KEYCODE_ENTER -> if (isExternal || isStylusSource) 1 else null

            KeyEvent.KEYCODE_VOLUME_UP,
            KeyEvent.KEYCODE_MEDIA_NEXT -> if (isExternal || isStylusSource) 2 else null

            KeyEvent.KEYCODE_MEDIA_PREVIOUS -> if (isExternal || isStylusSource) 3 else null

            else -> null
        }

        if (button != null) {
            if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
                methodChannel?.invokeMethod("stylusButton", button)
            }
            return true
        }

        return super.dispatchKeyEvent(event)
    }
}
