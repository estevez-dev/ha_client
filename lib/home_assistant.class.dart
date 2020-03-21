part of 'main.dart';

class HomeAssistant {

  static const DEFAULT_DASHBOARD = 'lovelace';

  static final HomeAssistant _instance = HomeAssistant._internal();

  factory HomeAssistant() {
    return _instance;
  }

  EntityCollection entities;
  HomeAssistantUI ui;
  Map _instanceConfig = {};
  String _userName;
  String _lovelaceDashbordUrl;
  HSVColor savedColor;
  int savedPlayerPosition;
  String sendToPlayerId;
  String sendFromPlayerId;
  Map services;
  bool autoUi = false;

  String fcmToken;

  Map _rawLovelaceData;
  var _rawStates;
  var _rawUserInfo;
  var _rawPanels;

  set lovelaceDashboardUrl(String val) => _lovelaceDashbordUrl = val;

  List<Panel> panels = [];

  Duration fetchTimeout = Duration(seconds: 30);

  String get locationName {
    if (!autoUi) {
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
    ConnectionManager().onLovelaceUpdatedCallback = _handleLovelaceUpdate;
    DeviceInfoManager().loadDeviceInfo();
  }

  Completer _fetchCompleter;

  Future fetchData(bool uiOnly) {
    if (_fetchCompleter != null && !_fetchCompleter.isCompleted) {
      Logger.w("Previous data fetch is not completed yet");
      return _fetchCompleter.future;
    }
    _fetchCompleter = Completer();
    List<Future> futures = [];
    if (!uiOnly) {
      if (entities == null) entities = EntityCollection(ConnectionManager().httpWebHost);
      futures.add(_getStates(null));
      futures.add(_getConfig(null));
      futures.add(_getUserInfo(null));
      futures.add(_getPanels(null));
      futures.add(_getServices(null));
    }
    if (!autoUi) {
      futures.add(_getLovelace(null));
    }
    Future.wait(futures).then((_) {
      if (isMobileAppEnabled) {
        _createUI();
        _fetchCompleter.complete();
        if (!uiOnly) MobileAppIntegrationManager.checkAppRegistration();
      } else {
        _fetchCompleter.completeError(HAError("Mobile app component not found", actions: [HAErrorAction.tryAgain(), HAErrorAction(type: HAErrorActionType.URL ,title: "Help",url: "http://ha-client.app/docs#mobile-app-integration")]));
      }
    }).catchError((e) {
      _fetchCompleter.completeError(e);
    });
    return _fetchCompleter.future;
  }

  Future<void> fetchDataFromCache() async {
    Logger.d('Loading cached data');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool cached = prefs.getBool('cached');
    if (cached != null && cached) {
      if (entities == null) entities = EntityCollection(ConnectionManager().httpWebHost);
      try {
        _getStates(prefs);
        if (!autoUi) {
          _getLovelace(prefs);
        }
        _getConfig(prefs);
        _getUserInfo(prefs);
        _getPanels(prefs);
        _getServices(prefs);
        if (isMobileAppEnabled) {
          _createUI();
        }  
      } catch (e) {
        Logger.d('Didnt get cached data: $e');  
      }
    }
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
        autoUi = true;
      }
      return Future.value();
    } else {
      Completer completer = Completer();
      ConnectionManager().sendSocketMessage(
        type: 'lovelace/config',
        additionalData: {
            'url_path': _lovelaceDashbordUrl == HomeAssistant.DEFAULT_DASHBOARD ? null : _lovelaceDashbordUrl
          }
      ).then((data) {
        _rawLovelaceData = data;
        completer.complete();
      }).catchError((e) {
        if ("$e" == "config_not_found") {
          autoUi = true;
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
  }

  Future _getPanels(SharedPreferences sharedPrefs) async {
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
    panels.clear();
    List<Panel> dashboards = [];
    data.forEach((k,v) {
        String title = v['title'] == null ? "${k[0].toUpperCase()}${k.substring(1)}" : "${v['title'][0].toUpperCase()}${v['title'].substring(1)}";
        if (v['component_name'] != null && v['component_name'] == 'lovelace') {
          dashboards.add(
            Panel(
              id: k,
              componentName: v['component_name'],
              title: title,
              urlPath: v['url_path'],
              config: v['config'],
              icon: (v['icon'] == null || v['icon'] == 'hass:view-dashboard') ? 'mdi:view-dashboard' : v['icon']
            )  
          );
        } else {
          panels.add(
            Panel(
              id: k,
              componentName: v['component_name'],
              title: title,
              urlPath: v['url_path'],
              config: v['config'],
              icon: v['icon']
            )
          );
        }
    });
    panels.insertAll(0, dashboards);
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

  void _handleLovelaceUpdate() {
    if (_fetchCompleter != null && _fetchCompleter.isCompleted) {
      eventBus.fire(new LovelaceChangedEvent());
    }
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

  void _createUI() {
    if (!autoUi && (_rawLovelaceData != null)) {
      Logger.d("Creating Lovelace UI");
      ui = HomeAssistantUI(_rawLovelaceData);
    } else {
      Logger.e("No lovelace config!!!!");
    }
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
