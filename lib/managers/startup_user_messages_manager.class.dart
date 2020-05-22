part of '../main.dart';

class StartupUserMessagesManager {

  static final StartupUserMessagesManager _instance = StartupUserMessagesManager
      ._internal();

  factory StartupUserMessagesManager() {
    return _instance;
  }

  StartupUserMessagesManager._internal();

  bool _needToshowDonateMessage;
  bool _whatsNewMessageShown;
  static final _donateMsgTimerKey = "user-msg-donate-timer";
  static final _donateMsgShownKey = "user-msg-donate-shpown";
  static final _whatsNewMessageKey = "user-msg-whats-new-url";

  void checkMessagesToShow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var tInt = prefs.getInt(_donateMsgTimerKey);
    if (tInt == null) {
      prefs.setInt(_donateMsgTimerKey, DateTime.now().millisecondsSinceEpoch);
      _needToshowDonateMessage = false;
    } else {
      bool wasShown = prefs.getBool(_donateMsgShownKey) ?? false;
      _needToshowDonateMessage = (Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - tInt).inDays >= 14) && !wasShown;
    }
    _whatsNewMessageShown = '${prefs.getString(_whatsNewMessageKey)}' == whatsNewUrl;
    if (!_whatsNewMessageShown) {
      _showWhatsNewMessage();
    } else if (_needToshowDonateMessage) {
      _showSupportAppDevelopmentMessage();
    }
  }

  void _showSupportAppDevelopmentMessage() {
    eventBus.fire(ShowPopupEvent(
      popup: Popup(
        title: "Hi!",
        body: "As you may have noticed this app contains no ads. Also all app features are available for you for free. I'm not planning to change this in nearest future, but still you can support this application development materially. There is one-time payment available as well as several subscription options. Thanks.",
        positiveText: "Show options",
        negativeText: "Later",
        onPositive: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(_donateMsgShownKey, true);
            eventBus.fire(ShowPageEvent(path: "/putchase"));
          });
        },
        onNegative: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setInt(_donateMsgTimerKey, DateTime.now().millisecondsSinceEpoch);
          });
        }
      )
    ));
  }

  void _showWhatsNewMessage() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_whatsNewMessageKey, whatsNewUrl);
      eventBus.fire(ShowPageEvent(path: "/whats-new"));
    });
  }

}
