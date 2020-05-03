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
        if (_locationInterval % 5 != 0) {
          _locationInterval = 5 * (_locationInterval ~/ 5);
        }
      });
    });
  }

  void _incLocationInterval() {
    if (_locationInterval < 720) {
      setState(() {
        _locationInterval = _locationInterval + 5;
      });
    }
  }

  void _decLocationInterval() {
    if (_locationInterval > 5) {
      setState(() {
        _locationInterval = _locationInterval - 5;
      });
    }
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
                    onPressed: () => _decLocationInterval(),
                  ),
                  Text("$_locationInterval", style: Theme.of(context).textTheme.title),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: Text("+", style: Theme.of(context).textTheme.title),
                    onPressed: () => _incLocationInterval(),
                  ),
                ],
              )
            ]
        );
  }

  @override
  void dispose() {
    LocationManager().setSettings(_locationTrackingEnabled, _locationInterval);
    super.dispose();
  }
}
