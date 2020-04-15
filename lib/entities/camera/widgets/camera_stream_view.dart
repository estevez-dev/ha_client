part of '../../../main.dart';

class CameraStreamView extends StatefulWidget {

  final bool withControls;

  CameraStreamView({Key key, this.withControls: true}) : super(key: key);

  @override
  _CameraStreamViewState createState() => _CameraStreamViewState();
}

class _CameraStreamViewState extends State<CameraStreamView> {

  CameraEntity _entity;
  String _streamUrl = "";
  bool _isLoaded = false;
  double _aspectRatio = 1.33;
  String _webViewHtml;
  String _jsMessageChannelName = 'unknown';
  Completer _loading;

  @override
  void initState() {
    super.initState();
  }

  Future _loadResources() {
    if (_loading != null && !_loading.isCompleted) {
      Logger.d("[Camera Player] Resources loading is not finished yet");
      return _loading.future;  
    }
    Logger.d("[Camera Player] Loading resources");
    _loading = Completer();
    _entity = EntityModel
          .of(context)
          .entityWrapper
          .entity;
    if (_entity.supportStream && HomeAssistant().isComponentEnabled('stream')) {
      HomeAssistant().getCameraStream(_entity.entityId)
        .then((data) {
          _jsMessageChannelName = 'HA_${_entity.entityId.replaceAll('.', '_')}';
            rootBundle.loadString('assets/html/cameraLiveView.html').then((file) {
              _webViewHtml = Uri.dataFromString(
                  file.replaceFirst('{{stream_url}}', '${ConnectionManager().httpWebHost}${data["url"]}').replaceFirst('{{message_channel}}', _jsMessageChannelName),
                  mimeType: 'text/html',
                  encoding: Encoding.getByName('utf-8')
              ).toString();
              _loading.complete();
            });
        })
        .catchError((e) {
          if (e == 'start_stream_failed') {
            Logger.e("[Camera Player] Home Assistant failed starting stream. Forcing MJPEG: $e");
            _loadMJPEG().then((_) {
              _loading.complete();
            });
          } else {
            _loading.completeError(e);
            Logger.e("[Camera Player] Error loading stream: $e");
          }
        });
    } else {
      _loadMJPEG().then((_) {
        _loading.complete();
      });
    }
    return _loading.future;
  }

  Future _loadMJPEG() async {
    _streamUrl = '${ConnectionManager().httpWebHost}/api/camera_proxy_stream/${_entity
        .entityId}?token=${_entity.attributes['access_token']}';
    _jsMessageChannelName = 'HA_${_entity.entityId.replaceAll('.', '_')}';
    var file = await rootBundle.loadString('assets/html/cameraView.html');
    _webViewHtml = Uri.dataFromString(
        file.replaceFirst('{{stream_url}}', _streamUrl).replaceFirst('{{message_channel}}', _jsMessageChannelName),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString();
  }

  Widget _buildScreen() {
    Widget screenWidget;
    if (!_isLoaded) {
      screenWidget = Center(
        child: EntityPicture(
          fit: BoxFit.contain,
        )
      );
    } else {
      screenWidget = WebView(
        initialUrl: _webViewHtml,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        debuggingEnabled: Logger.isInDebugMode,
        gestureNavigationEnabled: false,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: {
          JavascriptChannel(
            name: _jsMessageChannelName,
            onMessageReceived: ((message) {
              Logger.d('[Camera Player] Message from page: $message');
              setState((){
                _aspectRatio = double.tryParse(message.message) ?? 1.33;
              });
            })
          )
        }
      );
    }
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: screenWidget
    );
  }

  Widget _buildControls() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            iconSize: 40,
            color: Theme.of(context).accentColor,
            onPressed: _isLoaded ? () {
              setState(() {
                _isLoaded = false;  
              });
            } : null,
          ),
          Expanded(
            child: Container(),
          ),
          IconButton(
            icon: Icon(Icons.fullscreen),
            iconSize: 40,
            color: Theme.of(context).accentColor,
            onPressed: _isLoaded ? () {
              eventBus.fire(ShowEntityPageEvent());
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (conext) => FullScreenPage(
                    child: EntityModel(
                      child: CameraStreamView(
                        withControls: false
                      ),
                      handleTap: false,
                      entityWrapper: EntityWrapper(
                        entity: _entity
                      ),
                    ),
                  ),
                  fullscreenDialog: true
                )
              ).then((_) {
                eventBus.fire(ShowEntityPageEvent(entity: _entity));
              });
            } : null,
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded && (_loading == null || _loading.isCompleted)) {
      _loadResources().then((_) => setState((){ _isLoaded = true; }));
    }
    if (widget.withControls) {
      return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildScreen(),
            _buildControls()
          ],
        ),
      );
    } else {
      return _buildScreen();
    }
    
  }

  @override
  void dispose() {
    super.dispose();
  }
}