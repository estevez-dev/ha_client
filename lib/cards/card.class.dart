part of '../main.dart';

class CardData {

  String type;
  List<EntityWrapper> entities = [];
  List conditions;
  bool showEmpty;
  List stateFilter;
  bool stateColor = true;

  EntityWrapper get entity => entities.isNotEmpty ? entities[0] : null;

  factory CardData.parse(rawData) {
    try {
      if (rawData['type'] == null) {
        rawData['type'] = CardType.ENTITIES;
      } else if (!(rawData['type'] is String)) {
        return CardData(null);
      }
      switch (rawData['type']) {
          case CardType.ENTITIES:
            return EntitiesCardData(rawData);
            break;
          case CardType.ALARM_PANEL:
            return AlarmPanelCardData(rawData);
            break;
          case CardType.BUTTON:
            return ButtonCardData(rawData);
            break;
          case CardType.ENTITY_BUTTON:
            return ButtonCardData(rawData);
            break;
          case CardType.CONDITIONAL:
            return CardData.parse(rawData['card']);
            break;
          case CardType.ENTITY_FILTER:
            Map cardData = Map.from(rawData);
            cardData.remove('type');
            if (rawData.containsKey('card')) {
              cardData.addAll(rawData['card']);
            }
            cardData['type'] ??= CardType.ENTITIES;
            return CardData.parse(cardData);
            break;
          case CardType.GAUGE:
            return GaugeCardData(rawData);
            break;
          case CardType.GLANCE:
            return GlanceCardData(rawData);
            break;
          case CardType.HORIZONTAL_STACK:
            return HorizontalStackCardData(rawData);
            break;
          case CardType.VERTICAL_STACK:
            return VerticalStackCardData(rawData);
            break;
          case CardType.MARKDOWN:
            return MarkdownCardData(rawData);
            break;
          case CardType.MEDIA_CONTROL:
            return MediaControlCardData(rawData);
            break;
          //TODO make all other official Lovelace cards as Entities
          //All other cards should be unsupported and not shown
          default:
            return CardData(null);
        }
    } catch (error, stacktrace) {
      Logger.e('Error parsing card $rawData: $error', stacktrace: stacktrace);
      return ErrorCardData(rawData);
    }
  }

  CardData(rawData) {
    if (rawData != null && rawData is Map) {
      type = rawData['type'];
      conditions = rawData['conditions'] ?? [];
      showEmpty = rawData['show_empty'] ?? true;
      stateFilter = rawData['state_filter'] ?? [];
    } else {
      type = CardType.UNKNOWN;
      conditions = [];
      showEmpty = true;
      stateFilter = [];
    }
  }

  Widget buildCardWidget() {
    return UnsupportedCard(card: this);
  }

  List<EntityWrapper> getEntitiesToShow() {
    return entities.where((entityWrapper) {
      if (entityWrapper.entity.isHidden) {
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
          } catch (e, stacktrace) {
            Logger.e('Error filtering ${entityWrapper.entity.entityId} by $allowedState: $e', stacktrace: stacktrace);
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

  @override
  Widget buildCardWidget() {
    return EntitiesCard(card: this);
  }
  
  EntitiesCardData(rawData) : super(rawData) {
    //Parsing card data
    title = rawData["title"];
    icon = rawData['icon'];
    stateColor = rawData['state_color'] ?? false;
    showHeaderToggle = rawData['show_header_toggle'] ?? false;
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
              stateColor: rawEntity["state_color"] ?? stateColor,
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
              stateColor: rawEntity["state_color"] ?? stateColor,
              uiAction: EntityUIAction(rawEntityData: uiActionData)
          )
          );
        } else if (HomeAssistant().entities.isExist(rawEntity["entity"])) {
          Entity e = HomeAssistant().entities.get(rawEntity["entity"]);
          entities.add(
            EntityWrapper(
                entity: e,
                stateColor: rawEntity["state_color"] ?? stateColor,
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
  List<dynamic> states;
  
  @override
  Widget buildCardWidget() {
    return AlarmPanelCard(card: this);
  }
  
  AlarmPanelCardData(rawData) : super(rawData) {
    //Parsing card data
    name = rawData['name'];
    states = rawData['states'];
    //Parsing entity
    var entitiId = rawData["entity"];
    if (entitiId != null && entitiId is String) {
      if (HomeAssistant().entities.isExist(entitiId)) {
        entities.add(EntityWrapper(
            entity: HomeAssistant().entities.get(entitiId),
            stateColor: true,
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
  double iconHeightPx = 0;
  double iconHeightRem = 0;
  
  @override
  Widget buildCardWidget() {
    return EntityButtonCard(card: this);
  }
  
  ButtonCardData(rawData) : super(rawData) {
    //Parsing card data
    name = rawData['name'];
    icon = rawData['icon'];
    showName = rawData['show_name'] ?? true;
    showIcon = rawData['show_icon'] ?? true;
    stateColor = rawData['state_color'] ?? true;
    var rawHeight = rawData['icon_height'];
    if (rawHeight != null && rawHeight is String) {
      if (rawHeight.contains('px')) {
        iconHeightPx = double.tryParse(rawHeight.replaceFirst('px', '')) ?? 0;
      } else if (rawHeight.contains('rem')) {
        iconHeightRem = double.tryParse(rawHeight.replaceFirst('rem', '')) ?? 0; 
      } else if (rawHeight.contains('em')) {
        iconHeightRem = double.tryParse(rawHeight.replaceFirst('em', '')) ?? 0;
      }
    }
    //Parsing entity
    var entitiId = rawData["entity"];
    if (entitiId != null && entitiId is String) {
      if (HomeAssistant().entities.isExist(entitiId)) {
        entities.add(EntityWrapper(
            entity: HomeAssistant().entities.get(entitiId),
            overrideName: name,
            overrideIcon: icon,
            stateColor: stateColor,
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
          stateColor: stateColor,
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
  double min;
  double max;
  Map severity;

  @override
  Widget buildCardWidget() {
    return GaugeCard(card: this);
  }
  
  GaugeCardData(rawData) : super(rawData) {
    //Parsing card data
    name = rawData['name'];
    unit = rawData['unit'];
    if (rawData['min'] is int) {
      min = rawData['min'].toDouble();  
    } else if (rawData['min'] is double) {
      min = rawData['min'];
    } else {
      min = 0;
    }
    if (rawData['max'] is int) {
      max = rawData['max'].toDouble();  
    } else if (rawData['max'] is double) {
      max = rawData['max'];
    } else {
      max = 100;
    }
    severity = rawData['severity'];
    //Parsing entity
    var entitiId = rawData["entity"] is List ? rawData["entity"][0] : rawData["entity"];
    if (entitiId != null && entitiId is String) {
      if (HomeAssistant().entities.isExist(entitiId)) {
        entities.add(EntityWrapper(
            entity: HomeAssistant().entities.get(entitiId),
            overrideName: name
        ));
      } else {
        entities.add(EntityWrapper(entity: Entity.missed(entitiId)));
      }
    } else {
      entities.add(EntityWrapper(entity: Entity.missed('$entitiId')));
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

  @override
  Widget buildCardWidget() {
    return GlanceCard(card: this);
  }
  
  GlanceCardData(rawData) : super(rawData) {
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
                stateColor: stateColor,
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

  @override
  Widget buildCardWidget() {
    return HorizontalStackCard(card: this);
  }
  
  HorizontalStackCardData(rawData) : super(rawData) {
    if (rawData.containsKey('cards')) {
      childCards = rawData['cards'].map<CardData>((childCard) {
        return CardData.parse(childCard);
      }).toList();
    } else {
      childCards = [];
    }
  }

}

class VerticalStackCardData extends CardData {

  List<CardData> childCards;

  @override
  Widget buildCardWidget() {
    return VerticalStackCard(card: this);
  }
  
  VerticalStackCardData(rawData) : super(rawData) {
    if (rawData.containsKey('cards')) {
      childCards = rawData['cards'].map<CardData>((childCard) {
        return CardData.parse(childCard);
      }).toList();
    } else {
      childCards = [];
    }
  }

}

class MarkdownCardData extends CardData {

  String title;
  String content;

  @override
  Widget buildCardWidget() {
    return MarkdownCard(card: this);
  }
  
  MarkdownCardData(rawData) : super(rawData) {
    //Parsing card data
    title = rawData['title'];
    content = rawData['content'];
  }

}

class MediaControlCardData extends CardData {

  @override
  Widget buildCardWidget() {
    return MediaControlsCard(card: this);
  }

  MediaControlCardData(rawData) : super(rawData) {
    var entitiId = rawData["entity"];
    if (entitiId != null && entitiId is String) {
      if (HomeAssistant().entities.isExist(entitiId)) {
        entities.add(EntityWrapper(
            entity: HomeAssistant().entities.get(entitiId),
        ));
      } else {
        entities.add(EntityWrapper(entity: Entity.missed(entitiId)));
      }
    }
  }

}

class ErrorCardData extends CardData {

  String cardConfig;

  @override
  Widget buildCardWidget() {
    return ErrorCard(card: this);
  }

  ErrorCardData(rawData) : super(rawData) {
    cardConfig = '$rawData';
  }

}
