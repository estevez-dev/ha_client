package com.keyboardcrumbs.hassclient;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Build;
import android.os.IBinder;

public class Autostart extends BroadcastReceiver {

    public void onReceive(Context context, Intent intent) {
        if (Utils.requestingLocationUpdates(context) && Intent.ACTION_BOOT_COMPLETED.equalsIgnoreCase(intent.getAction())) {
            Intent serviceIntent = new Intent(context, LocationUpdatesService.class);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent);
            } else {
                context.startService(serviceIntent);
            }
        }
    }
}