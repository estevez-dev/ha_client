part of 'main.dart';

class HomeAssistant {

  static final HomeAssistant _instance = HomeAssistant._internal();

  factory HomeAssistant() {
    return _instance;
  }

  EntityCollection entities;
  HomeAssistantUI ui;
  Map _instanceConfig = {};
  String _userName;
  bool childMode;
  HSVColor savedColor;
  int savedPlayerPosition;
  String sendToPlayerId;
  String sendFromPlayerId;
  Map services;

  String fcmToken;

  Map _rawLovelaceData;
  var _rawStates;
  var _rawUserInfo;
  var _rawPanels;

  List<Panel> panels = [];

  Duration fetchTimeout = Duration(seconds: 30);

  String get locationName {
    if (ConnectionManager().useLovelace) {
      return ui?.title ?? "";
    } else {
      return _instanceConfig["location_name"] ?? "";
    }
  }
  String get userName => _userName ?? locationName;
  String get userAvatarText => userName.length > 0 ? userName[0] : "";
  bool get isNoEntities => entities == null || entities.isEmpty;
  bool get isNoViews => ui == null || ui.isEmpty;
  bool get isMobileAppEnabled => _instanceConfig["components"] != null && (_instanceConfig["components"] as List).contains("mobile_app");

  HomeAssistant._internal() {
    ConnectionManager().onStateChangeCallback = _handleEntityStateChange;
    DeviceInfoManager().loadDeviceInfo();
  }

  Completer _fetchCompleter;

  Future fetchData() {
    if (_fetchCompleter != null && !_fetchCompleter.isCompleted) {
      Logger.w("Previous data fetch is not completed yet");
      return _fetchCompleter.future;
    }
    if (entities == null) entities = EntityCollection(ConnectionManager().httpWebHost);
    _fetchCompleter = Completer();
    List<Future> futures = [];
    futures.add(_getStates(null));
    if (ConnectionManager().useLovelace) {
      futures.add(_getLovelace(null));
    }
    futures.add(_getConfig(null));
    futures.add(_getUserInfo(null));
    futures.add(_getPanels(null));
    futures.add(_getServices(null));
    Future.wait(futures).then((_) {
      if (isMobileAppEnabled) {
        if (!childMode) _createUI();
        _fetchCompleter.complete();
        MobileAppIntegrationManager.checkAppRegistration();
      } else {
        _fetchCompleter.completeError(HAError("Mobile app component not found", actions: [HAErrorAction.tryAgain(), HAErrorAction(type: HAErrorActionType.URL ,title: "Help",url: "http://ha-client.app/docs#mobile-app-integration")]));
      }
    }).catchError((e) {
      _fetchCompleter.completeError(e);
    });
    return _fetchCompleter.future;
  }

  Future fetchDataFromCache() async {
    if (_fetchCompleter != null && !_fetchCompleter.isCompleted) {
      Logger.w("Previous cached data fetch is not completed yet");
      return _fetchCompleter.future;
    }
    _fetchCompleter = Completer();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('cached') != null && prefs.getBool('cached')) {
      if (entities == null) entities = EntityCollection(ConnectionManager().httpWebHost);
      try {
        _getStates(prefs);
        if (ConnectionManager().useLovelace) {
          _getLovelace(prefs);
        }
        _getConfig(prefs);
        _getUserInfo(prefs);
        _getPanels(prefs);
        _getServices(prefs);
        if (isMobileAppEnabled) {
          if (!childMode) _createUI();
        }
      } catch (e) {
        Logger.d('Didnt get cached data: $e');  
      }
    }
    _fetchCompleter.complete();
  }

  void saveCache() async {
    Logger.d('Saving data to cache...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('cached_states', json.encode(_rawStates));
      await prefs.setString('cached_lovelace', json.encode(_rawLovelaceData));
      await prefs.setString('cached_user', json.encode(_rawUserInfo));
      await prefs.setString('cached_config', json.encode(_instanceConfig));
      await prefs.setString('cached_panels', json.encode(_rawPanels));
      await prefs.setString('cached_services', json.encode(services));
      await prefs.setBool('cached', true);
    } catch (e) {
      await prefs.setBool('cached', false);
      Logger.e('Error saving cache: $e');
    }
    Logger.d('Done saving cache');
  }

  Future logout() async {
    Logger.d("Logging out...");
    await ConnectionManager().logout().then((_) {
      ui?.clear();
      entities?.clear();
      panels?.clear();
    });
  }

  Future _getConfig(SharedPreferences sharedPrefs) async {
    if (sharedPrefs != null) {
      try {
        var data = json.decode(sharedPrefs.getString('cached_config'));
        _parseConfig(data);
      } catch (e) {
        throw HAError("Error getting config: $e");
      }
    } else {
      await ConnectionManager().sendSocketMessage(type: "get_config").then((data) => _parseConfig(data)).catchError((e) {
        throw HAError("Error getting config: $e");
      });
    }
  }

  void _parseConfig(data) {
    _instanceConfig = Map.from(data);
  }

  Future _getStates(SharedPreferences sharedPrefs) async {
    if (sharedPrefs != null) {
      try {
        var data = json.decode(sharedPrefs.getString('cached_states'));
        _parseStates(data);
      } catch (e) {
        throw HAError("Error getting states: $e");
      }
    } else {
      await ConnectionManager().sendSocketMessage(type: "get_states").then(
              (data) => _parseStates(data)
      ).catchError((e) {
        throw HAError("Error getting states: $e");
      });
    }
  }

  void _parseStates(data) {
    _rawStates = data;
    entities.parse(data);
  }

  Future _getLovelace(SharedPreferences sharedPrefs) {
    if (sharedPrefs != null) {
      try {
        var data = json.decode(sharedPrefs.getString('cached_lovelace'));
        _rawLovelaceData = data;
      } catch (e) {
        ConnectionManager().useLovelace = false;
      }
      return Future.value();
    } else {
      Completer completer = Completer();
      ConnectionManager().sendSocketMessage(type: "lovelace/config").then((data) {
        _rawLovelaceData = data;
        completer.complete();
      }).catchError((e) {
        if ("$e" == "config_not_found") {
          ConnectionManager().useLovelace = false;
          completer.complete();
        } else {
          completer.completeError(HAError("Error getting lovelace config: $e"));
        }
      });
      return completer.future;
    }
  }

  Future _getServices(SharedPreferences prefs) async {	
    if (prefs != null) {
      try {
        var data = json.decode(prefs.getString('cached_services'));
        _parseServices(data);
      } catch (e) {
        Logger.w("Can't get services: $e");  
      }
    }
    await ConnectionManager().sendSocketMessage(type: "get_services").then((data) => _parseServices(data)).catchError((e) {	
      Logger.w("Can't get services: $e");	
    });	
  }

  void _parseServices(data) {
    services = data;
  }

  Future _getUserInfo(SharedPreferences sharedPrefs) async {
    _userName = null;
    await ConnectionManager().sendSocketMessage(type: "auth/current_user").then((data) => _parseUserInfo(data)).catchError((e) {
      Logger.w("Can't get user info: $e");
    });
  }

  void _parseUserInfo(data) {
    _rawUserInfo = data;
    _userName = data["name"];
    childMode = _userName.startsWith("[child]");
  }

  Future _getPanels(SharedPreferences sharedPrefs) async {
    panels.clear();
    if (sharedPrefs != null) {
      try {
        var data = json.decode(sharedPrefs.getString('cached_panels'));
        _parsePanels(data);
      } catch (e) {
        throw HAError("Error getting panels list: $e");
      }
    } else {
      await ConnectionManager().sendSocketMessage(type: "get_panels").then((data) => _parsePanels(data)).catchError((e) {
        throw HAError("Error getting panels list: $e");
      });
    }
  }

  void _parsePanels(data) {
    _rawPanels = data;
    data.forEach((k,v) {
        String title = v['title'] == null ? "${k[0].toUpperCase()}${k.substring(1)}" : "${v['title'][0].toUpperCase()}${v['title'].substring(1)}";
        panels.add(Panel(
            id: k,
            type: v["component_name"],
            title: title,
            urlPath: v["url_path"],
            config: v["config"],
            icon: v["icon"]
        )
        );
      });
  }

  Future getCameraStream(String entityId) {
    Completer completer = Completer();

    ConnectionManager().sendSocketMessage(type: "camera/stream", additionalData: {"entity_id": entityId}).then((data) {
      completer.complete(data);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  void _handleEntityStateChange(Map eventData) {
    //TheLogger.debug( "New state for ${eventData['entity_id']}");
    if (_fetchCompleter != null && _fetchCompleter.isCompleted) {
      Map data = Map.from(eventData);
      eventBus.fire(new StateChangedEvent(
          entityId: data["entity_id"],
          needToRebuildUI: entities.updateState(data)
      ));
    }
  }

  void _parseLovelace() {
      Logger.d("--Title: ${_rawLovelaceData["title"]}");
      ui.title = _rawLovelaceData["title"];
      int viewCounter = 0;
      Logger.d("--Views count: ${_rawLovelaceData['views'].length}");
      _rawLovelaceData["views"].forEach((rawView){
        Logger.d("----view id: ${rawView['id']}");
        HAView view = HAView(
            count: viewCounter,
            id: "${rawView['id']}",
            name: rawView['title'],
            iconName: rawView['icon'],
            panel: rawView['panel'] ?? false,
        );

        if (rawView['badges'] != null && rawView['badges'] is List) {
          rawView['badges'].forEach((entity) {
            if (entity is String) {
              if (entities.isExist(entity)) {
                Entity e = entities.get(entity);
                view.badges.add(e);
              }
            } else {
              String eId = '${entity['entity']}';
              if (entities.isExist(eId)) {
                Entity e = entities.get(eId);
                view.badges.add(e);
              }
            }
          });
        }

        view.cards.addAll(_createLovelaceCards(rawView["cards"] ?? []));
        ui.views.add(
            view
        );
        viewCounter += 1;
      });
  }

  List<HACard> _createLovelaceCards(List rawCards) {
    List<HACard> result = [];
    rawCards.forEach((rawCard){
      try {
        //bool isThereCardOptionsInside = rawCard["card"] != null;
        var rawCardInfo =  rawCard["card"] ?? rawCard;
        HACard card = HACard(
            id: "card",
            name: rawCardInfo["title"] ?? rawCardInfo["name"],
            type: rawCardInfo['type'] ?? CardType.ENTITIES,
            columnsCount: rawCardInfo['columns'] ?? 4,
            showName: (rawCardInfo['show_name'] ?? rawCard['show_name']) ?? true,
            showHeaderToggle: (rawCardInfo['show_header_toggle'] ?? rawCard['show_header_toggle']) ?? true, 
            showState: (rawCardInfo['show_state'] ?? rawCard['show_state']) ?? true,
            showEmpty: (rawCardInfo['show_empty'] ?? rawCard['show_empty']) ?? true,
            stateFilter: (rawCard['state_filter'] ?? rawCardInfo['state_filter']) ?? [],
            states: rawCardInfo['states'],
            conditions: rawCard['conditions'] ?? [],
            content: rawCardInfo['content'],
            min: rawCardInfo['min'] ?? 0,
            max: rawCardInfo['max'] ?? 100,
            unit: rawCardInfo['unit'],
            severity: rawCardInfo['severity']
        );
        if (rawCardInfo["cards"] != null) {
          card.childCards = _createLovelaceCards(rawCardInfo["cards"]);
        }
        var rawEntities = rawCard["entities"] ?? rawCardInfo["entities"];
        rawEntities?.forEach((rawEntity) {
          if (rawEntity is String) {
            if (entities.isExist(rawEntity)) {
              card.entities.add(EntityWrapper(entity: entities.get(rawEntity)));
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
            } else if (entities.isExist(rawEntity["entity"])) {
              Entity e = entities.get(rawEntity["entity"]);
              card.entities.add(
                  EntityWrapper(
                      entity: e,
                      displayName: rawEntity["name"],
                      icon: rawEntity["icon"],
                      stateFilter: rawEntity['state_filter'] ?? [],
                      uiAction: EntityUIAction(rawEntityData: rawEntity)
                  )
              );
            } else {
              card.entities.add(EntityWrapper(entity: Entity.missed(rawEntity["entity"])));
            }
          }
        });
        var rawSingleEntity = rawCard["entity"] ?? rawCardInfo["entity"];
        if (rawSingleEntity != null) {
          var en = rawSingleEntity;
          if (en is String) {
            if (entities.isExist(en)) {
              Entity e = entities.get(en);
              card.linkedEntityWrapper = EntityWrapper(
                  entity: e,
                  icon: rawCardInfo["icon"],
                  displayName: rawCardInfo["name"],
                  uiAction: EntityUIAction(rawEntityData: rawCard)
              );
            } else {
              card.linkedEntityWrapper = EntityWrapper(entity: Entity.missed(en));
            }
          } else {
            if (entities.isExist(en["entity"])) {
              Entity e = entities.get(en["entity"]);
              card.linkedEntityWrapper = EntityWrapper(
                  entity: e,
                  icon: en["icon"],
                  displayName: en["name"],
                  stateFilter: en['state_filter'] ?? [],
                  uiAction: EntityUIAction(rawEntityData: rawCard)
              );
            } else {
              card.linkedEntityWrapper = EntityWrapper(entity: Entity.missed(en["entity"]));
            }
          }
        }
        result.add(card);
      } catch (e) {
          Logger.e("There was an error parsing card: ${e.toString()}");
      }
    });
    return result;
  }

  void _createUI() {
    ui = HomeAssistantUI();
    if ((ConnectionManager().useLovelace) && (_rawLovelaceData != null)) {
      Logger.d("Creating Lovelace UI");
      _parseLovelace();
    } else {
      Logger.d("Creating group-based UI");
      int viewCounter = 0;
      if (!entities.hasDefaultView) {
        HAView view = HAView(
            count: viewCounter,
            id: "group.default_view",
            name: "Home",
            childEntities: entities.filterEntitiesForDefaultView()
        );
        ui.views.add(
            view
        );
        viewCounter += 1;
      }
      entities.viewEntities.forEach((viewEntity) {
        HAView view = HAView(
            count: viewCounter,
            id: viewEntity.entityId,
            name: viewEntity.displayName,
            childEntities: viewEntity.childEntities
        );
        view.linkedEntity = viewEntity;
        ui.views.add(
            view
        );
        viewCounter += 1;
      });
    }
  }

  Widget buildViews(BuildContext context, TabController tabController) {
    return ui.build(context, tabController);
  }
}

/*
class SendMessageQueue {
  int _messageTimeout;
  List<HAMessage> _queue = [];

  SendMessageQueue(this._messageTimeout);

  void add(String message) {
    _queue.add(HAMessage(_messageTimeout, message));
  }

  List<String> getActualMessages() {
    _queue.removeWhere((item) => item.isExpired());
    List<String> result = [];
    _queue.forEach((haMessage){
      result.add(haMessage.message);
    });
    this.clear();
    return result;
  }

  void clear() {
    _queue.clear();
  }

}

class HAMessage {
  DateTime _timeStamp;
  int _messageTimeout;
  String message;

  HAMessage(this._messageTimeout, this.message) {
    _timeStamp = DateTime.now();
  }

  bool isExpired() {
    return DateTime.now().difference(_timeStamp).inSeconds > _messageTimeout;
  }
}*/
