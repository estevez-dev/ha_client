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
          "$backgroundTaskId$n",
          "haClientLocationTracking-0$n",
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
            networkType: workManager.NetworkType.connected
          )
        );
      }
    }
  }

  _stopLocationService() async {
    Logger.d("Canceling previous schedule if any...");
    await workManager.Workmanager.cancelByTag(backgroundTaskTag);
  }

  updateDeviceLocation() async {
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
          var response = await http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: json.encode(data)
          );
          Logger.d("[Foreground location] Got HTTP ${response.statusCode}");
        } else {
          Logger.d("[Foreground location] No location. Aborting.");
        }
    }
  }

}

void updateDeviceLocationIsolate() {
  workManager.Workmanager.executeTask((backgroundTask, data) {
    print("[Background $backgroundTask] Started");
    Geolocator geolocator = Geolocator();
    var battery = Battery();
    int batteryLevel = 100;
    String webhookId = data["webhookId"];
    String httpWebHost = data["httpWebHost"];
    if (webhookId != null && webhookId.isNotEmpty) {
        print("[Background $backgroundTask] hour=$battery");
        String url = "$httpWebHost/api/webhook/$webhookId";
        Map<String, String> headers = {};
        headers["Content-Type"] = "application/json";
        Map data = {
          "type": "update_location",
          "data": {
            "gps": [],
            "gps_accuracy": 0,
            "battery": batteryLevel
          }
        };
        print("[Background $backgroundTask] Getting battery level...");
        battery.batteryLevel.then((val) => data["data"]["battery"] = val).whenComplete((){
          print("[Background $backgroundTask] Getting device location...");
          geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, locationPermissionLevel: GeolocationPermission.locationAlways).then((location) {
            if (location != null) {
              print("[Background $backgroundTask] Got location: ${location.latitude} ${location.longitude}");
              data["data"]["gps"] = [location.latitude, location.longitude];
              data["data"]["gps_accuracy"] = location.accuracy;
              print("[Background $backgroundTask] Sending data home.");
              http.post(
                  url,
                  headers: headers,
                  body: json.encode(data)
              );
            } else {
              print("[Background $backgroundTask] No location. Finishing.");
            }
          }).catchError((e) {
            print("[Background $backgroundTask] Error getting current location: ${e.toString()}");
          });
        });
    }
    return Future.value(true);
  });
}