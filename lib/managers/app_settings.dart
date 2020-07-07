part of '../main.dart';

enum DisplayMode {normal, fullscreen}

class AppSettings {

  static const DEFAULT_HIVE_BOX = 'defaultSettingsBox';

  static const AUTH_TOKEN_KEY = 'llt';

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
  bool nextAlarmSensorCreated = false;
  DisplayMode displayMode;
  AppTheme appTheme;
  final int defaultLocationUpdateIntervalMinutes = 20;
  final int defaultActiveLocationUpdateIntervalSeconds = 900;
  Duration locationUpdateInterval;
  bool locationTrackingEnabled = false;

  bool get isAuthenticated => longLivedToken != null;
  bool get isTempAuthenticated => tempToken != null;

  loadStartupSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    appTheme = AppTheme.values[prefs.getInt('app-theme') ?? AppTheme.defaultTheme.index];
    displayMode = DisplayMode.values[prefs.getInt('display-mode') ?? DisplayMode.normal.index];
  }

  Future load(bool full) async {
    if (full) {
      await Hive.openBox(DEFAULT_HIVE_BOX);
      Logger.d('Loading settings...');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _domain = prefs.getString('hassio-domain');
      _port = prefs.getString('hassio-port');
      webhookId = prefs.getString('app-webhook-id');
      mobileAppDeviceName = prefs.getString('app-integration-device-name');
      scrollBadges = prefs.getBool('scroll-badges') ?? true;
      displayHostname = "$_domain:$_port";
      webSocketAPIEndpoint =
        "${prefs.getString('hassio-protocol')}://$_domain:$_port/api/websocket";
      httpWebHost =
        "${prefs.getString('hassio-res-protocol')}://$_domain:$_port";
      locationUpdateInterval = Duration(minutes: prefs.getInt("location-interval") ??
        defaultLocationUpdateIntervalMinutes);
      locationTrackingEnabled = prefs.getBool("location-enabled") ?? false;
      nextAlarmSensorCreated = prefs.getBool("next-alarm-sensor-created") ?? false;
      longLivedToken = Hive.box(DEFAULT_HIVE_BOX).get(AUTH_TOKEN_KEY);
      oauthUrl = "$httpWebHost/auth/authorize?client_id=${Uri.encodeComponent(
          'https://ha-client.app')}&redirect_uri=${Uri
          .encodeComponent(
          'https://ha-client.app/service/auth_callback.html')}";
    }
  }

  Future<dynamic> loadSingle(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('$key');
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
    Hive.box(DEFAULT_HIVE_BOX).delete(AUTH_TOKEN_KEY);
  }

  void saveLongLivedToken(token) {
    longLivedToken = token;
    tempToken = null;
    Hive.box(DEFAULT_HIVE_BOX).put(AUTH_TOKEN_KEY, longLivedToken);
  }

  bool isNotConfigured() {
    return _domain == null && _port == null && webhookId == null && mobileAppDeviceName == null;
  }

  bool isSomethingMissed() {
    return (_domain == null) || (_port == null) || (_domain.isEmpty) || (_port.isEmpty);
  }

}