package com.keyboardcrumbs.hassclient;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class LocationUpdatesAfterReboot extends BroadcastReceiver {

    public void onReceive(Context context, Intent intent) {
        if (LocationUtils.getLocationUpdatesState(context) == LocationUtils.LOCATION_UPDATES_SERVICE && Intent.ACTION_BOOT_COMPLETED.equalsIgnoreCase(intent.getAction())) {
            LocationUtils.startServiceFromBroadcast(context);
        }
    }
}