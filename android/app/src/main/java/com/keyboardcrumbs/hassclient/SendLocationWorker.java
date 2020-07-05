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

public class SendLocationWorker extends Worker {

    private Context currentContext;
    private static final String TAG = "SendLocationWorker";

    public static final String KEY_LAT_ARG = "Lat";
    public static final String KEY_LONG_ARG = "Long";
    public static final String KEY_ACC_ARG = "Acc";

    public SendLocationWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
        currentContext = context;
    }

    @NonNull
    @Override
    public Result doWork() {
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
                    dataToSend.put("type", "update_location");
                    JSONObject dataObject = new JSONObject();

                    JSONArray gps = new JSONArray();
                    gps.put(0, getInputData().getDouble(KEY_LAT_ARG, 0));
                    gps.put(1, getInputData().getDouble(KEY_LONG_ARG, 0));

                    dataObject.put("gps", gps);
                    dataObject.put("gps_accuracy", getInputData().getFloat(KEY_ACC_ARG, 0));
                    dataObject.put("battery", 41);

                    dataToSend.put("data", dataObject);

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
                Log.e(TAG, "Error =(", e);
                return Result.failure();
            }
        } else {
            Log.w(TAG, "Webhook id not found");
            return Result.failure();
        }
        return Result.success();
    }
}
