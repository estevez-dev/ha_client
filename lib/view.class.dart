part of 'main.dart';

class HAView {
  List<HACard> cards = [];
  List<Entity> badges = [];
  Entity linkedEntity;
  String name;
  String id;
  String iconName;
  final int count;
  bool isPanel;

  HAView({@required this.count, @required rawData}) {
    id = "${rawData['id']}";
    name = rawData['title'];
    iconName = rawData['icon'];
    isPanel = rawData['panel'] ?? false;

    if (rawData['badges'] != null && rawData['badges'] is List) {
        rawData['badges'].forEach((entity) {
          if (entity is String) {
            if (HomeAssistant().entities.isExist(entity)) {
              Entity e = HomeAssistant().entities.get(entity);
              badges.add(e);
            }
          } else {
            String eId = '${entity['entity']}';
            if (HomeAssistant().entities.isExist(eId)) {
              Entity e = HomeAssistant().entities.get(eId);
              badges.add(e);
            }
          }
        });
      }

      cards.addAll(_createLovelaceCards(rawData["cards"] ?? [], 1));
  }

  List<HACard> _createLovelaceCards(List rawCards, int depth) {
    List<HACard> result = [];
    rawCards.forEach((rawCard){
      try {
        //bool isThereCardOptionsInside = rawCard["card"] != null;
        var rawCardInfo =  rawCard["card"] ?? rawCard;
        HACard card = HACard(
            id: "card",
            name: rawCardInfo["title"] ?? rawCardInfo["name"],
            type: rawCardInfo['type'] ?? CardType.ENTITIES,
            icon: rawCardInfo['icon'],
            columnsCount: rawCardInfo['columns'] ?? 4,
            showName: (rawCardInfo['show_name'] ?? rawCard['show_name']) ?? true,
            showHeaderToggle: (rawCardInfo['show_header_toggle'] ?? rawCard['show_header_toggle']) ?? false, 
            showState: (rawCardInfo['show_state'] ?? rawCard['show_state']) ?? true,
            showEmpty: (rawCardInfo['show_empty'] ?? rawCard['show_empty']) ?? true,
            stateFilter: (rawCard['state_filter'] ?? rawCardInfo['state_filter']) ?? [],
            states: rawCardInfo['states'],
            conditions: rawCard['conditions'] ?? [],
            content: rawCardInfo['content'],
            min: rawCardInfo['min'] ?? 0,
            max: rawCardInfo['max'] ?? 100,
            unit: rawCardInfo['unit'],
            depth: depth,
            severity: rawCardInfo['severity']
        );
        if (rawCardInfo["cards"] != null) {
          card.childCards = _createLovelaceCards(rawCardInfo["cards"], depth + 1);
        }
        var rawEntities = rawCard["entities"] ?? rawCardInfo["entities"];
        var rawSingleEntity = rawCard["entity"] ?? rawCardInfo["entity"];
        if (rawEntities != null) {
          rawEntities.forEach((rawEntity) {
            if (rawEntity is String) {
              if (HomeAssistant().entities.isExist(rawEntity)) {
                card.entities.add(EntityWrapper(entity: HomeAssistant().entities.get(rawEntity)));
              } else {
                card.entities.add(EntityWrapper(entity: Entity.missed(rawEntity)));
              }
            } else {
              if (rawEntity["type"] == "divider") {
                card.entities.add(EntityWrapper(entity: Entity.divider()));
              } else if (rawEntity["type"] == "section") {
                card.entities.add(EntityWrapper(entity: Entity.section(rawEntity["label"] ?? "")));
              } else if (rawEntity["type"] == "call-service") {
                Map uiActionData = {
                  "tap_action": {
                    "action": EntityUIAction.callService,
                    "service": rawEntity["service"],
                    "service_data": rawEntity["service_data"]
                  },
                  "hold_action": EntityUIAction.none
                };
                card.entities.add(EntityWrapper(
                  entity: Entity.callService(
                    icon: rawEntity["icon"],
                    name: rawEntity["name"],
                    service: rawEntity["service"],
                    actionName: rawEntity["action_name"]
                  ),
                  uiAction: EntityUIAction(rawEntityData: uiActionData)
                )
                );
              } else if (rawEntity["type"] == "weblink") {
                Map uiActionData = {
                  "tap_action": {
                    "action": EntityUIAction.navigate,
                    "service": rawEntity["url"]
                  },
                  "hold_action": EntityUIAction.none
                };
                card.entities.add(EntityWrapper(
                    entity: Entity.weblink(
                        icon: rawEntity["icon"],
                        name: rawEntity["name"],
                        url: rawEntity["url"]
                    ),
                    uiAction: EntityUIAction(rawEntityData: uiActionData)
                )
                );
              } else if (HomeAssistant().entities.isExist(rawEntity["entity"])) {
                Entity e = HomeAssistant().entities.get(rawEntity["entity"]);
                card.entities.add(
                    EntityWrapper(
                        entity: e,
                        overrideName: rawEntity["name"],
                        overrideIcon: rawEntity["icon"],
                        stateFilter: rawEntity['state_filter'] ?? [],
                        uiAction: EntityUIAction(rawEntityData: rawEntity)
                    )
                );
              } else {
                card.entities.add(EntityWrapper(entity: Entity.missed(rawEntity["entity"])));
              }
            }
          });
        } else if (rawSingleEntity != null) {
          var en = rawSingleEntity;
          if (en is String) {
            if (HomeAssistant().entities.isExist(en)) {
              Entity e = HomeAssistant().entities.get(en);
              card.linkedEntityWrapper = EntityWrapper(
                  entity: e,
                  overrideIcon: rawCardInfo["icon"],
                  overrideName: rawCardInfo["name"],
                  uiAction: EntityUIAction(rawEntityData: rawCard)
              );
            } else {
              card.linkedEntityWrapper = EntityWrapper(entity: Entity.missed(en));
            }
          } else {
            if (HomeAssistant().entities.isExist(en["entity"])) {
              Entity e = HomeAssistant().entities.get(en["entity"]);
              card.linkedEntityWrapper = EntityWrapper(
                  entity: e,
                  overrideIcon: en["icon"],
                  overrideName: en["name"],
                  stateFilter: en['state_filter'] ?? [],
                  uiAction: EntityUIAction(rawEntityData: rawCard)
              );
            } else {
              card.linkedEntityWrapper = EntityWrapper(entity: Entity.missed(en["entity"]));
            }
          }
        } else {
          card.linkedEntityWrapper = EntityWrapper(
            entity: Entity.ghost(
              card.name,
              card.icon,
            ),
            uiAction: EntityUIAction(
              rawEntityData: rawCardInfo
            )
          );
        }
        result.add(card);
      } catch (e) {
          Logger.e("There was an error parsing card: ${e.toString()}");
      }
    });
    return result;
  }

  Widget buildTab() {
    if (linkedEntity == null) {
      if (iconName != null && iconName.isNotEmpty) {
        return
          Tab(
              icon:
              Icon(
                MaterialDesignIcons.getIconDataFromIconName(
                    iconName ?? "mdi:home-assistant"),
                size: 24.0,
              )
          );
      } else {
        return
          Tab(
              text: "${name?.toUpperCase() ?? "UNNAMED VIEW"}",
          );
      }
    } else {
      if (linkedEntity.icon != null && linkedEntity.icon.length > 0) {
        return Tab(
          icon: Icon(
              MaterialDesignIcons.getIconDataFromIconName(
                  linkedEntity.icon),
              size: 24.0,
            )
        );
      } else {
        return Tab(
            text: "${linkedEntity.displayName?.toUpperCase()}",
        );
      }

    }
  }

  Widget build(BuildContext context) {
    return ViewWidget(
      view: this,
    );
  }
}