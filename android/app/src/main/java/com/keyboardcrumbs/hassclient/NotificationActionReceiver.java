package com.keyboardcrumbs.hassclient;

import android.app.AlarmManager;
import android.content.Context;
import android.util.Log;
import android.content.BroadcastReceiver;
import android.content.Intent;

import android.app.NotificationManager;

import android.webkit.URLUtil;

import org.json.JSONObject;
import android.content.SharedPreferences;

public class NotificationActionReceiver extends BroadcastReceiver {

    private static final String TAG = "NotificationAction";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) {
            return;
        }

        String rawActionData = intent.getStringExtra("actionData");
        if (intent.hasExtra("tag")) {
            String notificationTag = intent.getStringExtra("tag");
            NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancel(notificationTag, 0);
        }
        SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        String webhookId = prefs.getString("flutter.app-webhook-id", null);
        if (webhookId != null) {
            try {
                String requestUrl = prefs.getString("flutter.hassio-res-protocol", "") +
                    "://" +
                    prefs.getString("flutter.hassio-domain", "") +
                    ":" +
                    prefs.getString("flutter.hassio-port", "") + "/api/webhook/" + webhookId;
                JSONObject actionData = new JSONObject(rawActionData);
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
                        JSONObject eventData = new JSONObject();
                        eventData.put("action", actionData.getString("action"));
                        requestData.put("event_data", eventData);
                    }
                    dataToSend.put("data", requestData);
                    String stringRequest = dataToSend.toString();
                    SendTask sendTask = new SendTask();
                    sendTask.execute(requestUrl, stringRequest);
                } else {
                    Log.w(TAG, "Invalid HA url");
                }
            } catch (Exception e) {
                Log.e(TAG, "Error handling notification action", e);    
            }
        } else {
            Log.w(TAG, "Webhook id not found");
        }
    }
}