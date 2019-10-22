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
  bool _isEnabled;

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _updateInterval = Duration(minutes: prefs.getInt("location-interval") ??
        defaultUpdateIntervalMinutes);
    _isEnabled = prefs.getBool("location-enabled") ?? false;
    if (_isEnabled) {
      _startLocationService();
    }
  }

  void setSettings(bool enabled, int interval) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (interval != _updateInterval.inMinutes) {
      prefs.setInt("location-interval", interval);
      _updateInterval = Duration(minutes: interval);
    }
    if (enabled && !_isEnabled) {
      Logger.d("Enabling location service");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("location-enabled", enabled);
      _isEnabled = true;
      _startLocationService();
    } else if (!enabled && _isEnabled) {
      Logger.d("Disabling location service");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("location-enabled", enabled);
      _isEnabled = false;
      _stopLocationService();
    }
  }

  void _startLocationService() async {
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

  void _stopLocationService() async {
    Logger.d("Canceling previous schedule if any...");
    await workManager.Workmanager.cancelByTag(backgroundTaskTag);
  }

  void updateDeviceLocation() async {
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
        int battery = DateTime
            .now()
            .hour;
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
    print("[Background $backgroundTask] Started");

    String webhookId = data["webhookId"];
    String httpWebHost = data["httpWebHost"];
    if (webhookId != null && webhookId.isNotEmpty) {
        int battery = DateTime.now().hour;
        print("[Background $backgroundTask] hour=$battery");
        String url = "$httpWebHost/api/webhook/$webhookId";
        Map<String, String> headers = {};
        headers["Content-Type"] = "application/json";
        print("[Background $backgroundTask] Getting device location...");
        Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).then((location) {
          print("[Background $backgroundTask] Got location: ${location.latitude} ${location.longitude}");
          print("[Background $backgroundTask] sending data home...");
          var data = {
            "type": "update_location",
            "data": {
              "gps": [location.latitude, location.longitude],
              "gps_accuracy": location.accuracy,
              "battery": battery
            }
          };
          http.post(
              url,
              headers: headers,
              body: json.encode(data)
          ).catchError((e) {
            print("[Background $backgroundTask] Error sending data: ${e.toString()}");
          }).then((_) {
            print("[Background $backgroundTask] Success!");
          });
        }).catchError((e) {
          print("[Background $backgroundTask] Error getting current location: ${e.toString()}. Trying last known...");
          Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.medium).then((location){
            print("[Background $backgroundTask] Got last known location: ${location.latitude} ${location.longitude}");
            print("[Background $backgroundTask] sending data home...");
            var data = {
              "type": "update_location",
              "data": {
                "gps": [location.latitude, location.longitude],
                "gps_accuracy": location.accuracy,
                "battery": battery
              }
            };
            http.post(
                url,
                headers: headers,
                body: json.encode(data)
            ).catchError((e) {
              print("[Background $backgroundTask] Error sending data: ${e.toString()}");
            }).then((_) {
              print("[Background $backgroundTask] Success!");
            });
          }).catchError((e){
            print("[Background $backgroundTask] Error getting last known location: ${e.toString()}. Sending fake...");
            print("[Background $backgroundTask] sending data home...");
            var data = {
              "type": "update_location",
              "data": {
                "gps": [40.34, 30.34],
                "gps_accuracy": 300,
                "battery": battery
              }
            };
            http.post(
                url,
                headers: headers,
                body: json.encode(data)
            ).catchError((e) {
              print("[Background $backgroundTask] Error sending data: ${e.toString()}");
            }).then((_) {
              print("[Background $backgroundTask] Success!");
            });
          });
        });
    } else {
        print("[Background $backgroundTask] No webhook id. Aborting");
    }
    return Future.value(true);
  });
}