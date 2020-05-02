part of '../main.dart';

class HACException implements Exception {
  String cause;
  final List<HAErrorAction> actions;

  HACException(this.cause, {this.actions: const [HAErrorAction.tryAgain()]});

  HACException.unableToConnect({this.actions = const [HAErrorAction.tryAgain()]}) {
    this.cause = "Unable to connect to Home Assistant";
  }

  HACException.disconnected({this.actions = const [HAErrorAction.reconnect()]}) {
    this.cause = "Disconnected";
  }

  HACException.checkConnectionSettings({this.actions = const [HAErrorAction.reload(), HAErrorAction(title: "Settings", type: HAErrorActionType.OPEN_CONNECTION_SETTINGS)]}) {
    this.cause = "Check connection settings";
  }

  @override
  String toString() {
    return 'HACException: $cause';
  }
}

class HACNotSetUpException implements Exception {
  @override
  String toString() {
    return 'HA Client is not set up';
  }
}

class HAErrorAction {
  final String title;
  final int type;
  final String url;

  const HAErrorAction({@required this.title, this.type: HAErrorActionType.FULL_RELOAD, this.url});

  const HAErrorAction.tryAgain({this.title = "Try again", this.type = HAErrorActionType.FULL_RELOAD, this.url});

  const HAErrorAction.reconnect({this.title = "Reconnect", this.type = HAErrorActionType.FULL_RELOAD, this.url});

  const HAErrorAction.reload({this.title = "Reload", this.type = HAErrorActionType.FULL_RELOAD, this.url});

  const HAErrorAction.loginAgain({this.title = "Login again", this.type = HAErrorActionType.RELOGIN, this.url});

}

class HAErrorActionType {
  static const FULL_RELOAD = 0;
  static const QUICK_RELOAD = 1;
  static const URL = 3;
  static const OPEN_CONNECTION_SETTINGS = 4;
  static const RELOGIN = 5;
}