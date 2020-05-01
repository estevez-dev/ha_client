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
    return '${HomeAssistant().userName}\'s ${DeviceInfoManager().model}';
  }

  static Future checkAppRegistration({bool forceRegister: false, bool showOkDialog: false}) {
    Completer completer = Completer();
    _appRegistrationData["device_name"] = ConnectionManager().mobileAppDeviceName ?? getDefaultDeviceName();
    (_appRegistrationData["app_data"] as Map)["push_token"] = "${HomeAssistant().fcmToken}";
    if (ConnectionManager().webhookId == null || forceRegister) {
      Logger.d("Mobile app was not registered yet or need to be reseted. Registering...");
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
          eventBus.fire(ShowPopupDialogEvent(
            title: "Mobile app Integration was created",
            body: "HA Client was registered as MobileApp in your Home Assistant. To start using notifications you need to restart your Home Assistant",
            positiveText: "Restart now",
            negativeText: "Later",
            onPositive: () {
              ConnectionManager().callService(domain: "homeassistant", service: "restart");
            },
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
          Logger.d("No registration data in response. MobileApp integration was removed or broken");
          _askToRegisterApp();
        } else {
          if (INTEGRATION_VERSION > ConnectionManager().appIntegrationVersion) {
            Logger.d('App registration needs to be updated');
            _askToRemoveAndRegisterApp();
          } else {
            Logger.d('App registration works fine');
            if (showOkDialog) {
              eventBus.fire(ShowPopupDialogEvent(
                  title: "All good",
                  body: "HA Client integration with your Home Assistant server works fine",
                  positiveText: "Nice!",
                  negativeText: "Ok"
              ));
            }
          }
        }
        completer.complete();
      }).catchError((e) {
        if (e is http.Response && e.statusCode == 410) {
          Logger.e("MobileApp integration was removed", skipCrashlytics: true);
          _askToRegisterApp();
        } else {
          Logger.e("Error updating app registration: $e");
          eventBus.fire(ShowPopupDialogEvent(
            title: "App integration is not working properly",
            body: "Something wrong with HA Client integration on your Home Assistant server. Please report this issue.",
            positiveText: "Report to GitHub",
            negativeText: "Report to Discord",
            onPositive: () {
              Launcher.launchURLInBrowser("https://github.com/estevez-dev/ha_client/issues/new");
            },
            onNegative: () {
              Launcher.launchURLInBrowser("https://discord.gg/AUzEvwn");
            },
          ));
        }
        completer.complete();
      });
      return completer.future;
    }
  }

  static void _askToRemoveAndRegisterApp() {
    eventBus.fire(ShowPopupDialogEvent(
      title: "Mobile app integration needs to be updated",
      body: "You need to update HA Client integration to continue using notifications and location tracking. Please remove 'Mobile App' integration for this device from your Home Assistant and restart Home Assistant. Then go back to HA Client to create app integration again.",
      positiveText: "Ok",
      negativeText: "Report an issue",
      onNegative: () {
        Launcher.launchURLInBrowser("https://github.com/estevez-dev/ha_client/issues/new");
      },
    ));
  }

  static void _askToRegisterApp() {
    eventBus.fire(ShowPopupDialogEvent(
      title: "App integration is broken",
      body: "Looks like app integration was removed from your Home Assistant or it needs to be updated. HA Client needs to be registered on your Home Assistant server to make it possible to use notifications and location tracking. Please remove 'Mobile App' integration for this device from your Home Assistant before registering and restart Home Assistant. Then go back here.",
      positiveText: "Register now",
      negativeText: "Cancel",
      onPositive: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.remove("app-webhook-id");
          ConnectionManager().webhookId = null;
          checkAppRegistration();
        });
      },
    ));
  }

}