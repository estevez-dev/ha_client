part of '../../../main.dart';

class CameraStreamView extends StatefulWidget {

  CameraStreamView({Key key}) : super(key: key);

  @override
  _CameraStreamViewState createState() => _CameraStreamViewState();
}

class _CameraStreamViewState extends State<CameraStreamView> {

  @override
  void initState() {
    super.initState();
  }

  CameraEntity _entity;
  String streamUrl = "";
  WebViewController webViewController;

  launchStream() {
    Launcher.launchURLInCustomTab(
      context: context,
      url: streamUrl
    );
  }

  @override
  Widget build(BuildContext context) {
    _entity = EntityModel
          .of(context)
          .entityWrapper
          .entity;
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

  @override
  void dispose() {
    super.dispose();
  }
}