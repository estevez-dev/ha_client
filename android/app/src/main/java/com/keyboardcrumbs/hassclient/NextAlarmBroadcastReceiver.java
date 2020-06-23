package com.keyboardcrumbs.hassclient;

import android.app.AlarmManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.ExistingWorkPolicy;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.WorkRequest;

import java.util.concurrent.TimeUnit;


public class NextAlarmBroadcastReceiver extends BroadcastReceiver {

    private static final String TAG = "NextAlarmReceiver";

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

        OneTimeWorkRequest uploadWorkRequest =
                new OneTimeWorkRequest.Builder(UpdateNextAlarmWorker.class)
                        .setBackoffCriteria(
                                BackoffPolicy.EXPONENTIAL,
                                10,
                                TimeUnit.SECONDS)
                        .setConstraints(constraints)
                        .build();

        WorkManager
                .getInstance(context)
                .enqueueUniqueWork("NextAlarmUpdate", ExistingWorkPolicy.REPLACE, uploadWorkRequest);
    }
}