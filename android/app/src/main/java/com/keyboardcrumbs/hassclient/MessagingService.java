package com.keyboardcrumbs.hassclient;

import java.util.Map;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;


public class MessagingService extends FirebaseMessagingService {

    private static final String TAG = "MessagingService";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d(TAG, "From: " + remoteMessage.getFrom());
        Map<String, String> data = remoteMessage.getData();
        if (data.size() > 0) {
           Log.d(TAG, "Message data payload: " + data);
           if (data.containsKey("body") || data.containsKey("title")) {
                sendNotification(
                    data.get("body"),
                    data.get("title"),
                    data.get("channelId"),
                    data.get("action1"),
                    data.get("action2"),
                    data.get("action3")
                    );
           }
        }
    }

    @Override
    public void onNewToken(String token) {
        Log.d(TAG, "Refreshed token: " + token);
        //TODO update token
    }

    private void executeAction() {
        OneTimeWorkRequest work = new OneTimeWorkRequest.Builder(NotificationActionWorker.class)
                .build();
        WorkManager.getInstance().beginWith(work).enqueue();
    }

    private void sendNotification(String messageBody, String messageTitle, String channelId, String action1, String action2, String action3) {
        if (channelId == null) {
            channelId = "ha_notify";
        }
        if (messageBody == null) {
            messageBody = "";
        }
        if (messageTitle == null) {
            messageTitle = "HA Client";
        }
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);
        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(this, channelId)
                        .setSmallIcon(R.drawable.mini_icon)
                        .setContentTitle(messageTitle)
                        .setContentText(messageBody)
                        .setAutoCancel(false)
                        .setSound(defaultSoundUri)
                        .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(channelId,
                    "Home Assistant notifications",
                    NotificationManager.IMPORTANCE_DEFAULT);
            notificationManager.createNotificationChannel(channel);
        }

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }
}