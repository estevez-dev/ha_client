part of '../main.dart';

class LocationManager {

  static final LocationManager _instance = LocationManager
      ._internal();

  factory LocationManager() {
    return _instance;
  }

  LocationManager._internal() {
    init();
  }

  final int defaultUpdateIntervalMinutes = 20;
  final String backgroundTaskId = "haclocationtask0";
  final String backgroundTaskTag = "haclocation";
  Duration _updateInterval;
  bool _isRunning;

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _updateInterval = Duration(minutes: prefs.getInt("location-interval") ??
        defaultUpdateIntervalMinutes);
    _isRunning = prefs.getBool("location-enabled") ?? false;
    if (_isRunning) {
      await _startLocationService();
    }
  }

  setSettings(bool enabled, int interval) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (interval != _updateInterval.inMinutes) {
      prefs.setInt("location-interval", interval);
      _updateInterval = Duration(minutes: interval);
      if (_isRunning) {
        Logger.d("Stopping location tracking...");
        _isRunning = false;
        await _stopLocationService();
      }
    }
    if (enabled && !_isRunning) {
      Logger.d("Starting location tracking");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("location-enabled", enabled);
      _isRunning = true;
      await _startLocationService();
    } else if (!enabled && _isRunning) {
      Logger.d("Stopping location tracking...");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("location-enabled", enabled);
      _isRunning = false;
      await _stopLocationService();
    }
  }

  _startLocationService() async {
    String webhookId = ConnectionManager().webhookId;
    String httpWebHost = ConnectionManager().httpWebHost;
    if (webhookId != null && webhookId.isNotEmpty) {
      Duration interval;
      int delayFactor;
      int taskCount;
      Logger.d("Starting location update for every ${_updateInterval
        .inMinutes} minutes...");
      if (_updateInterval.inMinutes == 10) {
        interval = Duration(minutes: 20);
        taskCount = 2;
        delayFactor = 10;
      } else if (_updateInterval.inMinutes == 5) {
        interval = Duration(minutes: 15);
        taskCount = 3;
        delayFactor = 5;
      } else {
        interval = _updateInterval;
        taskCount = 1;
        delayFactor = 0;
      }
      for (int i = 1; i <= taskCount; i++) {
        int delay = i*delayFactor;
        Logger.d("Scheduling location update task #$i for every ${interval.inMinutes} minutes in $delay minutes...");
        await workManager.Workmanager.registerPeriodicTask(
          "$backgroundTaskId$i",
          "haClientLocationTracking-0$i",
          tag: backgroundTaskTag,
          inputData: {
            "webhookId": webhookId,
            "httpWebHost": httpWebHost
          },
          frequency: interval,
          initialDelay: Duration(minutes: delay),
          existingWorkPolicy: workManager.ExistingWorkPolicy.keep,
          backoffPolicy: workManager.BackoffPolicy.linear,
          backoffPolicyDelay: interval,
          constraints: workManager.Constraints(
            networkType: workManager.NetworkType.connected,
          ),
        );
      }
    }
  }

  _stopLocationService() async {
    Logger.d("Canceling previous schedule if any...");
    await workManager.Workmanager.cancelAll();
  }

  updateDeviceLocation() async {
    try {
      Logger.d("[Foreground location] Started");
      Geolocator geolocator = Geolocator();
      var battery = Battery();
      String webhookId = ConnectionManager().webhookId;
      String httpWebHost = ConnectionManager().httpWebHost;
      if (webhookId != null && webhookId.isNotEmpty) {
          Logger.d("[Foreground location] Getting battery level...");
          int batteryLevel = await battery.batteryLevel;
          Logger.d("[Foreground location] Getting device location...");
          Position position = await geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              locationPermissionLevel: GeolocationPermission.locationAlways
            );
          if (position != null) {
            Logger.d("[Foreground location] Location: ${position.latitude} ${position.longitude}. Accuracy: ${position.accuracy}. (${position.timestamp})");
            String url = "$httpWebHost/api/webhook/$webhookId";
            Map data = {
              "type": "update_location",
              "data": {
                "gps": [position.latitude, position.longitude],
                "gps_accuracy": position.accuracy,
                "battery": batteryLevel ?? 100
              }
            };
            Logger.d("[Foreground location] Sending data home...");
            http.Response response = await http.post(
              url,
              headers: {"Content-Type": "application/json"},
              body: json.encode(data)
            );
            if (response.statusCode >= 300) {
              Logger.e('Foreground location update error: ${response.body}');
            }
            Logger.d("[Foreground location] Got HTTP ${response.statusCode}");
          } else {
            Logger.d("[Foreground location] No location. Aborting.");
          }
      }
    } catch (e, stack) {
      Logger.e('Foreground location error: ${e.toSTring()}', stacktrace: stack);
    }
  }

}

void updateDeviceLocationIsolate() {
  workManager.Workmanager.executeTask((backgroundTask, data) async {
    //print("[Background $backgroundTask] Started");
    Geolocator geolocator = Geolocator();
    var battery = Battery();
    String webhookId = data["webhookId"];
    String httpWebHost = data["httpWebHost"];
    //String logData = '==> ${DateTime.now()} [Background $backgroundTask]:';
    //print("[Background $backgroundTask] Getting path for log file...");
    //final logFileDirectory = await getExternalStorageDirectory();
    //print("[Background $backgroundTask] Opening log file...");
    //File logFile = File('${logFileDirectory.path}/ha-client-background-log.txt');
    //print("[Background $backgroundTask] Log file path: ${logFile.path}");
    if (webhookId != null && webhookId.isNotEmpty) {
      String url = "$httpWebHost/api/webhook/$webhookId";
      Map<String, String> headers = {};
      headers["Content-Type"] = "application/json";
      Map data = {
        "type": "update_location",
        "data": {
          "gps": [],
          "gps_accuracy": 0,
          "battery": 100
        }
      };
      //print("[Background $backgroundTask] Getting battery level...");
      int batteryLevel;
      try {
        batteryLevel = await battery.batteryLevel;
        //print("[Background $backgroundTask] Got battery level: $batteryLevel");
      } catch(e) {
        //print("[Background $backgroundTask] Error getting battery level: $e. Setting zero");
        batteryLevel = 0;
        //logData += 'Battery: error, $e';
      }
      if (batteryLevel != null) {
        data["data"]["battery"] = batteryLevel;
        //logData += 'Battery: success, $batteryLevel';
      }/* else {
        logData += 'Battery: error, level is null';
      }*/
      Position location;
      try {
        location = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, locationPermissionLevel: GeolocationPermission.locationAlways);
        if (location != null && location.latitude != null) {
          //logData += ' || Location: success, ${location.latitude} ${location.longitude} (${location.timestamp})';
          data["data"]["gps"] = [location.latitude, location.longitude];
          data["data"]["gps_accuracy"] = location.accuracy;
          try {
            http.Response response = await http.post(
                url,
                headers: headers,
                body: json.encode(data)
            );
            /*if (response.statusCode >= 200 && response.statusCode < 300) {
              logData += ' || Post: success, ${response.statusCode}';
            } else {
              logData += ' || Post: error, ${response.statusCode}';
            }*/
          } catch(e) {
            //logData += ' || Post: error, $e';
          }
        }/* else {
          logData += ' || Location: error, location is null';
        }*/
      } catch (e) {
        //print("[Background $backgroundTask] Location error: $e");
        //logData += ' || Location: error, $e';
      }
    }/* else {
      logData += 'Not configured';
    }*/
    //print("[Background $backgroundTask] Writing log data...");
    /*try {
      var fileMode;
      if (logFile.existsSync() && logFile.lengthSync() < 5000000) {
        fileMode = FileMode.append;
      } else {
        fileMode = FileMode.write;
      }
      await logFile.writeAsString('$logData\n', mode: fileMode);
    } catch (e) {
      print("[Background $backgroundTask] Error writing log: $e");
    }
    print("[Background $backgroundTask] Finished.");*/
    return true;
  });
}