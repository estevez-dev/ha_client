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
  final String backgroundTaskId = "haclocationtask4352";
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
    Logger.d("Scheduling location update for every ${_updateInterval
        .inMinutes} minutes...");
    String webhookId = ConnectionManager().webhookId;
    String httpWebHost = ConnectionManager().httpWebHost;
    if (webhookId != null && webhookId.isNotEmpty) {
      await workManager.Workmanager.registerPeriodicTask(
        backgroundTaskId,
        "haClientLocationTracking",
        tag: backgroundTaskTag,
        inputData: {
          "webhookId": webhookId,
          "httpWebHost": httpWebHost
        },
        frequency: _updateInterval,
        existingWorkPolicy: workManager.ExistingWorkPolicy.keep,
        backoffPolicy: workManager.BackoffPolicy.linear,
        backoffPolicyDelay: _updateInterval,
        constraints: workManager.Constraints(
          networkType: workManager.NetworkType.connected
        )
      );
    }
  }

  _stopLocationService() async {
    Logger.d("Canceling previous schedule if any...");
    await workManager.Workmanager.cancelByTag(backgroundTaskTag);
  }

  updateDeviceLocation() async {
    if (ConnectionManager().webhookId != null &&
          ConnectionManager().webhookId.isNotEmpty) {
        String url = "${ConnectionManager()
            .httpWebHost}/api/webhook/${ConnectionManager().webhookId}";
        Map<String, String> headers = {};
        Logger.d("[Location] Getting device location...");
        Position location = await Geolocator().getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
        Logger.d("[Location] Got location: ${location.latitude} ${location
            .longitude}. Sending home...");
        int battery = await Battery().batteryLevel;
        var data = {
          "type": "update_location",
          "data": {
            "gps": [location.latitude, location.longitude],
            "gps_accuracy": location.accuracy,
            "battery": battery
          }
        };
        headers["Content-Type"] = "application/json";
        await http.post(
            url,
            headers: headers,
            body: json.encode(data)
        );
        Logger.d("[Location] ...done.");
    }
  }

}

void updateDeviceLocationIsolate() {
  workManager.Workmanager.executeTask((backgroundTask, data) {
    //print("[Background $backgroundTask] Started");
    var battery = Battery();
    int batteryLevel = 100;
    String webhookId = data["webhookId"];
    String httpWebHost = data["httpWebHost"];
    if (webhookId != null && webhookId.isNotEmpty) {
        //print("[Background $backgroundTask] hour=$battery");
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
        //print("[Background $backgroundTask] Getting battery level...");
        battery.batteryLevel.then((val) => data["data"]["battery"] = val).whenComplete((){
          //print("[Background $backgroundTask] Getting device location...");
          Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).then((location) {
            //print("[Background $backgroundTask] Got location: ${location.latitude} ${location.longitude}");
            data["data"]["gps"] = [location.latitude, location.longitude];
            data["data"]["gps_accuracy"] = location.accuracy;
            //print("[Background $backgroundTask] Sending data home...");
            http.post(
                url,
                headers: headers,
                body: json.encode(data)
            );
          }).catchError((e) {
            //print("[Background $backgroundTask] Error getting current location: ${e.toString()}. Trying last known...");
            Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.medium).then((location){
              //print("[Background $backgroundTask] Got last known location: ${location.latitude} ${location.longitude}");
              data["data"]["gps"] = [location.latitude, location.longitude];
              data["data"]["gps_accuracy"] = location.accuracy;
              //print("[Background $backgroundTask] Sending data home...");
              http.post(
                url,
                headers: headers,
                body: json.encode(data)
              );
            });
          });
        });
    }
    return Future.value(true);
  });
}