part of '../../../main.dart';

class CameraStreamView extends StatefulWidget {

  CameraStreamView({Key key}) : super(key: key);

  @override
  _CameraStreamViewState createState() => _CameraStreamViewState();
}

class _CameraStreamViewState extends State<CameraStreamView> {

  CameraEntity _entity;
  String streamUrl = "";
  WebViewController webViewController;
  VideoPlayerController videoPlayerController;
  Timer monitorTimer;
  bool started = false;
  double aspectRatio = 1.33;
  String htmlView;
  String messageChannelName = 'unknown';

  @override
  void initState() {
    super.initState();
  }

  void loadResources() {
    Logger.d("[Camera Player] Loading resources");
    if (_entity.supportStream) {
      HomeAssistant().getCameraStream(_entity.entityId)
        .then((data) {
          Logger.d("[Camera Player] Stream url: ${ConnectionManager().httpWebHost}${data["url"]}");
          if (videoPlayerController != null) {
            videoPlayerController.dispose().then((_) => createPlayer(data));
          } else {
            createPlayer(data);
          }
        })
        .catchError((e) => Logger.e("[Camera Player] $e"));
    } else {
      streamUrl = '${ConnectionManager().httpWebHost}/api/camera_proxy_stream/${_entity
          .entityId}?token=${_entity.attributes['access_token']}';
      messageChannelName = 'HA_${_entity.entityId.replaceAll('.', '_')}';
      rootBundle.loadString('assets/html/cameraView.html').then((file) {
        htmlView = Uri.dataFromString(
            file.replaceFirst('{{stream_url}}', streamUrl).replaceFirst('{{message_channel}}', messageChannelName),
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8')
        ).toString();
        setState((){
          started = true;
        });
      });
    }
  }

  void createPlayer(data) {
    videoPlayerController = VideoPlayerController.network("${ConnectionManager().httpWebHost}${data["url"]}");
    videoPlayerController.initialize().then((_) {
      setState((){
        started = true;
        aspectRatio = videoPlayerController.value.aspectRatio;
      });
      autoPlay();
      startMonitor();
    }).catchError((e) {
      Logger.e("[Camera Player] Error player init. Retrying");
      loadResources();
    });
  }

  void autoPlay() {
    if (!videoPlayerController.value.isPlaying) {
      videoPlayerController.play();
    }
  }

  void startMonitor() {
    monitorTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (videoPlayerController.value.hasError) {
        setState(() {
          timer.cancel();
          started = false;
        });
      }
    });
  }

  Widget buildLoading() {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Center(
          child: CircularProgressIndicator()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!started) {
      _entity = EntityModel
          .of(context)
          .entityWrapper
          .entity;
      loadResources();
      return buildLoading();
    } else if (_entity.supportStream) {
      if (videoPlayerController.value.initialized) {
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: VideoPlayer(videoPlayerController),
        );
      } else {
        return buildLoading();
      }
    } else {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: WebView(
          initialUrl: htmlView,
          initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          debuggingEnabled: Logger.isInDebugMode,
          gestureNavigationEnabled: false,
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: {
            JavascriptChannel(
              name: messageChannelName,
              onMessageReceived: ((message) {
                setState((){
                  aspectRatio = double.tryParse(message.message) ?? 1.33;
                });
              })
            )
          },
          onWebViewCreated: (WebViewController controller) {
            webViewController = controller;
          },
          onPageStarted: (url) {
            /*rootBundle.loadString('assets/js/cameraImgViewHelper.js').then((js){
              webViewController.evaluateJavascript(js.replaceFirst('entity_id_placeholder', _entity.entityId.replaceAll('.', '_')));
            });*/
          },
        ),
      );
    }     
  }

  @override
  void dispose() {
    monitorTimer?.cancel();
    videoPlayerController?.dispose();
    super.dispose();
  }
}