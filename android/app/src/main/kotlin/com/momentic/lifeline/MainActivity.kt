package com.momentic.lifeline

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity

// ВАЖНО: Класс должен наследоваться от FlutterFragmentActivity,
// а не от FlutterActivity, для корректной работы плагина local_auth.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Edge-to-Edge rendering for all Android versions
        // Android 15+ uses windowOptOutEdgeToEdgeEnforcement in styles-v35.xml
        // to temporarily suppress deprecated API warnings until Android 16 migration
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}

