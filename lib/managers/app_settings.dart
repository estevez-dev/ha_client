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
  String longLivedToken;
  String tempToken;
  String oauthUrl;
  String webhookId;
  double haVersion;
  bool scrollBadges;
  int appIntegrationVersion;
  AppTheme appTheme;
  final int defaultLocationUpdateIntervalMinutes = 20;
  Duration locationUpdateInterval;
  bool locationTrackingEnabled = false;

  bool get isAuthenticated => longLivedToken != null;
  bool get isTempAuthenticated => tempToken != null;

  loadAppTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    appTheme = AppTheme.values[prefs.getInt('app-theme') ?? AppTheme.defaultTheme.index];
  }

  Future load(bool full) async {
    if (full) {
      Logger.d('Loading settings...');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _domain = prefs.getString('hassio-domain');
      _port = prefs.getString('hassio-port');
      webhookId = prefs.getString('app-webhook-id');
      mobileAppDeviceName = prefs.getString('app-integration-device-name');
      appIntegrationVersion = prefs.getInt('app-integration-version') ?? 0;
      scrollBadges = prefs.getBool('scroll-badges') ?? true;
      displayHostname = "$_domain:$_port";
      webSocketAPIEndpoint =
        "${prefs.getString('hassio-protocol')}://$_domain:$_port/api/websocket";
      httpWebHost =
        "${prefs.getString('hassio-res-protocol')}://$_domain:$_port";
      locationUpdateInterval = Duration(minutes: prefs.getInt("location-interval") ??
        defaultLocationUpdateIntervalMinutes);
      locationTrackingEnabled = prefs.getBool("location-enabled") ?? false;
      Logger.d('Done. $_domain:$_port');
      try {
        final storage = new FlutterSecureStorage();
        longLivedToken = await storage.read(key: "hacl_llt");
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

  Future save(Map<String, dynamic> settings) async {
    if (settings != null && settings.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      settings.forEach((k,v) async {
        if (v is String) {
          await prefs.setString(k, v);
        } else if (v is bool) {
          await prefs.setBool(k ,v);
        } else if (v is int) {
          await prefs.setInt(k ,v);
        } else if (v is double) {
          await prefs.setDouble(k, v);
        } else {
          Logger.e('Unknown setting type: <$k, $v>');
        }
      });
    }
  }

  Future startAuth() {
    return AuthManager().start(
      oauthUrl: oauthUrl
    ).then((token) {
      Logger.d("Token from AuthManager recived");
      tempToken = token;
    });
  }

  Future clearTokens() async {
    longLivedToken = null;
    tempToken = null;
    try {
      final storage = new FlutterSecureStorage();
      await storage.delete(key: "hacl_llt");
    } catch(e, stacktrace) {
      Logger.e("Error clearing tokens: $e", stacktrace: stacktrace);
    }
  }

  Future saveLongLivedToken(token) async {
    longLivedToken = token;
    tempToken = null;
    try {
      final storage = new FlutterSecureStorage();
      await storage.write(key: "hacl_llt", value: "$longLivedToken");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("oauth-used", true);
    } catch(e, stacktrace) {
      Logger.e("Error saving long-lived token: $e", stacktrace: stacktrace);
    }
  }

  bool isNotConfigured() {
    return _domain == null && _port == null && webhookId == null && mobileAppDeviceName == null;
  }

  bool isSomethingMissed() {
    return (_domain == null) || (_port == null) || (_domain.isEmpty) || (_port.isEmpty);
  }

}