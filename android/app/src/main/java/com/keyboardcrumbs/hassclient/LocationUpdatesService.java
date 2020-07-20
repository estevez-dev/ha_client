package com.keyboardcrumbs.hassclient;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.location.Location;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;

import androidx.annotation.Nullable;
import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.Data;
import androidx.work.ExistingWorkPolicy;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;

import android.util.Log;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;

import java.util.concurrent.TimeUnit;

public class LocationUpdatesService extends Service {

    private static final String TAG = LocationUpdatesService.class.getSimpleName();

    private NotificationManager mNotificationManager;

    private LocationRequest mLocationRequest;

    private FusedLocationProviderClient mFusedLocationClient;

    private LocationCallback mLocationCallback;

    private Handler mServiceHandler;

    public LocationUpdatesService() {
    }

    @Override
    public void onCreate() {
        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                onNewLocation(locationResult.getLastLocation());
            }
        };

        mLocationRequest = new LocationRequest();

        HandlerThread handlerThread = new HandlerThread(TAG);
        handlerThread.start();
        mServiceHandler = new Handler(handlerThread.getLooper());
        mNotificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "Location updates";
            NotificationChannel mChannel =
                    new NotificationChannel(LocationUtils.SERVICE_NOTIFICATION_CHANNEL_ID, name, NotificationManager.IMPORTANCE_LOW);

            mNotificationManager.createNotificationChannel(mChannel);
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "Service started");

        requestLocationUpdates();

        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        try {
            mFusedLocationClient.removeLocationUpdates(mLocationCallback);
        } catch (SecurityException unlikely) {
            //When we lost permission
            Log.i(TAG, "No location permission");
        }
        mServiceHandler.removeCallbacksAndMessages(null);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void requestLocationUpdates() {
        long requestInterval = LocationUtils.getLocationUpdateIntervals(getApplicationContext());
        int priority;
        if (requestInterval >= 600000) {
            mLocationRequest.setFastestInterval(60000);
            priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY;
        } else {
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY;
        }
        mLocationRequest.setPriority(priority);
        mLocationRequest.setInterval(requestInterval);
        Log.i(TAG, "Requesting location updates. Every " + requestInterval + "ms with priority of " + priority);
        startForeground(LocationUtils.SERVICE_NOTIFICATION_ID, LocationUtils.getNotification(this, null, LocationUtils.SERVICE_NOTIFICATION_CHANNEL_ID));
        try {
            mFusedLocationClient.requestLocationUpdates(mLocationRequest,
                    mLocationCallback, Looper.myLooper());
        } catch (SecurityException unlikely) {
            stopSelf();
        }
    }

    private void onNewLocation(Location location) {
        Log.i(TAG, "New location: " + location);

        mNotificationManager.notify(LocationUtils.SERVICE_NOTIFICATION_ID, LocationUtils.getNotification(this, location, LocationUtils.SERVICE_NOTIFICATION_CHANNEL_ID));

        Constraints constraints = new Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build();

        Data locationData = new Data.Builder()
                .putInt(SendDataHomeWorker.DATA_TYPE_KEY, SendDataHomeWorker.DATA_TYPE_LOCATION)
                .putDouble("Lat", location.getLatitude())
                .putDouble("Long", location.getLongitude())
                .putFloat("Acc", location.getAccuracy())
                .build();


        OneTimeWorkRequest uploadWorkRequest =
                new OneTimeWorkRequest.Builder(SendDataHomeWorker.class)
                        .setConstraints(constraints)
                        .setInputData(locationData)
                        .build();

        WorkManager
                .getInstance(getApplicationContext())
                .enqueueUniqueWork("SendLocationUpdate", ExistingWorkPolicy.REPLACE, uploadWorkRequest);
    }
}