package com.keyboardcrumbs.hassclient;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;

import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import android.os.IBinder;

import io.flutter.plugin.common.MethodChannel;

import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.ConnectionResult;
import com.google.firebase.iid.FirebaseInstanceId;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.keyboardcrumbs.hassclient/native";

    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;

    private LocationUpdatesService mService = null;

    private boolean mBound = false;

    private final ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            LocationUpdatesService.LocalBinder binder = (LocationUpdatesService.LocalBinder) service;
            mService = binder.getService();
            mBound = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mService = null;
            mBound = false;
        }
    };

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
                                                UpdateTokenTask updateTokenTask = new UpdateTokenTask(context);
                                                updateTokenTask.execute(token);
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
                            if (isNoLocationPermissions()) {
                                requestLocationPermissions();
                            } else {
                                mService.requestLocationUpdates();
                            }
                            result.success("");
                            break;
                        case "stopLocationService":
                            mService.removeLocationUpdates();
                            result.success("");
                            break;
                    }
                }
        );
    }

    private boolean checkPlayServices() {
        return (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(this) == ConnectionResult.SUCCESS);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        /*if (Utils.requestingLocationUpdates(this)) {
            if (isNoLocationPermissions()) {
                requestLocationPermissions();
            }
        }*/
    }

    @Override
    protected void onStart() {
        super.onStart();
        bindService(new Intent(this, LocationUpdatesService.class), mServiceConnection,
                Context.BIND_AUTO_CREATE);
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
        if (mBound) {
            unbindService(mServiceConnection);
            mBound = false;
        }
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
                mService.requestLocationUpdates();
            }
        }
    }

}
