package gg.venta.mobile

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

/**
 * Minimal foreground service whose sole purpose is satisfying Android's
 * requirement (enforced since Android 10, strict about
 * `foregroundServiceType="mediaProjection"` since Android 14) that a
 * foreground service of that type already be running before
 * `MediaProjection` capture is allowed to start. flutter_webrtc's
 * `getDisplayMedia` calls `MediaProjectionManager` directly without starting
 * one itself — the app has to. Started right before, and stopped right
 * after, screen-share capture from Dart via the `venta/screen_share`
 * `MethodChannel` registered in [MainActivity].
 */
class ScreenCaptureService : Service() {
    companion object {
        private const val CHANNEL_ID = "screen_share"
        private const val NOTIFICATION_ID = 4201
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startInForeground()
        return START_NOT_STICKY
    }

    private fun startInForeground() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "Screen sharing",
                    NotificationManager.IMPORTANCE_LOW,
                )
            )
        }
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Venta")
            .setContentText("Screen sharing")
            .setSmallIcon(applicationInfo.icon)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ServiceCompat.startForeground(
                this,
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }
}
