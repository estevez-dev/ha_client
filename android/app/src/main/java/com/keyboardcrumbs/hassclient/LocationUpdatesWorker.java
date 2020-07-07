package com.keyboardcrumbs.hassclient;

import android.content.Context;
import android.location.Location;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.concurrent.futures.CallbackToFutureAdapter;
import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.Data;
import androidx.work.ExistingWorkPolicy;
import androidx.work.ListenableWorker;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.WorkerParameters;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.common.util.concurrent.ListenableFuture;

import java.util.concurrent.TimeUnit;

public class LocationUpdatesWorker extends ListenableWorker {

    private Context currentContext;
    private LocationCallback callback;
    private FusedLocationProviderClient fusedLocationClient;

    public LocationUpdatesWorker(Context context, WorkerParameters params) {
        super(context, params);
        currentContext = context;
    }

    private void finish() {
        fusedLocationClient.removeLocationUpdates(callback);
    }



    @NonNull
    @Override
    public ListenableFuture<Result> startWork() {
        return CallbackToFutureAdapter.getFuture(completer -> {
            fusedLocationClient = LocationServices.getFusedLocationProviderClient(currentContext);

            callback = new LocationCallback() {
                @Override
                public void onLocationResult(LocationResult locationResult) {
                    super.onLocationResult(locationResult);
                    Location location = locationResult.getLastLocation();
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
                    finish();
                    completer.set(Result.success());
                }
            };

            LocationRequest locationRequest = new LocationRequest();
            int accuracy = LocationUtils.getLocationUpdatesPriority(getApplicationContext());
            locationRequest.setPriority(accuracy);
            locationRequest.setInterval(5000);
            locationRequest.setFastestInterval(1000);
            try {
                fusedLocationClient.requestLocationUpdates(locationRequest,
                        callback, Looper.myLooper());
            } catch (SecurityException e) {
                completer.setException(e);
            }
            return callback;
        });
    }
}
