part of '../main.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends ReceiveShareState<MainPage> with WidgetsBindingObserver, TickerProviderStateMixin {

  StreamSubscription<List<PurchaseDetails>> _subscription;
  StreamSubscription _stateSubscription;
  StreamSubscription _settingsSubscription;
  StreamSubscription _serviceCallSubscription;
  StreamSubscription _showEntityPageSubscription;
  StreamSubscription _showErrorSubscription;
  StreamSubscription _startAuthSubscription;
  StreamSubscription _showPopupDialogSubscription;
  StreamSubscription _showPopupMessageSubscription;
  StreamSubscription _reloadUISubscription;
  StreamSubscription _showPageSubscription;
  int _previousViewCount;
  bool _showLoginButton = false;
  bool _preventAppRefresh = false;
  String _savedSharedText;
  String _entityToShow;

  @override
  void initState() {
    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });
    super.initState();
    enableShareReceiving();
    WidgetsBinding.instance.addObserver(this);

    _firebaseMessaging.configure(
        onLaunch: (data) {
          Logger.d("Notification [onLaunch]: $data");
          return Future.value();
        },
        onMessage: (data) {
          Logger.d("Notification [onMessage]: $data");
          return _showNotification(title: data["notification"]["title"], text: data["notification"]["body"]);
        },
        onResume: (data) {
          Logger.d("Notification [onResume]: $data");
          return Future.value();
        }
    );

    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('mini_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: null);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _settingsSubscription = eventBus.on<SettingsChangedEvent>().listen((event) {
      Logger.d("Settings change event: reconnect=${event.reconnect}");
      if (event.reconnect) {
        _preventAppRefresh = false;
        _fullLoad();
      }
    });

    _fullLoad();
  }

  @override void receiveShare(Share shared) {
    if (shared.mimeType == ShareType.TYPE_PLAIN_TEXT) {
      _savedSharedText = shared.text;
    }
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      Logger.d('Notification clicked: ' + payload);
    }
  }

  Future _showNotification({String title, String text}) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'ha_notify', 'Home Assistant notifications', 'Notifications from Home Assistant notify service',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        title ?? appName,
        text,
        platformChannelSpecifics
    );
  }

  void _fullLoad() async {
    _showInfoBottomBar(progress: true,);
    _subscribe().then((_) {
      ConnectionManager().init(loadSettings: true, forceReconnect: true).then((__){
        _fetchData();
        StartupUserMessagesManager().checkMessagesToShow();
      }, onError: (e) {
        _setErrorState(e);
      });
    });
  }

  void _quickLoad() {
    _hideBottomBar();
    _showInfoBottomBar(progress: true,);
    ConnectionManager().init(loadSettings: false, forceReconnect: false).then((_){
      _fetchData();
      //StartupUserMessagesManager().checkMessagesToShow();
    }, onError: (e) {
      _setErrorState(e);
    });
  }

  _fetchData() async {
    if (_savedSharedText != null && !HomeAssistant().isNoEntities) {
      Logger.d("Got shared text: $_savedSharedText");
      Navigator.pushNamed(context, "/play-media", arguments: {"url": _savedSharedText});
      _savedSharedText = null;
    }
    await HomeAssistant().fetchData().then((_) {
      _hideBottomBar();
      int currentViewCount = HomeAssistant().ui?.views?.length ?? 0;
      if (_previousViewCount != currentViewCount) {
        Logger.d("Views count changed ($_previousViewCount->$currentViewCount). Creating new tabs controller.");
        _viewsTabController = TabController(vsync: this, length: currentViewCount);
        _previousViewCount = currentViewCount;
      }
    }).catchError((e) {
      if (e is HAError) {
        _setErrorState(e);
      } else {
        _setErrorState(HAError(e.toString()));
      }
    });
    eventBus.fire(RefreshDataFinishedEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Logger.d("$state");
    if (state == AppLifecycleState.resumed && ConnectionManager().settingsLoaded && !_preventAppRefresh) {
      _quickLoad();
    }
  }

  void _handlePurchaseUpdates(purchase) {
    if (purchase is List<PurchaseDetails>) {
      if (purchase[0].status == PurchaseStatus.purchased) {
        eventBus.fire(ShowPopupMessageEvent(
            title: "Thanks a lot!",
            body: "Thank you for supporting HA Client development!",
            buttonText: "Ok"
        ));
      } else {
        Logger.d("Purchase change handler: ${purchase[0].status}");
      }
    } else {
      Logger.e("Something wrong with purchase handling. Got: $purchase");
    }
  }

  Future _subscribe() {
    Completer completer = Completer();
    if (_stateSubscription == null) {
      _stateSubscription = eventBus.on<StateChangedEvent>().listen((event) {
        if (event.needToRebuildUI) {
          Logger.d("New entity. Need to rebuild UI");
          _quickLoad();
        } else {
          setState(() {});
        }
      });
    }
    if (_reloadUISubscription == null) {
      _reloadUISubscription = eventBus.on<ReloadUIEvent>().listen((event){
        _quickLoad();
      });
    }
    if (_showPopupDialogSubscription == null) {
      _showPopupDialogSubscription = eventBus.on<ShowPopupDialogEvent>().listen((event){
        _showPopupDialog(
            title: event.title,
            body: event.body,
            onPositive: event.onPositive,
            onNegative: event.onNegative,
            positiveText: event.positiveText,
            negativeText: event.negativeText
        );
      });
    }
    if (_showPopupMessageSubscription == null) {
      _showPopupMessageSubscription = eventBus.on<ShowPopupMessageEvent>().listen((event){
        _showPopupDialog(
            title: event.title,
            body: event.body,
            onPositive: event.onButtonClick,
            positiveText: event.buttonText,
            negativeText: null
        );
      });
    }
    if (_serviceCallSubscription == null) {
      _serviceCallSubscription =
          eventBus.on<ServiceCallEvent>().listen((event) {
            _callService(event.domain, event.service, event.entityId,
                event.additionalParams);
          });
    }

    if (_showEntityPageSubscription == null) {
      _showEntityPageSubscription =
          eventBus.on<ShowEntityPageEvent>().listen((event) {
            _showEntityPage(event.entity?.entityId);
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
        _showErrorBottomBar(event.error);
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
        }
      });
    }

    _firebaseMessaging.getToken().then((String token) {
      HomeAssistant().fcmToken = token;
      completer.complete();
    });
    return completer.future;
  }

  void _showOAuth() {
    _preventAppRefresh = true;
    Launcher.launchURLInCustomTab(
      url: ConnectionManager().oauthUrl
    );
  }

  _setErrorState(HAError e) {
    if (e == null) {
      _showErrorBottomBar(
          HAError("Unknown error")
      );
    } else {
      _showErrorBottomBar(e);
    }
  }

  void _showPopupDialog({String title, String body, var onPositive, var onNegative, String positiveText, String negativeText}) {
    List<Widget> buttons = [];
    buttons.add(FlatButton(
      child: new Text("$positiveText"),
      onPressed: () {
        Navigator.of(context).pop();
        if (onPositive != null) {
          onPositive();
        }
      },
    ));
    if (negativeText != null) {
      buttons.add(FlatButton(
        child: new Text("$negativeText"),
        onPressed: () {
          Navigator.of(context).pop();
          if (onNegative != null) {
            onNegative();
          }
        },
      ));
    }
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("$title"),
          content: new Text("$body"),
          actions: buttons,
        );
      },
    );
  }

  //TODO remove this shit.... maybe
  void _callService(String domain, String service, String entityId, Map additionalParams) {
    _showInfoBottomBar(
        message: "Calling $domain.$service",
        duration: Duration(seconds: 3)
    );
    ConnectionManager().callService(domain: domain, service: service, entityId: entityId, additionalServiceData: additionalParams).catchError((e) => _setErrorState(e));
  }

  void _showEntityPage(String entityId) {
    setState(() {
      _entityToShow = entityId;
    });
    if (_entityToShow!= null && MediaQuery.of(context).size.width < Sizes.tabletMinWidth) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntityViewPage(entityId: entityId),
          )
      );
    }
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
          accountEmail: Text(ConnectionManager().displayHostname ?? "Not configured"),
          onDetailsPressed: () {
            final flutterWebViewPlugin = new FlutterWebviewPlugin();
            flutterWebViewPlugin.onStateChanged.listen((viewState) async {
              if (viewState.type == WebViewState.startLoad) {
                Logger.d("[WebView] Injecting external auth JS");
                rootBundle.loadString('assets/js/externalAuth.js').then((js){
                  flutterWebViewPlugin.evalJavascript(js.replaceFirst("[token]", ConnectionManager()._token));
                });
              }
            });
            Navigator.of(context).pushNamed(
                "/webview",
                arguments: {
                  "url": "${ConnectionManager().httpWebHost}/profile?external_auth=1",
                  "title": "Profile"
                }
            );
          },
          currentAccountPicture: CircleAvatar(
            child: Text(
              HomeAssistant().userAvatarText,
              style: TextStyle(
                  fontSize: 32.0
              ),
            ),
          ),
        )
    );
    if (HomeAssistant().panels.isNotEmpty) {
      HomeAssistant().panels.forEach((Panel panel) {
        if (!panel.isHidden) {
          menuItems.add(
              new ListTile(
                  leading: Icon(MaterialDesignIcons.getIconDataFromIconName(panel.icon)),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${panel.title}"),
                      Container(width: 4.0,),
                      panel.isWebView ? Text("webview", style: TextStyle(fontSize: 8.0, color: Colors.black45),) : Container(width: 1.0,)
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    panel.handleOpen(context);
                  }
              )
          );
        }
      });
    }
    menuItems.addAll([
      Divider(),
      ListTile(
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:login-variant")),
        title: Text("Connection settings"),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/connection-settings');
        },
      )
    ]);
    menuItems.addAll([
      Divider(),
      new ListTile(
        leading: Icon(Icons.insert_drive_file),
        title: Text("Log"),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/log-view');
        },
      ),
      new ListTile(
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:github-circle")),
        title: Text("Report an issue"),
        onTap: () {
          Navigator.of(context).pop();
          Launcher.launchURL("https://github.com/estevez-dev/ha_client/issues/new");
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
          Launcher.launchURL("http://ha-client.homemade.systems/docs");
        },
      ),
      new ListTile(
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:discord")),
        title: Text("Join Discord channel"),
        onTap: () {
          Navigator.of(context).pop();
          Launcher.launchURL("https://discord.gg/AUzEvwn");
        },
      ),
      new AboutListTile(
          aboutBoxChildren: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURL("http://ha-client.homemade.systems/");
              },
              child: Text(
                "ha-client.homemade.systems",
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline
                ),
              ),
            ),
            Container(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.homemade.systems/terms_and_conditions");
              },
              child: Text(
                "Terms and Conditions",
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline
                ),
              ),
            ),
            Container(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.homemade.systems/privacy_policy");
              },
              child: Text(
                "Privacy Policy",
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline
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

  void _hideBottomBar() {
    //_scaffoldKey?.currentState?.hideCurrentSnackBar();
    setState(() {
      _showBottomBar = false;
    });
  }

  Widget _bottomBarAction;
  bool _showBottomBar = false;
  String _bottomBarText;
  bool _bottomBarProgress;
  Color _bottomBarColor;
  Timer _bottomBarTimer;

  void _showInfoBottomBar({String message, bool progress: false, Duration duration}) {
    _bottomBarTimer?.cancel();
    _bottomBarAction = Container(height: 0.0, width: 0.0,);
    _bottomBarColor = Colors.grey.shade50;
    setState(() {
      _bottomBarText = message;
      _bottomBarProgress = progress;
      _showBottomBar = true;
    });
    if (duration != null) {
      _bottomBarTimer = Timer(duration, () {
        _hideBottomBar();
      });
    }
  }

  void _showErrorBottomBar(HAError error) {
    TextStyle textStyle = TextStyle(
        color: Colors.blue,
        fontSize: Sizes.nameFontSize
    );
    _bottomBarColor = Colors.red.shade100;
    List<Widget> actions = [];
    error.actions.forEach((HAErrorAction action) {
      switch (action.type) {
        case HAErrorActionType.FULL_RELOAD: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              _fullLoad();
            },
          ));
          break;
        }

        case HAErrorActionType.QUICK_RELOAD: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              _quickLoad();
            },
          ));
          break;
        }

        case HAErrorActionType.RELOGIN: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              ConnectionManager().logout().then((_) => _fullLoad());
            },
          ));
          break;
        }

        case HAErrorActionType.URL: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              Launcher.launchURLInCustomTab(context: context, url: "${action.url}");
            },
          ));
          break;
        }

        case HAErrorActionType.OPEN_CONNECTION_SETTINGS: {
          actions.add(FlatButton(
            child: Text("${action.title}", style: textStyle),
            onPressed: () {
              Navigator.pushNamed(context, '/connection-settings');
            },
          ));
          break;
        }
      }
    });
    if (actions.isNotEmpty) {
      _bottomBarAction = Row(
        mainAxisSize: MainAxisSize.min,
        children: actions,
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      _bottomBarAction = Container(height: 0.0, width: 0.0,);
    }
    setState(() {
      _bottomBarProgress = false;
      _bottomBarText = "${error.message}";
      _showBottomBar = true;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildScaffoldBody(bool empty) {
    List<PopupMenuItem<String>> serviceMenuItems = [];
    List<PopupMenuItem<String>> mediaMenuItems = [];

    serviceMenuItems.add(PopupMenuItem<String>(
      child: new Text("Reload"),
      value: "reload",
    ));
    if (ConnectionManager().isAuthenticated) {
      _showLoginButton = false;
      serviceMenuItems.add(
          PopupMenuItem<String>(
            child: new Text("Logout"),
            value: "logout",
          ));
    }
    Widget mediaMenuIcon;
    int playersCount = 0;
    if (!empty && !HomeAssistant().entities.isEmpty) {
      List<Entity> activePlayers = HomeAssistant().entities.getByDomains(domains: ["media_player"], stateFiler: [EntityState.paused, EntityState.playing, EntityState.idle]);
      playersCount = activePlayers.length;
      mediaMenuItems.addAll(
          activePlayers.map((entity) => PopupMenuItem<String>(
            child: Text(
                "${entity.displayName}",
              style: TextStyle(
                color: EntityColor.stateColor(entity.state)
              ),
            ),
            value: "${entity.entityId}",
          )).toList()
      );
    }
    mediaMenuItems.addAll([
      PopupMenuItem<String>(
        child: new Text("Play media..."),
        value: "play_media",
      )
    ]);
    if (playersCount > 0) {
      mediaMenuIcon = Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Icon(MaterialDesignIcons.getIconDataFromIconName(
              "mdi:television"), color: Colors.white,),
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              height: 16,
              width: 16,
              decoration: new BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text("$playersCount", style: TextStyle(fontSize: 12)),
              ),
            ),
          )
        ],
      );
    } else {
      mediaMenuIcon = Icon(MaterialDesignIcons.getIconDataFromIconName(
          "mdi:television"), color: Colors.white,);
    }
    Widget mainScrollBody;
    if (empty) {
      if (_showLoginButton) {
        mainScrollBody = Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text("Login with Home Assistant", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                    color: Colors.blue,
                    onPressed: () => _fullLoad(),
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
      if (_entityToShow != null && MediaQuery.of(context).size.width >= Sizes.tabletMinWidth) {
        Entity entity = HomeAssistant().entities.get(_entityToShow);
        mainScrollBody = Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              child: HomeAssistant().buildViews(context, _viewsTabController),
            ),
            Container(
              width: Sizes.mainPageScreenSeparatorWidth,
              color: Colors.blue,
            ),
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: Sizes.entityPageMaxWidth),
              child: EntityPageLayout(entity: entity, showClose: true,),
            )
          ],
        );
      } else {
        _entityToShow = null;
        mainScrollBody = HomeAssistant().buildViews(context, _viewsTabController);
      }
    }

    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              primary: true,
              title: Text(HomeAssistant().locationName ?? ""),
              actions: <Widget>[
                IconButton(
                    icon: mediaMenuIcon,
                    onPressed: () {
                      showMenu(
                          position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width, 100.0, 50, 0.0),
                          context: context,
                          items: mediaMenuItems
                      ).then((String val) {
                        if (val == "play_media") {
                          Navigator.pushNamed(context, "/play-media", arguments: {"url": ""});
                        } else  {
                          _showEntityPage(val);
                        }
                      });
                    }
                ),
                IconButton(
                    icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:dots-vertical"), color: Colors.white,),
                    onPressed: () {
                      showMenu(
                          position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width, 100, 0.0, 0.0),
                          context: context,
                          items: serviceMenuItems
                      ).then((String val) {
                        if (val == "reload") {
                          _quickLoad();
                        } else if (val == "logout") {
                          HomeAssistant().logout().then((_) {
                            _quickLoad();
                          });
                        }
                      });
                    }
                )
              ],
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              bottom: empty ? null : TabBar(
                controller: _viewsTabController,
                tabs: buildUIViewTabs(),
                isScrollable: true,
              ),
            ),

          ];
        },
        body: mainScrollBody
    );
  }

  TabController _viewsTabController;

  @override
  Widget build(BuildContext context) {
    Widget bottomBar;
    if (_showBottomBar) {
      List<Widget> bottomBarChildren = [];
      if (_bottomBarText != null) {
        bottomBarChildren.add(
            Padding(
              padding: EdgeInsets.fromLTRB(
                  Sizes.leftWidgetPadding, Sizes.rowPadding, 0.0,
                  Sizes.rowPadding),
              child: Text(
                "$_bottomBarText",
                textAlign: TextAlign.left,
                softWrap: true,
              ),
            )

        );
      }
      if (_bottomBarProgress) {
        bottomBarChildren.add(
          CollectionScaleTransition(
            children: <Widget>[
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.on),),
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.unavailable),),
              Icon(Icons.stop, size: 10.0, color: EntityColor.stateColor(EntityState.off),),
            ],
          ),
        );
      }
      if (bottomBarChildren.isNotEmpty) {
        bottomBar = Container(
          color: _bottomBarColor,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: _bottomBarProgress ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: bottomBarChildren,
                ),
              ),
              _bottomBarAction
            ],
          ),
        );
      }
    }
    // This method is rerun every time setState is called.
    if (HomeAssistant().isNoViews) {
      return Scaffold(
          key: _scaffoldKey,
          primary: false,
          drawer: _buildAppDrawer(),
          bottomNavigationBar: bottomBar,
          body: _buildScaffoldBody(true)
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        drawer: _buildAppDrawer(),
        primary: false,
        bottomNavigationBar: bottomBar,
        body: _buildScaffoldBody(false),
      );
    }
  }

  @override
  void dispose() {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _viewsTabController?.dispose();
    _stateSubscription?.cancel();
    _settingsSubscription?.cancel();
    _serviceCallSubscription?.cancel();
    _showPopupDialogSubscription?.cancel();
    _showPopupMessageSubscription?.cancel();
    _showEntityPageSubscription?.cancel();
    _showErrorSubscription?.cancel();
    _startAuthSubscription?.cancel();
    _subscription?.cancel();
    _showPageSubscription?.cancel();
    _reloadUISubscription?.cancel();
    //TODO disconnect
    //widget.homeAssistant?.disconnect();
    super.dispose();
  }
}
