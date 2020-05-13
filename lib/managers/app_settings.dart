part of '../main.dart';

class AppSettings {

  static final AppSettings _instance = AppSettings._internal();

  factory AppSettings() {
    return _instance;
  }

  AppSettings._internal();

  String mobileAppDeviceName;
  String _domain;
  String _port;
  String displayHostname;
  String webSocketAPIEndpoint;
  String httpWebHost;
  String _token;
  String _tempToken;
  String oauthUrl;
  String webhookId;
  double haVersion;
  bool scrollBadges;
  int appIntegrationVersion;

  bool get isAuthenticated => _token != null;

  Future load(bool quick) async {
    if (!quick) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _domain = prefs.getString('hassio-domain');
      _port = prefs.getString('hassio-port');
      webhookId = prefs.getString('app-webhook-id');
      mobileAppDeviceName = prefs.getString('app-integration-device-name');
      appIntegrationVersion = prefs.getInt('app-integration-version') ?? 0;
      scrollBadges = prefs.getBool('scroll-badges') ?? true;
      displayHostname = "$_domain:$_port";
      _webSocketAPIEndpoint =
        "${prefs.getString('hassio-protocol')}://$_domain:$_port/api/websocket";
      httpWebHost =
        "${prefs.getString('hassio-res-protocol')}://$_domain:$_port";
      try {
        final storage = new FlutterSecureStorage();
        _token = await storage.read(key: "hacl_llt");
        Logger.d("Long-lived token read successful");
        oauthUrl = "$httpWebHost/auth/authorize?client_id=${Uri.encodeComponent(
            'https://ha-client.app')}&redirect_uri=${Uri
            .encodeComponent(
            'https://ha-client.app/service/auth_callback.html')}";
      } catch (e, stacktrace) {
        Logger.e("Error reading secure storage: $e", stacktrace: stacktrace);
      }
    }
  }

  Future startAuth() {
    return AuthManager().start(
      oauthUrl: oauthUrl
    ).then((token) {
      Logger.d("Token from AuthManager recived");
      _tempToken = token;
    });
  }

  bool isNotConfigured() {
    return _domain == null && _port == null && webhookId == null && mobileAppDeviceName == null;
  }

  bool isSomethingMissed() {
    return (_domain == null) || (_port == null) || (_domain.isEmpty) || (_port.isEmpty);
  }

}