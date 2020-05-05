part of '../main.dart';

class MobileAppIntegrationManager {

  static const INTEGRATION_VERSION = 3;

  static final _appRegistrationData = {
    "device_name": "",
    "app_version": "$appVersion",
    "manufacturer": DeviceInfoManager().manufacturer,
    "model": DeviceInfoManager().model,
    "os_version": DeviceInfoManager().osVersion,
    "app_data": {
      "push_token": "",
      "push_url": "https://us-central1-ha-client-c73c4.cloudfunctions.net/sendPushNotification"
    }
  };

  static String getDefaultDeviceName() {
    if (HomeAssistant().userName.isEmpty) {
      return '${DeviceInfoManager().model}';  
    }
    return '${HomeAssistant().userName}\'s ${DeviceInfoManager().model}';
  }

  static Future checkAppRegistration() {
    Completer completer = Completer();
    _appRegistrationData["device_name"] = ConnectionManager().mobileAppDeviceName ?? getDefaultDeviceName();
    (_appRegistrationData["app_data"] as Map)["push_token"] = "${HomeAssistant().fcmToken}";
    if (ConnectionManager().webhookId == null) {
      Logger.d("Mobile app was not registered yet. Registering...");
      var registrationData = Map.from(_appRegistrationData);
      registrationData.addAll({
        "device_id": "${DeviceInfoManager().unicDeviceId}",
        "app_id": "ha_client",
        "app_name": "$appName",
        "os_name": DeviceInfoManager().osName,
        "supports_encryption": false,
      });
      ConnectionManager().sendHTTPPost(
          endPoint: "/api/mobile_app/registrations",
          includeAuthHeader: true,
          data: json.encode(registrationData)
      ).then((response) {
        Logger.d("Processing registration responce...");
        var responseObject = json.decode(response);
        ConnectionManager().webhookId = responseObject["webhook_id"];
        ConnectionManager().appIntegrationVersion = INTEGRATION_VERSION;
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("app-webhook-id", responseObject["webhook_id"]);
          prefs.setInt('app-integration-version', INTEGRATION_VERSION);

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
        Logger.e("Error registering the app: $e");
      });
      return completer.future;
    } else {
      Logger.d("App was previously registered. Checking...");
      var updateData = {
        "type": "update_registration",
        "data": _appRegistrationData
      };
      ConnectionManager().sendHTTPPost(
          endPoint: "/api/webhook/${ConnectionManager().webhookId}",
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
          if (INTEGRATION_VERSION > ConnectionManager().appIntegrationVersion) {
            Logger.d('App registration needs to be updated');
            _askToRemoveAndRegisterApp();
          } else {
            Logger.d('App registration works fine');
          }
        }
        completer.complete();
      }).catchError((e) {
        if (e is http.Response && e.statusCode == 410) {
          Logger.w("MobileApp integration was removed");
          _askToRegisterApp();
        } else {
          Logger.w("Error updating app registration: $e");
          _showError();
        }
        completer.complete();
      });
      return completer.future;
    }
  }

  static void _showError() {
    eventBus.fire(ShowPopupEvent(
      popup: Popup(
        title: "App integration is not working properly",
        body: "Something wrong with HA Client integration on your Home Assistant server. Please report this issue. You can try to remove Mobile App integration from Home Assistant and restart server to fix this issue.",
        positiveText: "Report to GitHub",
        negativeText: "Report to Discord",
        onPositive: () {
          Launcher.launchURLInBrowser("https://github.com/estevez-dev/ha_client/issues/new");
        },
        onNegative: () {
          Launcher.launchURLInBrowser("https://discord.gg/u9vq7QE");
        },
      )
    ));
  }

  static void _askToRemoveAndRegisterApp() {
    eventBus.fire(ShowPopupEvent(
      popup: Popup(
        title: "Mobile app integration needs to be updated",
        body: "You need to update HA Client integration to continue using notifications and location tracking. Please remove 'Mobile App' integration for this device from your Home Assistant and restart Home Assistant. Then go back to HA Client to create app integration again.",
        positiveText: "Ok",
        negativeText: "Report an issue",
        onNegative: () {
          Launcher.launchURLInBrowser("https://github.com/estevez-dev/ha_client/issues/new");
        },
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