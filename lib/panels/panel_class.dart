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
  final String componentName;
  final String title;
  final String urlPath;
  final Map config;
  String icon;
  bool isHidden = true;
  bool isWebView = false;

  Panel({this.id, this.componentName, this.title, this.urlPath, this.icon, this.config}) {
    if (icon == null || !icon.startsWith("mdi:")) {
      icon = Panel.iconsByComponent[componentName];
    }
    isHidden = (componentName == 'kiosk' || componentName == 'states' || componentName == 'profile' || componentName == 'developer-tools');
    isWebView = (componentName != 'lovelace' && !componentName.startsWith('haclient'));
  }

  void handleOpen(BuildContext context) {
    if (componentName.startsWith('haclient')) {
      Navigator.of(context).pushNamed(urlPath);
    } else if (componentName == 'lovelace') {
      HomeAssistant().lovelaceDashboardUrl = this.urlPath;
      HomeAssistant().autoUi = false;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('lovelace_dashboard_url', this.urlPath);
        eventBus.fire(ReloadUIEvent());
      });
    } else {
      Launcher.launchAuthenticatedWebView(context: context, url: "${ConnectionManager().httpWebHost}/$urlPath", title: "${this.title}");
    }
  }

  Widget getMenuItemWidget(BuildContext context) {
    return ListTile(
        leading: Icon(MaterialDesignIcons.getIconDataFromIconName(this.icon)),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("${this.title}"),
            Container(width: 4.0,),
            isWebView ? Text("webview", style: Theme.of(context).textTheme.overline) : Container(width: 1.0,)
          ],
        ),
        onTap: () {
          Navigator.of(context).pop();
          this.handleOpen(context);
        }
    );
  }

  Widget getWidget() {
    switch (componentName) {
      default: {
        return Text("Unsupported panel component: $componentName");
      }
    }
  }

}