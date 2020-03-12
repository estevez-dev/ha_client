part of '../main.dart';

class EntityWrapper {

  String displayName;
  String icon;
  String unitOfMeasurement;
  String entityPicture;
  EntityUIAction uiAction;
  Entity entity;
  List stateFilter;


  EntityWrapper({
    this.entity,
    String icon,
    String displayName,
    this.uiAction,
    this.stateFilter
  }) {
    if (entity.statelessType == StatelessEntityType.NONE || entity.statelessType == StatelessEntityType.CALL_SERVICE || entity.statelessType == StatelessEntityType.WEBLINK) {
      this.icon = icon ?? entity.icon;
      if (icon == null) {
        entityPicture = entity.entityPicture;
      }
      this.displayName = displayName ?? entity.displayName;
      if (uiAction == null) {
        uiAction = EntityUIAction();
      }
      unitOfMeasurement = entity.unitOfMeasurement;
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
            new ShowEntityPageEvent(entity: entity));
        break;
      }

      case EntityUIAction.navigate: {
        if (uiAction.tapService != null && uiAction.tapService.startsWith("/")) {
          //TODO handle local urls
          Logger.w("Local urls is not supported yet");
        } else {
          Launcher.launchURL(uiAction.tapService);
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
              new ShowEntityPageEvent(entity: entity));
          break;
        }

        case EntityUIAction.navigate: {
          if (uiAction.holdService != null && uiAction.holdService.startsWith("/")) {
            //TODO handle local urls
            Logger.w("Local urls is not supported yet");
          } else {
            Launcher.launchURL(uiAction.holdService);
          }
          break;
        }

        default: {
          break;
        }
      }
  }

}