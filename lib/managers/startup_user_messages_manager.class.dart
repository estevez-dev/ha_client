part of '../main.dart';

class StartupUserMessagesManager {

  static final StartupUserMessagesManager _instance = StartupUserMessagesManager
      ._internal();

  factory StartupUserMessagesManager() {
    return _instance;
  }

  StartupUserMessagesManager._internal();

  bool _whatsNewMessageShown;
  static final _whatsNewMessageKey = "user-msg-whats-new-url";

  void checkMessagesToShow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _whatsNewMessageShown = '${prefs.getString(_whatsNewMessageKey)}' == whatsNewUrl;
    if (!_whatsNewMessageShown) {
      _showWhatsNewMessage();
    }
  }

  void _showWhatsNewMessage() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_whatsNewMessageKey, whatsNewUrl);
      eventBus.fire(ShowPageEvent(path: "/whats-new"));
    });
  }

}
