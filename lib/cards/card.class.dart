part of '../main.dart';

class HACard {
  List<EntityWrapper> entities = [];
  List<HACard> childCards = [];
  EntityWrapper linkedEntityWrapper;
  String name;
  String id;
  String type;
  String icon;
  bool showName;
  bool showState;
  bool showEmpty;
  bool showHeaderToggle;
  int columnsCount;
  List stateFilter;
  List states;
  List conditions;
  String content;
  String unit;
  int min;
  int max;
  int depth;
  Map severity;
  EntityUIAction action;

  HACard({
    this.name,
    this.id,
    this.linkedEntityWrapper,
    this.columnsCount: 4,
    this.showName: true,
    this.showHeaderToggle: true,
    this.showState: true,
    this.stateFilter: const [],
    this.showEmpty: true,
    this.content,
    this.states,
    this.conditions: const [],
    this.unit,
    this.min,
    this.max,
    this.depth: 1,
    this.severity,
    this.icon,
    @required this.type
  }) {
    if (this.columnsCount <= 0) {
      this.columnsCount = 4;
    }
  }

  List<EntityWrapper> getEntitiesToShow() {
    return entities.where((entityWrapper) {
      if (HomeAssistant().autoUi && entityWrapper.entity.isHidden) {
        return false;
      }
      List currentStateFilter;
      if (entityWrapper.stateFilter != null && entityWrapper.stateFilter.isNotEmpty) {
        currentStateFilter = entityWrapper.stateFilter;
      } else {
        currentStateFilter = stateFilter;
      }
      bool showByFilter = currentStateFilter.isEmpty;
      for (var allowedState in currentStateFilter) {
        if (allowedState is String && allowedState == entityWrapper.entity.state) {
          showByFilter = true;
          break;
        } else if (allowedState is Map) {
          try {
            var tmpVal = allowedState['attribute'] != null ? entityWrapper.entity.getAttribute(allowedState['attribute']) : entityWrapper.entity.state;
            var valToCompareWith = allowedState['value'];
            var valToCompare;
            if (valToCompareWith is! String && tmpVal is String) {
              valToCompare = double.tryParse(tmpVal);
            } else {
              valToCompare = tmpVal;
            }
            if (valToCompare != null) {
              bool result;
              switch (allowedState['operator']) {
                case '<=': { result = valToCompare <= valToCompareWith;}
                break;
                
                case '<': { result = valToCompare < valToCompareWith;}
                break;

                case '>=': { result = valToCompare >= valToCompareWith;}
                break;

                case '>': { result = valToCompare > valToCompareWith;}
                break;

                case '!=': { result = valToCompare != valToCompareWith;}
                break;

                case 'regex': {
                  RegExp regExp = RegExp(valToCompareWith.toString());
                  result = regExp.hasMatch(valToCompare.toString());
                }
                break;

                default: {
                    result = valToCompare == valToCompareWith;
                  }
              }
              if (result) {
                showByFilter = true;
                break;
              }  
            }
          } catch (e) {
            Logger.e('Error filtering ${entityWrapper.entity.entityId} by $allowedState');
            Logger.e('$e');
          }
        }
      }
      return showByFilter;
    }).toList();
  }
}

class CardData {

  String type;
  final int depth;
  List<EntityWrapper> entities = [];
  List conditions;
  bool showEmapty;
  List stateFilter;

  factory CardData.parse(Map<String, dynamic> rawData, {depth}) {
    switch (rawData['type']) {
      case CardType.ENTITIES:
        return EntitiesCardData(rawData, depth: depth);
        break;
      case CardType.ALARM_PANEL:
        return AlarmPanelCardData(rawData, depth: depth);
        break;
      case CardType.BUTTON:
        return ButtonCardData(rawData, depth: depth);
        break;
      case CardType.ENTITY_BUTTON:
        return ButtonCardData(rawData, depth: depth);
        break;
      case CardType.CONDITIONAL:
        return CardData.parse(rawData['card'], depth: depth);
        break;
      case CardType.ENTITY_FILTER:
        Map<String, dynamic> cardData = Map.from(rawData);
        cardData.remove('type');
        if (rawData.containsKey('card')) {
          cardData.addAll(rawData['card']);
        }
        cardData['type'] ??= CardType.ENTITIES;
        return CardData.parse(cardData, depth: depth);
        break;
      case CardType.GAUGE:
        return GaugeCardData(rawData, depth: depth);
        break;
      case CardType.GLANCE:
        return GlanceCardData(rawData, depth: depth);
        break;
      case CardType.HORIZONTAL_STACK:
        return HorizontalStackCardData(rawData, depth: depth);
        break;
      case CardType.VERTICAL_STACK:
        return VerticalStackCardData(rawData, depth: depth);
        break;
      default:
        //TODO check for 'entity' and 'entities'
        return EntitiesCardData(rawData, depth: depth);
    }
  }

  CardData(Map<String, dynamic> rawData, {this.depth: 1}) {
    type = rawData['type'] ?? CardType.ENTITIES;
    conditions = rawData['conditions'];
    showEmapty = rawData['show_empty'] ?? true;
    stateFilter = rawData['state_filter'] ?? [];
  }

  List<EntityWrapper> getEntitiesToShow() {
    return entities.where((entityWrapper) {
      if (HomeAssistant().autoUi && entityWrapper.entity.isHidden) {
        return false;
      }
      List currentStateFilter;
      if (entityWrapper.stateFilter != null && entityWrapper.stateFilter.isNotEmpty) {
        currentStateFilter = entityWrapper.stateFilter;
      } else {
        currentStateFilter = stateFilter;
      }
      bool showByFilter = currentStateFilter.isEmpty;
      for (var allowedState in currentStateFilter) {
        if (allowedState is String && allowedState == entityWrapper.entity.state) {
          showByFilter = true;
          break;
        } else if (allowedState is Map) {
          try {
            var tmpVal = allowedState['attribute'] != null ? entityWrapper.entity.getAttribute(allowedState['attribute']) : entityWrapper.entity.state;
            var valToCompareWith = allowedState['value'];
            var valToCompare;
            if (valToCompareWith is! String && tmpVal is String) {
              valToCompare = double.tryParse(tmpVal);
            } else {
              valToCompare = tmpVal;
            }
            if (valToCompare != null) {
              bool result;
              switch (allowedState['operator']) {
                case '<=': { result = valToCompare <= valToCompareWith;}
                break;
                
                case '<': { result = valToCompare < valToCompareWith;}
                break;

                case '>=': { result = valToCompare >= valToCompareWith;}
                break;

                case '>': { result = valToCompare > valToCompareWith;}
                break;

                case '!=': { result = valToCompare != valToCompareWith;}
                break;

                case 'regex': {
                  RegExp regExp = RegExp(valToCompareWith.toString());
                  result = regExp.hasMatch(valToCompare.toString());
                }
                break;

                default: {
                    result = valToCompare == valToCompareWith;
                  }
              }
              if (result) {
                showByFilter = true;
                break;
              }  
            }
          } catch (e) {
            Logger.e('Error filtering ${entityWrapper.entity.entityId} by $allowedState');
            Logger.e('$e');
          }
        }
      }
      return showByFilter;
    }).toList();
  }

}

class EntitiesCardData extends CardData {

  String title;
  String icon;
  bool showHeaderToggle;
  bool stateColor;
  
  EntitiesCardData(Map<String, dynamic> rawData, {int depth: 1}) : super(rawData, depth: depth) {
    //Parsing card data
    title = rawData["title"];
    icon = rawData['icon'];
    showHeaderToggle = rawData['show_header_toggle'] ?? false; 
    stateColor = rawData['state_color'] ?? true;
    //Parsing entities
    var rawEntities = rawData["entities"] ?? [];
    rawEntities.forEach((rawEntity) {
      if (rawEntity is String) {
        if (HomeAssistant().entities.isExist(rawEntity)) {
          entities.add(EntityWrapper(entity: HomeAssistant().entities.get(rawEntity)));
        } else {
          entities.add(EntityWrapper(entity: Entity.missed(rawEntity)));
        }
      } else {
        if (rawEntity["type"] == "divider") {
          entities.add(EntityWrapper(entity: Entity.divider()));
        } else if (rawEntity["type"] == "section") {
          entities.add(EntityWrapper(entity: Entity.section(rawEntity["label"] ?? "")));
        } else if (rawEntity["type"] == "call-service") {
          Map uiActionData = {
            "tap_action": {
              "action": EntityUIAction.callService,
              "service": rawEntity["service"],
              "service_data": rawEntity["service_data"]
            },
            "hold_action": EntityUIAction.none
          };
          entities.add(
            EntityWrapper(
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
          entities.add(EntityWrapper(
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
          entities.add(
            EntityWrapper(
                entity: e,
                overrideName: rawEntity["name"],
                overrideIcon: rawEntity["icon"],
                stateFilter: rawEntity['state_filter'] ?? [],
                uiAction: EntityUIAction(rawEntityData: rawEntity)
            )
          );
        } else {
          entities.add(EntityWrapper(entity: Entity.missed(rawEntity["entity"])));
        }
      }
    });
  }

}

class AlarmPanelCardData extends CardData {

  String name;
  List<String> states;
  
  AlarmPanelCardData(Map<String, dynamic> rawData, {int depth: 1}) : super(rawData, depth: depth) {
    //Parsing card data
    name = rawData['name'];
    states = rawData['states'];
    //Parsing entity
    var entitiId = rawData["entity"];
    if (entitiId != null && entitiId is String) {
      if (HomeAssistant().entities.isExist(entitiId)) {
        entities.add(EntityWrapper(
            entity: HomeAssistant().entities.get(entitiId),
            overrideName: name
        ));
      } else {
        entities.add(EntityWrapper(entity: Entity.missed(entitiId)));
      }
    }
    
  }

}

class ButtonCardData extends CardData {

  String name;
  String icon;
  bool showName;
  bool showIcon;
  
  ButtonCardData(Map<String, dynamic> rawData, {int depth: 1}) : super(rawData, depth: depth) {
    //Parsing card data
    name = rawData['name'];
    icon = rawData['icon'];
    showName = rawData['show_name'];
    showIcon = rawData['show_icon'];
    //Parsing entity
    var entitiId = rawData["entity"];
    if (entitiId != null && entitiId is String) {
      if (HomeAssistant().entities.isExist(entitiId)) {
        entities.add(EntityWrapper(
            entity: HomeAssistant().entities.get(entitiId),
            overrideName: name,
            overrideIcon: icon,
            uiAction: EntityUIAction(
              rawEntityData: rawData
            )
        ));
      } else {
        entities.add(EntityWrapper(entity: Entity.missed(entitiId)));
      }
    } else if (entitiId == null) {
      entities.add(
        EntityWrapper(
          entity: Entity.ghost(
            name,
            icon,
          ),
          uiAction: EntityUIAction(
            rawEntityData: rawData
          )
        )
      );
    }
  }
}

class GaugeCardData extends CardData {

  String name;
  String unit;
  int min;
  int max;
  Map severity;
  
  GaugeCardData(Map<String, dynamic> rawData, {int depth: 1}) : super(rawData, depth: depth) {
    //Parsing card data
    name = rawData['name'];
    unit = rawData['unit'];
    min = rawData['min'] ?? 0;
    max = rawData['max'] ?? 100;
    severity = rawData['severity'];
    //Parsing entity
    var entitiId = rawData["entity"];
    if (entitiId != null && entitiId is String) {
      if (HomeAssistant().entities.isExist(entitiId)) {
        entities.add(EntityWrapper(
            entity: HomeAssistant().entities.get(entitiId),
            overrideName: name
        ));
      } else {
        entities.add(EntityWrapper(entity: Entity.missed(entitiId)));
      }
    }
    
  }

}

class GlanceCardData extends CardData {

  String title;
  bool showName;
  bool showIcon;
  bool showState;
  bool stateColor;
  int columnsCount;
  
  GlanceCardData(Map<String, dynamic> rawData, {int depth: 1}) : super(rawData, depth: depth) {
    //Parsing card data
    title = rawData["title"];
    showName = rawData['show_name'] ?? true;
    showIcon = rawData['show_icon'] ?? true;
    showState = rawData['show_state'] ?? true;
    stateColor = rawData['state_color'] ?? true;
    columnsCount = rawData['columns'] ?? 4;
    //Parsing entities
    var rawEntities = rawData["entities"] ?? [];
    rawEntities.forEach((rawEntity) {
      if (rawEntity is String) {
        if (HomeAssistant().entities.isExist(rawEntity)) {
          entities.add(EntityWrapper(entity: HomeAssistant().entities.get(rawEntity)));
        } else {
          entities.add(EntityWrapper(entity: Entity.missed(rawEntity)));
        }
      } else {
        if (HomeAssistant().entities.isExist(rawEntity["entity"])) {
          Entity e = HomeAssistant().entities.get(rawEntity["entity"]);
          entities.add(
            EntityWrapper(
                entity: e,
                overrideName: rawEntity["name"],
                overrideIcon: rawEntity["icon"],
                stateFilter: rawEntity['state_filter'] ?? [],
                uiAction: EntityUIAction(rawEntityData: rawEntity)
            )
          );
        } else {
          entities.add(EntityWrapper(entity: Entity.missed(rawEntity["entity"])));
        }
      }
    });
  }

}

class HorizontalStackCardData extends CardData {

  List<CardData> childCards;
  
  HorizontalStackCardData(Map<String, dynamic> rawData, {int depth: 1}) : super(rawData, depth: depth) {
    if (rawData.containsKey('cards')) {
      childCards = rawData['cards'].map((childCard) {
        return CardData.parse(childCard, depth: this.depth + 1);
      }).toList();
    } else {
      childCards = [];
    }
  }

}

class VerticalStackCardData extends CardData {

  List<CardData> childCards;
  
  VerticalStackCardData(Map<String, dynamic> rawData, {int depth: 1}) : super(rawData, depth: depth) {
    if (rawData.containsKey('cards')) {
      childCards = rawData['cards'].map((childCard) {
        return CardData.parse(childCard);
      }).toList();
    } else {
      childCards = [];
    }
  }

}