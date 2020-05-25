package com.keyboardcrumbs.hassclient;

import android.content.Context;
import androidx.annotation.NonNull;
import android.util.Log;
import android.content.BroadcastReceiver;
import android.content.Intent;

import android.app.NotificationManager;

import android.webkit.URLUtil;

import org.json.JSONObject;
import android.content.SharedPreferences;

public class NotificationActionReceiver extends BroadcastReceiver {

    private static final String TAG = "NotificationActionReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        String rawActionData = intent.getStringExtra("actionData");
        String notificationTag = intent.getStringExtra("tag");
        Log.d(TAG, "Has 'tag': " + intent.hasExtra("tag"));
        Log.d(TAG, "Canceling notification by tag: " + notificationTag);
        NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(notificationTag, 0);
        SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        String webhookId = prefs.getString("flutter.app-webhook-id", null);
        if (webhookId != null) {
            try {
                Log.d(TAG, "Got webhook id");
                String requestUrl = prefs.getString("flutter.hassio-res-protocol", "") +
                    "://" +
                    prefs.getString("flutter.hassio-domain", "") +
                    ":" +
                    prefs.getString("flutter.hassio-port", "") + "/api/webhook/" + webhookId;
                JSONObject actionData = new JSONObject(rawActionData);
                Log.d(TAG, "request url: " + requestUrl);
                if (URLUtil.isValidUrl(requestUrl)) {
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
                    }
                    dataToSend.put("data", requestData);
                    String stringRequest = dataToSend.toString();
                    Log.d(TAG, "Data to send home: " + stringRequest);
                    SendTask sendTask = new SendTask();
                    sendTask.execute(requestUrl, stringRequest);
                } else {
                    Log.w(TAG, "Invalid url");
                }
            } catch (Exception e) {
                Log.e(TAG, "Error handling notification action", e);    
            }
        } else {
            Log.d(TAG, "Webhook id not found");
        }
    }
}