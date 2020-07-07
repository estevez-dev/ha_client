package com.keyboardcrumbs.hassclient;

import android.content.Context;
import android.content.BroadcastReceiver;
import android.content.Intent;

import android.app.NotificationManager;

import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.Data;
import androidx.work.ExistingWorkPolicy;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;

import java.util.concurrent.TimeUnit;

public class NotificationActionReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) {
            return;
        }
        String intentAction = intent.getAction();
        if (intentAction == null || !intentAction.equalsIgnoreCase(MessagingService.NOTIFICATION_ACTION_BROADCAST)) {
            return;
        }
        String rawActionData = intent.getStringExtra("actionData");
        if (intent.hasExtra("tag")) {
            String notificationTag = intent.getStringExtra("tag");
            NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancel(notificationTag, 0);
        }
        Constraints constraints = new Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build();
        Data workerData = new Data.Builder()
                .putInt(SendDataHomeWorker.DATA_TYPE_KEY, SendDataHomeWorker.DATA_TYPE_NOTIFICATION_ACTION)
                .putString("rawActionData", rawActionData)
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
                .enqueueUniqueWork("NotificationAction", ExistingWorkPolicy.APPEND, uploadWorkRequest);
    }
}