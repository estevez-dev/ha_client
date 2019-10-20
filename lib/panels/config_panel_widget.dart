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

  restart() {
    eventBus.fire(ShowPopupDialogEvent(
      title: "Are you sure you want to restart Home Assistant?",
      body: "This will restart your Home Assistant server.",
      positiveText: "Sure. Make it so",
      negativeText: "What?? No!",
      onPositive: () {
        ConnectionManager().callService(domain: "homeassistant", service: "restart", entityId: null);
      },
    ));
  }

  stop() {
    eventBus.fire(ShowPopupDialogEvent(
      title: "Are you sure you want to STOP Home Assistant?",
      body: "This will STOP your Home Assistant server. It means that your web interface as well as HA Client will not work untill you'll find a way to start your server using ssh or something.",
      positiveText: "Sure. Make it so",
      negativeText: "What?? No!",
      onPositive: () {
        ConnectionManager().callService(domain: "homeassistant", service: "stop", entityId: null);
      },
    ));
  }

  updateRegistration() {
    MobileAppIntegrationManager.checkAppRegistration(showOkDialog: true);
  }

  resetRegistration() {
    eventBus.fire(ShowPopupDialogEvent(
      title: "Waaaait",
      body: "If you don't whant to have duplicate integrations and entities in your HA for your current device, first you need to remove MobileApp integration from Integration settings in HA and restart server.",
      positiveText: "Done it already",
      negativeText: "Ok, I will",
      onPositive: () {
        MobileAppIntegrationManager.checkAppRegistration(showOkDialog: true, forceRegister: true);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.only(left: Sizes.leftWidgetPadding, right: Sizes.rightWidgetPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                    title: Text("Mobile app integration",
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: Sizes.largeFontSize))
                ),
                Text("Registration", style: TextStyle(fontSize: Sizes.largeFontSize-2)),
                Container(height: Sizes.rowPadding,),
                Text("${HomeAssistant().userName}'s ${DeviceInfoManager().model}, ${DeviceInfoManager().osName} ${DeviceInfoManager().osVersion}"),
                Container(height: 6.0,),
                Text("Here you can manually check if HA Client integration with your Home Assistant works fine. As mobileApp integration in Home Assistant is still in development, this is not 100% correct check."),
                //Divider(),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    RaisedButton(
                        color: Colors.blue,
                        onPressed: () => updateRegistration(),
                        child: Text("Check registration", style: TextStyle(color: Colors.white))
                    ),
                    Container(width: 10.0,),
                    RaisedButton(
                        color: Colors.redAccent,
                        onPressed: () => resetRegistration(),
                        child: Text("Reset registration", style: TextStyle(color: Colors.white))
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        LinkToWebConfig(name: "Home AssistantConfiguration", url: ConnectionManager().httpWebHost+"/config"),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
