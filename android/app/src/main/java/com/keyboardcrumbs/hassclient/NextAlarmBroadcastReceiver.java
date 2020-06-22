package com.keyboardcrumbs.hassclient;

import android.app.AlarmManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import android.webkit.URLUtil;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

import org.json.JSONArray;
import org.json.JSONObject;
import android.content.SharedPreferences;


public class NextAlarmBroadcastReceiver extends BroadcastReceiver {

    private static final String TAG = "NextAlarmReceiver";
    private static final SimpleDateFormat DATE_TIME_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:00", Locale.ENGLISH);
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
    private static final SimpleDateFormat TIME_FORMAT = new SimpleDateFormat("HH:mm:00", Locale.ENGLISH);

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
        final AlarmManager alarmManager;
        if (android.os.Build.VERSION.SDK_INT >= 23) {
            alarmManager = context.getSystemService(AlarmManager.class);
        } else {
            alarmManager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
        }

        final AlarmManager.AlarmClockInfo alarmClockInfo = alarmManager.getNextAlarmClock();

        SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        String webhookId = prefs.getString("flutter.app-webhook-id", null);
        if (webhookId != null) {
            try {
                String requestUrl = prefs.getString("flutter.hassio-res-protocol", "") +
                        "://" +
                        prefs.getString("flutter.hassio-domain", "") +
                        ":" +
                        prefs.getString("flutter.hassio-port", "") + "/api/webhook/" + webhookId;
                JSONObject dataToSend = new JSONObject();
                if (URLUtil.isValidUrl(requestUrl)) {
                    dataToSend.put("type", "update_sensor_states");
                    JSONArray dataArray = new JSONArray();
                    JSONObject sensorData = new JSONObject();
                    JSONObject sensorAttrs = new JSONObject();
                    sensorData.put("unique_id", "next_alarm");
                    sensorData.put("type", "sensor");
                    final long triggerTimestamp;
                    if (alarmClockInfo != null) {
                        triggerTimestamp = alarmClockInfo.getTriggerTime();
                        final Calendar calendar = Calendar.getInstance();
                        calendar.setTimeInMillis(triggerTimestamp);
                        sensorData.put("state", DATE_TIME_FORMAT.format(calendar.getTime()));
                        sensorAttrs.put("date", DATE_FORMAT.format(calendar.getTime()));
                        sensorAttrs.put("time", TIME_FORMAT.format(calendar.getTime()));
                        sensorAttrs.put("timestamp", triggerTimestamp);
                    } else {
                        sensorData.put("state", "");
                        sensorAttrs.put("date", "");
                        sensorAttrs.put("time", "");
                        sensorAttrs.put("timestamp", 0);
                    }
                    sensorData.put("icon", "mdi:alarm");
                    sensorData.put("attributes", sensorAttrs);
                    dataArray.put(0, sensorData);
                    dataToSend.put("data", dataArray);

                    String stringRequest = dataToSend.toString();
                    SendTask sendTask = new SendTask();
                    sendTask.execute(requestUrl, stringRequest);
                } else {
                    Log.w(TAG, "Invalid HA url");
                }
            } catch (Exception e) {
                Log.e(TAG, "Error setting next alarm", e);
            }
        } else {
            Log.w(TAG, "Webhook id not found");
        }
    }
}