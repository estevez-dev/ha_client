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

  final int defaultUpdateIntervalMinutes = 15;
  final String alarmId = "ha_location_background";
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
      updateDeviceLocation();
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
    await workManager.Workmanager.registerPeriodicTask(
      alarmId,
      "simplePeriodicTask",
      frequency: _updateInterval,
      existingWorkPolicy: workManager.ExistingWorkPolicy.replace,
      constraints: workManager.Constraints(
        networkType: workManager.NetworkType.connected
      )
    );
  }

  void _stopLocationService() async {
    Logger.d("Canceling previous schedule if any...");
    await workManager.Workmanager.cancelByUniqueName(alarmId);
  }

  void updateDeviceLocation() async {
    if (_isEnabled) {
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
      } else {
        Logger.d("[Location] No webhook id. Aborting");
      }
    } else {
      Logger.d("[Location] Location tracking is disabled");
    }
  }

}

void updateDeviceLocationIsolate() {
  workManager.Workmanager.executeTask((backgroundTask, _) {
    print("[Location isolate] Started: $backgroundTask");
    //Completer completer = Completer();

    SharedPreferences.getInstance().then((prefs){
      print("[Location isolate] loading settings");
      String webhookId = prefs.getString('app-webhook-id');
      String domain = prefs.getString('hassio-domain');
      String port = prefs.getString('hassio-port');
      String httpWebHost =
          "${prefs.getString('hassio-res-protocol')}://$domain:$port";
      if (webhookId != null && webhookId.isNotEmpty) {
        Logger.d("[Location isolate] Getting device location...");
        Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).then((location) {
          Logger.d("[Location isolate] Got location: ${location.latitude} ${location.longitude}. Sending home...");
          int battery = DateTime.now().hour;
          String url = "$httpWebHost/api/webhook/$webhookId";
          Map<String, String> headers = {};
          headers["Content-Type"] = "application/json";
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
            print("[Location isolate] Error sending data: ${e.toString()}");
          }).then((_) {
            print("[Location isolate] done!");
          });
        });
      } else {
        print("[Location isolate] No webhook id. Aborting");
      }
    });

    return Future.value(true);
  });
}