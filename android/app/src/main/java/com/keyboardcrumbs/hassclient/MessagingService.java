package com.keyboardcrumbs.hassclient;

import java.util.Map;
import java.net.URL;
import java.net.URLConnection;
import java.io.IOException;
import java.io.InputStream;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.webkit.URLUtil;


public class MessagingService extends FirebaseMessagingService {

    private static final String TAG = "MessagingService";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Map<String, String> data = remoteMessage.getData();
        if (data.size() > 0) {
           if (data.containsKey("body") || data.containsKey("title")) {
                sendNotification(data);
           }
        }
    }

    @Override
    public void onNewToken(String token) {
        //TODO update token
    }

    private void sendNotification(Map<String, String> data) {
        String channelId, messageBody, messageTitle, imageUrl, nTag, channelDescription;
        boolean autoCancel;
        if (!data.containsKey("channelId")) {
            channelId = "ha_notify";
            channelDescription = "Default notification channel";
        } else {
            channelId = data.get("channelId");
            channelDescription = channelId;
        }
        if (!data.containsKey("body")) {
            messageBody = "";
        } else {
            messageBody = data.get("body");
        }
        if (!data.containsKey("title")) {
            messageTitle = "HA Client";
        } else {
            messageTitle = data.get("title");
        }
        if (!data.containsKey("tag")) {
            nTag = String.valueOf(System.currentTimeMillis());
        } else {
            nTag = data.get("tag");
        }
        if (data.containsKey("dismiss")) {
            try {
                boolean dismiss = Boolean.parseBoolean(data.get("dismiss"));
                if (dismiss) {
                    NotificationManager notificationManager =
                        (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                    notificationManager.cancel(nTag, 0);
                    return;
                }
            } catch (Exception e) {
                //nope
            }
        }
        if (data.containsKey("autoDismiss")) {
            try {
                autoCancel = Boolean.parseBoolean(data.get("autoDismiss"));
            } catch (Exception e) {
                autoCancel = true;
            }
        } else {
            autoCancel = true;
        }
        imageUrl = data.get("image");
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
                        .setAutoCancel(autoCancel)
                        .setSound(defaultSoundUri)
                        .setContentIntent(pendingIntent);
        if (URLUtil.isValidUrl(imageUrl)) {
            Bitmap image = getBitmapFromURL(imageUrl);
            if (image != null) {
                notificationBuilder.setStyle(new NotificationCompat.BigPictureStyle().bigPicture(image).bigLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.blank_icon)));
                notificationBuilder.setLargeIcon(image);
            }
        }
        for (int i = 1; i <= 3; i++) {
            if (data.containsKey("action" + i)) {
                Intent broadcastIntent = new Intent(this, NotificationActionReceiver.class);
                if (autoCancel) {
                    broadcastIntent.putExtra("tag", nTag);
                }
                broadcastIntent.putExtra("actionData", data.get("action" + i + "_data"));
                PendingIntent actionIntent = PendingIntent.getBroadcast(this, i, broadcastIntent, PendingIntent.FLAG_CANCEL_CURRENT);
                notificationBuilder.addAction(R.drawable.mini_icon, data.get("action" + i), actionIntent);
            }   
        }
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(channelId,
                    channelDescription,
                    NotificationManager.IMPORTANCE_HIGH);
            notificationManager.createNotificationChannel(channel);
        }

        notificationManager.notify(nTag, 0 /* ID of notification */, notificationBuilder.build());
    }

    private Bitmap getBitmapFromURL(String imageUrl) {
        try {
            URL url = new URL(imageUrl);
            URLConnection connection = url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            return BitmapFactory.decodeStream(input);
        } catch (IOException e) {
            return null;
        }
    }
}