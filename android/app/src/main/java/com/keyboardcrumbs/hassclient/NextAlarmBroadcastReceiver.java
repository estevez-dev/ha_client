package com.keyboardcrumbs.hassclient;

import android.app.AlarmManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.Data;
import androidx.work.ExistingWorkPolicy;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;

import java.util.concurrent.TimeUnit;


public class NextAlarmBroadcastReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) {
            return;
        }

        final boolean isBootIntent = Intent.ACTION_BOOT_COMPLETED.equalsIgnoreCase(intent.getAction());
        final boolean isNextAlarmIntent = AlarmManager.ACTION_NEXT_ALARM_CLOCK_CHANGED.equalsIgnoreCase(intent.getAction());
        if (!isBootIntent && !isNextAlarmIntent) {
            return;
        }
        Constraints constraints = new Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build();

        Data workerData = new Data.Builder()
                .putInt(SendDataHomeWorker.DATA_TYPE_KEY, SendDataHomeWorker.DATA_TYPE_NEXT_ALARM)
                .build();

        OneTimeWorkRequest uploadWorkRequest =
                new OneTimeWorkRequest.Builder(SendDataHomeWorker.class)
                        .setBackoffCriteria(
                                BackoffPolicy.EXPONENTIAL,
                                10,
                                TimeUnit.SECONDS)
                        .setInputData(workerData)
                        .setConstraints(constraints)
                        .build();

        WorkManager
                .getInstance(context)
                .enqueueUniqueWork("NextAlarmUpdate", ExistingWorkPolicy.REPLACE, uploadWorkRequest);
    }
}