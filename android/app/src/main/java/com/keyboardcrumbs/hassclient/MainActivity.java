package com.keyboardcrumbs.hassclient;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.content.Context;

import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.google.firebase.messaging.FirebaseMessaging;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.keyboardcrumbs.hassclient/native";
  
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
                @Override
                public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                    if (call.method.equals("getFCMToken")) {
                        FirebaseInstanceId.getInstance().getInstanceId()
                            .addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                                @Override
                                public void onComplete(@NonNull Task<InstanceIdResult> task) {
                                    if (task.isSuccessful()) {
                                        Context context = getActivity();
                                        String token = task.getResult().getToken();
                                        UpdateTokenTask updateTokenTask = new UpdateTokenTask(context);
                                        updateTokenTask.execute(token);
                                        result.success(token);
                                    } else {
                                        result.error("fcm_error", task.getException().getMessage(), task.getException());
                                    }
                                }
                            });
                    }
                }
            }
        );
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

}
