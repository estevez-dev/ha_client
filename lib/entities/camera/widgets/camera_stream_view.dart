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
  double aspectRatio = 1.78;

  @override
  void initState() {
    super.initState();
  }

  void loadStreamUrl() {
    setState((){
      started = true;
    });
    Logger.d("[Camera Player] Loading stream url");
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
  }

  void createPlayer(data) {
    videoPlayerController = VideoPlayerController.network("${ConnectionManager().httpWebHost}${data["url"]}");
    videoPlayerController.initialize().then((_) {
      setState((){
        aspectRatio = videoPlayerController.value.aspectRatio;
      });
      autoPlay();
      startMonitor();
    }).catchError((e) {
      Logger.e("[Camera Player] Error player init. Retrying");
      loadStreamUrl();
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
    _entity = EntityModel
          .of(context)
          .entityWrapper
          .entity;
    if (_entity.supportStream && !started) {
      loadStreamUrl();
      return buildLoading();
    } else if (_entity.supportStream && started) {
      if (videoPlayerController.value.initialized) {
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: VideoPlayer(videoPlayerController),
        );
      } else {
        return buildLoading();
      }
    } else {
      streamUrl = '${ConnectionManager().httpWebHost}/api/camera_proxy_stream/${_entity
          .entityId}?token=${_entity.attributes['access_token']}';
      return AspectRatio(
        aspectRatio: 1.33,
        child: WebView(
          initialUrl: streamUrl,
          initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          debuggingEnabled: Logger.isInDebugMode,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController controller) {
            webViewController = controller;
          },
          onPageStarted: (url) {
            rootBundle.loadString('assets/js/cameraImgViewHelper.js').then((js){
              webViewController.evaluateJavascript(js);
            });
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