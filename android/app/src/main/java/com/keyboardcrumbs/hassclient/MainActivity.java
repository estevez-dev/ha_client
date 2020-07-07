package com.keyboardcrumbs.hassclient;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.work.WorkManager;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.Manifest;
import android.app.NotificationManager;
import android.content.Context;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;

import io.flutter.plugin.common.MethodChannel;

import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.ConnectionResult;
import com.google.firebase.iid.FirebaseInstanceId;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.keyboardcrumbs.hassclient/native";

    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;

    private int locationUpdatesType = LocationUtils.LOCATION_UPDATES_DISABLED;
    private long locationUpdatesInterval = LocationUtils.DEFAULT_LOCATION_UPDATE_INTERVAL_S * 1000;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    Context context = getActivity();
                    switch (call.method) {
                        case "getFCMToken":
                            if (checkPlayServices()) {
                                FirebaseInstanceId.getInstance().getInstanceId()
                                        .addOnCompleteListener(task -> {
                                            if (task.isSuccessful()) {
                                                String token = task.getResult().getToken();
                                                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).edit().putString("flutter.npush-token", token).apply();
                                                result.success(token);
                                            } else {
                                                Exception ex = task.getException();
                                                if (ex != null) {
                                                    result.error("fcm_error", ex.getMessage(), null);
                                                } else {
                                                    result.error("fcm_error", "Unknown", null);
                                                }

                                            }
                                        });
                            } else {
                                result.error("google_play_service_error", "Google Play Services unavailable", null);
                            }
                            break;
                        case "startLocationService":
                            try {
                                locationUpdatesInterval = LocationUtils.getLocationUpdateIntervals(this);
                                if (locationUpdatesInterval >= LocationUtils.MIN_WORKER_LOCATION_UPDATE_INTERVAL_MS) {
                                    locationUpdatesType = LocationUtils.LOCATION_UPDATES_WORKER;
                                } else {
                                    locationUpdatesType = LocationUtils.LOCATION_UPDATES_SERVICE;
                                }
                                if (isNoLocationPermissions()) {
                                    requestLocationPermissions();
                                } else {
                                    startLocationUpdates();
                                }
                                result.success("");
                            } catch (Exception e) {
                                result.error("location_error", e.getMessage(), null);
                            }
                            break;
                        case "stopLocationService":
                            stopLocationUpdates();
                            result.success("");
                            break;
                        case "cancelOldLocationWorker":
                            WorkManager.getInstance(this).cancelAllWorkByTag("haclocation");
                            result.success("");
                            break;
                    }
                }
        );
    }

    private boolean checkPlayServices() {
        return (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(this) == ConnectionResult.SUCCESS);
    }

    private void startLocationUpdates() {
        if (locationUpdatesType == LocationUtils.LOCATION_UPDATES_SERVICE) {
            LocationUtils.startService(this);
            LocationUtils.setLocationUpdatesState(this, locationUpdatesType);
        } else if (locationUpdatesType == LocationUtils.LOCATION_UPDATES_WORKER) {
            LocationUtils.startWorker(this, locationUpdatesInterval);
            LocationUtils.setLocationUpdatesState(this, locationUpdatesType);
        } else {
            stopLocationUpdates();
        }
    }

    private void stopLocationUpdates() {
        Intent myService = new Intent(MainActivity.this, LocationUpdatesService.class);
        stopService(myService);
        WorkManager.getInstance(this).cancelUniqueWork(LocationUtils.LOCATION_WORK_NAME);
        NotificationManager notificationManager;
        if (android.os.Build.VERSION.SDK_INT >= 23) {
            notificationManager = getSystemService(NotificationManager.class);
        } else {
            notificationManager = (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
        }
        notificationManager.cancel(LocationUtils.WORKER_NOTIFICATION_ID);
        LocationUtils.setLocationUpdatesState(this, LocationUtils.LOCATION_UPDATES_DISABLED);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    private boolean isNoLocationPermissions() {
        return PackageManager.PERMISSION_GRANTED != ActivityCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION);
    }

    private void requestLocationPermissions() {
        ActivityCompat.requestPermissions(MainActivity.this,
                new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                REQUEST_PERMISSIONS_REQUEST_CODE);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        if (requestCode == REQUEST_PERMISSIONS_REQUEST_CODE) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startLocationUpdates();
            } else {
                stopLocationUpdates();
            }
        }
    }

}
