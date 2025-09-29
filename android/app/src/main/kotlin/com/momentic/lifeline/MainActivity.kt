package com.momentic.lifeline

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity

// ВАЖНО: Класс должен наследоваться от FlutterFragmentActivity,
// а не от FlutterActivity, для корректной работы плагина local_auth.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}

