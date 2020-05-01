part of '../main.dart';

class EntityWrapper {

  String overrideName;
  final String overrideIcon;
  final bool stateColor;
  EntityUIAction uiAction;
  Entity entity;
  String unitOfMeasurementOverride;
  final List stateFilter;

  String get icon => overrideIcon ?? entity.icon;
  String get entityPicture => entity.entityPicture;
  String get displayName => overrideName ?? entity.displayName;
  String get unitOfMeasurement => unitOfMeasurementOverride ?? entity.unitOfMeasurement;

  EntityWrapper({
    this.entity,
    this.overrideIcon,
    this.overrideName,
    this.stateColor: true,
    this.uiAction,
    this.stateFilter
  }) {
    if (entity.statelessType == StatelessEntityType.ghost || entity.statelessType == StatelessEntityType.none || entity.statelessType == StatelessEntityType.callService || entity.statelessType == StatelessEntityType.webLink) {
      if (uiAction == null) {
        uiAction = EntityUIAction();
      }
    }
  }

  void handleTap() {
    switch (uiAction.tapAction) {
      case EntityUIAction.toggle: {
        ConnectionManager().callService(domain: "homeassistant", service: "toggle", entityId: entity.entityId);
        break;
      }

      case EntityUIAction.callService: {
        if (uiAction.tapService != null) {
          ConnectionManager().callService(
            domain: uiAction.tapService.split(".")[0],
            service: uiAction.tapService.split(".")[1],
            data: uiAction.tapServiceData
          );
        }
        break;
      }

      case EntityUIAction.none: {
        break;
      }

      case EntityUIAction.moreInfo: {
        eventBus.fire(
            new ShowEntityPageEvent(entityId: entity.entityId));
        break;
      }

      case EntityUIAction.navigate: {
        if (uiAction.tapService != null && uiAction.tapService.startsWith("/")) {
          //TODO handle local urls
          Launcher.launchURLInBrowser('${ConnectionManager().httpWebHost}${uiAction.tapService}');
        } else {
          Launcher.launchURLInBrowser(uiAction.tapService);
        }
        break;
      }

      default: {
        break;
      }
    }
  }

  void handleHold() {
      switch (uiAction.holdAction) {
        case EntityUIAction.toggle: {
          ConnectionManager().callService(domain: "homeassistant", service: "toggle", entityId: entity.entityId);
          break;
        }

        case EntityUIAction.callService: {
          if (uiAction.holdService != null) {
            ConnectionManager().callService(
              domain: uiAction.holdService.split(".")[0],
              service: uiAction.holdService.split(".")[1],
              data: uiAction.holdServiceData
            );
          }
          break;
        }

        case EntityUIAction.moreInfo: {
          eventBus.fire(
              new ShowEntityPageEvent(entityId: entity.entityId));
          break;
        }

        case EntityUIAction.navigate: {
          if (uiAction.holdService != null && uiAction.holdService.startsWith("/")) {
            //TODO handle local urls
            Launcher.launchURLInBrowser('${ConnectionManager().httpWebHost}${uiAction.holdService}');
          } else {
            Launcher.launchURLInBrowser(uiAction.holdService);
          }
          break;
        }

        default: {
          break;
        }
      }
  }

  void handleDoubleTap() {
      switch (uiAction.doubleTapAction) {
        case EntityUIAction.toggle: {
          ConnectionManager().callService(domain: "homeassistant", service: "toggle", entityId: entity.entityId);
          break;
        }

        case EntityUIAction.callService: {
          if (uiAction.doubleTapService != null) {
            ConnectionManager().callService(
              domain: uiAction.doubleTapService.split(".")[0],
              service: uiAction.doubleTapService.split(".")[1],
              data: uiAction.doubleTapServiceData
            );
          }
          break;
        }

        case EntityUIAction.moreInfo: {
          eventBus.fire(
              new ShowEntityPageEvent(entityId: entity.entityId));
          break;
        }

        case EntityUIAction.navigate: {
          if (uiAction.doubleTapService != null && uiAction.doubleTapService.startsWith("/")) {
            //TODO handle local urls
            Launcher.launchURLInBrowser('${ConnectionManager().httpWebHost}${uiAction.doubleTapService}');
          } else {
            Launcher.launchURLInBrowser(uiAction.doubleTapService);
          }
          break;
        }

        default: {
          break;
        }
      }
  }

}