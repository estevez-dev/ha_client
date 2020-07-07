package com.keyboardcrumbs.hassclient;

import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.os.Build;

import androidx.work.ExistingPeriodicWorkPolicy;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;

import java.text.DateFormat;
import java.util.Date;
import java.util.concurrent.TimeUnit;

class LocationUtils {

    static final String KEY_REQUESTING_LOCATION_UPDATES = "flutter.location-updates-state";
    static final String KEY_LOCATION_UPDATE_INTERVAL = "flutter.location-updates-interval";
    static final String KEY_LOCATION_UPDATE_PRIORITY = "flutter.location-updates-priority";

    static final String LOCATION_WORK_NAME = "HALocationWorker";

    static final int LOCATION_UPDATES_DISABLED = 0;
    static final int LOCATION_UPDATES_SERVICE = 1;
    static final int LOCATION_UPDATES_WORKER = 2;

    static final int DEFAULT_LOCATION_UPDATE_INTERVAL_S = 900; //15 minutes
    static final long MIN_WORKER_LOCATION_UPDATE_INTERVAL_MS = 900000; //15 minutes

    static int getLocationUpdatesState(Context context) {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getInt(KEY_REQUESTING_LOCATION_UPDATES, LOCATION_UPDATES_DISABLED);
    }

    static long getLocationUpdateIntervals(Context context) {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getLong(KEY_LOCATION_UPDATE_INTERVAL, DEFAULT_LOCATION_UPDATE_INTERVAL_S) * 1000;
    }

    static int getLocationUpdatesPriority(Context context) {
        return (int) context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getLong(KEY_LOCATION_UPDATE_PRIORITY, 102);
    }

    static void setLocationUpdatesState(Context context, int locationUpdatesState) {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .edit()
                .putInt(KEY_REQUESTING_LOCATION_UPDATES, locationUpdatesState)
                .apply();
    }

    static String getLocationText(Location location) {
        return location == null ? "Accuracy: unknown" :
                "Accuracy: " + location.getAccuracy();
    }

    static String getLocationTitle(Location location) {
        return location == null ? "Requesting location..." : "Location updated at " + DateFormat.getDateTimeInstance().format(new Date(location.getTime()));
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
}
