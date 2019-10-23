part of '../main.dart';

class MobileAppIntegrationManager {

  static final _appRegistrationData = {
    "app_version": "$appVersion",
    "device_name": "",
    "manufacturer": DeviceInfoManager().manufacturer,
    "model": DeviceInfoManager().model,
    "os_version": DeviceInfoManager().osVersion,
    "app_data": {
      "push_token": "",
      "push_url": "https://us-central1-ha-client-c73c4.cloudfunctions.net/sendPushNotification"
    }
  };

  static Future checkAppRegistration({bool forceRegister: false, bool showOkDialog: false}) {
    Completer completer = Completer();
    _appRegistrationData["device_name"] = "${HomeAssistant().userName}'s ${DeviceInfoManager().model}";
    (_appRegistrationData["app_data"] as Map)["push_token"] = "${HomeAssistant().fcmToken}";
    if (ConnectionManager().webhookId == null || forceRegister) {
      Logger.d("Mobile app was not registered yet or need to be reseted. Registering...");
      var registrationData = Map.from(_appRegistrationData);
      registrationData.addAll({
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
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("app-webhook-id", responseObject["webhook_id"]);
          ConnectionManager().webhookId = responseObject["webhook_id"];

          completer.complete();
          eventBus.fire(ShowPopupDialogEvent(
            title: "Mobile app Integration was created",
            body: "HA Client was registered as MobileApp in your Home Assistant. To start using notifications you need to restart your Home Assistant",
            positiveText: "Restart now",
            negativeText: "Later",
            onPositive: () {
              ConnectionManager().callService(domain: "homeassistant", service: "restart", entityId: null);
            },
          ));
        });
      }).catchError((e) {
        completer.complete();
        Logger.e("Error registering the app: ${e.toString()}");
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
        if (response == null || response.isEmpty) {
          Logger.d("No registration data in response. MobileApp integration was removed");
          _askToRegisterApp();
        } else {
          Logger.d("App registration works fine");
          if (showOkDialog) {
            eventBus.fire(ShowPopupDialogEvent(
                title: "All good",
                body: "HA Client integration with your Home Assistant server works fine",
                positiveText: "Nice!",
                negativeText: "Ok"
            ));
          }
        }
        completer.complete();
      }).catchError((e) {
        if (e['code'] != null && e['code'] == 410) {
          Logger.e("MobileApp integration was removed");
          _askToRegisterApp();
        } else {
          Logger.e("Error updating app registration: ${e.toString()}");
          eventBus.fire(ShowPopupDialogEvent(
            title: "App integration is not working properly",
            body: "Something wrong with HA Client integration on your Home Assistant server. Please report this issue.",
            positiveText: "Report to GitHub",
            negativeText: "Report to Discord",
            onPositive: () {
              Launcher.launchURL("https://github.com/estevez-dev/ha_client/issues/new");
            },
            onNegative: () {
              Launcher.launchURL("https://discord.gg/AUzEvwn");
            },
          ));
        }
        completer.complete();
      });
      return completer.future;
    }
  }

  static void _askToRegisterApp() {
    eventBus.fire(ShowPopupDialogEvent(
      title: "App integration was removed",
      body: "Looks like app integration was removed from your Home Assistant. HA Client needs to be registered on your Home Assistant server to make it possible to use notifications and other useful stuff.",
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