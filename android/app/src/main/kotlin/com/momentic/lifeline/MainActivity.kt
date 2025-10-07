package com.momentic.lifeline

import android.os.Build
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity

// ВАЖНО: Класс должен наследоваться от FlutterFragmentActivity,
// а не от FlutterActivity, для корректной работы плагина local_auth.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Android 15+ Edge-to-Edge enforcement
        // enableEdgeToEdge() automatically handles:
        // - setStatusBarColor (deprecated)
        // - setNavigationBarColor (deprecated)
        // - setNavigationBarDividerColor (deprecated)
        // - LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES (deprecated)
        // API 35 = Android 15 (VANILLA_ICE_CREAM)
        if (Build.VERSION.SDK_INT >= 35) {
            enableEdgeToEdge()
        } else {
            // For Android 14 and below, use the traditional approach
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
}

