package com.keyboardcrumbs.hassclient;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;

public class Autostart extends BroadcastReceiver {

    private PendingResult result;

    private final ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            LocationUpdatesService.LocalBinder binder = (LocationUpdatesService.LocalBinder) service;
            binder.getService().requestLocationUpdates();
            result.finish();
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {

        }

    };

    public void onReceive(Context context, Intent intent) {
        if (/*Utils.requestingLocationUpdates(context) && */Intent.ACTION_BOOT_COMPLETED.equalsIgnoreCase(intent.getAction())) {
            context.getApplicationContext().bindService(new Intent(context, LocationUpdatesService.class), mServiceConnection,
                    Context.BIND_AUTO_CREATE);
            result = goAsync();
        }
    }
}