package com.keyboardcrumbs.hassclient;

import android.util.Log;
import android.os.AsyncTask;

import java.net.URL;
import java.net.HttpURLConnection;
import java.io.OutputStream;

import android.webkit.URLUtil;

import org.json.JSONObject;
import android.content.SharedPreferences;
import android.content.Context;
import java.lang.ref.WeakReference;


public class UpdateTokenTask extends AsyncTask<String, String, String> {

    private static final String TAG = "UpdateTokenTask";

    private WeakReference<Context> contextRef;

    public UpdateTokenTask(Context context){
        contextRef = new WeakReference<>(context);
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
    }

    @Override
    protected String doInBackground(String... params) {
        Log.d(TAG, "Updating push token");
        Context context = contextRef.get();
        if (context != null) {
            String token = params[0];
            SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putString("flutter.notification-token", token);
            editor.commit();
        }
        return null;
    }
}