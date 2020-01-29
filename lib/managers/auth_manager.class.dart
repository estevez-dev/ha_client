part of '../main.dart';

class AuthManager {

  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  Future start({String oauthUrl}) {
    Completer completer = Completer();
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.startsWith("https://ha-client.estevez.dev/service/auth_callback.html")) {
        Logger.d("url=$url");
        String authCode = url.split("=")[1];
        Logger.d("authCode=$authCode");
        Logger.d("We have auth code. Getting temporary access token...");
        ConnectionManager().sendHTTPPost(
          endPoint: "/auth/token",
          contentType: "application/x-www-form-urlencoded",
          includeAuthHeader: false,
          data: "grant_type=authorization_code&code=$authCode&client_id=${Uri.encodeComponent('https://ha-client.estevez.dev')}"
        ).then((response) {
          Logger.d("Got temp token");
          String tempToken = json.decode(response)['access_token'];
          Logger.d("Closing webview...");
          eventBus.fire(StartAuthEvent(oauthUrl, false));
          completer.complete(tempToken);
        }).catchError((e) {
          Logger.e("Error getting temp token: ${e.toString()}");
          eventBus.fire(StartAuthEvent(oauthUrl, false));
          completer.completeError(HAError("Error getting temp token"));
        }).whenComplete(() => flutterWebviewPlugin.close());
      }
    });
    Logger.d("Launching OAuth");
    eventBus.fire(StartAuthEvent(oauthUrl, true));
    return completer.future;
    }

}