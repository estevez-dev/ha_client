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

class SettingsChangedEvent {
  bool reconnect;

  SettingsChangedEvent(this.reconnect);
}

class RefreshDataFinishedEvent {
  RefreshDataFinishedEvent();
}

class ReloadUIEvent {
  ReloadUIEvent();
}

class StartAuthEvent {
  String oauthUrl;
  bool showButton;

  StartAuthEvent(this.oauthUrl, this.showButton);
}

class ServiceCallEvent {
  String domain;
  String service;
  String entityId;
  Map<String, dynamic> additionalParams;

  ServiceCallEvent(this.domain, this.service, this.entityId, this.additionalParams);
}

class ShowPopupDialogEvent {
  final String title;
  final String body;
  final String positiveText;
  final String negativeText;
  final  onPositive;
  final  onNegative;

  ShowPopupDialogEvent({this.title, this.body, this.positiveText: "Ok", this.negativeText: "Cancel", this.onPositive, this.onNegative});
}

class ShowPopupMessageEvent {
  final String title;
  final String body;
  final String buttonText;
  final  onButtonClick;

  ShowPopupMessageEvent({this.title, this.body, this.buttonText: "Ok", this.onButtonClick});
}

class ShowEntityPageEvent {
  final Entity entity;

  ShowEntityPageEvent({this.entity});
}

class ShowPageEvent {
  final String path;
  final bool goBackFirst;

  ShowPageEvent({@required this.path, this.goBackFirst: false});
}

class ShowErrorEvent {
  final HAError error;

  ShowErrorEvent(this.error);
}