part of '../../main.dart';

class IntegrationSettingsPage extends StatefulWidget {
  IntegrationSettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _IntegrationSettingsPageState createState() => new _IntegrationSettingsPageState();
}

class _IntegrationSettingsPageState extends State<IntegrationSettingsPage> {

  int _locationInterval = LocationManager().defaultUpdateIntervalMinutes;
  bool _locationTrackingEnabled = false;
  bool _wait = false;
  String _deviceName = '';
  bool _applyNameEnabled = false;
  String _newDeviceName = '';

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
        _deviceName = _newDeviceName = ConnectionManager().mobileAppDeviceName ?? MobileAppIntegrationManager.getDefaultDeviceName();
        _locationTrackingEnabled = prefs.getBool("location-enabled") ?? false;
        _locationInterval = prefs.getInt("location-interval") ?? LocationManager().defaultUpdateIntervalMinutes;
        if (_locationInterval % 5 != 0) {
          _locationInterval = 5 * (_locationInterval ~/ 5);
        }
      });
    });
  }

  void incLocationInterval() {
    if (_locationInterval < 720) {
      setState(() {
        _locationInterval = _locationInterval + 5;
      });
    }
  }

  void decLocationInterval() {
    if (_locationInterval > 5) {
      setState(() {
        _locationInterval = _locationInterval - 5;
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
        ConnectionManager().callService(domain: "homeassistant", service: "restart");
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
        ConnectionManager().callService(domain: "homeassistant", service: "stop");
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

  _switchLocationTrackingState(bool state) async {
    if (state) {
      await LocationManager().updateDeviceLocation();
    }
    await LocationManager().setSettings(_locationTrackingEnabled, _locationInterval);
    setState(() {
      _wait = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
              Text("Location tracking", style: Theme.of(context).textTheme.title),
              Container(height: Sizes.rowPadding,),
              InkWell(
                onTap: () => Launcher.launchURLInCustomTab(context: context, url: "http://ha-client.app/docs#location-tracking"),
                child: Text(
                  "Please read documentation!",
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline
                  )
                ),
              ),
              Container(height: Sizes.rowPadding,),
              Row(
                children: <Widget>[
                  Text("Enable device location tracking"),
                  Switch(
                    value: _locationTrackingEnabled,
                    onChanged: _wait ? null : (value) {
                      setState(() {
                        _locationTrackingEnabled = value;
                        _wait = true;
                      });
                      _switchLocationTrackingState(value);
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
                    child: Text("-", style: Theme.of(context).textTheme.title),
                    onPressed: () => decLocationInterval(),
                  ),
                  Text("$_locationInterval", style: Theme.of(context).textTheme.title),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: Text("+", style: Theme.of(context).textTheme.title),
                    onPressed: () => incLocationInterval(),
                  ),
                ],
              ),
              Divider(),
              Text("Device name", style: Theme.of(context).textTheme.title),
              Container(height: Sizes.rowPadding,),
              TextField(
                /*decoration: InputDecoration(
                    labelText: "Long-lived token"
                ),*/
                controller: TextEditingController.fromValue(TextEditingValue(text: _newDeviceName)),
                onChanged: (value) {
                  setState(() {
                    _newDeviceName = value;
                    _applyNameEnabled = _newDeviceName != _deviceName;
                  });
                }
              ),
              Container(height: 6.0,),
              RaisedButton(
                color: Colors.blue,
                onPressed: () => _applyNameEnabled ? updateRegistration() : null,
                child: Text("Update device name", style: Theme.of(context).textTheme.button)
              ),
            ]
        );
  }

  @override
  void dispose() {
    LocationManager().setSettings(_locationTrackingEnabled, _locationInterval);
    super.dispose();
  }
}
