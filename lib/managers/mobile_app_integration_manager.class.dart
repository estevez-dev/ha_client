part of '../main.dart';

class MobileAppIntegrationManager {

  static final _appRegistrationData = {
    "device_name": "",
    "app_version": "$appVersion",
    "manufacturer": DeviceInfoManager().manufacturer,
    "model": DeviceInfoManager().model,
    "os_version": DeviceInfoManager().osVersion,
    "app_data": {
      "push_token": "",
      "push_url": "https://us-central1-ha-client-c73c4.cloudfunctions.net/pushNotifyV3"
    }
  };

  static String getDefaultDeviceName() {
    if (HomeAssistant().userName.isEmpty) {
      return '${DeviceInfoManager().model}';  
    }
    return '${HomeAssistant().userName}\'s ${DeviceInfoManager().model}';
  }

  static Future checkAppRegistration() async {
    int attempts = 1;
    bool done = false;
    Logger.d("[MobileAppIntegrationManager] Stratring mobile app integration check...");
    while (attempts <= 5 && !done) {
      Logger.d("[MobileAppIntegrationManager] check attempt $attempts");
      String fcmToken = await AppSettings().loadSingle('notification-token');
      if (fcmToken != null) {
        Logger.d("[MobileAppIntegrationManager] token exist");
        await _doCheck(fcmToken);
        done = true;
      } else {
        Logger.d("[MobileAppIntegrationManager] no fcm token. Retry in 5 seconds");
        attempts++;
        await Future.delayed(Duration(seconds: 5));
      }
    }
    if (!done) {
      Logger.e("[MobileAppIntegrationManager] No FCM token");
    }
  }

  static Future _doCheck(String fcmToken) {
    Completer completer = Completer();
    _appRegistrationData["device_name"] = AppSettings().mobileAppDeviceName ?? getDefaultDeviceName();
    (_appRegistrationData["app_data"] as Map)["push_token"] = "$fcmToken";
    if (AppSettings().webhookId == null) {
      Logger.d("Mobile app was not registered yet. Registering...");
      var registrationData = Map.from(_appRegistrationData);
      registrationData.addAll({
        "app_id": "ha_client",
        "app_name": "$appName",
        "os_name": DeviceInfoManager().osName,
        "supports_encryption": false,
      });
      if (AppSettings().haVersion >= 104) {
        registrationData.addAll({
          "device_id": "${DeviceInfoManager().unicDeviceId}"
        });
      }
      ConnectionManager().sendHTTPPost(
          endPoint: "/api/mobile_app/registrations",
          includeAuthHeader: true,
          data: json.encode(registrationData)
      ).then((response) {
        Logger.d("Processing registration responce...");
        var responseObject = json.decode(response);
        AppSettings().webhookId = responseObject["webhook_id"];
        AppSettings().save({
          'app-webhook-id': responseObject["webhook_id"]
        }).then((prefs) {
          completer.complete();
          eventBus.fire(ShowPopupEvent(
            popup: Popup(
              title: "Mobile app Integration was created",
              body: "HA Client was registered as MobileApp in your Home Assistant. To start using notifications you need to restart your Home Assistant",
              positiveText: "Restart now",
              negativeText: "Later",
              onPositive: () {
                ConnectionManager().callService(domain: "homeassistant", service: "restart");
              },
            )
          ));
        });
      }).catchError((e) {
        completer.complete();
        if (e is http.Response) {
          Logger.e("Error registering the app: ${e.statusCode}: ${e.body}");
        } else {
          Logger.e("Error registering the app: ${e?.toString()}");
        }
        _showError();
      });
    } else {
      Logger.d("App was previously registered. Checking...");
      var updateData = {
        "type": "update_registration",
        "data": _appRegistrationData
      };
      ConnectionManager().sendHTTPPost(
          endPoint: "/api/webhook/${AppSettings().webhookId}",
          includeAuthHeader: false,
          data: json.encode(updateData)
      ).then((response) {
        var registrationData;
        try {
          registrationData = json.decode(response);
        } catch (e) {
          registrationData = null;
        }
        if (registrationData == null || registrationData.isEmpty) {
          Logger.w("No registration data in response. MobileApp integration was removed or broken");
          _askToRegisterApp();
        } else {
          Logger.d('App registration works fine');
        }
        completer.complete();
      }).catchError((e) {
        if (e is http.Response && e.statusCode == 410) {
          Logger.w("MobileApp integration was removed");
          _askToRegisterApp();
        } else if (e is http.Response) {
          Logger.w("Error updating app registration: ${e.statusCode}: ${e.body}");
          _showError();
        } else {
          Logger.w("Error updating app registration: ${e?.toString()}");
          _showError();
        }
        completer.complete();
      });
    }
    return completer.future;
  }

  static void _showError() {
    eventBus.fire(ShowPopupEvent(
      popup: Popup(
        title: "App integration is not working properly",
        body: "Something wrong with HA Client integration on your Home Assistant server. Please report this issue. You can try to remove Mobile App integration from Home Assistant and restart server to fix this issue.",
        positiveText: "Report issue",
        negativeText: "Close",
        onPositive: () {
          Launcher.launchURLInBrowser("https://github.com/estevez-dev/ha_client/issues/new");
        }
      )
    ));
  }

  static void _askToRegisterApp() {
    eventBus.fire(ShowPopupEvent(
      popup: RegisterAppPopup(
        title: "Mobile App integration is missing",
        body: "Looks like mobile app integration was removed from your Home Assistant or it needs to be updated.",
      )
    ));
  }

}