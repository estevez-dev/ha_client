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
  bool started = false;
  String streamUrl = "";

  launchStream() {
    Launcher.launchURLInCustomTab(
      context: context,
      url: streamUrl
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!started) {
      _entity = EntityModel
          .of(context)
          .entityWrapper
          .entity;
      started = true;
    }
    streamUrl = '${ConnectionManager().httpWebHost}/api/camera_proxy_stream/${_entity
        .entityId}?token=${_entity.attributes['access_token']}';
    return Column(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.all(20.0),
            child: IconButton(
              icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:monitor-screenshot"), color: Colors.amber),
              iconSize: 50.0,
              onPressed: () => launchStream(),
            )
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}