package com.chijia.flutter_one_btn_call_car

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import io.flutter.app.FlutterApplication

class Application : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()

            // 預設 channel：ding_dong（其他通知用）
            val defaultChannel = NotificationChannel(
                "default_notification_channel",
                "一鍵叫車通知",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "接收叫車相關通知"
                setSound(Uri.parse("android.resource://${packageName}/raw/ding_dong"), audioAttributes)
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                enableLights(true)
            }
            notificationManager.createNotificationChannel(defaultChannel)

            // got_a_driver channel：司機已接單、司機抵達（需後端指定 channel_id）
            val gotADriverChannel = NotificationChannel(
                "got_a_driver_channel",
                "司機接單/抵達通知",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "司機已接單或司機抵達時的通知"
                setSound(Uri.parse("android.resource://${packageName}/raw/got_a_driver"), audioAttributes)
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                enableLights(true)
            }
            notificationManager.createNotificationChannel(gotADriverChannel)
        }
    }
}

