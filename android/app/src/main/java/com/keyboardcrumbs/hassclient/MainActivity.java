package com.keyboardcrumbs.hassclient;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.share.FlutterShareReceiverActivity;

public class MainActivity extends FlutterShareReceiverActivity {
  private static final String CHANNEL = "haclient.deeplink/channel";
  
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    
    Intent intent = getIntent();
    Uri data = intent.getData();

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call.method.equals("initialLink")) {
                  if (startString != null) {
                    result.success(startString);
                  }
                }
              }
            });

    if (data != null) {
      startString = data.toString();
    }
  }
}
