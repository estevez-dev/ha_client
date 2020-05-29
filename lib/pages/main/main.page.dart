part of '../../main.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver, TickerProviderStateMixin {

  StreamSubscription _stateSubscription;
  StreamSubscription _lovelaceSubscription;
  StreamSubscription _settingsSubscription;
  StreamSubscription _serviceCallSubscription;
  StreamSubscription _showEntityPageSubscription;
  StreamSubscription _showErrorSubscription;
  StreamSubscription _startAuthSubscription;
  StreamSubscription _showPopupSubscription;
  StreamSubscription _reloadUISubscription;
  StreamSubscription _fullReloadSubscription;
  StreamSubscription _showPageSubscription;
  BottomInfoBarController _bottomInfoBarController;
  bool _popupShown = false;
  int _previousViewCount;
  bool _showLoginButton = false;
  bool _preventAppRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bottomInfoBarController = BottomInfoBarController();

    _settingsSubscription = eventBus.on<SettingsChangedEvent>().listen((event) {
      Logger.d("Settings change event: reconnect=${event.reconnect}");
      if (event.reconnect) {
        _preventAppRefresh = false;
        _fullLoad();
      }
    });

    _fullLoad();
  }

  void _fullLoad() {
    _bottomInfoBarController.showInfoBottomBar(progress: true,);
    Logger.d('[loading] fullLoad');
    _subscribe().then((_) {
      Logger.d('[loading] subscribed');
      ConnectionManager().init(loadSettings: true, forceReconnect: true).then((__){
        Logger.d('[loading] COnnection manager initialized');
        SharedPreferences.getInstance().then((prefs) {
          HomeAssistant().currentDashboardPath = prefs.getString('lovelace_dashboard_url') ?? HomeAssistant.DEFAULT_DASHBOARD;
          _fetchData(useCache: true);
          LocationManager();
          StartupUserMessagesManager().checkMessagesToShow();
          MobileAppIntegrationManager.checkAppRegistration();
        });
      }, onError: (e) {
        if (e is HACNotSetUpException) {
          Navigator.of(context).pushReplacementNamed('/quick-start');
        } else {
          _setErrorState(e);
        }
      });
    });
  }

  void _quickLoad({bool uiOnly: false}) {
    _bottomInfoBarController.showInfoBottomBar(progress: true,);
    ConnectionManager().init(loadSettings: false, forceReconnect: false).then((_){
      _fetchData(useCache: false, uiOnly: uiOnly);
    }, onError: (e) {
      _setErrorState(e);
    });
  }

  _fetchData({useCache: false, uiOnly: false}) async {
    if (useCache && !uiOnly) {
      HomeAssistant().fetchDataFromCache().then((_) {
        setState((){});  
      });
    }
    await HomeAssistant().fetchData(uiOnly).then((_) {
      setState((){
        _bottomInfoBarController.hideBottomBar();
      });
      HomeAssistant().saveCache();
    }).catchError((e) {
      if (e is HACException) {
        _setErrorState(e);
      } else {
        _setErrorState(HACException(e.toString()));
      }
    });
    eventBus.fire(RefreshDataFinishedEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Logger.d("$state");
    if (state == AppLifecycleState.resumed && ConnectionManager().settingsLoaded && !_preventAppRefresh) {
      _quickLoad();
    } else if (state == AppLifecycleState.paused && ConnectionManager().settingsLoaded && !_preventAppRefresh) {
      //HomeAssistant().saveCache();
    }
  }

  Future _subscribe() async {
    if (_stateSubscription == null) {
      _stateSubscription = eventBus.on<StateChangedEvent>().listen((event) {
        if (event.needToRebuildUI) {
          Logger.d("Need to rebuild UI");
          _quickLoad();
        } else {
          setState(() {});
        }
      });
    }
    if (_lovelaceSubscription == null) {
      _lovelaceSubscription = eventBus.on<LovelaceChangedEvent>().listen((event) {
        _quickLoad();
      });
    }
    if (_reloadUISubscription == null) {
      _reloadUISubscription = eventBus.on<ReloadUIEvent>().listen((event){
        _quickLoad(uiOnly: true);
      });
    }
    if (_fullReloadSubscription == null) {
      _fullReloadSubscription = eventBus.on<FullReloadEvent>().listen((event){
        _fullLoad();
      });
    }
    if (_showPopupSubscription == null) {
      _showPopupSubscription = eventBus.on<ShowPopupEvent>().listen((event){
        if (!_popupShown) {
          _popupShown = true;
          if (event.goBackFirst) {
            Navigator.of(context).pop();
          }
          event.popup.show(context).then((_){
            _popupShown = false;
          });
        }
      });
    }
    if (_serviceCallSubscription == null) {
      _serviceCallSubscription =
          eventBus.on<NotifyServiceCallEvent>().listen((event) {
            _notifyServiceCalled(event.domain, event.service, event.entityId);
          });
    }

    if (_showEntityPageSubscription == null) {
      _showEntityPageSubscription =
          eventBus.on<ShowEntityPageEvent>().listen((event) {
            Logger.d('Showing entity page event handled: ${event.entityId}');
            _showEntityPage(event.entityId);
          });
    }

    if (_showPageSubscription == null) {
      _showPageSubscription =
          eventBus.on<ShowPageEvent>().listen((event) {
            _showPage(event.path, event.goBackFirst);
          });
    }

    if (_showErrorSubscription == null) {
      _showErrorSubscription = eventBus.on<ShowErrorEvent>().listen((event){
        _bottomInfoBarController.showErrorBottomBar(event.error);
      });
    }

    if (_startAuthSubscription == null) {
      _startAuthSubscription = eventBus.on<StartAuthEvent>().listen((event){
        setState(() {
          _showLoginButton = event.showButton;
        });
        if (event.showButton) {
          _showOAuth();
        } else {
          _preventAppRefresh = false;
          Navigator.of(context).pop();
        }
      });
    }

    /*_firebaseMessaging.getToken().then((String token) {
      HomeAssistant().fcmToken = token;
      completer.complete();
    });*/
  }

  void _showOAuth() {
    _preventAppRefresh = true;
    Navigator.of(context).pushNamed("/auth", arguments: {"url": AppSettings().oauthUrl});
  }

  _setErrorState(HACException e) {
    if (e == null) {
      _bottomInfoBarController.showErrorBottomBar(
          HACException("Unknown error")
      );
    } else {
      _bottomInfoBarController.showErrorBottomBar(e);
    }
  }

  void _notifyServiceCalled(String domain, String service, entityId) {
    _bottomInfoBarController.showInfoBottomBar(
        message: "Calling $domain.$service",
        duration: Duration(seconds: 4)
    );
  }

  void _showEntityPage(String entityId) {
    Logger.d('Showing entity page: $entityId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntityViewPage(entityId: entityId),
      )
    );
    /*if (_entityToShow!= null && MediaQuery.of(context).size.width < Sizes.tabletMinWidth) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntityViewPage(entityId: entityId),
          )
      );
    }*/
  }

  void _showPage(String path, bool goBackFirst) {
    if (goBackFirst) {
      Navigator.pop(context);
    }
    Navigator.pushNamed(
        context,
        path
    );
  }

  List<Tab> buildUIViewTabs() {
    List<Tab> result = [];

    if (HomeAssistant().ui.views.isNotEmpty) {
      HomeAssistant().ui.views.forEach((HAView view) {
        result.add(view.buildTab());
      });
    }

    return result;
  }

  Drawer _buildAppDrawer() {
    List<Widget> menuItems = [];
    menuItems.add(
        UserAccountsDrawerHeader(
          accountName: Text(HomeAssistant().userName),
          accountEmail: Text(HomeAssistant().locationName ?? ""),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Theme.of(context).backgroundColor,
            child: Text(
              HomeAssistant().userAvatarText,
              style: Theme.of(context).textTheme.display1
            ),
          ),
        )
    );
    if (HomeAssistant().panels.isNotEmpty) {
      HomeAssistant().panels.forEach((Panel panel) {
        if (!panel.isHidden) {
          menuItems.add(
              panel.getMenuItemWidget(context)
          );
        }
      });
    }
    menuItems.addAll([
      Divider(),
      ListTile(
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:cellphone-settings-variant")),
        title: Text("App settings"),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/app-settings');
        },
      )
    ]);
    menuItems.addAll([
      Divider(),
      new ListTile(
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:github-circle")),
        title: Text("Report an issue"),
        onTap: () {
          Navigator.of(context).pop();
          Launcher.launchURLInBrowser("https://github.com/estevez-dev/ha_client/issues/new");
        },
      ),
      Divider(),
      new ListTile(
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:food")),
        title: Text("Support app development"),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/putchase');
        },
      ),
      Divider(),
      new ListTile(
        leading: Icon(Icons.help),
        title: Text("Help"),
        onTap: () {
          Navigator.of(context).pop();
          Launcher.launchURLInCustomTab(
            context: context,
            url: "http://ha-client.app/help"
          );
        },
      ),
      new ListTile(
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:discord")),
        title: Text("Contacts/Discussion"),
        onTap: () {
          Navigator.of(context).pop();
          Launcher.launchURLInBrowser("https://discord.gg/u9vq7QE");
        },
      ),
      new ListTile(
        title: Text("What's new?"),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/whats-new');
        }
      ),
      new AboutListTile(
          aboutBoxChildren: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURLInBrowser("http://ha-client.app/");
              },
              child: Text(
                "ha-client.app",
                style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Container(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.app/terms_and_conditions");
              },
              child: Text(
                "Terms and Conditions",
                style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Container(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.app/privacy_policy");
              },
              child: Text(
                "Privacy Policy",
                style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
          applicationName: appName,
          applicationVersion: appVersion
      )
    ]);
    return new Drawer(
      child: ListView(
        children: menuItems,
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildScaffoldBody(bool empty) {
    List<Entity> activePlayers = [];
    List<Entity> activeLights = [];
    Color mediaMenuIconColor;
    Color lightMenuIconColor;

    int currentViewCount = HomeAssistant().ui?.views?.length ?? 0;
    if (_previousViewCount != currentViewCount) {
      Logger.d("Views count changed ($_previousViewCount->$currentViewCount). Creating new tabs controller.");
      _viewsTabController = TabController(vsync: this, length: currentViewCount);
      _previousViewCount = currentViewCount;
    }

    if (AppSettings().isAuthenticated) {
      _showLoginButton = false;
    }
     
    
    if (!empty && !HomeAssistant().entities.isEmpty) {
      activePlayers = HomeAssistant().entities.getByDomains(includeDomains: ["media_player"], stateFiler: [EntityState.paused, EntityState.playing, EntityState.idle]);
      activeLights = HomeAssistant().entities.getByDomains(includeDomains: ["light"], stateFiler: [EntityState.on]);
    }
    
    if (activePlayers.isNotEmpty) {
      mediaMenuIconColor = Theme.of(context).accentColor;
    } else {
      mediaMenuIconColor = Theme.of(context).primaryIconTheme.color;
    }
    if (activeLights.isNotEmpty) {
      lightMenuIconColor = Theme.of(context).accentColor;
    } else {
      lightMenuIconColor = Theme.of(context).primaryIconTheme.color;
    }
    Widget mainScrollBody;
    if (empty) {
      if (_showLoginButton) {
        mainScrollBody = Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text("Login", style: Theme.of(context).textTheme.button),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => _fullLoad(),
                  ),
                  Container(height: 20,),
                  FlatButton(
                    child: Text("Login with long-lived token", style: Theme.of(context).textTheme.button),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => eventBus.fire(ShowPopupEvent(
                      popup: TokenLoginPopup()
                    ))
                  ),
                  Container(height: 20,),
                  FlatButton(
                    child: Text("Connection settings", style: Theme.of(context).textTheme.button),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => Navigator.of(context).pushNamed('/connection-settings')
                  )
                ]
            )
        );
      } else {
        mainScrollBody = Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("...")
              ]
          ),
        );
      }
    } else {
      mainScrollBody = HomeAssistant().ui.build(context, _viewsTabController);
    }

    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              primary: true,
              title: Text(HomeAssistant().locationName ?? ""),
              actions: <Widget>[
                PopupMenuButton(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:dots-vertical"), color: Theme.of(context).primaryIconTheme.color)
                  ),
                  onSelected: (String val) {
                    if (val == "reload") {
                      _quickLoad();
                    } else if (val == "logout")  {
                      HomeAssistant().logout().then((_) {
                        _quickLoad();
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    List<PopupMenuEntry<String>> result = [
                      PopupMenuItem<String>(
                        child: new Text("Reload"),
                        value: "reload",
                      )
                    ];
                    if (AppSettings().isAuthenticated) {
                      result.addAll([
                          PopupMenuDivider(),
                          PopupMenuItem<String>(
                            child: new Text("Logout"),
                            value: "logout",
                          )]);
                    }
                    return result;
                  },      
                ),
              ],
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              expandedHeight: 130,
              flexibleSpace: FlexibleSpaceBar(
                title: Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      PopupMenuButton<String>(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Icon(
                            MaterialDesignIcons.getIconDataFromIconName("mdi:television"),
                            color: mediaMenuIconColor,
                            size: 20,
                          )
                        ),
                        onSelected: (String val) {
                          if (val == "play_media") {
                            Navigator.pushNamed(context, "/play-media", arguments: {"url": ""});
                          } else if (val != null)  {
                            _showEntityPage(val);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          List<PopupMenuEntry<String>> result = [
                            PopupMenuDivider(),
                            PopupMenuItem<String>(
                              child: new Text("Play media..."),
                              value: "play_media",
                            )
                          ];
                          if (activePlayers.isNotEmpty) {
                            result.insertAll(0,
                              activePlayers.map((entity) => PopupMenuItem<String>(
                                child: Text(
                                    "${entity.displayName}",
                                  style: Theme.of(context).textTheme.body1.copyWith(
                                    color: HAClientTheme().getColorByEntityState(entity.state, context)
                                  )
                                ),
                                value: "${entity.entityId}",
                              )).toList()
                            );
                          } else {
                            result.insert(0, PopupMenuItem<String>(
                              child: new Text("No active players"),
                              value: "_",
                              enabled: false,
                            ));
                          }
                          return result;
                        }
                      ),
                      PopupMenuButton<String>(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Icon(
                            MaterialDesignIcons.getIconDataFromIconName("mdi:lightbulb-outline"),
                            color: lightMenuIconColor,
                            size: 20
                          )
                        ),
                        onSelected: (String val) {
                          if (val == 'turn_off_all') {
                              ConnectionManager().callService(
                                service: 'turn_off',
                                domain: 'light',
                                entityId: 'all'
                              );
                            } else if (val == 'turn_on_all') {
                              ConnectionManager().callService(
                                service: 'turn_on',
                                domain: 'light',
                                entityId: 'all'
                              );
                            }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              child: new Text("Turn on all lights"),
                              value: "turn_on_all",
                            ),
                            PopupMenuItem<String>(
                              child: new Text("Turn off all ligts"),
                              value: "turn_off_all",
                              enabled: activeLights.isNotEmpty,
                            )
                          ],
                      )
                    ],
                  )                ),
                centerTitle: true,
              ),
              bottom: empty ? null : TabBar(
                controller: _viewsTabController,
                tabs: buildUIViewTabs(),
                isScrollable: true,
              ),
            ),

          ];
        },
        body: mainScrollBody,
    );
  }

  TabController _viewsTabController;

  @override
  Widget build(BuildContext context) {
    if (HomeAssistant().isNoViews) {
        return Scaffold(
            key: _scaffoldKey,
            primary: false,
            drawer: _buildAppDrawer(),
            bottomNavigationBar: BottomInfoBar(
              controller: _bottomInfoBarController,
            ),
            body: SafeArea(
              top: false,
              child: _buildScaffoldBody(true)
            )
        );
      } else {
        return Scaffold(
          key: _scaffoldKey,
          drawer: _buildAppDrawer(),
          primary: false,
          bottomNavigationBar: BottomInfoBar(
            controller: _bottomInfoBarController,
          ),
          body: SafeArea(
            top: false,
            child: _buildScaffoldBody(false)
          )
        );
      }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Hive.close();
    //final flutterWebviewPlugin = new FlutterWebviewPlugin();
    //flutterWebviewPlugin.dispose();
    _viewsTabController?.dispose();
    _stateSubscription?.cancel();
    _lovelaceSubscription?.cancel();
    _settingsSubscription?.cancel();
    _serviceCallSubscription?.cancel();
    _showPopupSubscription?.cancel();
    _showEntityPageSubscription?.cancel();
    _showErrorSubscription?.cancel();
    _startAuthSubscription?.cancel();
    _showPageSubscription?.cancel();
    _fullReloadSubscription?.cancel();
    _reloadUISubscription?.cancel();
    super.dispose();
  }
}
