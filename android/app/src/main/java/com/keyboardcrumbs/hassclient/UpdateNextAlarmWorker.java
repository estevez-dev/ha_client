package com.keyboardcrumbs.hassclient;

import android.app.AlarmManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;
import android.webkit.URLUtil;

import androidx.annotation.NonNull;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

public class UpdateNextAlarmWorker extends Worker {

    private Context currentContext;
    private static final String TAG = "NextAlarmWorker";
    private static final SimpleDateFormat DATE_TIME_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:00", Locale.ENGLISH);
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
    private static final SimpleDateFormat TIME_FORMAT = new SimpleDateFormat("HH:mm:00", Locale.ENGLISH);

    public UpdateNextAlarmWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
        currentContext = context;
    }

    @NonNull
    @Override
    public Result doWork() {
        final AlarmManager alarmManager;
        if (android.os.Build.VERSION.SDK_INT >= 23) {
            alarmManager = currentContext.getSystemService(AlarmManager.class);
        } else {
            alarmManager = (AlarmManager)currentContext.getSystemService(Context.ALARM_SERVICE);
        }

        final AlarmManager.AlarmClockInfo alarmClockInfo = alarmManager.getNextAlarmClock();

        SharedPreferences prefs = currentContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
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
                    try {
                        URL url = new URL(requestUrl);
                        HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                        urlConnection.setRequestMethod("POST");
                        urlConnection.setRequestProperty("Content-Type", "application/json");
                        urlConnection.setDoOutput(true);
                        byte[] outputBytes = stringRequest.getBytes("UTF-8");
                        OutputStream os = urlConnection.getOutputStream();
                        os.write(outputBytes);

                        int responseCode = urlConnection.getResponseCode();
                        urlConnection.disconnect();
                        if (responseCode >= 300) {
                            return Result.retry();
                        }
                    } catch (Exception e) {
                        Log.e(TAG, "Error sending data", e);
                        return Result.retry();
                    }
                } else {
                    Log.w(TAG, "Invalid HA url");
                    return Result.failure();
                }
            } catch (Exception e) {
                Log.e(TAG, "Error setting next alarm", e);
                return Result.failure();
            }
        } else {
            Log.w(TAG, "Webhook id not found");
            return Result.failure();
        }
        return Result.success();
    }
}
