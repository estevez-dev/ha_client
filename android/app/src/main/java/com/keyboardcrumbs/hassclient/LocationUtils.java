package com.keyboardcrumbs.hassclient;

import android.app.Notification;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.os.Build;

import androidx.core.app.NotificationCompat;
import androidx.work.ExistingPeriodicWorkPolicy;
import androidx.work.ExistingWorkPolicy;
import androidx.work.OneTimeWorkRequest;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;

import java.text.DateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;

class LocationUtils {

    static final String KEY_REQUESTING_LOCATION_UPDATES = "flutter.location-updates-state";
    static final String KEY_LOCATION_UPDATE_INTERVAL = "flutter.location-updates-interval";
    static final String KEY_LOCATION_SHOW_NOTIFICATION = "flutter.location-updates-show-notification";

    static final String WORKER_NOTIFICATION_CHANNEL_ID = "location_worker";
    static final int WORKER_NOTIFICATION_ID = 954322;
    static final String SERVICE_NOTIFICATION_CHANNEL_ID = "location_service";
    static final int SERVICE_NOTIFICATION_ID = 954311;
    static final String ONETIME_NOTIFICATION_CHANNEL_ID = "location_request";
    static final int ONETIME_NOTIFICATION_ID = 954333;

    static final String REQUEST_LOCATION_NOTIFICATION = "request_location_update";

    static final String LOCATION_WORK_NAME = "HALocationWorker";
    static final String LOCATION_REQUEST_NAME = "HALocationRequest";

    static final int LOCATION_UPDATES_DISABLED = 0;
    static final int LOCATION_UPDATES_SERVICE = 1;
    static final int LOCATION_UPDATES_WORKER = 2;

    static final int DEFAULT_LOCATION_UPDATE_INTERVAL_MS = 900000; //15 minutes
    static final long MIN_WORKER_LOCATION_UPDATE_INTERVAL_MS = 900000; //15 minutes

    static int getLocationUpdatesState(Context context) {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getInt(KEY_REQUESTING_LOCATION_UPDATES, LOCATION_UPDATES_DISABLED);
    }

    static long getLocationUpdateIntervals(Context context) {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getLong(KEY_LOCATION_UPDATE_INTERVAL, DEFAULT_LOCATION_UPDATE_INTERVAL_MS);
    }

    static boolean showNotification(Context context) {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getBoolean(KEY_LOCATION_SHOW_NOTIFICATION, true);
    }

    static void setLocationUpdatesState(Context context, int locationUpdatesState) {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .edit()
                .putInt(KEY_REQUESTING_LOCATION_UPDATES, locationUpdatesState)
                .apply();
    }

    static void setLocationUpdatesSettings(Context context, long interval, boolean showNotification) {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_LOCATION_SHOW_NOTIFICATION, showNotification)
                .putLong(KEY_LOCATION_UPDATE_INTERVAL, interval)
                .apply();
    }

    static void startService(Context context) {
        Intent myService = new Intent(context, LocationUpdatesService.class);
        context.startService(myService);
    }

    static void startServiceFromBroadcast(Context context) {
        Intent serviceIntent = new Intent(context, LocationUpdatesService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent);
        } else {
            context.startService(serviceIntent);
        }
    }

    static void startWorker(Context context, long interval) {
        PeriodicWorkRequest periodicWork = new PeriodicWorkRequest.Builder(LocationUpdatesWorker.class, interval, TimeUnit.MILLISECONDS)
                .build();
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(LocationUtils.LOCATION_WORK_NAME, ExistingPeriodicWorkPolicy.REPLACE, periodicWork);
    }

    static void requestLocationOnce(Context context) {
        Intent myService = new Intent(context, LocationRequestService.class);
        context.startService(myService);
        //OneTimeWorkRequest oneTimeWork = new OneTimeWorkRequest.Builder(LocationUpdatesWorker.class)
        //        .build();
        //WorkManager.getInstance(context).enqueueUniqueWork(LocationUtils.LOCATION_REQUEST_NAME, ExistingWorkPolicy.REPLACE, oneTimeWork);
    }

    static Notification getNotification(Context context, Location location, String channelId) {
        CharSequence title = "Location tracking";
        CharSequence text = location == null ? "Accuracy: unknown" : "Accuracy: " + location.getAccuracy() + " m";
        CharSequence bigText = location == null ? "Waiting for location..." : "Time: " + DateFormat.getDateTimeInstance().format(new Date(location.getTime())) +
                System.getProperty("line.separator") + "Accuracy: " + location.getAccuracy() + " m" +
                System.getProperty("line.separator") + "Location: " + location.getLatitude() + ", " + location.getLongitude();

                PendingIntent activityPendingIntent = PendingIntent.getActivity(context, 0,
                new Intent(context, MainActivity.class), 0);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelId)
                .setContentIntent(activityPendingIntent)
                .setContentTitle(title)
                .setContentText(text)
                .setStyle(new NotificationCompat.BigTextStyle()
                        .bigText(bigText))
                .setPriority(-1)
                .setOngoing(true)
                .setSmallIcon(R.drawable.mini_icon_location)
                .setWhen(System.currentTimeMillis());

        return builder.build();
    }

    static Notification getRequestNotification(Context context, Location location, String channelId) {
        CharSequence title = "Updating location...";
        CharSequence text = location == null ? "Waiting for location..." : "Accuracy: " + location.getAccuracy() + " m";

        PendingIntent activityPendingIntent = PendingIntent.getActivity(context, 0,
                new Intent(context, MainActivity.class), 0);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelId)
                .setContentIntent(activityPendingIntent)
                .setContentTitle(title)
                .setContentText(text)
                .setPriority(-1)
                .setOngoing(true)
                .setSmallIcon(R.drawable.mini_icon_location)
                .setWhen(System.currentTimeMillis());

        return builder.build();
    }
}
