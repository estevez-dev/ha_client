part of '../main.dart';

class StartupUserMessagesManager {

  static final StartupUserMessagesManager _instance = StartupUserMessagesManager
      ._internal();

  factory StartupUserMessagesManager() {
    return _instance;
  }

  StartupUserMessagesManager._internal() {}

  bool _supportAppDevelopmentMessageShown;
  bool _whatsNewMessageShown;
  static final _supportAppDevelopmentMessageKey = "user-message-shown-support-development_3";
  static final _whatsNewMessageKey = "user-message-shown-whats-new-660";

  void checkMessagesToShow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _supportAppDevelopmentMessageShown = prefs.getBool(_supportAppDevelopmentMessageKey) ?? false;
    _whatsNewMessageShown = prefs.getBool(_whatsNewMessageKey) ?? false;
    if (!_whatsNewMessageShown) {
      _showWhatsNewMessage();
    } else if (!_supportAppDevelopmentMessageShown) {
      _showSupportAppDevelopmentMessage();
    }
  }

  void _showSupportAppDevelopmentMessage() {
    eventBus.fire(ShowPopupDialogEvent(
        title: "Hi!",
        body: "As you may have noticed this app contains no ads. Also all app features are available for you for free. I'm not planning to change this in nearest future, but still you can support this application development materially. There is one-time payment available as well as several subscription options. Thanks.",
        positiveText: "Show options",
        negativeText: "Cancel",
        onPositive: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(_supportAppDevelopmentMessageKey, true);
            eventBus.fire(ShowPageEvent(path: "/putchase"));
          });
        },
        onNegative: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(_supportAppDevelopmentMessageKey, true);
          });
        }
    ));
  }

  void _showWhatsNewMessage() {
    eventBus.fire(ShowPopupDialogEvent(
        title: "What's new",
        body: "You can now share any media url to HA Client via Android share menu. It will try to play that media on one of your media player. There is also 'tv' button available in app header if you want to send some url manually",
        positiveText: "Full release notes",
        negativeText: "Ok",
        onPositive: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(_whatsNewMessageKey, true);
            Launcher.launchURL("https://github.com/estevez-dev/ha_client/releases");
          });
        },
        onNegative: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(_whatsNewMessageKey, true);
          });
        }
    ));
  }

}