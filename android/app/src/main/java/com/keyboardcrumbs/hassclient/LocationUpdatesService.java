package com.keyboardcrumbs.hassclient;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.location.Location;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
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

    private static final String PACKAGE_NAME =
            "com.keyboardcrumbs.hassclient";

    private static final String TAG = LocationUpdatesService.class.getSimpleName();

    private static final String CHANNEL_ID = "location_service";

    private static final String EXTRA_STARTED_FROM_NOTIFICATION = PACKAGE_NAME +
            ".started_from_notification";

    //private final IBinder mBinder = new LocalBinder();

    private static final int NOTIFICATION_ID = 954311;

    private NotificationManager mNotificationManager;

    private LocationRequest mLocationRequest;

    private FusedLocationProviderClient mFusedLocationClient;

    private LocationCallback mLocationCallback;

    private Handler mServiceHandler;

    private Location mLocation;

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
        mLocationRequest.setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);

        getLastLocation();

        HandlerThread handlerThread = new HandlerThread(TAG);
        handlerThread.start();
        mServiceHandler = new Handler(handlerThread.getLooper());
        mNotificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "Location updates";
            NotificationChannel mChannel =
                    new NotificationChannel(CHANNEL_ID, name, NotificationManager.IMPORTANCE_LOW);

            mNotificationManager.createNotificationChannel(mChannel);
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "Service started");
        boolean startedFromNotification = intent.getBooleanExtra(EXTRA_STARTED_FROM_NOTIFICATION,
                false);

        // We got here because the user decided to remove location updates from the notification.
        if (startedFromNotification) {
            stopSelf();
        } else {
            requestLocationUpdates();
        }

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
        long requestInterval = Utils.getLocationUpdateIntervals(getApplicationContext());
        Log.i(TAG, "Requesting location updates. Interval is " + requestInterval);
        mLocationRequest.setInterval(requestInterval);
        mLocationRequest.setFastestInterval(requestInterval);
        startForeground(NOTIFICATION_ID, getNotification());
        try {
            mFusedLocationClient.requestLocationUpdates(mLocationRequest,
                    mLocationCallback, Looper.myLooper());
        } catch (SecurityException unlikely) {
            stopSelf();
        }
    }

    private Notification getNotification() {
        Intent intent = new Intent(this, LocationUpdatesService.class);

        CharSequence text = Utils.getLocationText(mLocation);

        intent.putExtra(EXTRA_STARTED_FROM_NOTIFICATION, true);

        PendingIntent servicePendingIntent = PendingIntent.getService(this, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT);

        PendingIntent activityPendingIntent = PendingIntent.getActivity(this, 0,
                new Intent(this, MainActivity.class), 0);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .addAction(R.drawable.blank_icon, "Open HA Client",
                        activityPendingIntent)
                .addAction(R.drawable.blank_icon, "Stop",
                        servicePendingIntent)
                .setContentText(text)
                .setPriority(-1)
                .setContentTitle(Utils.getLocationTitle(mLocation))
                .setOngoing(true)
                .setSmallIcon(R.drawable.mini_icon)
                .setWhen(System.currentTimeMillis());

        return builder.build();
    }

    private void getLastLocation() {
        try {
            mFusedLocationClient.getLastLocation()
                    .addOnCompleteListener(task -> {
                        if (task.isSuccessful() && task.getResult() != null) {
                            mLocation = task.getResult();
                        } else {
                            Log.w(TAG, "Failed to get location.");
                        }
                    });
        } catch (SecurityException unlikely) {
            Log.e(TAG, "Lost location permission." + unlikely);
        }
    }

    private void onNewLocation(Location location) {
        Log.i(TAG, "New location: " + location);

        mLocation = location;

        mNotificationManager.notify(NOTIFICATION_ID, getNotification());

        Constraints constraints = new Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build();

        Data locationData = new Data.Builder()
                .putDouble("Lat", mLocation.getLatitude())
                .putDouble("Long", mLocation.getLongitude())
                .putFloat("Acc", mLocation.getAccuracy())
                .build();


        OneTimeWorkRequest uploadWorkRequest =
                new OneTimeWorkRequest.Builder(SendLocationWorker.class)
                        .setBackoffCriteria(
                                BackoffPolicy.EXPONENTIAL,
                                10,
                                TimeUnit.SECONDS)
                        .setConstraints(constraints)
                        .setInputData(locationData)
                        .build();

        WorkManager
                .getInstance(getApplicationContext())
                .enqueueUniqueWork("SendLocationUpdate", ExistingWorkPolicy.REPLACE, uploadWorkRequest);
    }
}