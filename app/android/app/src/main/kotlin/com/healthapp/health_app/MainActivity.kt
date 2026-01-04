package com.healthapp.health_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var aiCoreChannel: AiCoreChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize AI Core platform channel
        aiCoreChannel = AiCoreChannel(
            context = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        aiCoreChannel?.dispose()
        aiCoreChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
