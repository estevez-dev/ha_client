package com.keyboardcrumbs.hassclient;

import android.content.Context;
import android.location.Location;
import android.preference.PreferenceManager;

import java.text.DateFormat;
import java.util.Date;

class Utils {

    static final String KEY_REQUESTING_LOCATION_UPDATES = "flutter.foreground-location-service";
    static final String KEY_LOCATION_UPDATE_INTERVAL = "flutter.active-location-interval";

    static boolean requestingLocationUpdates(Context context) {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getBoolean(KEY_REQUESTING_LOCATION_UPDATES, false);
    }

    static long getLocationUpdateIntervals(Context context) {
        return context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getLong(KEY_LOCATION_UPDATE_INTERVAL, 90) * 1000;
    }

    static void setRequestingLocationUpdates(Context context, boolean requestingLocationUpdates) {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_REQUESTING_LOCATION_UPDATES, requestingLocationUpdates)
                .apply();
    }

    static String getLocationText(Location location) {
        return location == null ? "Accuracy: unknown" :
                "Accuracy: " + location.getAccuracy();
    }

    static String getLocationTitle(Location location) {
        return location == null ? "Requesting location..." : "Location updated at " + DateFormat.getDateTimeInstance().format(new Date(location.getTime()));
    }
}
