package com.keyboardcrumbs.hassclient;

import android.app.AlarmManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.BatteryManager;
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
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

public class SendDataHomeWorker extends Worker {
    public static final String DATA_TYPE_KEY = "dataType";

    public static final int DATA_TYPE_LOCATION = 1;
    public static final int DATA_TYPE_NEXT_ALARM = 2;
    public static final int DATA_TYPE_NOTIFICATION_ACTION = 3;

    private Context currentContext;
    private static final String TAG = "SendDataHomeWorker";

    public static final String KEY_LAT_ARG = "Lat";
    public static final String KEY_LONG_ARG = "Long";
    public static final String KEY_ACC_ARG = "Acc";

    private static final SimpleDateFormat DATE_TIME_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:00", Locale.ENGLISH);
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
    private static final SimpleDateFormat TIME_FORMAT = new SimpleDateFormat("HH:mm:00", Locale.ENGLISH);

    public SendDataHomeWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
        currentContext = context;
    }

    @NonNull
    @Override
    public Result doWork() {
        Log.d(TAG, "Start sending data home");
        SharedPreferences prefs = currentContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        String webhookId = prefs.getString("flutter.app-webhook-id", null);
        if (webhookId != null) {
            try {
                String requestUrl = prefs.getString("flutter.hassio-res-protocol", "") +
                        "://" +
                        prefs.getString("flutter.hassio-domain", "") +
                        ":" +
                        prefs.getString("flutter.hassio-port", "") + "/api/webhook/" + webhookId;
                if (URLUtil.isValidUrl(requestUrl)) {
                    int dataType = getInputData().getInt(DATA_TYPE_KEY, 0);
                    String stringRequest;
                    if (dataType == DATA_TYPE_LOCATION) {
                        Log.d(TAG, "Location data");
                        stringRequest = getLocationDataToSend();
                    } else if (dataType == DATA_TYPE_NEXT_ALARM) {
                        Log.d(TAG, "Next alarm data");
                        stringRequest = getNextAlarmDataToSend();
                    } else if (dataType == DATA_TYPE_NOTIFICATION_ACTION) {
                        Log.d(TAG, "Notification action data");
                        stringRequest = getNotificationActionData();
                    } else {
                        Log.e(TAG, "doWork() unknown data type: " + dataType);
                        return Result.failure();
                    }
                    try {
                        URL url = new URL(requestUrl);
                        HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                        urlConnection.setRequestMethod("POST");
                        urlConnection.setRequestProperty("Content-Type", "application/json");
                        urlConnection.setDoOutput(true);
                        assert stringRequest != null;
                        byte[] outputBytes = stringRequest.getBytes(StandardCharsets.UTF_8);
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
                Log.e(TAG, "Error =(", e);
                return Result.failure();
            }
        } else {
            Log.w(TAG, "Webhook id not found");
            return Result.failure();
        }
        return Result.success();
    }

    private String getLocationDataToSend() {
        try {
            JSONObject dataToSend = new JSONObject();
            dataToSend.put("type", "update_location");
            JSONObject dataObject = new JSONObject();

            JSONArray gps = new JSONArray();
            gps.put(0, getInputData().getDouble(KEY_LAT_ARG, 0));
            gps.put(1, getInputData().getDouble(KEY_LONG_ARG, 0));

            dataObject.put("gps", gps);
            dataObject.put("gps_accuracy", getInputData().getFloat(KEY_ACC_ARG, 0));

            BatteryManager bm;
            if (android.os.Build.VERSION.SDK_INT >= 23) {
                bm = currentContext.getSystemService(BatteryManager.class);
            } else {
                bm = (BatteryManager)currentContext.getSystemService(Context.BATTERY_SERVICE);
            }
            int batLevel = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);

            dataObject.put("battery", batLevel);

            dataToSend.put("data", dataObject);
            return dataToSend.toString();
        } catch (Exception e) {
            Log.e(TAG,"getLocationDataToSend", e);
            return null;
        }
    }

    private String getNotificationActionData() {
        try {
            String rawActionData = getInputData().getString("rawActionData");
            if (rawActionData == null || rawActionData.length() == 0) {
                Log.e(TAG,"getNotificationActionData rawAction data is empty");
                return null;
            }
            JSONObject actionData = new JSONObject(rawActionData);
            JSONObject dataToSend = new JSONObject();
            JSONObject requestData = new JSONObject();
            if (actionData.getString("action").equals("call-service")) {
                dataToSend.put("type", "call_service");
                requestData.put("domain", actionData.getString("service").split("\\.")[0]);
                requestData.put("service", actionData.getString("service").split("\\.")[1]);
                if (actionData.has("service_data")) {
                    requestData.put("service_data", actionData.get("service_data"));
                }
            } else {
                dataToSend.put("type", "fire_event");
                requestData.put("event_type", "ha_client_event");
                JSONObject eventData = new JSONObject();
                eventData.put("action", actionData.getString("action"));
                requestData.put("event_data", eventData);
            }
            dataToSend.put("data", requestData);
            return dataToSend.toString();
        } catch (Exception e) {
            Log.e(TAG,"getNotificationActionData", e);
            return null;
        }
    }

    private String getNextAlarmDataToSend() {
        try {
            final AlarmManager alarmManager;
            if (android.os.Build.VERSION.SDK_INT >= 23) {
                alarmManager = currentContext.getSystemService(AlarmManager.class);
            } else {
                alarmManager = (AlarmManager)currentContext.getSystemService(Context.ALARM_SERVICE);
            }

            final AlarmManager.AlarmClockInfo alarmClockInfo = alarmManager.getNextAlarmClock();

            JSONObject dataToSend = new JSONObject();
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
                Date date = calendar.getTime();
                sensorData.put("state", DATE_TIME_FORMAT.format(date));
                sensorAttrs.put("date", DATE_FORMAT.format(date));
                sensorAttrs.put("time", TIME_FORMAT.format(date));
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
            return dataToSend.toString();
        } catch (Exception e) {
            Log.e(TAG,"getNextAlarmDataToSend", e);
            return null;
        }
    }
}
