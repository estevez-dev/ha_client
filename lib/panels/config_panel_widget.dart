part of '../main.dart';

class ConfigPanelWidget extends StatefulWidget {
  ConfigPanelWidget({Key key}) : super(key: key);

  @override
  _ConfigPanelWidgetState createState() => new _ConfigPanelWidgetState();
}

class _ConfigPanelWidgetState extends State<ConfigPanelWidget> {

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        LinkToWebConfig(name: "Home Assistant configuration", url: AppSettings().httpWebHost+"/config"),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
