part of '../main.dart';

class StateChangedEvent {
  String entityId;
  String newState;
  bool needToRebuildUI;

  StateChangedEvent({
    this.entityId,
    this.newState,
    this.needToRebuildUI: false
  });
}

class LovelaceChangedEvent {}

class SettingsChangedEvent {
  bool reconnect;

  SettingsChangedEvent(this.reconnect);
}

class RefreshDataFinishedEvent {
  RefreshDataFinishedEvent();
}

class ReloadUIEvent {
  //TODO uiOnly bool

  ReloadUIEvent();
}

class FullReloadEvent {
  FullReloadEvent();
}

class ChangeThemeEvent {

  final AppTheme theme;

  ChangeThemeEvent(this.theme);
}

class StartAuthEvent {
  String oauthUrl;
  bool showButton;

  StartAuthEvent(this.oauthUrl, this.showButton);
}

class NotifyServiceCallEvent {
  String domain;
  String service;
  var entityId;

  NotifyServiceCallEvent(this.domain, this.service, this.entityId);
}

class ShowPopupEvent {
  final Popup popup;
  final bool goBackFirst;

  ShowPopupEvent({this.popup, this.goBackFirst: false});
}

class ShowEntityPageEvent {
  final String entityId;

  ShowEntityPageEvent({@required this.entityId});
}

class ShowPageEvent {
  final String path;
  final bool goBackFirst;

  ShowPageEvent({@required this.path, this.goBackFirst: false});
}

class ShowErrorEvent {
  final HACException error;

  ShowErrorEvent(this.error);
}