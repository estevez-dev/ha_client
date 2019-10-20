part of '../main.dart';

class AuthManager {

  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();
  StreamSubscription deepLinksSubscription;

  Future start({String oauthUrl}) {
    Completer completer = Completer();
    deepLinksSubscription?.cancel();
    deepLinksSubscription = getUriLinksStream().listen((Uri uri) {
            Logger.d("[LINKED AUTH] We got something private: $uri");
            Logger.d("[LINKED AUTH] code=${uri.queryParameters["code"]}");
            _getTempToken(oauthUrl, uri.queryParameters["code"])
              .then((tempToken) => completer.complete(tempToken))
              .catchError((_){
                completer.completeError(HAError("Auth error"));
              });
          }, onError: (err) {
            Logger.e("[LINKED AUTH] Error handling linked auth: $e");
            completer.completeError(HAError("Auth error"));
          });
    Logger.d("Launching OAuth");
    eventBus.fire(StartAuthEvent(oauthUrl, true));
    return completer.future;
  }

  Future _getTempToken(String oauthUrl,String authCode) {
    Completer completer = Completer();
    ConnectionManager().sendHTTPPost(
            endPoint: "/auth/token",
            contentType: "application/x-www-form-urlencoded",
            includeAuthHeader: false,
            data: "grant_type=authorization_code&code=$authCode&client_id=${Uri.encodeComponent('http://ha-client.homemade.systems')}"
        ).then((response) {
          Logger.d("Got temp token");
          String tempToken = json.decode(response)['access_token'];
          eventBus.fire(StartAuthEvent(oauthUrl, false));
          completer.complete(tempToken);
        }).catchError((e) {
          //flutterWebviewPlugin.close();
          Logger.e("Error getting temp token: ${e.toString()}");
          eventBus.fire(StartAuthEvent(oauthUrl, false));
          completer.completeError(HAError("Error getting temp token"));
        });
    return completer.future;
  }

}