part of '../main.dart';

enum DisplayMode {normal, fullscreen}

class AppSettings {

  static const DEFAULT_HIVE_BOX = 'defaultSettingsBox';

  static const AUTH_TOKEN_KEY = 'llt';

  static const platform = const MethodChannel('com.keyboardcrumbs.hassclient/native');

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
  final int defaultLocationUpdateIntervalSeconds = 900;

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
      await migrate(prefs);
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
      longLivedToken = Hive.box(DEFAULT_HIVE_BOX).get(AUTH_TOKEN_KEY);
      oauthUrl = "$httpWebHost/auth/authorize?client_id=${Uri.encodeComponent(
          'https://ha-client.app')}&redirect_uri=${Uri
          .encodeComponent(
          'https://ha-client.app/service/auth_callback.html')}";
    }
  }

  Future migrate(SharedPreferences prefs) async {
    //Migrating to new location tracking. TODO: Remove when no version 1.2.0 (and older) in the wild
    if (prefs.getBool("location-tracking-migrated") == null) {
      Logger.d("[MIGRATION] Migrating to new location tracking...");
      bool oldLocationTrackingEnabled = prefs.getBool("location-enabled") ?? false;
      if (oldLocationTrackingEnabled) {
        await platform.invokeMethod('cancelOldLocationWorker');
        int oldLocationTrackingInterval = prefs.getInt("location-interval") ?? 0;
        if (oldLocationTrackingInterval < 15) {
          oldLocationTrackingInterval = 15;
        }
        try {
          await platform.invokeMethod('startLocationService', <String, dynamic>{
            'location-updates-interval': oldLocationTrackingInterval * 60 * 1000,
            'location-updates-priority': 100,
            'location-updates-show-notification': true
          });
        } catch (e, stack) {
          Logger.e("[MIGRATION] Can't start new location tracking: $e", stacktrace: stack);
        }
      } else {
        Logger.d("[MIGRATION] Old location tracking was disabled");
      }
      await prefs.setBool("location-tracking-migrated", true);
    }
    //Migrating from integration without next alarm sensor. TODO: remove when no version 1.1.2 (and older) in the wild
    nextAlarmSensorCreated = prefs.getBool("next-alarm-sensor-created") ?? false;
    //Done
    Logger.d("[MIGRATION] Done.");
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