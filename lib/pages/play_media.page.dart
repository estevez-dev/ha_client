part of '../main.dart';

class PlayMediaPage extends StatefulWidget {

  final String mediaUrl;
  final String mediaType;

  PlayMediaPage({Key key, this.mediaUrl, this.mediaType}) : super(key: key);

  @override
  _PlayMediaPageState createState() => new _PlayMediaPageState();
}

class _PlayMediaPageState extends State<PlayMediaPage> {

  bool _loaded = false;
  String _error = "";
  String _validationMessage = "";
  List<Entity> _players;
  String _mediaUrl;
  String _contentType;
  bool _useMediaExtractor = false;
  bool _isMediaExtractorExist = false;
  StreamSubscription _stateSubscription;
  StreamSubscription _refreshDataSubscription;
  List<String> _contentTypes = ["movie", "video", "music", "image", "image/jpg", "playlist"];

  @override
  void initState() {
    super.initState();
    _mediaUrl = widget.mediaUrl;
    if (widget.mediaType.isNotEmpty) {
      if (!_contentTypes.contains(widget.mediaType)) {
        _contentTypes.insert(0, widget.mediaType);
        _contentType = _contentTypes[0];
      } else {
        _contentType = widget.mediaType;
      }
    } else {
      _contentType = _contentTypes[0];
    }
    _stateSubscription = eventBus.on<StateChangedEvent>().listen((event) {
      if (event.entityId.contains("media_player")) {
        Logger.d("State change event handled by play media page: ${event.entityId}");
        setState(() {});
      }
    });
    _refreshDataSubscription = eventBus.on<RefreshDataFinishedEvent>().listen((event) {
      _loadMediaEntities();
    });
    _loadMediaEntities();
  }

  _loadMediaEntities() async {
    if (HomeAssistant().isNoEntities) {
      setState(() {
        _loaded = false;
      });
    } else {
      _isMediaExtractorExist = HomeAssistant().services.containsKey("media_extractor");
      //_useMediaExtractor = _isMediaExtractorExist;
      _players = HomeAssistant().entities.getByDomains(domains: ["media_player"]);
      setState(() {
        if (_players.isNotEmpty) {
          _loaded = true;
        } else {
          _loaded = false;
          _error = "Looks like you don't have any media player";
        }
      });
    }
  }

  void _playMedia(Entity entity) {
    if (_mediaUrl == null || _mediaUrl.isEmpty) {
      setState(() {
        _validationMessage = "Media url must be specified";
      });
    } else {
      String serviceDomain;
      if (_useMediaExtractor) {
        serviceDomain = "media_extractor";
      } else {
        serviceDomain = "media_player";
      }
      Navigator.pop(context);
      ConnectionManager().callService(
          domain: serviceDomain,
          entityId: entity.entityId,
          service: "play_media",
          additionalServiceData: {
            "media_content_id": _mediaUrl,
            "media_content_type": _contentType
          }
      );
      HomeAssistant().sendToPlayerId = entity.entityId;
      if (HomeAssistant().sendFromPlayerId != null) {
        eventBus.fire(ServiceCallEvent(HomeAssistant().sendFromPlayerId.split(".")[0], "turn_off", HomeAssistant().sendFromPlayerId, null));
        HomeAssistant().sendFromPlayerId = null;
      }
      eventBus.fire(ShowEntityPageEvent(entity: entity));
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget body;
    if (!_loaded) {
      body = _error.isEmpty ? PageLoadingIndicator() : PageLoadingError(errorText: _error);
    } else {
      List<Widget> children = [];
      children.add(CardHeader(name: "Media:"));
      children.add(
        TextField(
          maxLines: 5,
          minLines: 1,
          decoration: InputDecoration(
              labelText: "Media url"
          ),
          controller: TextEditingController.fromValue(TextEditingValue(text: _mediaUrl)),
          onChanged: (value) {
            _mediaUrl = value;
          }
        ),
      );
      if (_validationMessage.isNotEmpty) {
        children.add(Text(
          "$_validationMessage",
          style: TextStyle(color: Colors.red)
        ));
      }
      children.addAll(<Widget>[
        Container(height: Sizes.rowPadding,),
        DropdownButton<String>(
          value: _contentType,
          isExpanded: true,
          items: _contentTypes.map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _contentType = value;
            });
          },
        )
      ]
      );
      if (_isMediaExtractorExist) {
        children.addAll(<Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Text("Use media extractor"),
                ),
                Switch(
                  value: _useMediaExtractor,
                  onChanged: (value) => setState((){_useMediaExtractor = value;}),
                ),
              ],
            ),
            Container(
              height: Sizes.rowPadding,
            )
          ]
        );
      } else {
        children.addAll(<Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Text("You can use media extractor here"),
              ),
              GestureDetector(
                onTap: () {
                  Launcher.launchURLInCustomTab(
                    context: context,
                    url: "https://www.home-assistant.io/components/media_extractor/"
                  );
                },
                child: Text(
                  "How?",
                  style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: Sizes.doubleRowPadding,
          )
        ]
        );
      }
      children.add(CardHeader(name: "Play on:"));
      children.addAll(
          _players.map((player) => InkWell(
            child: EntityModel(
                entityWrapper: EntityWrapper(entity: player),
                handleTap: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: Sizes.doubleRowPadding),
                  child: DefaultEntityContainer(state: player._buildStatePart(context)),
                )
            ),
            onTap: () => _playMedia(player),
          ))
      );
      body = ListView(
        padding: EdgeInsets.all(Sizes.leftWidgetPadding),
          scrollDirection: Axis.vertical,
          children: children
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        }),
        title: new Text("Play media"),
      ),
      body: body,
    );
  }

  @override
  void dispose(){
    HomeAssistant().sendFromPlayerId = null;
    _stateSubscription?.cancel();
    _refreshDataSubscription?.cancel();
    super.dispose();
  }
  
}