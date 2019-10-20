part of '../main.dart';

class ConfigPanelWidget extends StatefulWidget {
  ConfigPanelWidget({Key key}) : super(key: key);

  @override
  _ConfigPanelWidgetState createState() => new _ConfigPanelWidgetState();
}

class _ConfigPanelWidgetState extends State<ConfigPanelWidget> {

  int _locationInterval = LocationManager().defaultUpdateIntervalMinutes;
  bool _locationTrackingEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _locationTrackingEnabled = prefs.getBool("location-enabled") ?? false;
        _locationInterval = prefs.getInt("location-interval") ?? LocationManager().defaultUpdateIntervalMinutes;
      });
    });
  }

  void incLocationInterval() {
    if (_locationInterval < 720) {
      setState(() {
        _locationInterval = _locationInterval + 1;
      });
    }
  }

  void decLocationInterval() {
    if (_locationInterval > 1) {
      setState(() {
        _locationInterval = _locationInterval - 1;
      });
    }
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
                Divider(),
                Text("Location tracking", style: TextStyle(fontSize: Sizes.largeFontSize-2)),
                Container(height: Sizes.rowPadding,),
                Row(
                  children: <Widget>[
                    Text("Enable device location tracking"),
                    Switch(
                      value: _locationTrackingEnabled,
                      onChanged: (value) {
                        SharedPreferences.getInstance().then((prefs) => prefs.setBool("location-enabled", value));
                        setState(() {
                          _locationTrackingEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                Container(height: Sizes.rowPadding,),
                Text("Location update interval in minutes:"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //Expanded(child: Container(),),
                    FlatButton(
                      padding: EdgeInsets.all(0.0),
                      child: Text("+", style: TextStyle(fontSize: Sizes.largeFontSize)),
                      onPressed: () => incLocationInterval(),
                    ),
                    Text("$_locationInterval", style: TextStyle(fontSize: Sizes.largeFontSize)),
                    FlatButton(
                      padding: EdgeInsets.all(0.0),
                      child: Text("-", style: TextStyle(fontSize: Sizes.largeFontSize)),
                      onPressed: () => decLocationInterval(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        LinkToWebConfig(name: "Home Assistant configuration", url: ConnectionManager().httpWebHost+"/config"),
      ],
    );
  }

  @override
  void dispose() {
    LocationManager().setSettings(_locationTrackingEnabled, _locationInterval);
    super.dispose();
  }
}
