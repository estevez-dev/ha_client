package com.keyboardcrumbs.hassclient;

import android.util.Log;
import android.os.AsyncTask;

import java.net.URL;
import java.net.HttpURLConnection;
import java.io.OutputStream;

public class SendTask extends AsyncTask<String, String, String> {

    private static final String TAG = "SendTask";

    public SendTask(){
        //set context variables if required
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
    }

    @Override
    protected String doInBackground(String... params) {
        String urlString = params[0];
        String data = params[1];

        try {
            URL url = new URL(urlString);
            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestMethod("POST");
            urlConnection.setRequestProperty("Content-Type", "application/json");
            urlConnection.setDoOutput(true);
            byte[] outputBytes = data.getBytes("UTF-8");
            OutputStream os = urlConnection.getOutputStream();
            os.write(outputBytes);

            int responseCode = urlConnection.getResponseCode();

            urlConnection.disconnect();
        } catch (Exception e) {
            Log.e(TAG, "Error sending data", e); 
        }
        return null;
    }
}