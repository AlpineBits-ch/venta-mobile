package gg.venta.mobile

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val screenShareChannel = "venta/screen_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, screenShareChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Started/stopped immediately before/after flutter_webrtc's
                    // getDisplayMedia — see ScreenCaptureService for why this
                    // is required at all.
                    "start" -> {
                        startForegroundService(Intent(this, ScreenCaptureService::class.java))
                        result.success(null)
                    }
                    "stop" -> {
                        stopService(Intent(this, ScreenCaptureService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
