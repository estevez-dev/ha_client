part of '../main.dart';

class Panel {

  static const iconsByComponent = {
    "config": "mdi:settings",
    "history": "mdi:poll-box",
    "map": "mdi:tooltip-account",
    "logbook": "mdi:format-list-bulleted-type",
    "custom": "mdi:home-assistant"
  };

  final String id;
  final String type;
  final String title;
  final String urlPath;
  final Map config;
  String icon;
  bool isHidden = true;
  bool isWebView = false;

  Panel({this.id, this.type, this.title, this.urlPath, this.icon, this.config}) {
    if (icon == null || !icon.startsWith("mdi:")) {
      icon = Panel.iconsByComponent[type];
    }
    isHidden = (type == 'lovelace' || type == 'kiosk' || type == 'states' || type == 'profile' || type == 'developer-tools');
    isWebView = (type != 'config');
  }

  void handleOpen(BuildContext context) {
    if (type == "config") {
      Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PanelPage(title: "$title", panel: this),
          )
      );
    } else {
      Launcher.launchURLInCustomTab(url: "${ConnectionManager().httpWebHost}/$urlPath");
    }
  }

  Widget getWidget() {
    switch (type) {
      case "config": {
        return ConfigPanelWidget();
      }

      default: {
        return Text("Unsupported panel component: $type");
      }
    }
  }

}